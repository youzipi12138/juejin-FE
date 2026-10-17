//
//  FeedStore.swift
//

import Foundation
import Observation

@Observable
@MainActor
final class FeedStore {
    private(set) var articles: [Article] = []
    /// 数据是真从后端拿的，还是回落到了样例数据
    private(set) var isLive = false
    private(set) var isLoading = false

    private let service: FeedService

    init(service: FeedService = LiveFeedService()) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            articles = try await service.loadRecommendFeed()
            isLive = true
        } catch {
            // 后端没起来也要能跑：回落到样例数据。
            // 这行日志顺带证明了 Configs 里的地址确实被读进来了 ——
            // 打完 dev 换 Release，这里会打出 prod 的域名。
            print("[FeedStore] \(AppEnvironment.name) @ \(AppEnvironment.apiBaseURL) 拉取失败："
                  + "\(error.localizedDescription)；回落 SampleData")
            articles = SampleData.articles
            isLive = false
        }
    }
}
