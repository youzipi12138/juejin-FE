# JuejinClone

SwiftUI 写的掘金客户端克隆。最低支持 iOS 18.0。

## 目录结构

```
Configs/                       构建期配置（在同步组之外，不会被塞进 Resources）
  Base.xcconfig                公共设置；INFOPLIST_FILE 指向同目录的 Info.plist
  Debug.xcconfig               dev 环境，#include Base，使用 Info-Debug.plist
  Release.xcconfig             prod 环境，#include Base
  Info.plist                   Release 的 API_BASE_URL / ENV_NAME / ATS
  Info-Debug.plist             dev 的 ATS（允许公网 HTTP IP）

JuejinClone.xcodeproj

JuejinClone/                   源码（PBXFileSystemSynchronizedRootGroup）
  App/                         入口
  Navigation/                  底部 tab：AppTab / MainTabView / CustomCapsuleTabBar
  Features/                    按页面分
    Home/                      首页（TopBar / 分类栏 / 热榜 / 文章流 / FeedStore）
    Profile/                   我（资料头 / 数据 / 快捷入口 / 创作者中心 / 常用功能）
    Placeholder/               沸点、发现、课程 3 个 tab 的占位
  Core/
    Config/AppEnvironment      全 App 唯一的配置读取入口
    Networking/                APIClient / APIError / FeedService / AuthService
    Session/                   AuthStore（登录态 + token 持久化）
    DesignSystem/              Theme、Color+Hex
  Components/                  跨页面复用：Icons（Lucide 渲染器）、Avatar、MetaLabel
  Models/                      数据模型 + SampleData
  Resources/Assets.xcassets
```

## 切换 dev / prod 后端

后端地址的唯一来源是 `Configs/Debug.xcconfig`（dev）和 `Configs/Release.xcconfig`（prod）：

```
API_BASE_URL = http:/$()/49.233.89.175
```

dev 后端是公网 HTTP IP，Debug 配置使用 `Configs/Info-Debug.plist` 放宽 ATS；
Release 继续使用 `Configs/Info.plist`，不要把 `NSAllowsArbitraryLoads` 带进发布构建。

改完 **Clean Build Folder** 一次（`⇧⌘K`），然后：

```bash
xcodebuild -project JuejinClone.xcodeproj -scheme JuejinClone \
  -configuration Debug -showBuildSettings | grep API_BASE_URL
```

⚠️ **`//` 必须写成 `/$()/`**。xcconfig 里 `//` 是行注释开头，直接写
`http://49.233.89.175` 会被**静默截断成 `http:`**，不报错，只在运行时表现为请求全挂。

链路：`xcconfig` → 构建期替换 `Info.plist` 里的 `$(API_BASE_URL)` → `AppEnvironment` 读出来 →
`APIClient` 用它拼 URL。配置错配会在启动时 `preconditionFailure` 当场炸，不会静默回落。

Debug 构建下首页顶栏有个橙色/绿色角标显示当前环境（`DEV` / `PROD`）。

## 手机号验证码登录（已接入 dev 后端）

已接入：

- `POST /api/auth/sms/send`
- `POST /api/auth/sms/login`（未注册手机号自动注册）
- `GET /api/auth/me`
- `POST /api/auth/logout`

登录态在 `AuthStore`，token 暂存 `UserDefaults`（上线前建议换 Keychain）。
登录后首页卡片和个人页会显示后端返回的昵称；未登录仍回落到 `SampleData.profile`。

dev 后端短信仍是 mock，且出于安全考虑验证码**不会**通过接口返回。
在登录页点「获取短信验证码」后，到服务器 app 日志里取验证码：

```bash
ssh -i ~/.ssh/juejin_github_actions ubuntu@49.233.89.175 \
  "docker compose -f /opt/juejin/compose.yml logs --tail=200 app | grep 模拟短信 | tail -1"
```

如果后端本地启动并开启 `SMS_EXPOSE_CODE=true`，`debugCode` 会自动填入验证码输入框。

### 联调启动参数（仅 Debug）

```bash
# 直接打开登录页
xcrun simctl launch booted com.pengchen.JuejinClone -OpenLogin YES

# 自动用手机号 + 验证码登录（验证码从服务器日志取）
xcrun simctl launch booted com.pengchen.JuejinClone \
  -DevLoginPhone 13900139001 -DevLoginCode 123456
```

这些参数只在 `#if DEBUG` 下生效，不会影响 Release。

### 构建

```bash
xcodebuild -project JuejinClone.xcodeproj -scheme JuejinClone \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -derivedDataPath /tmp/JuejinCloneDerived build CODE_SIGNING_ALLOWED=NO
```

首页文章流接口 `/api/v1/feed/*` 后端尚未实现，仍然使用 `SampleData` 回落。

## 个人页

「我」tab 已接入登录态：登录后显示后端 `nickname`，未登录回落到 `SampleData.profile`。
底部新增「退出登录」（登录后可见），调用 `/api/auth/logout` 并清理本地 token。
入口都做成了 Button，点下去先弹一条「还没做」的提示，避免看起来像坏了。
头像是从设计稿里裁出来的 `ProfileAvatar` imageset，接真实用户时换成服务端图片即可。

联调时可以直接落到某个 tab（只作用于本次启动，不写 UserDefaults）：

```bash
xcrun simctl launch booted com.pengchen.JuejinClone -InitialTab profile
```

## 底栏为什么分两条分支

iOS 26 的 Liquid Glass 是**系统 chrome** 的一部分——只有用系统的 `TabView` 才会自动获得。
自绘的 `HStack` 不管怎么调材质都拿不到那层折射和触摸反馈。所以：

- **iOS 26+**：`TabView` + `Tab`，标签栏是系统 Liquid Glass，白捡。
  配 `.tabBarMinimizeBehavior(.onScrollDown)` 滚动时自动收起。
- **iOS 18–25**：自绘悬浮胶囊 `CustomCapsuleTabBar`，用 `.ultraThinMaterial` 做毛玻璃
  （那一版上能拿到的最好效果）。

代价：两套底栏的图标不一样。原生 `Tab` 只吃 `Image`，塞不进 Lucide 的自绘 `Shape`，
所以 26 用 SF Symbols、18 用 Lucide。

本机只装了 iOS 26.5 模拟器，正常情况下永远走原生分支。要看 18 那条：

```bash
xcrun simctl launch booted com.pengchen.JuejinClone -ForceLegacyTabBar YES
```
