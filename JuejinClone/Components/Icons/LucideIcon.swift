//
//  LucideIcon.swift
//  用 SwiftUI 原生 Path 渲染 Lucide 图标（替代 react-lucide）。
//

import SwiftUI

/// 把 24×24 视口的 Lucide 路径等比缩放并居中到目标 rect
struct LucideShape: Shape {
    let d: String

    func path(in rect: CGRect) -> Path {
        guard !d.isEmpty else { return Path() }
        let scale = min(rect.width, rect.height) / 24
        let dx = rect.minX + (rect.width - 24 * scale) / 2
        let dy = rect.minY + (rect.height - 24 * scale) / 2
        let t = CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: dx, ty: dy)
        return SVGPath.parse(d).applying(t)
    }
}

/// 用法：`LucideIcon(name: "house", size: 22, color: Theme.brand)`
struct LucideIcon: View {
    let name: String
    var size: CGFloat = 24
    var color: Color = Theme.textPrimary
    /// 以 24 视口为基准的线宽，Lucide 默认 2
    var lineWidth: CGFloat = 2

    var body: some View {
        LucideShape(d: LucideData.icons[name] ?? "")
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: lineWidth * size / 24,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(width: size, height: size)
    }
}

#Preview("图标总览") {
    let names = ["house", "flame", "compass", "book-open", "user",
                 "search", "calendar-check", "thumbs-up", "message-circle",
                 "x", "menu", "ellipsis", "chevron-right", "bookmark"]
    return ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
            ForEach(names, id: \.self) { n in
                VStack(spacing: 6) {
                    LucideIcon(name: n, size: 28, color: Theme.brand)
                    Text(n).font(.system(size: 9)).foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding()
    }
}
