//
//  TabBarWhiteBackground.swift
//
//  iOS 26 的原生 TabView 底栏是 Liquid Glass，SwiftUI 没有提供改背景色的
//  接口（toolbarBackground / UITabBar.appearance() 对这条新栏都不生效）。
//  这里找到底层的 UITabBar，把它配置成不透明白底：
//    - 图标、选中胶囊、点击时的切换动画仍然由系统原生绘制
//    - 只是把玻璃下面的内容挡住，让整条栏显示为白色
//
//  这是公开 API（UITabBarAppearance / isTranslucent），没有用私有类名。
//

import SwiftUI
import UIKit

struct TabBarWhiteBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = TabBarConfiguratorView()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private final class TabBarConfiguratorView: UIView {
    private var didConfigure = false

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil, !didConfigure else { return }
        configure(attempt: 0)
    }

    /// SwiftUI 会在启动的头几帧里创建或刷新 UITabBar，
    /// 所以没找到时短暂重试；找到后只配置一次。
    private func configure(attempt: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            guard let window = self.window, let tabBar = Self.findTabBar(in: window) else {
                if attempt < 20 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.configure(attempt: attempt + 1)
                    }
                }
                return
            }

            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear

            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
            tabBar.isTranslucent = false

            // UITabBarAppearance 只会让中间的玻璃平台变白，栏的左右外边距
            // 和 Home Indicator 区域仍然透出下面的内容。垫一层铺满 UITabBar
            // 的白底，让整条栏是通栏白色。
            let whiteView = UIView()
            whiteView.backgroundColor = .white
            whiteView.frame = tabBar.bounds
            whiteView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            whiteView.isUserInteractionEnabled = false
            tabBar.insertSubview(whiteView, at: 0)

            self.didConfigure = true
        }
    }

    private static func findTabBar(in view: UIView) -> UITabBar? {
        if let tabBar = view as? UITabBar { return tabBar }
        for subview in view.subviews {
            if let found = findTabBar(in: subview) { return found }
        }
        return nil
    }
}
