//
//  CustomCapsuleTabBar.swift
//  悬浮式底部导航（iOS 18 分支）
//
//  原来这里是 .fill(Color.white) —— 一块不透明白矩形，所以看着没有玻璃感。
//  iOS 18 上没有 Liquid Glass，ultraThinMaterial 就是能拿到的最好毛玻璃。
//  iOS 26 不走这条分支（见 MainTabView），系统自带的标签栏才是真玻璃。
//

import SwiftUI

struct CustomCapsuleTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let active = tab == selection

                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 3) {
                        LucideIcon(
                            name: tab.lucideIcon,
                            size: 22,
                            color: active ? Theme.brand : Theme.textPrimary
                        )
                        Text(tab.title)
                            .font(.system(size: 10, weight: active ? .medium : .regular))
                            .foregroundStyle(active ? Theme.brand : Theme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            // 半透明的高亮块，让下面的玻璃透出来；
                            // 用原来的 Theme.fill（不透明明灰）会把玻璃盖死。
                            .fill(active ? Theme.brand.opacity(0.14) : Color.clear)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.10), radius: 12, y: 2)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 2)
    }
}

#Preview("iOS 18 自绘胶囊") {
    ZStack(alignment: .bottom) {
        Theme.pageBG.ignoresSafeArea()
        // 放点彩色内容在底下，好看清毛玻璃到底透不透
        LinearGradient(colors: [.orange, .pink, .purple],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
        CustomCapsuleTabBar(selection: .constant(.home))
    }
}
