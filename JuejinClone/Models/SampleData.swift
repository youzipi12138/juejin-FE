//
//  SampleData.swift
//  后端起来之前喂给 UI 的样例数据。
//  等 /api/v1/feed/* 接通后，这里只作为拉取失败时的回落（见 FeedStore）。
//

import Foundation

enum SampleData {
    static let profile = Profile(
        name: "jump123",
        avatarAsset: "ProfileAvatar",
        level: "LV.3",
        jyLevel: "JY.5",
        badgeCount: 0,
        likes: 29,
        favorites: 111,
        following: 21,
        checkInDays: 1,
        topic: "#每天一个知识点#"
    )

    static let categories: [Category] = [
        Category(id: "follow", title: "关注", hasDot: false),
        Category(id: "recommend", title: "推荐", hasDot: false),
        Category(id: "hot", title: "热榜", hasDot: false),
        Category(id: "headline", title: "头条精选", hasDot: true),
        Category(id: "backend", title: "后端", hasDot: false),
        Category(id: "frontend", title: "前端", hasDot: false),
        Category(id: "ai", title: "AI", hasDot: false),
        Category(id: "tools", title: "开发工具", hasDot: false),
    ]

    static let hot: [HotItem] = [
        HotItem(id: "hot-1", rank: 1, title: "SQL 编辑器不只是写查询：我用 KStudio...", heat: "2781热度"),
        HotItem(id: "hot-2", rank: 2, title: "老干妈靠AI闷赚54亿，你的AI还在写文案？", heat: "1494 热度"),
        HotItem(id: "hot-3", rank: 3, title: "把 AutoCAD 搬进浏览器，到底有多难？...", heat: "1161 热度"),
    ]

    static let articles: [Article] = [
        Article(
            id: "a-1",
            title: "用了Pi基本就回不去了，如果你也在用Pi，强烈推荐安装pi-chrome",
            author: "jerrywus",
            summary: "用了Pi基本就回不去了，如果你也在用Pi，强烈推荐安装pi-chrome。它能让 Pi coding agent 操作你平时用的 Chrome，把浏览器变成 agent 的手和眼。",
            likes: 13,
            comments: 7,
            tag: "Agent"
        ),
        Article(
            id: "a-2",
            title: "🍉 我把《天龙八部》喂给了 AI，问它\u{201C}段誉会什么武功？\u{201D}答案让我惊呆了",
            author: "默_笙",
            summary: "一、RAG 完整链路：从文件到回答。1.1 天龙八部 RAG 的\u{201C}五步法\u{201D}老师说：这五步串起来，就是一个完整的生产级 RAG 链路。",
            likes: 100,
            comments: 40,
            tag: "前端"
        ),
        Article(
            id: "a-3",
            title: "DeepSeek 昨晚刚开源了 Harness：附万少的 2 万字解读",
            author: "掘金酱",
            summary: "从 agent 循环到工具调用协议，逐层拆开这套 harness 的设计取舍，以及它和主流 agent 框架的差异。",
            likes: 256,
            comments: 88,
            tag: "AI"
        ),
    ]
}
