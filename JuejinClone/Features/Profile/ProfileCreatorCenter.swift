//
//  ProfileCreatorCenter.swift
//  创作者中心：四个数据/创作入口 + 置顶话题
//

import SwiftUI

enum CreatorShortcut: String, CaseIterable, Identifiable {
    case content, followers, activity, drafts

    var id: String { rawValue }

    var title: String {
        switch self {
        case .content: "内容数据"
        case .followers: "关注者数据"
        case .activity: "创作活动"
        case .drafts: "草稿箱"
        }
    }
}

struct ProfileCreatorCenter: View {
    let topic: String
    var onSelect: (String) -> Void = { _ in }

    var body: some View {
        ProfileCard {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Text("创作者中心")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    Spacer(minLength: 8)

                    Button {
                        onSelect("创作者中心")
                    } label: {
                        HStack(spacing: 2) {
                            Text("进入首页")
                                .font(.system(size: 12.5))
                            LucideIcon(name: "chevron-right", size: 11, color: Theme.textSecondary)
                        }
                        .foregroundStyle(Theme.textSecondary)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("进入创作者中心首页")
                }

                HStack(spacing: 0) {
                    ForEach(CreatorShortcut.allCases) { shortcut in
                        Button {
                            onSelect(shortcut.title)
                        } label: {
                            VStack(spacing: 4) {
                                CreatorGlyph(shortcut: shortcut)

                                Text(shortcut.title)
                                    .font(.system(size: 13.5))
                                    .foregroundStyle(Theme.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(shortcut.title)
                    }
                }
                .padding(.top, 10)

                Button {
                    onSelect("话题 \(topic)")
                } label: {
                    HStack(spacing: 10) {
                        Text("话题")
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundStyle(Theme.brand)

                        Rectangle()
                            .fill(Theme.divider)
                            .frame(width: 1, height: 13)

                        Text(topic)
                            .font(.system(size: 13.5))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        LucideIcon(name: "chevron-right", size: 13, color: Theme.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .background(
                        ProfileStyle.topicBG,
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
            }
            .padding(16)
        }
    }
}

// MARK: - 四个入口的图标

private struct CreatorGlyph: View {
    let shortcut: CreatorShortcut

    var body: some View {
        Group {
            switch shortcut {
            case .content:
                ContentDataGlyph()
            case .followers:
                FollowersGlyph()
            case .activity:
                AccentedIcon(name: "megaphone", accent: .trailing)
            case .drafts:
                AccentedIcon(name: "inbox", accent: .top)
            }
        }
        .frame(width: 34, height: 34)
    }
}

/// 文档 + 折线，顶部一条品牌蓝（对应截图里的「内容数据」）
private struct ContentDataGlyph: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .stroke(ProfileStyle.icon, lineWidth: 1.6)
                .frame(width: 22, height: 26)

            Capsule()
                .fill(Theme.brand)
                .frame(width: 13, height: 3)
                .offset(y: -14)

            ChartLine()
                .stroke(ProfileStyle.icon, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                .frame(width: 12, height: 7)
                .offset(y: -1)

            Capsule()
                .fill(ProfileStyle.icon)
                .frame(width: 10, height: 1.8)
                .offset(y: 7)
        }
    }
}

private struct ChartLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY + rect.height * 0.25))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.32, y: rect.minY + rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.55, y: rect.midY + rect.height * 0.12))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

/// 圆圈里的折线，底部一条蓝色底座（对应「关注者数据」）
private struct FollowersGlyph: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(ProfileStyle.icon, lineWidth: 1.6)
                .frame(width: 26, height: 26)

            ChartLine()
                .stroke(ProfileStyle.icon, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                .frame(width: 12, height: 7)
                .offset(y: -1)

            Capsule()
                .fill(Theme.brand)
                .frame(width: 16, height: 3)
                .offset(y: 15)
        }
    }
}

private struct AccentedIcon: View {
    enum Accent { case top, trailing }

    let name: String
    let accent: Accent

    var body: some View {
        ZStack {
            LucideIcon(name: name, size: 27, color: ProfileStyle.icon, lineWidth: 1.65)

            switch accent {
            case .top:
                Capsule()
                    .fill(Theme.brand)
                    .frame(width: 13, height: 3)
                    .offset(y: -13)
            case .trailing:
                Capsule()
                    .fill(Theme.brand)
                    .frame(width: 3, height: 11)
                    .offset(x: 13)
            }
        }
    }
}

#Preview {
    ProfileCreatorCenter(topic: "#每天一个知识点#")
        .padding()
        .background(Theme.pageBG)
}
