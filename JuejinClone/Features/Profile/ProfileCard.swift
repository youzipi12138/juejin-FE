//
//  ProfileCard.swift
//  个人页的白色圆角板块。
//
//  只负责「白底 + 圆角」，内边距交给调用方：
//  快速入口那一排要贴边均分四格，创作者中心则是常规 16pt 内边距，
//  统一写死在这里反而要到处传参。
//

import SwiftUI

enum ProfileStyle {
    static let topBarIcon = Color(hex: 0x4C5260)
    /// 卡片里那些细线图标，比正文深一点
    static let icon = Color(hex: 0x363B46)
    static let badgePillBG = Color(hex: 0xF5F8FF)
    static let topicBG = Color(hex: 0xF4F5F8)
}

struct ProfileCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
