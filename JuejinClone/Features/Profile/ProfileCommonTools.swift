//
//  ProfileCommonTools.swift
//  常用功能：4 列 × 2 行
//
//  「推广中心」的圆形 ¥ 是掘金的收益图标，Lucide 没有现成的，
//  用圆环加一个 ¥ Shape 拼出来；其余都用 Lucide 线稿，线宽统一。
//

import SwiftUI

enum CommonTool: String, CaseIterable, Identifiable {
    case courses, promotion, circle, reading, signup, wallet, tags, feedback

    var id: String { rawValue }

    var title: String {
        switch self {
        case .courses: "课程中心"
        case .promotion: "推广中心"
        case .circle: "我的圈子"
        case .reading: "阅读记录"
        case .signup: "我的报名"
        case .wallet: "我的钱包"
        case .tags: "标签管理"
        case .feedback: "意见反馈"
        }
    }
}

struct ProfileCommonTools: View {
    var onSelect: (String) -> Void = { _ in }

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0, alignment: .top),
        count: 4
    )

    var body: some View {
        ProfileCard {
            VStack(alignment: .leading, spacing: 18) {
                Text("常用功能")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                LazyVGrid(columns: columns, spacing: 23) {
                    ForEach(CommonTool.allCases) { tool in
                        Button {
                            onSelect(tool.title)
                        } label: {
                            VStack(spacing: 8) {
                                icon(for: tool)
                                    .frame(width: 32, height: 32)

                                Text(tool.title)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(tool.title)
                    }
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func icon(for tool: CommonTool) -> some View {
        switch tool {
        case .promotion:
            PromotionGlyph()
        case .feedback:
            FeedbackGlyph()
        case .courses:
            LucideIcon(name: "book-open", size: 27, color: ProfileStyle.icon, lineWidth: 1.6)
        case .circle:
            LucideIcon(name: "circle-user", size: 27, color: ProfileStyle.icon, lineWidth: 1.6)
        case .reading:
            LucideIcon(name: "file-clock", size: 27, color: ProfileStyle.icon, lineWidth: 1.6)
        case .signup:
            LucideIcon(name: "flag", size: 27, color: ProfileStyle.icon, lineWidth: 1.6)
        case .wallet:
            LucideIcon(name: "wallet", size: 27, color: ProfileStyle.icon, lineWidth: 1.6)
        case .tags:
            LucideIcon(name: "tag", size: 27, color: ProfileStyle.icon, lineWidth: 1.6)
        }
    }
}

// MARK: - 推广中心图标

private struct PromotionGlyph: View {
    private let stroke = StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round)

    var body: some View {
        ZStack {
            Circle()
                .stroke(ProfileStyle.icon, lineWidth: 1.6)
                .frame(width: 24, height: 24)

            YenMark()
                .stroke(ProfileStyle.icon, style: stroke)
        }
        .frame(width: 30, height: 30)
    }
}

private struct YenMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 10, y: 7))
        path.addLine(to: CGPoint(x: 15, y: 13))
        path.addLine(to: CGPoint(x: 20, y: 7))
        path.move(to: CGPoint(x: 15, y: 13))
        path.addLine(to: CGPoint(x: 15, y: 21))
        path.move(to: CGPoint(x: 10, y: 16))
        path.addLine(to: CGPoint(x: 20, y: 16))
        path.move(to: CGPoint(x: 10, y: 19))
        path.addLine(to: CGPoint(x: 20, y: 19))
        return path
    }
}

// MARK: - 意见反馈图标

/// 气泡里加一道笑弧，和截图里那个带表情的反馈图标一致
private struct FeedbackGlyph: View {
    var body: some View {
        ZStack {
            LucideIcon(name: "message-square", size: 27, color: ProfileStyle.icon, lineWidth: 1.6)

            SmileMark()
                .stroke(
                    ProfileStyle.icon,
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
                .frame(width: 10, height: 6)
                .offset(y: -1)
        }
        .frame(width: 30, height: 30)
    }
}

private struct SmileMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

#Preview {
    ProfileCommonTools()
        .padding()
        .background(Theme.pageBG)
}
