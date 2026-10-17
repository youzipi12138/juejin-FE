//
//  ArticleFeed.swift
//

import SwiftUI

struct ArticleFeed: View {
    let articles: [Article]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(articles.enumerated()), id: \.element.id) { i, article in
                ArticleCard(article: article)

                if i < articles.count - 1 {
                    Rectangle()
                        .fill(Theme.divider)
                        .frame(height: 0.5)
                        .padding(.leading, Theme.gutter + 22 + 6)
                }
            }
        }
        .background(Color.white)
    }
}

struct ArticleCard: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(article.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Avatar(name: article.author, size: 22)
                Text(article.author)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }

            Text(article.summary)
                .font(.system(size: 15))
                .foregroundStyle(Theme.textBody)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                MetaLabel(icon: "thumbs-up", text: "\(article.likes)")
                MetaLabel(icon: "message-circle", text: "\(article.comments)")

                Spacer(minLength: 8)

                if let tag = article.tag {
                    Text(tag)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Theme.fill, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                }

                LucideIcon(name: "x", size: 14, color: Theme.textSecondary)
            }
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.vertical, 16)
    }
}
