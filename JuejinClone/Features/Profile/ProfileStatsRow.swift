//
//  ProfileStatsRow.swift
//  点赞 / 收藏 / 关注
//

import SwiftUI

struct ProfileStatsRow: View {
    let profile: Profile
    var onSelect: (String) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 0) {
            stat(profile.likes, title: "点赞")
            stat(profile.favorites, title: "收藏")
            stat(profile.following, title: "关注")
        }
    }

    private func stat(_ value: Int, title: String) -> some View {
        Button {
            onSelect(title)
        } label: {
            VStack(spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 22, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.textPrimary)

                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) \(value)")
    }
}

#Preview {
    ProfileStatsRow(profile: SampleData.profile)
        .padding()
        .background(Theme.pageBG)
}
