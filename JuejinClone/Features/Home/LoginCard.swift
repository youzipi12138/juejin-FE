//
//  LoginCard.swift
//

import SwiftUI

struct LoginCard: View {
    var onLogin: () -> Void

    var body: some View {
        Button(action: onLogin) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("登录账号")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("收藏文章，同步阅读记录，数据永不丢失")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Text("登录")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.brand)
            }
            .padding(.horizontal, Theme.gutter)
            .padding(.vertical, 16)
            .background(Color.white)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("登录账号")
    }
}
