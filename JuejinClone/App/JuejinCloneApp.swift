//
//  JuejinCloneApp.swift
//  JuejinClone
//

import SwiftUI

@main
struct JuejinCloneApp: App {
    @StateObject private var auth = AuthStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(auth)
                .task {
                    await auth.restoreSession()

                    #if DEBUG
                    // 本地联调用：xcrun simctl launch ... -DevLoginPhone 139... -DevLoginCode 123456
                    if !auth.isLoggedIn,
                       let phone = UserDefaults.standard.string(forKey: "DevLoginPhone"),
                       let code = UserDefaults.standard.string(forKey: "DevLoginCode") {
                        _ = try? await auth.login(phone: phone, code: code)
                    }
                    #endif
                }
        }
    }
}
