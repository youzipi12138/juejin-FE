//
//  APIError.swift
//

import Foundation

enum APIError: Error, LocalizedError {
    /// baseURL + path 拼不出合法 URL
    case invalidURL(String)
    /// 连接层失败（拒绝连接、超时、DNS…）
    case transport(Error)
    /// 非 2xx
    case status(Int)
    /// 响应体和模型对不上
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let path):
            return "URL 拼不出来：\(path)"
        case .transport(let error):
            return "连不上：\(error.localizedDescription)"
        case .status(let code):
            return "HTTP \(code)"
        case .decoding(let error):
            return "解析失败：\(error.localizedDescription)"
        }
    }
}
