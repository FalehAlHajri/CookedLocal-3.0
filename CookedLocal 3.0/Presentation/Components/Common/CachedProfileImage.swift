//
//  CachedProfileImage.swift
//  Cooked Local
//

import SwiftUI

struct CachedProfileImage: View {
    let urlString: String?
    let size: CGFloat

    @State private var cachedImage: UIImage?

    private static let cache = NSCache<NSString, UIImage>()
    private static let diskCacheKey = "cachedProfileImageData"
    private static let diskCacheURLKey = "cachedProfileImageURL"

    var body: some View {
        Group {
            if let image = cachedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let urlString = urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .aspectRatio(contentMode: .fill)
                            .onAppear { cacheImage(from: url, urlString: urlString) }
                    case .failure:
                        fallbackIcon
                    case .empty:
                        ProgressView().scaleEffect(0.6)
                    @unknown default:
                        fallbackIcon
                    }
                }
            } else {
                fallbackIcon
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .onAppear { loadCached() }
        .onChange(of: urlString) { _ in
            cachedImage = nil
            loadCached()
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .foregroundColor(.neutral600)
    }

    private func loadCached() {
        // Check memory cache first
        if let urlString = urlString, let cached = Self.cache.object(forKey: urlString as NSString) {
            cachedImage = cached
            return
        }
        // Check disk cache
        let savedURL = UserDefaults.standard.string(forKey: Self.diskCacheURLKey)
        if let urlString = urlString, urlString == savedURL,
           let data = UserDefaults.standard.data(forKey: Self.diskCacheKey),
           let image = UIImage(data: data) {
            Self.cache.setObject(image, forKey: urlString as NSString)
            cachedImage = image
        }
    }

    private func cacheImage(from url: URL, urlString: String) {
        Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data) else { return }
            Self.cache.setObject(image, forKey: urlString as NSString)
            UserDefaults.standard.set(data, forKey: Self.diskCacheKey)
            UserDefaults.standard.set(urlString, forKey: Self.diskCacheURLKey)
            await MainActor.run { cachedImage = image }
        }
    }

    /// Call this when user changes profile pic or logs out to clear the disk cache
    static func clearCache() {
        cache.removeAllObjects()
        UserDefaults.standard.removeObject(forKey: diskCacheKey)
        UserDefaults.standard.removeObject(forKey: diskCacheURLKey)
    }
}
