//
//  APIClient.swift
//

import Foundation

/// 薄薄一层 URLSession 封装。默认从 AppEnvironment 取 baseURL，
/// 所以 Configs 里配的地址是真的被用上的，不是死配置。
struct APIClient {
    let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: URL = AppEnvironment.apiBaseURL,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        guard var comps = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL(path)
        }
        if !query.isEmpty { comps.queryItems = query }

        guard let url = comps.url else { throw APIError.invalidURL(path) }

        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.status(-1)
            }
            guard (200..<300).contains(http.statusCode) else {
                throw APIError.status(http.statusCode)
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.transport(error)
        }
    }
}
