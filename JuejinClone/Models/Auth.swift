//
//  Auth.swift
//  后端 /api/auth/* 的响应模型
//

import Foundation

struct AuthUser: Decodable, Identifiable, Equatable {
    let id: Int64
    let username: String
    let phone: String?
    let nickname: String?
    let role: String
    let status: Int
    let createTime: String?
    let updateTime: String?
}

struct SMSCodeResponse: Decodable {
    let phone: String
    let expiresIn: Int
    let retryAfter: Int
    /// 仅 dev mock 模式返回
    let debugCode: String?
}

struct LoginResponse: Decodable {
    let token: String
    let tokenType: String
    let expiresIn: Int
    let user: AuthUser
    let newUser: Bool?
}

struct EmptyBody: Encodable {}
