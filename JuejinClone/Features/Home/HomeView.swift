//
//  HomeView.swift
//  首页：顶部搜索 + 分类 tab + 内容流
//
//  底栏不在这里 —— 由 MainTabView 统一负责，这样 iOS 26 才能走系统 TabView
//  拿到 Liquid Glass，而不是被一个 ZStack overlay 挡住。
//

import SwiftUI

struct HomeView: View {
    var onLogin: () -> Void = {}

    @State private var categoryIndex = 1   // 默认选中「推荐」
    @State private var store = FeedStore()

    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            CategoryTabBar(index: $categoryIndex)
            Divider().overlay(Theme.divider)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    LoginCard { onLogin() }
                    HotListCard(items: SampleData.hot)
                    ArticleFeed(articles: store.articles)
                }
                .padding(.bottom, 8)
            }
        }
        .background(Theme.pageBG)
        .task { await store.load() }
    }
}

#Preview {
    HomeView()
}
