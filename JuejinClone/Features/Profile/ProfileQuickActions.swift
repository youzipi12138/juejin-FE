//
//  ProfileQuickActions.swift
//  签到 / 幸运转盘 / Bug 挑战赛 / 福利兑换
//
//  这四个图标是彩色插画风，Lucide 只有线稿，所以用 SwiftUI 图形手绘：
//  尺寸都按 36pt 画在固定画布上，缩放时不会走样。
//

import SwiftUI

struct ProfileQuickActions: View {
    let checkInDays: Int
    var onSelect: (String) -> Void = { _ in }

    private struct Item: Identifiable {
        enum Kind: Equatable { case checkIn, wheel, bug, gift }
        let kind: Kind
        let title: String
        var id: String { title }
    }

    private var items: [Item] {
        [
            Item(kind: .checkIn, title: "已签到\(checkInDays)天"),
            Item(kind: .wheel, title: "幸运转盘"),
            Item(kind: .bug, title: "Bug挑战赛"),
            Item(kind: .gift, title: "福利兑换"),
        ]
    }

    var body: some View {
        ProfileCard {
            HStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        onSelect(item.title)
                    } label: {
                        VStack(spacing: 7) {
                            glyph(for: item.kind)
                                .frame(width: 36, height: 38)

                            label(for: item)
                                .font(.system(size: 14))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 17)
        }
    }

    @ViewBuilder
    private func glyph(for kind: Item.Kind) -> some View {
        switch kind {
        case .checkIn: CheckInGlyph()
        case .wheel: LuckyWheelGlyph()
        case .bug: BugQuestGlyph()
        case .gift: GiftGlyph()
        }
    }

    private func label(for item: Item) -> Text {
        if item.kind == .checkIn {
            return Text("已签到").foregroundStyle(Theme.textPrimary)
                + Text("\(checkInDays)天").foregroundStyle(Theme.brand)
        }
        return Text(item.title).foregroundStyle(Theme.textPrimary)
    }
}

// MARK: - 彩色图标

/// 蓝色日历 + 白色对勾，顶上两个「装订环」
struct CheckInGlyph: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x74BEFF), Color(hex: 0x1F76FF)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 34, height: 34)

            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.38), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 34, height: 34)

            HStack(spacing: 13) {
                Capsule().fill(.white.opacity(0.95)).frame(width: 4, height: 8)
                Capsule().fill(.white.opacity(0.95)).frame(width: 4, height: 8)
            }
            .offset(y: -17)

            CheckmarkShape()
                .stroke(.white, style: StrokeStyle(lineWidth: 3.4, lineCap: .round, lineJoin: .round))
                .frame(width: 15, height: 11)
                .offset(y: 2)
        }
        .frame(width: 36, height: 38)
        .shadow(color: Color(hex: 0x1F76FF).opacity(0.30), radius: 5, y: 3)
    }
}

private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.04, y: rect.minY + rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.minY + rect.height * 0.94))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.98, y: rect.minY + rect.height * 0.08))
        return path
    }
}

/// 橙色转盘 + 中间白色圆盘和 ¥
struct LuckyWheelGlyph: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color(hex: 0xFFD27A), Color(hex: 0xFF9D2E), Color(hex: 0xFF7A18),
                            Color(hex: 0xFFB84A), Color(hex: 0xFFD27A),
                        ],
                        center: .center
                    )
                )

            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(0.38))
                    .frame(width: 10, height: 13)
                    .offset(y: -9)
                    .rotationEffect(.degrees(Double(index) * 90))
            }

            Circle()
                .fill(.white.opacity(0.96))
                .frame(width: 13, height: 13)
                .shadow(color: .black.opacity(0.08), radius: 1, y: 1)

            Text("¥")
                .font(.system(size: 8, weight: .black))
                .foregroundStyle(Color(hex: 0xFF8A1F))
        }
        .frame(width: 34, height: 34)
        .shadow(color: Color(hex: 0xFF8A1F).opacity(0.30), radius: 5, y: 3)
    }
}

/// 紫色像素小虫
struct BugQuestGlyph: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xC6A6FF), Color(hex: 0x8446FF)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 30, height: 25)
                .overlay(alignment: .top) {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 1).fill(.white.opacity(0.95)).frame(width: 4, height: 4)
                        RoundedRectangle(cornerRadius: 1).fill(.white.opacity(0.95)).frame(width: 4, height: 4)
                    }
                    .padding(.top, 7)
                }

            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 1.5).fill(Color(hex: 0x7A3BF0)).frame(width: 4, height: 5)
                RoundedRectangle(cornerRadius: 1.5).fill(Color(hex: 0x7A3BF0)).frame(width: 4, height: 5)
            }
        }
        .frame(width: 36, height: 34)
        .shadow(color: Color(hex: 0x7C3AED).opacity(0.28), radius: 5, y: 3)
    }
}

/// 红色礼盒：两层盒子 + 蝴蝶结 + 白色横条
struct GiftGlyph: View {
    private let red = Color(hex: 0xFF5A5F)
    private let deepRed = Color(hex: 0xE63A46)

    var body: some View {
        ZStack {
            HStack(spacing: 1) {
                Capsule().fill(red).frame(width: 11, height: 7).rotationEffect(.degrees(-28))
                Capsule().fill(red).frame(width: 11, height: 7).rotationEffect(.degrees(28))
            }
            .offset(y: -12)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [red, deepRed],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 28, height: 18)
                .offset(y: 7)

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xFF8386), red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 34, height: 9)
                .offset(y: -3)

            Capsule()
                .fill(.white.opacity(0.95))
                .frame(width: 10, height: 3)
                .offset(y: -3)
        }
        .frame(width: 36, height: 36)
        .shadow(color: red.opacity(0.30), radius: 5, y: 3)
    }
}

#Preview {
    ProfileQuickActions(checkInDays: 1)
        .padding()
        .background(Theme.pageBG)
}
