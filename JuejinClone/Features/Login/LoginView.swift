//
//  LoginView.swift
//  手机号登录页：样式对齐参考图（logo + 标题、+86 手机号、获取验证码、
//  协议勾选、底部第三方登录）。
//

import Foundation
import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthStore

    /// 由导航方传入，保证能可靠地关掉登录页
    var onBack: (() -> Void)?

    @State private var countryCode = "+86"
    @State private var phone = ""
    @State private var code = ""
    @State private var agreed = false
    @State private var alertMessage: String?
    @State private var isSending = false
    @State private var isLoggingIn = false
    @State private var cooldown = 0

    private let countryCodes = ["+86", "+852", "+853", "+886", "+1"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton

            header
                .padding(.top, 42)
                .padding(.horizontal, 28)

            phoneEntry
                .padding(.top, 88)
                .padding(.horizontal, 28)

            sendCodeButton
                .padding(.top, 24)
                .padding(.horizontal, 28)

            codeEntry
                .padding(.top, 16)
                .padding(.horizontal, 28)

            if AppEnvironment.isDev {
                Text("开发环境：验证码请查看服务器 app 容器日志")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, 8)
                    .padding(.horizontal, 28)
            }

            agreementRow
                .padding(.top, 14)
                .padding(.horizontal, 28)

            loginButton
                .padding(.top, 16)
                .padding(.horizontal, 28)

            Spacer(minLength: 24)

            socialRow
                .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        // 白色铺满整屏，包括状态栏和 Home Indicator 区域
        .background(Color.white.ignoresSafeArea())
        .alert("提示", isPresented: alertBinding) {
            Button("好", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    // MARK: - 顶部

    private var backButton: some View {
        Button {
            if let onBack {
                onBack()
            } else {
                dismiss()
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(Color(hex: 0x1D2129))
                .frame(width: 44, height: 44, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.leading, 14)
        .padding(.top, 2)
        .accessibilityLabel("返回")
    }

    private var header: some View {
        HStack(spacing: 12) {
            JuejinLogoMark()
                .frame(width: 38, height: 38)

            Text("登录体验更多精彩")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(hex: 0x1D2129))
        }
    }

    // MARK: - 手机号

    private var phoneEntry: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Menu {
                    ForEach(countryCodes, id: \.self) { code in
                        Button(code) { countryCode = code }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(countryCode)
                            .font(.system(size: 18))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(Color(hex: 0x1D2129))
                }

                ZStack(alignment: .leading) {
                    if phone.isEmpty {
                        Text("请输入手机号")
                            .font(.system(size: 20))
                            .foregroundStyle(Theme.textSecondary.opacity(0.55))
                    }

                    TextField("", text: $phone)
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: 0x1D2129))
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                        .tint(Theme.brand)
                        .onChange(of: phone) { _, newValue in
                            let formatted = Self.formatPhone(newValue)
                            if formatted != newValue { phone = formatted }
                        }
                }
            }

            Rectangle()
                .fill(Theme.divider)
                .frame(height: 0.5)
        }
    }

    private var sendCodeButton: some View {
        Button {
            sendCode()
        } label: {
            Text(sendCodeTitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(sendCodeBackground,
                            in: RoundedRectangle(cornerRadius: 4, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isSending || cooldown > 0)
        .opacity(isSending ? 0.7 : 1)
    }

    private var sendCodeTitle: String {
        if cooldown > 0 { return "\(cooldown) 秒后重新获取" }
        return isSending ? "发送中…" : "获取短信验证码"
    }

    private var sendCodeBackground: Color {
        cooldown > 0 ? Theme.textSecondary : Theme.brand
    }

    private var codeEntry: some View {
        HStack(spacing: 12) {
            Text("验证码")
                .font(.system(size: 15))
                .foregroundStyle(Theme.textSecondary)

            TextField("请输入 6 位验证码", text: $code)
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: 0x1D2129))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .tint(Theme.brand)
                .onChange(of: code) { _, newValue in
                    let digits = String(newValue.filter(\.isNumber).prefix(6))
                    if digits != newValue { code = digits }
                }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Color(hex: 0xF5F6F7),
                    in: RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    private var loginButton: some View {
        Button {
            login()
        } label: {
            HStack(spacing: 8) {
                if isLoggingIn {
                    ProgressView().tint(.white)
                }
                Text(isLoggingIn ? "登录中…" : "登录 / 注册")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Theme.brand,
                        in: RoundedRectangle(cornerRadius: 4, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isLoggingIn)
        .opacity(isLoggingIn ? 0.7 : 1)
    }

    // MARK: - 协议

    private var agreementRow: some View {
        HStack(spacing: 8) {
            Button {
                agreed.toggle()
            } label: {
                ZStack {
                    if agreed {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Theme.brand)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(Color(hex: 0xD0D3D9), lineWidth: 1)
                    }
                }
                .frame(width: 18, height: 18)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("同意用户协议和隐私政策")
            .accessibilityAddTraits(agreed ? .isSelected : [])

            Text("已阅读并同意“用户协议”和“隐私政策”")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: - 第三方登录

    private var socialRow: some View {
        HStack(spacing: 22) {
            socialButton(accessibilityLabel: "微信登录") {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 23))
                    .foregroundStyle(Color(hex: 0x07C160))
            }

            socialButton(accessibilityLabel: "Apple 登录") {
                Image(systemName: "apple.logo")
                    .font(.system(size: 23))
                    .foregroundStyle(.black)
            }

            socialButton(accessibilityLabel: "账号密码登录") {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x5D5675))
                        .frame(width: 30, height: 30)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }

            socialButton(accessibilityLabel: "GitHub 登录") {
                GitHubMark()
                    .fill(.black)
                    .frame(width: 26, height: 26)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func socialButton<Content: View>(
        accessibilityLabel: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Button {
            alertMessage = "\(accessibilityLabel)暂未接入"
        } label: {
            content()
                .frame(width: 42, height: 42)
                .background(Circle().fill(Color.white))
                .overlay(Circle().stroke(Color(hex: 0xE5E6EB), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - 交互

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )
    }

    private var phoneDigits: String {
        phone.filter(\.isNumber)
    }

    private func sendCode() {
        guard validatePhoneAndAgreement() else { return }

        isSending = true
        Task { @MainActor in
            defer { isSending = false }
            do {
                let response = try await auth.sendSMSCode(phone: phoneDigits)
                if let debugCode = response.debugCode, !debugCode.isEmpty {
                    code = debugCode
                    alertMessage = "测试环境验证码已自动填入：\(debugCode)"
                } else if AppEnvironment.isDev {
                    alertMessage = "验证码已发送（mock）。请到服务器 app 日志查看验证码。"
                } else {
                    alertMessage = "验证码已发送，请查收短信"
                }
                startCooldown(seconds: response.retryAfter)
            } catch {
                alertMessage = error.localizedDescription
            }
        }
    }

    private func login() {
        guard validatePhoneAndAgreement() else { return }
        guard code.count == 6 else {
            alertMessage = "请输入 6 位验证码"
            return
        }

        isLoggingIn = true
        Task { @MainActor in
            defer { isLoggingIn = false }
            do {
                _ = try await auth.login(phone: phoneDigits, code: code)
                if let onBack {
                    onBack()
                } else {
                    dismiss()
                }
            } catch {
                alertMessage = error.localizedDescription
            }
        }
    }

    private func validatePhoneAndAgreement() -> Bool {
        guard countryCode == "+86" else {
            alertMessage = "当前仅支持中国大陆手机号（+86）"
            return false
        }
        guard phoneDigits.range(of: "^1[3-9]\\d{9}$", options: .regularExpression) != nil else {
            alertMessage = "请输入正确的 11 位手机号"
            return false
        }
        guard agreed else {
            alertMessage = "请先阅读并同意用户协议和隐私政策"
            return false
        }
        return true
    }

    private func startCooldown(seconds: Int) {
        cooldown = max(0, seconds)
        Task { @MainActor in
            while cooldown > 0 {
                try? await Task.sleep(for: .seconds(1))
                cooldown -= 1
            }
        }
    }

    private static func formatPhone(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber).prefix(11)
        var result = ""
        for (index, digit) in digits.enumerated() {
            if index == 3 || index == 7 { result.append(" ") }
            result.append(digit)
        }
        return result
    }
}

// MARK: - 掘金 Logo

/// 掘金 logo：蓝色圆角方块 + 三层向下箭头。
private struct JuejinLogoMark: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Theme.brand)
            .overlay {
                JuejinLogoGlyph()
                    .fill(.white)
                    .padding(9)
            }
            .accessibilityHidden(true)
    }
}

private struct JuejinLogoGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // 三层 V 形箭头，从窄到宽
        chevron(in: rect,
                top: 0.16, width: 0.26, height: 0.18,
                thickness: 0.10, into: &path)
        chevron(in: rect,
                top: 0.38, width: 0.48, height: 0.20,
                thickness: 0.10, into: &path)
        chevron(in: rect,
                top: 0.60, width: 0.70, height: 0.24,
                thickness: 0.10, into: &path)

        return path
    }

    private func chevron(
        in rect: CGRect,
        top: CGFloat,
        width: CGFloat,
        height: CGFloat,
        thickness: CGFloat,
        into path: inout Path
    ) {
        let w = width * rect.width
        let h = height * rect.height
        let t = thickness * rect.height
        let cx = rect.midX
        let topY = rect.minY + top * rect.height
        let tipY = topY + h
        let left = cx - w / 2
        let right = cx + w / 2
        let inset = w * 0.16

        path.move(to: CGPoint(x: left, y: topY))
        path.addLine(to: CGPoint(x: cx, y: tipY))
        path.addLine(to: CGPoint(x: right, y: topY))
        path.addLine(to: CGPoint(x: right - inset, y: topY))
        path.addLine(to: CGPoint(x: cx, y: tipY - t))
        path.addLine(to: CGPoint(x: left + inset, y: topY))
        path.closeSubpath()
    }
}

// MARK: - GitHub mark

private struct GitHubMark: Shape {
    /// GitHub 官方 mark，24×24 视口
    private static let d = "M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"

    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 24
        return SVGPath.parse(Self.d)
            .applying(CGAffineTransform(scaleX: scale, y: scale))
            .offsetBy(dx: rect.minX, dy: rect.minY)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthStore())
}
