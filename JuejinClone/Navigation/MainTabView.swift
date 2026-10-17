//
//  MainTabView.swift
//
//  底栏为什么要分两条分支：
//  iOS 26 的 Liquid Glass 是**系统 chrome** 的一部分，只有用系统的 TabView
//  才会自动获得 —— 自绘的 HStack 不管怎么调材质都拿不到那层折射和交互反馈。
//  所以 26 走原生，18（没有 Liquid Glass）走自绘胶囊，用 ultraThinMaterial
//  拿到它在那一版上能给到的最好毛玻璃。
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selection: AppTab = .home

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            if AppEnvironment.forceLegacyTabBar {
                legacyTabBar
            } else {
                systemTabBar
            }
        } else {
            legacyTabBar
        }
    }

    /// iOS 26：系统标签栏自动就是 Liquid Glass，不需要手写任何材质代码。
    @available(iOS 26.0, *)
    private var systemTabBar: some View {
        TabView(selection: $selection) {
            ForEach(AppTab.allCases) { tab in
                Tab(tab.title, systemImage: tab.systemImage, value: tab) {
                    destination(for: tab)
                }
            }
        }
        // 滚动时保持 5 个 tab 全部可见，不收起
        .tabBarMinimizeBehavior(.never)
        // 白底栏；选中态的 Liquid Glass 胶囊仍然由系统绘制
        .toolbarBackground(Color.white, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

    /// iOS 18：自绘悬浮胶囊。用 safeAreaInset 而不是 ZStack overlay，
    /// 这样滚动内容会自动让开，不用手写 bottom padding。
    private var legacyTabBar: some View {
        destination(for: selection)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CustomCapsuleTabBar(selection: $selection)
            }
    }

    @ViewBuilder
    private func destination(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        default:
            PlaceholderView(tab: tab)
        }
    }
}

#Preview {
    MainTabView()
}
