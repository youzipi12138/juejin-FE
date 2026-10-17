//
//  HotItem.swift
//

import Foundation

struct HotItem: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let rank: Int
    let title: String
    let heat: String
}
