//
//  Theme.swift
//  掘金风格的设计 token
//

import SwiftUI

enum Theme {
    /// 品牌蓝
    static let brand = Color(hex: 0x1E80FF)
    /// 页面底色（白色板块之间露出的灰）
    static let pageBG = Color(hex: 0xF4F5F5)
    /// 搜索框底色
    static let fill = Color(hex: 0xF2F3F5)

    static let textPrimary = Color(hex: 0x252933)
    /// 摘要正文，比标题浅、比辅助文字深
    static let textBody = Color(hex: 0x515767)
    static let textSecondary = Color(hex: 0x8A919F)
    static let divider = Color(hex: 0xE4E6EB)

    /// 热榜名次徽章
    static func hotBadge(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color(hex: 0xF64242)   // 红
        case 2: return Color(hex: 0xFF7A38)   // 橙
        default: return Color(hex: 0xFFB800)  // 金
        }
    }

    /// 板块左右统一边距
    static let gutter: CGFloat = 16
}
