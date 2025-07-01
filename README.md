# SwiftUIMasonryLayouts

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018%2B%20%7C%20macOS%2015%2B%20%7C%20tvOS%2018%2B%20%7C%20watchOS%2011%2B%20%7C%20visionOS%202%2B-blue.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

现代化的 SwiftUI 瀑布流布局库，基于 iOS 18.0+ Layout 协议构建，提供高性能、灵活的瀑布流布局解决方案。

## ✨ 特性

- 🚀 **高性能**: 基于原生 Layout 协议，智能缓存机制
- 📱 **多平台支持**: iOS、macOS、tvOS、watchOS、visionOS 全平台兼容
- 🔄 **双轴布局**: 支持垂直和水平瀑布流布局
- 📐 **响应式设计**: 内置断点系统，根据屏幕尺寸自动调整布局
- 🔄 **懒加载渲染**: 只渲染可见区域，大幅减少内存占用
- 🔌 **智能回调机制**: 可视范围变化、到达顶部/底部回调
- 🛡️ **类型安全**: 完全的 Swift 类型安全和泛型支持
- 🎨 **SwiftUI 原生**: 完全基于 SwiftUI，无需额外依赖

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
    .package(url: "https://github.com/beyoug/SwiftUIMasonryLayouts.git", from: "1.0.0")
]
```

## 🚀 快速开始

### 基础导入

```swift
import SwiftUI
import SwiftUIMasonryLayouts
```

### 1. 普通瀑布流创建

适用于静态内容和简单布局场景：

```swift
struct BasicMasonryExample: View {
    let items = Array(1...20)

    var body: some View {
        ScrollView {
            MasonryView(
                axis: .vertical,
                lines: .fixed(2),
                hSpacing: 8,
                vSpacing: 8
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

### 2. 懒加载瀑布流创建

推荐用于大数据集和高性能场景：

```swift
struct LazyMasonryExample: View {
    @State private var photos = PhotoItem.sampleData

    var body: some View {
        LazyMasonryView(
            photos,
            configuration: .columns(2)
        ) { photo in
            AsyncImage(url: photo.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
            .clipped()
            .cornerRadius(8)
        }
        .onReachBottom {
            // 加载更多数据
            Task { await loadMorePhotos() }
        }
        .padding()
    }

    private func loadMorePhotos() async {
        // 实现加载更多逻辑
    }
}
```

## 📚 更多示例

更多使用示例请参阅：

- **[分页加载演示](Sources/SwiftUIMasonryLayouts/Examples/PaginationDemoExample.swift)** - 完整的分页加载示例，包含500条测试数据



## 🤝 贡献

欢迎贡献代码！部分代码由AI完成，可能存在并未覆盖到的特殊场景，如有任何问题欢迎pr。

## 📄 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

## 👨‍💻 作者

**Beyoug** - [GitHub](https://github.com/beyoug)

## 🌟 致谢

## 📚 示例画廊

库中包含了完整的示例画廊，展示各种功能和使用场景：

```swift
import SwiftUIMasonryLayouts

// 在您的应用中使用示例画廊
ExampleGallery()
```

示例包括：
- **回调机制演示** - 展示可视范围变化、到达顶部/底部回调
- **真实刷新场景** - 演示正确的下拉刷新和分页加载
- **调试示例** - 用于调试和测试的各种布局配置
- **业务集成示例** - 实际业务场景的完整实现

## 🙏 致谢

特别感谢：
- **SwiftUI 团队** - 提供强大的 Layout 协议基础
- **Augment Code** - 提供 Claude Sonnet 4 AI 助手协助开发和文档编写
- **开源社区** - 提供灵感和反馈

---

**SwiftUIMasonryLayouts** - 让瀑布流布局变得简单而强大 🚀
