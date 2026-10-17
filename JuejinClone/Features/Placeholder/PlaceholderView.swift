//
//  PlaceholderView.swift
//  沸点 / 发现 / 课程 / 我 四个 tab 的占位页
//

import SwiftUI

struct PlaceholderView: View {
    let tab: AppTab

    var body: some View {
        VStack(spacing: 10) {
            LucideIcon(name: tab.lucideIcon, size: 40, color: Theme.textSecondary)
            Text(tab.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            Text("还没做")
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.pageBG)
    }
}

#Preview {
    PlaceholderView(tab: .boiling)
}
