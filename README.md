# SwiftUIMasonryLayouts

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018%2B%20%7C%20macOS%2015%2B%20%7C%20tvOS%2018%2B%20%7C%20watchOS%2011%2B%20%7C%20visionOS%202%2B-blue.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

现代化的 SwiftUI 瀑布流布局库，基于 iOS 18.0+ Layout 协议构建，提供高性能、灵活的瀑布流布局解决方案。

## ✨ 特性

- 🚀 **高性能**: 基于原生 Layout 协议，提供最佳性能和缓存机制
- 📱 **多平台支持**: iOS、macOS、tvOS、watchOS、visionOS 全平台兼容
- 🎯 **灵活配置**: 支持固定列数和自适应列数，可配置间距和放置模式
- 🔄 **双轴布局**: 支持垂直和水平瀑布流布局
- 📐 **响应式设计**: 内置断点系统，根据屏幕尺寸自动调整布局
- 🎨 **简洁 API**: 统一的 MasonryView 组件，易于使用和集成
- ⚡ **类型安全**: 基于 Swift 6.0，支持 Sendable 协议，线程安全

## 📋 系统要求

- iOS 18.0+ / macOS 15.0+ / tvOS 18.0+ / watchOS 11.0+ / visionOS 2.0+
- Swift 6.0+
- Xcode 16.0+

## 📦 安装

### Swift Package Manager

在 Xcode 中添加包依赖：

```
https://github.com/beyoug/SwiftUIMasonryLayouts.git
```

或在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/beyoug/SwiftUIMasonryLayouts.git", branch: "main")
]
```

## 🚀 快速开始

### 基础导入

```swift
import SwiftUI
import SwiftUIMasonryLayouts
```

### 最简单的瀑布流

```swift
struct ContentView: View {
    let items = Array(1...20)

    var body: some View {
        ScrollView {
            MasonryView(
                axis: .vertical,
                lines: .fixed(2),
                horizontalSpacing: 8,
                verticalSpacing: 8,
                placementMode: .fill
            ) {
                ForEach(items, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.7))
                        .frame(height: CGFloat.random(in: 100...300))
                        .overlay(Text("\(item)").foregroundColor(.white))
                }
            }
            .padding()
        }
    }
}
```

## 📚 核心组件

### MasonryView - 统一的瀑布流视图

`MasonryView` 是库中唯一的公共视图组件，通过不同的初始化方式支持各种布局需求：

#### 1. 基础瀑布流
```swift
MasonryView(
    axis: .vertical,              // 布局轴向：垂直或水平
    lines: .fixed(2),             // 列数：固定2列
    horizontalSpacing: 8,         // 水平间距
    verticalSpacing: 8,           // 垂直间距
    placementMode: .fill          // 放置模式：智能填充或顺序放置
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

#### 2. 响应式瀑布流
```swift
MasonryView(breakpoints: MasonryConfiguration.commonBreakpoints) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

## 📚 详细使用指南

### 1. 布局轴向配置

#### 垂直瀑布流（默认）
```swift
// 垂直双列布局
MasonryView(
    axis: .vertical,
    lines: .fixed(2)
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// 自适应列数（根据屏幕宽度自动调整）
MasonryView(
    axis: .vertical,
    lines: .adaptive(minSize: 120)
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

#### 水平瀑布流
```swift
ScrollView(.horizontal) {
    MasonryView(
        axis: .horizontal,
        lines: .fixed(3)
    ) {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }
    .padding()
}
```

### 2. 行列数配置

#### 固定数量
```swift
MasonryView(lines: .fixed(2)) { ... }    // 固定2列/行
MasonryView(lines: .fixed(3)) { ... }    // 固定3列/行
```

#### 自适应数量
```swift
// 最小尺寸约束：每列/行至少120pt宽/高
MasonryView(lines: .adaptive(minSize: 120)) { ... }

// 最大尺寸约束：每列/行最多200pt宽/高
MasonryView(lines: .adaptive(maxSize: 200)) { ... }
```

### 3. 放置模式

#### Fill 模式（推荐）
```swift
MasonryView(placementMode: .fill) {
    // 智能填充到当前最短的列/行
    // 视觉效果更平衡，空间利用率高
}
```

#### Order 模式
```swift
MasonryView(placementMode: .order) {
    // 按顺序循环放置到各列/行
    // 保持元素的逻辑顺序
}
```

### 4. 响应式布局

#### 使用预设断点
```swift
MasonryView(breakpoints: MasonryConfiguration.commonBreakpoints) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

#### 自定义断点
```swift
let customBreakpoints: [CGFloat: MasonryConfiguration] = [
    0: .singleColumn,      // 0-479pt: 单列
    480: .twoColumns,      // 480-767pt: 双列
    768: .threeColumns,    // 768-1023pt: 三列
    1024: .fourColumns     // 1024pt+: 四列
]

MasonryView(breakpoints: customBreakpoints) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

### 5. 预设配置

#### 垂直布局预设
```swift
MasonryConfiguration.singleColumn    // 单列
MasonryConfiguration.twoColumns      // 双列
MasonryConfiguration.threeColumns    // 三列
MasonryConfiguration.fourColumns     // 四列
MasonryConfiguration.adaptiveColumns // 自适应（最小120pt）
```

#### 水平布局预设
```swift
MasonryConfiguration.singleRow       // 单行
MasonryConfiguration.twoRows         // 双行
MasonryConfiguration.threeRows       // 三行
```

#### 使用预设配置
```swift
let config = MasonryConfiguration.threeColumns
    .withSpacing(horizontal: 12, vertical: 16)
    .withPlacementMode(.order)

MasonryView(
    axis: config.axis,
    lines: config.lines,
    horizontalSpacing: config.horizontalSpacing,
    verticalSpacing: config.verticalSpacing,
    placementMode: config.placementMode
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

## 🔧 预览和调试

项目包含了完整的预览文件，帮助您快速测试和理解不同配置：

- **QuickMasonryPreview**: 日常开发使用的快速预览
- **ComprehensiveMasonryPreview**: 涵盖所有配置组合的全面测试

在 Xcode 中打开 `/SwiftUIMasonryLayouts/Sources/Previews/` 文件夹查看这些预览。


## 📄 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

## 👨‍💻 作者

**Beyoug** - [GitHub](https://github.com/beyoug)

## 🌟 致谢

特别感谢：
- **SwiftUI 团队** - 提供强大的 Layout 协议基础
- **Augment Code** - 提供 Claude Sonnet 4 AI 助手协助开发和文档编写
- **开源社区** - 提供灵感和反馈
