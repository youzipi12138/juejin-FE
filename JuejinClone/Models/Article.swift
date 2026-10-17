//
//  Article.swift
//

import Foundation

struct Article: Identifiable, Codable, Sendable, Hashable {
    /// 服务端给的稳定 id（原来用 UUID()，那样没法从 JSON 解出来）
    let id: String
    let title: String
    let author: String
    let summary: String
    let likes: Int
    let comments: Int
    /// 右下角分类标签，没有则不显示
    let tag: String?
}
