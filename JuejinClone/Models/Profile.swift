//
//  Profile.swift
//  个人页（「我」tab）的展示数据。
//
//  现在没有登录态和后端接口，先用 SampleData.profile 喂满整页；
//  等 /api/v1/user/profile 接通后，把 ProfileStore 按 FeedStore 的写法补上即可。
//

import Foundation

struct Profile: Hashable, Sendable {
    let name: String
    /// Assets.xcassets 里的头像名
    let avatarAsset: String
    /// 掘金等级，如 LV.3
    let level: String
    /// 掘金会员等级，如 JY.5
    let jyLevel: String
    let badgeCount: Int
    let likes: Int
    let favorites: Int
    let following: Int
    /// 已连续签到天数
    let checkInDays: Int
    /// 创作者中心里挂的话题
    let topic: String
}
