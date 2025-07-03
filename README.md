# SwiftUIMasonryLayouts

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018%2B%20%7C%20macOS%2015%2B%20%7C%20tvOS%2018%2B%20%7C%20watchOS%2011%2B%20%7C%20visionOS%202%2B-blue.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

现代化的 SwiftUI 瀑布流布局库，基于 iOS 18.0+ Layout 协议构建，提供高性能、灵活的瀑布流布局解决方案。

## ✨ 核心特性

### 🚀 高性能架构
- **原生 Layout 协议** - 基于 SwiftUI Layout 协议，获得最佳性能
- **智能缓存系统** - 自动缓存布局计算结果，避免重复计算
- **懒加载渲染** - 只渲染可见区域，大幅减少内存占用
- **优化的滚动性能** - 流畅的滚动体验，无卡顿

### 📱 全平台支持
- **iOS 18.0+** - 完整功能支持
- **macOS 15.0+** - 原生 macOS 体验
- **tvOS 18.0+** - 适配大屏幕交互
- **watchOS 11.0+** - 优化小屏幕显示
- **visionOS 2.0+** - 支持空间计算

### 🎨 灵活布局
- **双轴布局** - 支持垂直和水平瀑布流
- **响应式设计** - 内置断点系统，自动适配不同屏幕尺寸
- **自适应列数** - 根据内容宽度自动调整列数
- **智能间距** - 自动计算最佳间距

### 🔌 智能交互
- **滚动回调** - 到达顶部/底部时的智能回调
- **分页加载** - 内置分页加载机制，支持无限滚动
- **可配置触发** - 灵活的触发阈值配置
- **防抖机制** - 避免频繁触发，优化性能

## 📋 系统要求

- **iOS 18.0+** / **macOS 15.0+** / **tvOS 18.0+** / **watchOS 11.0+** / **visionOS 2.0+**
- **Swift 6.0+**
- **Xcode 16.0+**

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

### 导入库

```swift
import SwiftUIMasonryLayouts
```

### 基础用法

#### 1. 简单瀑布流

```swift
import SwiftUI
import SwiftUIMasonryLayouts

struct ContentView: View {
    let items = Array(1...20)

    var body: some View {
        ScrollView {
            MasonryStack(columns: 2, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.3))
                        .frame(height: CGFloat.random(in: 100...200))
                        .overlay(Text("\(item)"))
                }
            }
            .padding()
        }
    }
}
```

#### 2. 懒加载瀑布流（推荐）

```swift
struct LazyContentView: View {
    @StateObject private var dataLoader = DataLoader()

    var body: some View {
        LazyMasonryStack(
            dataLoader.items,
            columns: 2,
            spacing: 8
        ) { item in
            ItemView(item: item)
        }
        .onReachBottom {
            dataLoader.loadNextPage()
        }
        .onAppear {
            dataLoader.loadInitialData()
        }
    }
}
```

#### 3. 水平瀑布流

```swift
struct HorizontalMasonryView: View {
    let items = Array(1...20)

    var body: some View {
        ScrollView(.horizontal) {
            MasonryStack(rows: 3, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.3))
                        .frame(width: CGFloat.random(in: 100...200))
                        .overlay(Text("\(item)"))
                }
            }
            .padding()
        }
    }
}
```

#### 4. 响应式布局

```swift
struct ResponsiveMasonryView: View {
    let items = Array(1...50)

    var body: some View {
        ScrollView {
            MasonryStack(
                phoneColumns: 2,
                tabletColumns: 4,
                spacing: 8
            ) {
                ForEach(items, id: \.self) { item in
                    ItemView(item: item)
                }
            }
            .padding()
        }
    }
}
```

#### 5. 自适应列数

```swift
struct AdaptiveMasonryView: View {
    let items = Array(1...30)

    var body: some View {
        ScrollView {
            MasonryStack(adaptiveColumns: 150, spacing: 12) {
                ForEach(items, id: \.self) { item in
                    ItemView(item: item)
                }
            }
            .padding()
        }
    }
}
```

## ⚙️ 高级配置

### 配置对象

使用 `MasonryConfiguration` 进行详细配置：

```swift
struct AdvancedMasonryView: View {
    let items = Array(1...100)

    var body: some View {
        LazyMasonryStack(
            items,
            configuration: MasonryConfiguration(
                axis: .vertical,
                lines: .adaptive(minSize: 120),
                hSpacing: 12,
                vSpacing: 16,
                placement: .fill,
                bottomTriggerThreshold: 0.7,  // 滚动到70%时触发
                topTriggerThreshold: 50,      // 距离顶部50px时触发
                debounceInterval: 0.5         // 0.5秒防抖
            )
        ) { item in
            ItemView(item: item)
        }
        .onReachBottom {
            loadMoreData()
        }
        .onReachTop {
            refreshData()
        }
    }
}
```

### 预设配置

库提供了多种预设配置：

```swift
// 默认配置
LazyMasonryStack(items, configuration: .default) { item in
    ItemView(item: item)
}

// 自适应列配置
LazyMasonryStack(items, configuration: .adaptiveColumns) { item in
    ItemView(item: item)
}

// 早期触发配置（50%触发）
LazyMasonryStack(items, configuration: .earlyTrigger) { item in
    ItemView(item: item)
}

// 快速响应配置（0.5秒防抖）
LazyMasonryStack(items, configuration: .fastResponse) { item in
    ItemView(item: item)
}
```

### 自定义断点

创建响应式布局：

```swift
struct ResponsiveBreakpointsView: View {
    let items = Array(1...100)

    var body: some View {
        ScrollView {
            MasonryStack(
                breakpoints: [
                    0: .columns(1),      // 小屏幕：1列
                    480: .columns(2),    // 中屏幕：2列
                    768: .columns(3),    // 大屏幕：3列
                    1024: .columns(4)    // 超大屏幕：4列
                ]
            ) {
                ForEach(items, id: \.self) { item in
                    ItemView(item: item)
                }
            }
            .padding()
        }
    }
}
```

## 📊 性能优化

### 缓存机制

库内置智能缓存系统，自动优化性能：

- **布局缓存** - 缓存布局计算结果
- **尺寸缓存** - 缓存子视图尺寸
- **配置缓存** - 缓存配置哈希值
- **智能失效** - 配置变化时自动清除缓存

### 最佳实践

1. **使用 LazyMasonryStack** - 对于大量数据，优先使用懒加载版本
2. **合理设置触发阈值** - 根据网络状况调整 `bottomTriggerThreshold`
3. **适当的防抖间隔** - 避免频繁触发，建议 0.5-2.0 秒
4. **预设配置** - 使用预设配置可获得更好的性能

```swift
// ✅ 推荐：使用懒加载和预设配置
LazyMasonryStack(items, configuration: .fastResponse) { item in
    ItemView(item: item)
}

// ❌ 不推荐：频繁的自定义配置
LazyMasonryStack(items, configuration: MasonryConfiguration(
    debounceInterval: 0.1  // 过短的防抖间隔
)) { item in
    ItemView(item: item)
}
```

## 📚 API 文档

### MasonryStack

基础瀑布流视图，适用于静态内容：

```swift
public struct MasonryStack<Content: View>: View {
    // 基础初始化
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        hSpacing: CGFloat = 8,
        vSpacing: CGFloat = 8,
        placement: MasonryPlacementMode = .fill,
        @ViewBuilder content: @escaping () -> Content
    )

    // 配置对象初始化
    public init(
        configuration: MasonryConfiguration,
        @ViewBuilder content: @escaping () -> Content
    )

    // 便捷初始化
    public init(columns: Int, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content)
    public init(rows: Int, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content)
    public init(adaptiveColumns minWidth: CGFloat, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content)
    public init(phoneColumns: Int, tabletColumns: Int, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content)
}
```

### LazyMasonryStack

懒加载瀑布流视图，适用于大量数据和分页场景：

```swift
public struct LazyMasonryStack<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Identifiable {
    // 基础初始化
    public init(
        _ data: Data,
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        hSpacing: CGFloat = 8,
        vSpacing: CGFloat = 8,
        placement: MasonryPlacementMode = .fill,
        bottomTriggerThreshold: CGFloat = 0.6,
        topTriggerThreshold: CGFloat = 0,
        debounceInterval: TimeInterval = 1.0,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    )

    // 配置对象初始化
    public init(
        _ data: Data,
        configuration: MasonryConfiguration,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    )

    // 便捷初始化
    public init(_ data: Data, columns: Int, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content)
    public init(_ data: Data, rows: Int, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content)
    public init(_ data: Data, adaptiveColumns minWidth: CGFloat, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content)
}
```

### 回调方法

```swift
extension LazyMasonryStack {
    // 到达底部回调
    public func onReachBottom(_ action: @escaping () -> Void) -> some View

    // 到达顶部回调
    public func onReachTop(_ action: @escaping () -> Void) -> some View
}
```

### MasonryConfiguration

配置对象，用于详细控制布局行为：

```swift
public struct MasonryConfiguration {
    public let axis: Axis                           // 布局轴向
    public let lines: MasonryLines                  // 行/列配置
    public let hSpacing: CGFloat                    // 水平间距
    public let vSpacing: CGFloat                    // 垂直间距
    public let placement: MasonryPlacementMode      // 放置模式
    public let bottomTriggerThreshold: CGFloat      // 底部触发阈值 (0.0-1.0)
    public let topTriggerThreshold: CGFloat         // 顶部触发阈值 (像素值)
    public let debounceInterval: TimeInterval       // 防抖间隔 (秒)
}
```

### 预设配置

```swift
extension MasonryConfiguration {
    static let `default`: MasonryConfiguration         // 默认配置
    static let adaptiveColumns: MasonryConfiguration   // 自适应列配置
    static let twoRows: MasonryConfiguration           // 双行配置
    static let earlyTrigger: MasonryConfiguration      // 早期触发配置
    static let lateTrigger: MasonryConfiguration       // 延迟触发配置
    static let fastResponse: MasonryConfiguration      // 快速响应配置
    static let slowResponse: MasonryConfiguration      // 慢速响应配置
}
```

## 🎯 使用场景

### 1. 图片画廊

```swift
struct PhotoGallery: View {
    @StateObject private var photoLoader = PhotoLoader()

    var body: some View {
        LazyMasonryStack(
            photoLoader.photos,
            adaptiveColumns: 150,
            spacing: 4
        ) { photo in
            AsyncImage(url: photo.url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
            }
            .cornerRadius(8)
        }
        .onReachBottom {
            photoLoader.loadNextPage()
        }
    }
}
```

### 2. 商品列表

```swift
struct ProductGrid: View {
    @StateObject private var productLoader = ProductLoader()

    var body: some View {
        LazyMasonryStack(
            productLoader.products,
            phoneColumns: 2,
            tabletColumns: 3,
            spacing: 12
        ) { product in
            ProductCard(product: product)
        }
        .onReachBottom {
            productLoader.loadNextPage()
        }
        .refreshable {
            await productLoader.refresh()
        }
    }
}
```

### 3. 社交媒体动态

```swift
struct FeedView: View {
    @StateObject private var feedLoader = FeedLoader()

    var body: some View {
        LazyMasonryStack(
            feedLoader.posts,
            columns: 1,
            spacing: 16
        ) { post in
            PostCard(post: post)
        }
        .onReachBottom {
            feedLoader.loadNextPage()
        }
        .onReachTop {
            feedLoader.refreshLatest()
        }
    }
}
```

## ❓ 常见问题

### Q: 为什么需要 iOS 18.0+？

A: 本库基于 SwiftUI 的 Layout 协议构建，该协议在 iOS 18.0 中得到了重要改进，提供了更好的性能和稳定性。

### Q: 如何处理不同高度的内容？

A: 库会自动计算每个子视图的实际尺寸，并智能分配到最短的列中，无需手动指定高度。

### Q: 可以在 ScrollView 中使用吗？

A: `MasonryStack` 需要放在 `ScrollView` 中使用，而 `LazyMasonryStack` 内置了滚动功能，不需要额外的 `ScrollView`。

### Q: 如何优化大量数据的性能？

A: 使用 `LazyMasonryStack` 并合理设置 `bottomTriggerThreshold` 和 `debounceInterval` 参数。

### Q: 支持自定义动画吗？

A: 库遵循 SwiftUI 的动画系统，可以使用标准的 SwiftUI 动画修饰符。

## 🔧 故障排除

### 编译错误

如果遇到编译错误，请检查：

1. **系统版本** - 确保目标平台版本符合要求
2. **Swift 版本** - 确保使用 Swift 6.0+
3. **Xcode 版本** - 确保使用 Xcode 16.0+

### 性能问题

如果遇到性能问题：

1. **使用懒加载** - 对于大量数据，使用 `LazyMasonryStack`
2. **调整触发阈值** - 增大 `bottomTriggerThreshold` 值
3. **增加防抖间隔** - 增大 `debounceInterval` 值
4. **检查子视图复杂度** - 简化子视图的布局复杂度

### 布局问题

如果布局不符合预期：

1. **检查数据源** - 确保数据实现了 `Identifiable` 协议
2. **检查子视图尺寸** - 确保子视图有明确的尺寸约束
3. **检查容器尺寸** - 确保父容器有足够的空间

## 🤝 贡献

我们欢迎社区贡献！请遵循以下步骤：

1. **Fork** 本仓库
2. **创建** 功能分支 (`git checkout -b feature/AmazingFeature`)
3. **提交** 更改 (`git commit -m 'Add some AmazingFeature'`)
4. **推送** 到分支 (`git push origin feature/AmazingFeature`)
5. **创建** Pull Request

### 开发指南

- 遵循 Swift 编码规范
- 添加适当的文档注释
- 编写单元测试
- 确保所有平台编译通过

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- 感谢 Apple 提供的 SwiftUI Layout 协议
- 感谢所有贡献者和用户的支持
- 特别感谢 SwiftUI 社区的宝贵建议

## 📞 联系我们

- **GitHub Issues** - [提交问题](https://github.com/beyoug/SwiftUIMasonryLayouts/issues)
- **讨论** - [GitHub Discussions](https://github.com/beyoug/SwiftUIMasonryLayouts/discussions)

---

**SwiftUIMasonryLayouts** - 让瀑布流布局变得简单而强大 🚀
```

## 🚀 快速开始

### 基础导入

```swift
import SwiftUI
import SwiftUIMasonryLayouts
```

### 📝 命名约定

采用符合 SwiftUI 命名习惯的 Stack 风格命名：

- **主要组件**：`MasonryStack` 和 `LazyMasonryStack`
- **便捷别名**：`Masonry` 和 `LazyMasonry`

推荐使用 `MasonryStack` 和 `LazyMasonryStack` 获得最佳的代码可读性。

### 1. 普通瀑布流创建

适用于静态内容和简单布局场景：

```swift
struct BasicMasonryExample: View {
    let items = Array(1...20)

    var body: some View {
        ScrollView {
            MasonryStack(
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
        LazyMasonryStack(
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
