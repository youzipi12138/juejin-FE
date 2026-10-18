//
//  APIClient.swift
//

import Foundation

/// 薄薄一层 URLSession 封装。默认从 AppEnvironment 取 baseURL，
/// 所以 Configs 里配的地址是真的被用上的，不是死配置。
struct APIClient {
    let baseURL: URL
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(baseURL: URL = AppEnvironment.apiBaseURL,
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func get<T: Decodable>(_ path: String,
                           query: [URLQueryItem] = [],
                           token: String? = nil) async throws -> T {
        let data = try await perform(path: path,
                                     method: "GET",
                                     query: query,
                                     body: nil,
                                     token: token)
        return try decode(data, path: path)
    }

    func post<T: Decodable, B: Encodable>(_ path: String,
                                          body: B,
                                          token: String? = nil) async throws -> T {
        let bodyData = try encoder.encode(body)
        let data = try await perform(path: path,
                                     method: "POST",
                                     query: [],
                                     body: bodyData,
                                     token: token)
        return try decode(data, path: path)
    }

    func postVoid<B: Encodable>(_ path: String,
                                body: B,
                                token: String? = nil) async throws {
        let bodyData = try encoder.encode(body)
        _ = try await perform(path: path,
                              method: "POST",
                              query: [],
                              body: bodyData,
                              token: token)
    }

    // MARK: - Private

    private func perform(path: String,
                         method: String,
                         query: [URLQueryItem],
                         body: Data?,
                         token: String?) async throws -> Data {
        let url = try makeURL(path: path, query: query)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.status(-1)
            }
            guard (200..<300).contains(http.statusCode) else {
                if let errorBody = try? decoder.decode(APIErrorBody.self, from: data),
                   let message = errorBody.message,
                   !message.isEmpty {
                    throw APIError.server(http.statusCode, message)
                }
                throw APIError.status(http.statusCode)
            }
            return data
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.transport(error)
        }
    }

    private func decode<T: Decodable>(_ data: Data, path: String) throws -> T {
        if let envelope = try? decoder.decode(APIEnvelope<T>.self, from: data) {
            if envelope.code != 200 {
                throw APIError.server(envelope.code, envelope.message)
            }
            if let value = envelope.data {
                return value
            }
        }

        // 兼容不包 envelope 的普通 JSON
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func makeURL(path: String, query: [URLQueryItem]) throws -> URL {
        var base = baseURL.absoluteString
        if base.hasSuffix("/") { base.removeLast() }

        let normalizedPath = path.hasPrefix("/") ? path : "/" + path
        guard var comps = URLComponents(string: base + normalizedPath) else {
            throw APIError.invalidURL(path)
        }
        if !query.isEmpty {
            comps.queryItems = query
        }
        guard let url = comps.url else {
            throw APIError.invalidURL(path)
        }
        return url
    }
}
