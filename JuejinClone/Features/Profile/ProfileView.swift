//
//  ProfileView.swift
//  「我」tab：个人信息 + 快捷入口 + 创作者中心 + 常用功能
//
//  页面结构照搬掘金个人页：顶部工具条、头像/等级、三项数据，
//  然后是三块白色卡片。底栏不在这个文件里 —— 由 MainTabView 统一负责，
//  和首页一样，这样 iOS 26 才能走系统 TabView 拿到 Liquid Glass。
//

import SwiftUI

struct ProfileView: View {
    private let profile = SampleData.profile

    /// 目前还没接对应的后端/路由，点任何入口先给一个短提示，避免「点了没反应」
    @State private var toast: String?
    /// 连续点击时只让最后一次的定时器清掉 toast
    @State private var toastToken = 0

    var body: some View {
        ZStack(alignment: .top) {
            Theme.pageBG.ignoresSafeArea()
            topWash

            VStack(spacing: 0) {
                // 顶栏固定，不跟着内容滚动
                ProfileTopBar(onSelect: showToast)
                    .padding(.horizontal, Theme.gutter)
                    .padding(.top, 2)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ProfileHeader(
                            profile: profile,
                            onOpenProfile: { showToast("个人主页") },
                            onOpenBadges: { showToast("我的徽章") }
                        )
                        .padding(.horizontal, Theme.gutter)
                        .padding(.top, 12)

                        ProfileStatsRow(profile: profile, onSelect: showToast)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 20)

                        VStack(spacing: 12) {
                            ProfileQuickActions(checkInDays: profile.checkInDays, onSelect: showToast)
                            ProfileCreatorCenter(topic: profile.topic, onSelect: showToast)
                            ProfileCommonTools(onSelect: showToast)
                        }
                        .padding(.horizontal, Theme.gutter)
                        .padding(.bottom, 28)
                    }
                }
            }
        }
        .overlay(alignment: .bottom) { toastView }
    }

    /// 顶部从近白过渡到页面灰，和截图里那层柔光一致；不跟着内容滚动
    private var topWash: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex: 0xFCFCFD), location: 0),
                .init(color: Color(hex: 0xFAFAFC), location: 0.28),
                .init(color: Theme.pageBG, location: 0.72),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(maxWidth: .infinity)
        .frame(height: 450)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var toastView: some View {
        if let toast {
            Text("「\(toast)」还没做")
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(.black.opacity(0.78), in: Capsule())
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .allowsHitTesting(false)
        }
    }

    private func showToast(_ title: String) {
        toastToken += 1
        let token = toastToken
        withAnimation(.smooth(duration: 0.2)) { toast = title }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            guard token == toastToken else { return }
            withAnimation(.smooth(duration: 0.2)) { toast = nil }
        }
    }
}

#Preview {
    ProfileView()
}
