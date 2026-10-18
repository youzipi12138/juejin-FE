//
//  AuthStore.swift
//  全 App 登录态。token 暂存 UserDefaults；上线前建议换成 Keychain。
//

import Foundation
import SwiftUI

@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var user: AuthUser?
    @Published private(set) var token: String?
    @Published private(set) var isRestoring = false

    private let service: AuthService
    private let tokenKey = "auth.token"

    var isLoggedIn: Bool { token != nil && user != nil }

    var displayName: String {
        user?.nickname ?? user?.username ?? "掘友"
    }

    init(service: AuthService = AuthService()) {
        self.service = service
        self.token = UserDefaults.standard.string(forKey: tokenKey)
    }

    func sendSMSCode(phone: String) async throws -> SMSCodeResponse {
        try await service.sendSMSCode(phone: phone)
    }

    @discardableResult
    func login(phone: String, code: String) async throws -> LoginResponse {
        let response = try await service.login(phone: phone, code: code)
        token = response.token
        user = response.user
        UserDefaults.standard.set(response.token, forKey: tokenKey)
        return response
    }

    func logout() async {
        if let token {
            try? await service.logout(token: token)
        }
        clear()
    }

    /// App 启动时尝试用本地 token 恢复登录态；401 会清掉本地 token
    func restoreSession() async {
        guard let token, user == nil, !isRestoring else { return }
        isRestoring = true
        defer { isRestoring = false }

        do {
            user = try await service.me(token: token)
        } catch {
            clear()
        }
    }

    private func clear() {
        token = nil
        user = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
