//
//  AppTab.swift
//  底部 5 个 tab 的单一数据源。
//
//  两套图标名并存的原因见 MainTabView：iOS 26 走系统 TabView（只吃 Image，
//  所以用 SF Symbols），iOS 18 走自绘底栏（用原有的 Lucide 渲染器）。
//

import Foundation

enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case home, boiling, discover, courses, profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "首页"
        case .boiling: "沸点"
        case .discover: "发现"
        case .courses: "课程"
        case .profile: "我"
        }
    }

    /// iOS 26 原生 TabView 用
    var systemImage: String {
        switch self {
        case .home: "house"
        case .boiling: "flame"
        case .discover: "safari"
        case .courses: "book"
        case .profile: "person"
        }
    }

    /// iOS 18 自绘底栏用（对应 LucideData 里的键）
    var lucideIcon: String {
        switch self {
        case .home: "house"
        case .boiling: "flame"
        case .discover: "compass"
        case .courses: "book-open"
        case .profile: "user"
        }
    }
}
