//
//  Avatar.swift
//

import SwiftUI

/// 没有真实头像，用昵称首字生成一个稳定的色块占位
struct Avatar: View {
    let name: String
    var size: CGFloat = 22

    private static let palette: [Color] = [
        Color(hex: 0x5B8FF9), Color(hex: 0x61DDAA), Color(hex: 0xF6BD16),
        Color(hex: 0x7262FD), Color(hex: 0x78D3F8), Color(hex: 0x9661BC),
    ]

    // 不用 hashValue：Swift 的哈希每次进程启动都会变，头像颜色会跟着跳
    private var seed: Int {
        name.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
    }

    var body: some View {
        Circle()
            .fill(Self.palette[seed % Self.palette.count])
            .frame(width: size, height: size)
            .overlay(
                Text(String(name.prefix(1)))
                    .font(.system(size: size * 0.5, weight: .medium))
                    .foregroundStyle(.white)
            )
    }
}
