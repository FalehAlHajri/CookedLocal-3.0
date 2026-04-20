//
//  ImageCacheManager.swift
//  Cooked Local
//

import Foundation
import UIKit
import SwiftUI
import Combine

/// Centralized image caching manager with memory + disk + ETag support
final class ImageCacheManager {
    static let shared = ImageCacheManager()

    // Memory cache
    private let memoryCache = NSCache<NSString, UIImage>()

    // Disk cache directory
    private let diskCacheURL: URL
    private let metadataURL: URL

    // Cache metadata (ETags and timestamps)
    private var cacheMetadata: [String: CacheMetadata] = [:]
    private let metadataQueue = DispatchQueue(label: "com.cookedlocal.imagecache.metadata")

    private struct CacheMetadata: Codable {
        let etag: String?
        let lastModified: Date
        let contentType: String?
    }

    private init() {
        // Set up disk cache in app's caches directory
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cachesDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        metadataURL = diskCacheURL.appendingPathComponent("metadata.json")

        // Create cache directory
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)

        // Load existing metadata
        loadMetadata()

        // Configure memory cache limits
        memoryCache.countLimit = 100 // Max 100 images in memory
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    // MARK: - Public Methods

    /// Fetch image with ETag support - returns cached version and checks for updates
    func image(for urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw ImageCacheError.invalidURL
        }

        let cacheKey = urlString as NSString

        // 1. Check memory cache first
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            // Check for update in background
            Task { try? await refreshIfNeeded(url: url, urlString: urlString) }
            return cachedImage
        }

        // 2. Check disk cache
        if let diskImage = loadFromDisk(key: urlString) {
            memoryCache.setObject(diskImage, forKey: cacheKey)
            // Check for update in background
            Task { try? await refreshIfNeeded(url: url, urlString: urlString) }
            return diskImage
        }

        // 3. Fetch from network
        return try await fetchAndCache(url: url, urlString: urlString)
    }

    /// Prefetch images for better UX
    func prefetchImages(urls: [String]) {
        Task {
            for urlString in urls {
                guard URL(string: urlString) != nil else { continue }
                let _ = try? await image(for: urlString)
            }
        }
    }

    /// Clear all caches
    func clearCache() {
        memoryCache.removeAllObjects()

        metadataQueue.async { [weak self] in
            guard let self = self else { return }
            try? FileManager.default.removeItem(at: self.diskCacheURL)
            try? FileManager.default.createDirectory(at: self.diskCacheURL, withIntermediateDirectories: true)
            self.cacheMetadata.removeAll()
            self.saveMetadata()
        }
    }

    /// Clean up old cache entries (call periodically)
    func cleanupOldCache(maxAge: TimeInterval = 7 * 24 * 60 * 60) { // 7 days default
        metadataQueue.async { [weak self] in
            guard let self = self else { return }
            let cutoffDate = Date().addingTimeInterval(-maxAge)

            let oldEntries = self.cacheMetadata.filter { $0.value.lastModified < cutoffDate }
            for key in oldEntries.keys {
                self.cacheMetadata.removeValue(forKey: key)
                let fileURL = self.diskCacheURL.appendingPathComponent(self.sanitizedFileName(for: key))
                try? FileManager.default.removeItem(at: fileURL)
            }
            self.saveMetadata()
        }
    }

    // MARK: - Private Methods

    private func refreshIfNeeded(url: URL, urlString: String) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD" // Lightweight check

        if let etag = metadata(for: urlString)?.etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { return }

        // If 304 Not Modified, cache is still valid
        if httpResponse.statusCode == 304 {
            updateTimestamp(for: urlString)
            return
        }

        // If 200, fetch new version
        if httpResponse.statusCode == 200 {
            let _ = try await fetchAndCache(url: url, urlString: urlString)
        }
    }

    private func fetchAndCache(url: URL, urlString: String) async throws -> UIImage {
        var request = URLRequest(url: url)

        // Add ETag header if we have cached version
        if let etag = metadata(for: urlString)?.etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageCacheError.invalidResponse
        }

        // Handle 304 Not Modified
        if httpResponse.statusCode == 304 {
            if let cachedImage = loadFromDisk(key: urlString) ?? memoryCache.object(forKey: urlString as NSString) {
                updateTimestamp(for: urlString)
                return cachedImage
            }
        }

        guard httpResponse.statusCode == 200,
              let image = UIImage(data: data) else {
            throw ImageCacheError.downloadFailed
        }

        // Extract ETag from response
        let etag = httpResponse.allHeaderFields["Etag"] as? String ??
                  httpResponse.allHeaderFields["ETag"] as? String

        // Cache the image
        await cacheImage(image, data: data, for: urlString, etag: etag, contentType: httpResponse.mimeType)

        return image
    }

    private func cacheImage(_ image: UIImage, data: Data, for urlString: String, etag: String?, contentType: String?) async {
        let cacheKey = urlString as NSString

        // Memory cache
        memoryCache.setObject(image, forKey: cacheKey)

        // Disk cache
        let fileURL = diskCacheURL.appendingPathComponent(sanitizedFileName(for: urlString))
        try? data.write(to: fileURL)

        // Update metadata
        metadataQueue.async { [weak self] in
            self?.cacheMetadata[urlString] = CacheMetadata(
                etag: etag,
                lastModified: Date(),
                contentType: contentType
            )
            self?.saveMetadata()
        }
    }

    private func loadFromDisk(key: String) -> UIImage? {
        let fileURL = diskCacheURL.appendingPathComponent(sanitizedFileName(for: key))
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    private func metadata(for urlString: String) -> CacheMetadata? {
        metadataQueue.sync {
            cacheMetadata[urlString]
        }
    }

    private func updateTimestamp(for urlString: String) {
        metadataQueue.async { [weak self] in
            guard var metadata = self?.cacheMetadata[urlString] else { return }
            metadata = CacheMetadata(
                etag: metadata.etag,
                lastModified: Date(),
                contentType: metadata.contentType
            )
            self?.cacheMetadata[urlString] = metadata
            self?.saveMetadata()
        }
    }

    private func loadMetadata() {
        metadataQueue.sync {
            guard let data = try? Data(contentsOf: metadataURL),
                  let metadata = try? JSONDecoder().decode([String: CacheMetadata].self, from: data) else {
                return
            }
            cacheMetadata = metadata
        }
    }

    private func saveMetadata() {
        guard let data = try? JSONEncoder().encode(cacheMetadata) else { return }
        try? data.write(to: metadataURL)
    }

    private func sanitizedFileName(for urlString: String) -> String {
        // Create safe filename from URL
        let sanitized = urlString
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "=", with: "_")
            .replacingOccurrences(of: "&", with: "_")
        return sanitized + ".cache"
    }
}

// MARK: - Errors

enum ImageCacheError: Error {
    case invalidURL
    case invalidResponse
    case downloadFailed
    case decodingFailed
}

// MARK: - SwiftUI View

struct CachedAsyncImage: View {
    let urlString: String?
    let contentMode: ContentMode
    let placeholder: AnyView

    @StateObject private var viewModel = CachedAsyncImageViewModel()

    init(
        urlString: String?,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: () -> some View = { Color.gray }
    ) {
        self.urlString = urlString
        self.contentMode = contentMode
        self.placeholder = AnyView(placeholder())
    }

    var body: some View {
        Group {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if viewModel.isLoading {
                ProgressView()
            } else if viewModel.error != nil {
                placeholder
            } else {
                placeholder
            }
        }
        .onAppear {
            viewModel.loadImage(from: urlString)
        }
        .onChange(of: urlString) { newUrl in
            viewModel.loadImage(from: newUrl)
        }
    }
}

// MARK: - ViewModel

@MainActor
final class CachedAsyncImageViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: Error?

    func loadImage(from urlString: String?) {
        guard let urlString = urlString, !urlString.isEmpty else {
            image = nil
            return
        }

        // Reset state
        image = nil
        error = nil
        isLoading = true

        Task {
            do {
                let loadedImage = try await ImageCacheManager.shared.image(for: urlString)
                self.image = loadedImage
                self.isLoading = false
            } catch {
                self.error = error
                self.isLoading = false
            }
        }
    }
}
