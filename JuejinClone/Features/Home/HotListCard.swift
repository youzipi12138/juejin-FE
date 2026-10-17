//
//  HotListCard.swift
//

import SwiftUI

struct HotListCard: View {
    let items: [HotItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("热榜")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.bottom, 14)

            VStack(spacing: 16) {
                ForEach(items) { item in
                    HStack(spacing: 10) {
                        Text("\(item.rank)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 18)
                            .background(
                                Theme.hotBadge(item.rank),
                                in: RoundedRectangle(cornerRadius: 4, style: .continuous)
                            )

                        Text(item.title)
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        Text(item.heat)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                            .layoutPriority(1)
                    }
                }
            }
        }
        .padding(Theme.gutter)
        .background(Color.white)
    }
}
