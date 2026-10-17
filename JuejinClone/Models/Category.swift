//
//  Category.swift
//

import Foundation

struct Category: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let title: String
    /// 标题右上角的红点（如「头条精选」）
    let hasDot: Bool
}
