//
//  MainTabView.swift
//
//  底栏为什么要分两条分支：
//  iOS 26 的 Liquid Glass 是**系统 chrome** 的一部分，只有用系统的 TabView
//  才会自动获得 —— 自绘的 HStack 不管怎么调材质都拿不到那层折射和交互反馈。
//  所以 26 走原生，18（没有 Liquid Glass）走自绘胶囊，用 ultraThinMaterial
//  拿到它在那一版上能给到的最好毛玻璃。
//
//  登录页放在 TabView 之上，用横向推入的覆盖层呈现：底栏和首页保持不动，
//  登录页从右侧盖上来，返回时再横向滑走，避免底栏在底部「凭空出现」。
//

import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .home
    @State private var showLogin = false

    var body: some View {
        ZStack {
            tabContent

            if showLogin {
                LoginView(onBack: closeLogin)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
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
        // 滚动时保持 5 个 tab 全部可见，不收起成一个
        .tabBarMinimizeBehavior(.never)
        // 原生玻璃栏下面垫白底
        .background { TabBarWhiteBackground() }
    }

    /// iOS 18：自绘悬浮胶囊。用 safeAreaInset 而不是 ZStack overlay，
    /// 这样滚动内容会自动让开，不用手写 bottom padding。
    private var legacyTabBar: some View {
        destination(for: selection)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CustomCapsuleTabBar(selection: $selection)
            }
    }

    private func openLogin() {
        withAnimation(.smooth(duration: 0.32)) {
            showLogin = true
        }
    }

    private func closeLogin() {
        withAnimation(.smooth(duration: 0.32)) {
            showLogin = false
        }
    }

    @ViewBuilder
    private func destination(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView(onLogin: openLogin)
        default:
            PlaceholderView(tab: tab)
        }
    }
}

#Preview {
    MainTabView()
}
