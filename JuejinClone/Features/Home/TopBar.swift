//
//  TopBar.swift
//  顶部：搜索框 + 环境角标 + 签到
//

import SwiftUI

struct TopBar: View {
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                LucideIcon(name: "search", size: 16, color: Theme.textSecondary)
                Text("探索稀土掘金")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .frame(height: 34)
            .background(Theme.fill, in: RoundedRectangle(cornerRadius: 6, style: .continuous))

            #if DEBUG
            EnvironmentBadge()
            #endif

            CheckInButton()
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

#if DEBUG
/// 仅 DEBUG 可见：显示当前读的是哪套后端配置。
/// 切 scheme 就能肉眼确认，不用去翻构建日志。
struct EnvironmentBadge: View {
    var body: some View {
        Text(AppEnvironment.name.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(AppEnvironment.isDev ? Color.orange : Color.green, in: Capsule())
    }
}
#endif

struct CheckInButton: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.brand)
                .frame(width: 32, height: 32)
                .overlay(
                    LucideIcon(name: "calendar-check", size: 18, color: .white)
                )

            Text("签到")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 3)
                .padding(.vertical, 1)
                .background(Theme.brand, in: Capsule())
                .overlay(Capsule().stroke(.white, lineWidth: 1))
                .offset(x: 4, y: 3)
        }
    }
}
