//
//  ProfileHeader.swift
//  头像、昵称、等级徽章、个人主页入口
//

import SwiftUI

struct ProfileHeader: View {
    let profile: Profile
    var onOpenProfile: () -> Void = {}
    var onOpenBadges: () -> Void = {}

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(profile.avatarAsset)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
                .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
                .accessibilityLabel("头像")

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(profile.name)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 6)

                    Button(action: onOpenProfile) {
                        HStack(spacing: 2) {
                            Text("个人主页")
                                .font(.system(size: 13))
                            LucideIcon(name: "chevron-right", size: 12, color: Theme.textSecondary)
                        }
                        .foregroundStyle(Theme.textSecondary)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("个人主页")
                }

                HStack(spacing: 5) {
                    LevelBadge(
                        text: profile.level,
                        tint: [Color(hex: 0x9FE2FF), Color(hex: 0x55B7FF), Color(hex: 0x2B8BF2)]
                    )
                    LevelBadge(
                        text: profile.jyLevel,
                        tint: [Color(hex: 0xEEE4FF), Color(hex: 0xD6BEFF), Color(hex: 0xB395FF)],
                        foreground: Color(hex: 0x5030A8)
                    )
                    BadgePill(count: profile.badgeCount, action: onOpenBadges)
                }
            }
            .padding(.top, 3)
        }
    }
}

// MARK: - 等级徽章

/// LV.3 / JY.5：斜切的彩带，两头各斜一刀
struct LevelBadge: View {
    let text: String
    let tint: [Color]
    var foreground: Color = .white

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .heavy, design: .rounded))
            .kerning(0.1)
            .foregroundStyle(foreground)
            .padding(.horizontal, 6.5)
            .frame(height: 16)
            .background {
                LevelRibbon()
                    .fill(LinearGradient(colors: tint, startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .overlay {
                LevelRibbon()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.32), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
            .overlay {
                LevelRibbon().stroke(.white.opacity(0.35), lineWidth: 0.5)
            }
            .shadow(color: (tint.last ?? .clear).opacity(0.24), radius: 1.5, y: 1)
    }
}

private struct LevelRibbon: Shape {
    func path(in rect: CGRect) -> Path {
        let slant = min(3.5, rect.width / 4)
        var path = Path()
        path.move(to: CGPoint(x: slant, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - slant, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - 徽章计数

/// 浅蓝胶囊：橙色定位针 +「0 徽章」+ 箭头
struct BadgePill: View {
    let count: Int
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                BadgePin()

                Text("\(count) 徽章")
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .foregroundStyle(Theme.brand)

                LucideIcon(name: "chevron-right", size: 10, color: Theme.brand)
            }
            .padding(.leading, 7)
            .padding(.trailing, 6)
            .frame(height: 20)
            .background(Capsule().fill(ProfileStyle.badgePillBG))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(count) 个徽章")
    }
}

struct BadgePin: View {
    var body: some View {
        ZStack {
            PinShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xFFC24A), Color(hex: 0xFF8A00)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Circle()
                .fill(.white)
                .frame(width: 3.5, height: 3.5)
                .offset(y: -2)
        }
        .frame(width: 11, height: 15)
    }
}

private struct PinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let head = rect.width
        var path = Path()
        path.addEllipse(in: CGRect(x: rect.minX, y: rect.minY, width: head, height: head))
        path.move(to: CGPoint(x: rect.minX + head * 0.14, y: rect.minY + head * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + head * 0.86, y: rect.minY + head * 0.52))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ProfileHeader(profile: SampleData.profile)
        .padding()
        .background(Color.white)
}
