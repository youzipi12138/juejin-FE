//
//  CategoryTabBar.swift
//

import SwiftUI

struct CategoryTabBar: View {
    @Binding var index: Int

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 22) {
                    ForEach(Array(SampleData.categories.enumerated()), id: \.element.id) { i, c in
                        CategoryTab(category: c, selected: i == index)
                            .contentShape(Rectangle())
                            .onTapGesture { index = i }
                    }
                }
                .padding(.horizontal, Theme.gutter)
            }

            LucideIcon(name: "menu", size: 20, color: Theme.textPrimary)
                .padding(.leading, 10)
                .padding(.trailing, Theme.gutter)
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

struct CategoryTab: View {
    let category: Category
    let selected: Bool

    var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: .topTrailing) {
                Text(category.title)
                    .font(.system(size: 16, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? Theme.textPrimary : Theme.textSecondary)

                if category.hasDot {
                    Circle()
                        .fill(Color(hex: 0xF64242))
                        .frame(width: 5, height: 5)
                        .offset(x: 5, y: 1)
                }
            }

            RoundedRectangle(cornerRadius: 1.5)
                .fill(selected ? Theme.brand : .clear)
                .frame(width: 16, height: 3)
        }
    }
}
