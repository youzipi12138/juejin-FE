//
//  AuthService.swift
//  手机号验证码登录 / 登出 / 当前用户
//

import Foundation

struct AuthService {
    let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func sendSMSCode(phone: String) async throws -> SMSCodeResponse {
        try await client.post("/api/auth/sms/send", body: SMSCodeRequest(phone: phone))
    }

    func login(phone: String, code: String) async throws -> LoginResponse {
        try await client.post("/api/auth/sms/login",
                              body: SMSCodeLoginRequest(phone: phone, code: code))
    }

    func me(token: String) async throws -> AuthUser {
        try await client.get("/api/auth/me", token: token)
    }

    func logout(token: String) async throws {
        try await client.postVoid("/api/auth/logout", body: EmptyBody(), token: token)
    }
}

private struct SMSCodeRequest: Encodable {
    let phone: String
}

private struct SMSCodeLoginRequest: Encodable {
    let phone: String
    let code: String
}
