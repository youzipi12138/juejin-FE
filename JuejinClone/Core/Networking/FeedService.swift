//
//  FeedService.swift
//

import Foundation

/// 后端接口还没给契约，先把"该长什么样"定下来。
/// 路径是占位的，等后端定了一起调这一个文件。
protocol FeedService: Sendable {
    func loadRecommendFeed() async throws -> [Article]
    func loadHotList() async throws -> [HotItem]
    func loadCategories() async throws -> [Category]
}

struct LiveFeedService: FeedService {
    let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func loadRecommendFeed() async throws -> [Article] {
        try await client.get("/api/v1/feed/recommend")
    }

    func loadHotList() async throws -> [HotItem] {
        try await client.get("/api/v1/feed/hot")
    }

    func loadCategories() async throws -> [Category] {
        try await client.get("/api/v1/feed/categories")
    }
}
