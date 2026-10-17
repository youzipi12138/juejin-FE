//
//  ProfileTopBar.swift
//  个人页顶部：左边扫一扫，右边夜间模式 / 消息 / 设置。
//
//  没有用 NavigationStack：这页不 push 任何子页面，自绘一排按钮
//  最省事，也不会平白多出一条导航栏。
//

import SwiftUI

struct ProfileTopBar: View {
    var onSelect: (String) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 0) {
            button(icon: "scan-line", title: "扫一扫")

            Spacer(minLength: 0)

            HStack(spacing: 14) {
                button(icon: "moon", title: "夜间模式")
                button(icon: "bell", title: "消息")
                button(icon: "settings", title: "设置")
            }
        }
        .frame(height: 44)
    }

    private func button(icon: String, title: String) -> some View {
        Button {
            onSelect(title)
        } label: {
            LucideIcon(name: icon, size: 22, color: ProfileStyle.topBarIcon, lineWidth: 1.8)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

#Preview {
    ProfileTopBar()
        .padding(.horizontal, Theme.gutter)
        .background(Color.white)
}
