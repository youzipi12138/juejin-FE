//
//  AppEnvironment.swift
//  全 App 唯一的配置入口。
//
//  值的来源链条：
//      Configs/{Debug,Release}.xcconfig
//        → 构建期替换 Info.plist 里的 $(API_BASE_URL) / $(ENV_NAME)
//        → 运行时在这里读出来
//
//  要换后端地址，改 Configs/Debug.xcconfig 或 Release.xcconfig，别改这里。
//

import Foundation

enum AppEnvironment {
    /// "dev" / "prod"，来自 xcconfig 的 ENV_NAME
    static let name: String = value(for: "ENV_NAME") ?? "unknown"

    /// 来自 xcconfig 的 API_BASE_URL
    static let apiBaseURL: URL = {
        guard let raw = value(for: "API_BASE_URL"), let url = URL(string: raw) else {
            // 配置错配要当场炸，不能静默回落成某个默认域名 ——
            // 否则会变成"看着能跑，其实全在打生产"。
            preconditionFailure("""
                Info.plist 里读不到 API_BASE_URL。
                排查：
                  1. Configs/*.xcconfig 是否已挂到该 build configuration
                  2. xcodebuild -project JuejinClone.xcodeproj -scheme JuejinClone \
                       -configuration Debug -showBuildSettings | grep API_BASE_URL
                """)
        }
        return url
    }()

    static var isDev: Bool { name == "dev" }

    /// 启动参数 `-ForceLegacyTabBar YES`：
    /// 在 iOS 26 上强制走自绘胶囊底栏，用来验证 iOS 18 那条分支的外观
    /// （本机只装了 iOS 26.5 模拟器，正常情况下永远走不到 18 的分支）。
    static var forceLegacyTabBar: Bool {
        UserDefaults.standard.bool(forKey: "ForceLegacyTabBar")
    }

    /// 读 Info.plist，顺便挡掉没被替换成功的字面量 "$(FOO)"
    private static func value(for key: String) -> String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !raw.isEmpty,
              !raw.hasPrefix("$(") else { return nil }
        return raw
    }
}
