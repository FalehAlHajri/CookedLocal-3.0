//
//  NetworkManager.swift
//  Cooked Local
//

import Foundation

// MARK: - API Error

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(String)
    case serverError(String)
    case unauthorized
    case notFound
    case badRequest(String)
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .noData:
            return "No data received from server."
        case .decodingFailed(let detail):
            return "Failed to parse response: \(detail)"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Session expired. Please sign in again."
        case .notFound:
            return "Resource not found."
        case .badRequest(let message):
            return message
        case .unknown(let code):
            return "Unexpected error (HTTP \(code))."
        }
    }
}

// MARK: - Base API Response Wrappers

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let statusCode: Int?
    let message: String?
    let data: T?
}

struct APIPaginatedResponse<T: Decodable>: Decodable {
    let success: Bool
    let statusCode: Int?
    let message: String?
    let meta: APIMeta?
    let data: [T]?
}

struct APIMeta: Decodable {
    let totalResult: Int?
    let currentPage: FlexibleInt?
    let limit: FlexibleInt?
    let totalPage: Int?

    enum CodingKeys: String, CodingKey {
        case totalResult = "total_result"
        case currentPage = "current_page"
        case limit
        case totalPage = "total_page"
    }
}

/// Handles JSON values that may arrive as either Int or String.
struct FlexibleInt: Decodable {
    let value: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let strVal = try? container.decode(String.self), let parsed = Int(strVal) {
            value = parsed
        } else {
            throw DecodingError.typeMismatch(
                Int.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int or String-encoded Int")
            )
        }
    }
}

struct APIErrorResponse: Decodable {
    let success: Bool
    let message: String?
}

// MARK: - NetworkManager

final class NetworkManager {
    static let shared = NetworkManager()

    private let baseURL = "https://api.cookedlocal.net/api/v1"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Generic Request

    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true,
        customToken: String? = nil
    ) async throws -> T {
        let url = try buildURL(path: path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = customToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if requiresAuth, let token = TokenManager.shared.getToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: urlRequest)
        return try handleResponse(data: data, response: response)
    }

    // MARK: - GET Request with Query Items

    func request<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem],
        requiresAuth: Bool = true
    ) async throws -> T {
        let url = try buildURL(path: path, queryItems: queryItems)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = TokenManager.shared.getToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: urlRequest)
        return try handleResponse(data: data, response: response)
    }

    // MARK: - Paginated Request

    func requestPaginated<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        requiresAuth: Bool = true
    ) async throws -> [T] {
        let url = try buildURL(path: path, queryItems: queryItems)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = TokenManager.shared.getToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: urlRequest)
        return try handlePaginatedResponse(data: data, response: response)
    }

    // MARK: - Multipart Request

    func requestMultipart<T: Decodable>(
        path: String,
        method: String = "POST",
        fields: [String: String],
        fileData: Data?,
        fileFieldName: String = "thumbnail",
        fileName: String = "image.jpg",
        mimeType: String = "image/jpeg",
        requiresAuth: Bool = true
    ) async throws -> T {
        let url = try buildURL(path: path)
        let boundary = "Boundary-\(UUID().uuidString)"
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = TokenManager.shared.getToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.httpBody = buildMultipartBody(
            boundary: boundary,
            fields: fields,
            fileData: fileData,
            fileFieldName: fileFieldName,
            fileName: fileName,
            mimeType: mimeType
        )

        let (data, response) = try await session.data(for: urlRequest)
        return try handleResponse(data: data, response: response)
    }

    // MARK: - Multipart Request with Multiple Files

    struct MultipartFile {
        let fieldName: String
        let data: Data
        let fileName: String
        let mimeType: String
    }

    func requestMultipartMultiFile<T: Decodable>(
        path: String,
        method: String = "POST",
        fields: [String: String],
        files: [MultipartFile] = [],
        requiresAuth: Bool = true
    ) async throws -> T {
        let url = try buildURL(path: path)
        let boundary = "Boundary-\(UUID().uuidString)"
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = TokenManager.shared.getToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.httpBody = buildMultipartBodyMultiFile(boundary: boundary, fields: fields, files: files)

        let (data, response) = try await session.data(for: urlRequest)
        return try handleResponse(data: data, response: response)
    }

    // MARK: - Multipart Void Request (no response body needed)

    func requestMultipartVoid(
        path: String,
        method: String = "POST",
        fields: [String: String],
        fileData: Data?,
        fileFieldName: String = "thumbnail",
        fileName: String = "image.jpg",
        mimeType: String = "image/jpeg",
        requiresAuth: Bool = true
    ) async throws {
        let url = try buildURL(path: path)
        let boundary = "Boundary-\(UUID().uuidString)"
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = TokenManager.shared.getToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.httpBody = buildMultipartBody(
            boundary: boundary,
            fields: fields,
            fileData: fileData,
            fileFieldName: fileFieldName,
            fileName: fileName,
            mimeType: mimeType
        )

        #if DEBUG
        let fieldLog = fields.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        print("[Multipart] \(method) \(path) — Fields: \(fieldLog)")
        if let fileData = fileData {
            print("[Multipart] Attaching file: \(fileName) (\(mimeType), \(fileData.count) bytes)")
        } else {
            print("[Multipart] No file attached")
        }
        #endif

        let (data, response) = try await session.data(for: urlRequest)
        try validateResponse(data: data, response: response)

        if let apiStatus = try? JSONDecoder().decode(APIErrorResponse.self, from: data), !apiStatus.success {
            throw APIError.serverError(apiStatus.message ?? "Request failed")
        }
    }

    // MARK: - Void Request (no response body needed)

    func requestVoid(
        path: String,
        method: String = "POST",
        body: Encodable? = nil,
        requiresAuth: Bool = true,
        customToken: String? = nil
    ) async throws {
        let url = try buildURL(path: path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = customToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if requiresAuth, let token = TokenManager.shared.getToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: urlRequest)
        try validateResponse(data: data, response: response)
    }

    // MARK: - Private Helpers

    private func buildURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(string: "\(baseURL)/\(path)") else {
            throw APIError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        return url
    }

    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        try validateResponse(data: data, response: response)
        let decoder = JSONDecoder()
        do {
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
            guard apiResponse.success, let result = apiResponse.data else {
                throw APIError.serverError(apiResponse.message ?? "Unknown server error")
            }
            return result
        } catch let decodingError as DecodingError {
            throw APIError.decodingFailed(decodingError.localizedDescription)
        }
    }

    private func handlePaginatedResponse<T: Decodable>(data: Data, response: URLResponse) throws -> [T] {
        try validateResponse(data: data, response: response)
        let decoder = JSONDecoder()
        do {
            let apiResponse = try decoder.decode(APIPaginatedResponse<T>.self, from: data)
            guard apiResponse.success else {
                throw APIError.serverError(apiResponse.message ?? "Unknown server error")
            }
            return apiResponse.data ?? []
        } catch let decodingError as DecodingError {
            throw APIError.decodingFailed(decodingError.localizedDescription)
        }
    }

    private func validateResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError("Invalid response")
        }
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            DispatchQueue.main.async {
                SessionManager.shared.clearSession()
            }
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 400:
            let errorBody = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))
            throw APIError.badRequest(errorBody?.message ?? "Bad request")
        default:
            let errorBody = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))
            throw APIError.serverError(errorBody?.message ?? "Server error \(httpResponse.statusCode)")
        }
    }

    private func buildMultipartBodyMultiFile(
        boundary: String,
        fields: [String: String],
        files: [MultipartFile]
    ) -> Data {
        var body = Data()
        let crlf = "\r\n"
        let prefix = "--\(boundary)\(crlf)"

        for (key, value) in fields {
            body.append(Data(prefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\(crlf)\(crlf)".utf8))
            body.append(Data("\(value)\(crlf)".utf8))
        }

        for file in files {
            body.append(Data(prefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(file.fieldName)\"; filename=\"\(file.fileName)\"\(crlf)".utf8))
            body.append(Data("Content-Type: \(file.mimeType)\(crlf)\(crlf)".utf8))
            body.append(file.data)
            body.append(Data(crlf.utf8))
        }

        body.append(Data("--\(boundary)--\(crlf)".utf8))
        return body
    }

    private func buildMultipartBody(
        boundary: String,
        fields: [String: String],
        fileData: Data?,
        fileFieldName: String,
        fileName: String,
        mimeType: String
    ) -> Data {
        var body = Data()
        let crlf = "\r\n"
        let prefix = "--\(boundary)\(crlf)"

        for (key, value) in fields {
            body.append(Data(prefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\(crlf)\(crlf)".utf8))
            body.append(Data("\(value)\(crlf)".utf8))
        }

        if let fileData = fileData {
            body.append(Data(prefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\(crlf)".utf8))
            body.append(Data("Content-Type: \(mimeType)\(crlf)\(crlf)".utf8))
            body.append(fileData)
            body.append(Data(crlf.utf8))
        }

        body.append(Data("--\(boundary)--\(crlf)".utf8))
        return body
    }
}
