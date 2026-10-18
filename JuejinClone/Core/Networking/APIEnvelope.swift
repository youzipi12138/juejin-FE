//
//  APIEnvelope.swift
//  后端统一返回：{ "code": 200, "message": "...", "data": ... }
//

import Foundation

struct APIEnvelope<T: Decodable>: Decodable {
    let code: Int
    let message: String
    let data: T?
}

struct APIErrorBody: Decodable {
    let code: Int?
    let message: String?
}
