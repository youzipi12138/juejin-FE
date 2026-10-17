//
//  MetaLabel.swift
//

import SwiftUI

/// 图标 + 数字的小组合，如「👍 13」
struct MetaLabel: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            LucideIcon(name: icon, size: 16, color: Theme.textSecondary)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
