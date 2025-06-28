# SwiftUIMasonryLayouts API 使用文档

## 📋 目录

1. [快速开始](#快速开始)
2. [核心视图组件](#核心视图组件)
3. [配置系统](#配置系统)
4. [使用场景指南](#使用场景指南)
5. [高级特性](#高级特性)
6. [性能优化](#性能优化)
7. [最佳实践](#最佳实践)
8. [故障排除](#故障排除)

## 快速开始

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
            MasonryView.vertical(columns: .fixed(2)) {
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

## 核心视图组件

### 1. MasonryView - 基础瀑布流视图

适用于小到中等数据集（< 1000项），提供最简单直观的API。

#### 📝 API 定义

```swift
public struct MasonryView<Content: View>: View
```

#### 🔧 初始化器

```swift
public init(
    axis: Axis = .vertical,
    lines: MasonryLines,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    @ViewBuilder content: @escaping () -> Content
)
```

#### 🚀 便捷静态方法

```swift
// 垂直瀑布流
static func vertical<C: View>(
    columns: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    @ViewBuilder content: @escaping () -> C
) -> MasonryView<C>

// 水平瀑布流
static func horizontal<C: View>(
    rows: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    @ViewBuilder content: @escaping () -> C
) -> MasonryView<C>
```

#### 💡 使用示例

```swift
// 基础垂直瀑布流
MasonryView.vertical(columns: .fixed(2)) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// 自适应列数
MasonryView.vertical(columns: .adaptive(minSize: 120)) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// 水平瀑布流
ScrollView(.horizontal) {
    MasonryView.horizontal(rows: .fixed(2)) {
        ForEach(items) { item in
            ItemView(item: item)
                .frame(width: CGFloat.random(in: 120...200))
        }
    }
}

// 完整参数配置
MasonryView(
    axis: .vertical,
    lines: .fixed(3),
    horizontalSpacing: 12,
    verticalSpacing: 16,
    placementMode: .fill
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

#### 🎯 适用场景
- 小数据集（< 100项）
- 静态内容展示
- 快速原型开发
- 简单的瀑布流需求

### 2. DataMasonryView - 数据驱动瀑布流视图

基于数据集合的瀑布流视图，提供更好的数据绑定和性能优化。

#### 📝 API 定义

```swift
public struct DataMasonryView<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View
```

#### 🔧 初始化器

```swift
// 通用初始化器
public init(
    axis: Axis = .vertical,
    lines: MasonryLines,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    data: Data,
    id: KeyPath<Data.Element, ID>,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)

// Identifiable 数据简化初始化器
public init(
    axis: Axis = .vertical,
    lines: MasonryLines,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    data: Data,
    @ViewBuilder content: @escaping (Data.Element) -> Content
) where Data.Element: Identifiable, ID == Data.Element.ID
```

#### 🚀 便捷静态方法

```swift
// 垂直数据驱动瀑布流
static func vertical<D, I, C>(
    columns: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    data: D,
    id: KeyPath<D.Element, I>,
    @ViewBuilder content: @escaping (D.Element) -> C
) -> DataMasonryView<D, I, C>

// 水平数据驱动瀑布流
static func horizontal<D, I, C>(
    rows: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    data: D,
    id: KeyPath<D.Element, I>,
    @ViewBuilder content: @escaping (D.Element) -> C
) -> DataMasonryView<D, I, C>
```

#### 💡 使用示例

```swift
// 定义数据模型
struct PhotoItem: Identifiable {
    let id = UUID()
    let url: URL
    let title: String
    let aspectRatio: CGFloat
}

// 基础数据驱动瀑布流
DataMasonryView.vertical(
    columns: .fixed(3),
    data: photos,
    id: \.id
) { photo in
    VStack(alignment: .leading) {
        AsyncImage(url: photo.url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
        }

        Text(photo.title)
            .font(.caption)
            .padding(.horizontal, 8)
    }
    .background(Color.white)
    .cornerRadius(8)
    .shadow(radius: 2)
}

// Identifiable 数据简化用法
DataMasonryView.vertical(
    columns: .adaptive(minSize: 150),
    data: identifiableItems
) { item in
    ItemView(item: item)
}

// 自定义配置
DataMasonryView(
    axis: .vertical,
    lines: .adaptive(minSize: 120),
    horizontalSpacing: 12,
    verticalSpacing: 16,
    placementMode: .order,
    data: articles,
    id: \.id
) { article in
    ArticleCard(article: article)
}
```

#### 🎯 适用场景
- 中等数据集（100-1000项）
- 数据驱动的动态内容
- 需要数据绑定的场景
- API数据展示

### 3. LazyMasonryView - 虚拟化懒加载瀑布流视图

真正的虚拟化实现，只渲染可见区域内的项目，适用于大型数据集。支持数万个项目的高性能渲染。

#### 📝 API 定义

```swift
public struct LazyMasonryView<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View
```

#### 🔧 初始化器

```swift
// 通用初始化器
public init(
    axis: Axis = .vertical,
    lines: MasonryLines,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    data: Data,
    id: KeyPath<Data.Element, ID>,
    estimatedItemSize: CGSize = CGSize(width: 150, height: 200),
    @ViewBuilder content: @escaping (Data.Element) -> Content
)

// Identifiable 数据简化初始化器
public init(
    axis: Axis = .vertical,
    lines: MasonryLines,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    data: Data,
    estimatedItemSize: CGSize = CGSize(width: 150, height: 200),
    @ViewBuilder content: @escaping (Data.Element) -> Content
) where Data.Element: Identifiable, ID == Data.Element.ID
```

#### 🚀 便捷静态方法

```swift
// 垂直虚拟化瀑布流
static func vertical<D, I, C>(
    columns: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    data: D,
    id: KeyPath<D.Element, I>,
    estimatedItemSize: CGSize = CGSize(width: 150, height: 200),
    @ViewBuilder content: @escaping (D.Element) -> C
) -> LazyMasonryView<D, I, C>
```

#### 💡 使用示例

```swift
// 基础虚拟化瀑布流
LazyMasonryView.vertical(
    columns: .adaptive(minSize: 150),
    data: largeDataSet,
    id: \.id,
    estimatedItemSize: CGSize(width: 150, height: 200)
) { item in
    ItemView(item: item)
}

// 动态预估尺寸
struct PhotoItem {
    let aspectRatio: CGFloat

    var estimatedSize: CGSize {
        let width: CGFloat = 150
        return CGSize(width: width, height: width / aspectRatio)
    }
}

LazyMasonryView.vertical(
    columns: .fixed(2),
    data: photos,
    id: \.id,
    estimatedItemSize: photos.first?.estimatedSize ?? CGSize(width: 150, height: 200)
) { photo in
    PhotoView(photo: photo)
}

// 大数据集示例
let massiveDataSet = Array(1...50000)
LazyMasonryView.vertical(
    columns: .fixed(3),
    data: massiveDataSet,
    id: \.self,
    estimatedItemSize: CGSize(width: 120, height: 180)
) { item in
    Text("Item \(item)")
        .frame(height: CGFloat.random(in: 100...250))
        .background(Color.blue.opacity(0.3))
        .cornerRadius(8)
}
```

#### ⚡ 虚拟化特性

- **智能缓存**：自动缓存布局计算结果
- **增量更新**：只更新可见区域的变化
- **内存管理**：主动监控内存使用，自动清理
- **并发安全**：使用 Actor 模式确保线程安全

#### 🎯 适用场景
- 大数据集（> 1000项）
- 无限滚动列表
- 图片画廊
- 社交媒体动态
- 商品列表

#### ⚠️ 重要提示
- `estimatedItemSize` 越准确，性能越好
- 避免在虚拟化视图中使用复杂的动画
- 确保数据源的稳定性

### 4. ResponsiveMasonryView - 响应式瀑布流视图

根据屏幕宽度自动调整布局的响应式瀑布流视图，适用于需要适配不同设备的场景。

#### 📝 API 定义

```swift
public struct ResponsiveMasonryView<Content: View>: View
```

#### 🔧 初始化器

```swift
public init(
    breakpoints: [CGFloat: MasonryConfiguration],
    @ViewBuilder content: @escaping () -> Content
)
```

#### 🚀 便捷静态方法

```swift
// 使用通用响应式断点
static func withCommonBreakpoints<C: View>(
    @ViewBuilder content: @escaping () -> C
) -> ResponsiveMasonryView<C>

// 使用设备特定断点
static func deviceAdaptive<C: View>(
    @ViewBuilder content: @escaping () -> C
) -> ResponsiveMasonryView<C>
```

#### 💡 使用示例

```swift
// 自定义断点配置
ResponsiveMasonryView(
    breakpoints: [
        0: .vertical(columns: .fixed(1)),      // 小屏幕：单列
        400: .vertical(columns: .fixed(2)),    // 中等屏幕：双列
        800: .vertical(columns: .fixed(3)),    // 大屏幕：三列
        1200: .vertical(columns: .fixed(4))    // 超大屏幕：四列
    ]
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// 使用预设断点（推荐）
ResponsiveMasonryView.withCommonBreakpoints {
    ForEach(articles) { article in
        ArticleCard(article: article)
    }
}

// 设备特定断点
ResponsiveMasonryView.deviceAdaptive {
    ForEach(photos) { photo in
        PhotoView(photo: photo)
    }
}
```

#### 📱 预设断点

```swift
// 通用断点
commonBreakpoints = [
    0: .singleColumn,      // 0-400pt
    400: .twoColumns,      // 400-800pt
    800: .threeColumns     // 800pt+
]

// 设备特定断点（iOS）
deviceBreakpoints = [
    0: .singleColumn,      // iPhone 竖屏
    375: .twoColumns,      // iPhone 横屏
    768: .threeColumns     // iPad
]
```

#### 🎯 适用场景
- 多设备适配需求
- 响应式网页风格应用
- 需要根据屏幕尺寸调整的布局
- 通用组件开发

## 配置系统

### 1. MasonryConfiguration - 瀑布流配置

完整的瀑布流布局配置，包含所有布局参数。

#### 📝 API 定义

```swift
public struct MasonryConfiguration: Sendable {
    public let axis: Axis                           // 布局轴向
    public let lines: MasonryLines                  // 行或列的配置
    public let horizontalSpacing: CGFloat           // 水平间距
    public let verticalSpacing: CGFloat             // 垂直间距
    public let placementMode: MasonryPlacementMode  // 放置模式
}
```

#### 🔧 初始化器

```swift
public init(
    axis: Axis = .vertical,
    lines: MasonryLines,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill
)
```

#### 🚀 便捷静态方法

```swift
// 创建垂直瀑布流配置
static func vertical(
    columns: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill
) -> MasonryConfiguration

// 创建水平瀑布流配置
static func horizontal(
    rows: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill
) -> MasonryConfiguration
```

#### 🔄 链式配置方法

```swift
// 修改间距
func withSpacing(
    horizontal: CGFloat? = nil,
    vertical: CGFloat? = nil
) -> MasonryConfiguration

// 修改放置模式
func withPlacementMode(_ mode: MasonryPlacementMode) -> MasonryConfiguration
```

#### 💡 使用示例

```swift
// 基础配置
let config = MasonryConfiguration.vertical(
    columns: .adaptive(minSize: 150),
    spacing: 12,
    placementMode: .fill
)

// 链式配置
let customConfig = MasonryConfiguration.threeColumns
    .withSpacing(horizontal: 16, vertical: 20)
    .withPlacementMode(.order)

// 使用配置创建MasonryView
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

### 2. MasonryLines - 行列配置

定义瀑布流视图中行或列数量的配置。

#### 📝 API 定义

```swift
public enum MasonryLines: Sendable, Equatable, Hashable {
    case adaptive(sizeConstraint: AdaptiveSizeConstraint)  // 自适应行或列
    case fixed(Int)                                        // 固定行或列
}

public enum AdaptiveSizeConstraint: Equatable, Sendable, Hashable {
    case min(CGFloat)  // 最小尺寸约束
    case max(CGFloat)  // 最大尺寸约束
}
```

#### 🚀 便捷静态方法

```swift
// 自适应配置
static func adaptive(minSize: CGFloat) -> MasonryLines
static func adaptive(maxSize: CGFloat) -> MasonryLines

// 固定配置（带验证）
static func fixedCount(_ count: Int) -> MasonryLines
```

#### 💡 使用示例

```swift
// 固定列数
.fixed(2)                    // 固定2列
.fixedCount(3)              // 固定3列（带验证，推荐）

// 自适应列数
.adaptive(minSize: 120)      // 自适应，最小宽度120pt
.adaptive(maxSize: 200)      // 自适应，最大宽度200pt

// 实际应用
MasonryView.vertical(columns: .adaptive(minSize: 150)) {
    // 根据屏幕宽度自动计算列数，每列最小150pt
}

MasonryView.vertical(columns: .fixed(3)) {
    // 固定3列布局
}
```

### 3. MasonryPlacementMode - 放置模式

定义瀑布流子视图在可用空间中如何放置的模式。

#### 📝 API 定义

```swift
public enum MasonryPlacementMode: Hashable, CaseIterable, Sendable {
    case fill   // 填充模式：智能放置到空间最多的列中
    case order  // 顺序模式：按视图树顺序依次放置
}
```

#### 💡 使用示例和对比

```swift
// 填充模式（推荐）- 视觉效果更好
MasonryView.vertical(
    columns: .fixed(2),
    placementMode: .fill
) {
    // 项目会被放置到当前空间最多的列中
    // 结果：更紧凑、更美观的布局
}

// 顺序模式 - 保持逻辑顺序
MasonryView.vertical(
    columns: .fixed(2),
    placementMode: .order
) {
    // 项目按照在视图树中的顺序依次放置
    // 结果：保持阅读顺序，但可能有空隙
}
```

#### 🎯 选择指南

| 模式 | 适用场景 | 优点 | 缺点 |
|------|---------|------|------|
| `.fill` | 图片展示、卡片布局 | 视觉效果好、空间利用率高 | 可能打乱逻辑顺序 |
| `.order` | 文章列表、时间线 | 保持逻辑顺序 | 可能有视觉空隙 |

### 4. 预设配置

库提供了丰富的预设配置，可以快速开始开发。

#### 📋 基础预设

```swift
// 垂直布局预设
MasonryConfiguration.singleColumn    // 单列垂直布局
MasonryConfiguration.twoColumns      // 双列垂直布局
MasonryConfiguration.threeColumns    // 三列垂直布局
MasonryConfiguration.fourColumns     // 四列垂直布局
MasonryConfiguration.adaptiveColumns // 自适应布局（最小120pt列宽）

// 水平布局预设
MasonryConfiguration.singleRow       // 单行水平布局
MasonryConfiguration.twoRows         // 双行水平布局
MasonryConfiguration.threeRows       // 三行水平布局
```

#### 📱 响应式断点预设

```swift
// 通用响应式断点
MasonryConfiguration.commonBreakpoints = [
    0: .singleColumn,      // 手机竖屏
    480: .twoColumns,      // 手机横屏 / 小平板
    768: .threeColumns,    // 平板
    1024: .fourColumns     // 桌面
]

// 设备特定响应式断点（iOS）
MasonryConfiguration.deviceBreakpoints = [
    0: .singleColumn,      // iPhone 竖屏
    375: .twoColumns,      // iPhone 横屏
    768: .threeColumns     // iPad
]

// 紧凑断点（适用于小屏幕）
MasonryConfiguration.compactBreakpoints = [
    0: .singleColumn,
    320: .twoColumns
]

// 扩展断点（适用于大屏幕）
MasonryConfiguration.extendedBreakpoints = [
    0: .singleColumn,                              // 最小
    480: .twoColumns,                              // 小
    768: .threeColumns,                            // 中
    1024: .fourColumns,                            // 大
    1440: MasonryConfiguration(lines: .fixed(5)),  // 超大
    1920: MasonryConfiguration(lines: .fixed(6))   // 极大
]
```

#### 💡 预设使用示例

```swift
// 使用基础预设
let twoColumnsConfig = MasonryConfiguration.twoColumns
MasonryView(
    axis: twoColumnsConfig.axis,
    lines: twoColumnsConfig.lines,
    horizontalSpacing: twoColumnsConfig.horizontalSpacing,
    verticalSpacing: twoColumnsConfig.verticalSpacing,
    placementMode: twoColumnsConfig.placementMode
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// 修改预设
let customConfig = MasonryConfiguration.threeColumns
    .withSpacing(horizontal: 16, vertical: 20)

// 使用响应式预设
ResponsiveMasonryView(breakpoints: MasonryConfiguration.commonBreakpoints) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

## 使用场景指南

### 🎯 视图类型选择指南

| 视图类型 | 数据量 | 适用场景 | 性能特点 | 推荐指数 |
|---------|--------|---------|---------|---------|
| `MasonryView` | < 100项 | 静态内容、快速原型 | 简单直接 | ⭐⭐⭐⭐⭐ |
| `DataMasonryView` | 100-1000项 | 数据驱动、动态内容 | 更好的数据绑定 | ⭐⭐⭐⭐ |
| `LazyMasonryView` | > 1000项 | 大数据集、无限滚动 | 虚拟化渲染 | ⭐⭐⭐⭐⭐ |
| `ResponsiveMasonryView` | 任意 | 多设备适配 | 自动响应 | ⭐⭐⭐⭐ |

### 📱 常见使用场景

#### 1. 图片画廊

```swift
// 适用于照片展示、作品集等
LazyMasonryView.vertical(
    columns: .adaptive(minSize: 150),
    data: photos,
    id: \.id,
    estimatedItemSize: CGSize(width: 150, height: 200)
) { photo in
    AsyncImage(url: photo.url) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipped()
    } placeholder: {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 200)
    }
    .cornerRadius(8)
}
```

#### 2. 商品列表

```swift
// 适用于电商应用、商品展示
DataMasonryView.vertical(
    columns: .fixed(2),
    data: products,
    id: \.id
) { product in
    VStack(alignment: .leading, spacing: 8) {
        AsyncImage(url: product.imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 150)
        }

        VStack(alignment: .leading, spacing: 4) {
            Text(product.name)
                .font(.headline)
                .lineLimit(2)

            Text("$\(product.price, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
    }
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 4)
}
```

#### 3. 社交媒体动态

```swift
// 适用于社交应用、动态流
LazyMasonryView.vertical(
    columns: .fixed(1),
    data: posts,
    id: \.id,
    estimatedItemSize: CGSize(width: 350, height: 300)
) { post in
    VStack(alignment: .leading, spacing: 12) {
        // 用户信息
        HStack {
            AsyncImage(url: post.user.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(post.user.name)
                    .font(.headline)
                Text(post.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }

        // 内容
        Text(post.content)
            .font(.body)

        // 图片（如果有）
        if let imageURL = post.imageURL {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
            }
            .cornerRadius(8)
        }

        // 互动按钮
        HStack {
            Button("👍 \(post.likes)") { }
            Button("💬 \(post.comments)") { }
            Button("🔄 \(post.shares)") { }
            Spacer()
        }
        .font(.caption)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 2)
}
```

#### 4. 文章卡片

```swift
// 适用于新闻应用、博客等
ResponsiveMasonryView.withCommonBreakpoints {
    ForEach(articles) { article in
        VStack(alignment: .leading, spacing: 12) {
            // 特色图片
            AsyncImage(url: article.featuredImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
            }
            .frame(height: 120)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {
                // 分类标签
                Text(article.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)

                // 标题
                Text(article.title)
                    .font(.headline)
                    .lineLimit(3)

                // 摘要
                Text(article.summary)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(4)

                // 元信息
                HStack {
                    Text(article.author)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(article.publishDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
```

#### 5. 响应式设计

```swift
// 适用于需要适配多种屏幕尺寸的应用
ResponsiveMasonryView(
    breakpoints: [
        0: .vertical(columns: .fixed(1)),      // 手机竖屏
        400: .vertical(columns: .fixed(2)),    // 手机横屏/小平板
        768: .vertical(columns: .fixed(3)),    // 平板
        1024: .vertical(columns: .fixed(4))    // 大平板/桌面
    ]
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

## 高级特性

### 🚀 虚拟化机制

`LazyMasonryView` 实现了真正的虚拟化渲染：

#### 核心特性
- **智能缓存**：自动缓存布局计算结果，避免重复计算
- **增量更新**：只更新可见区域的变化，提升滚动性能
- **内存管理**：主动监控内存使用，自动清理过期缓存
- **并发安全**：使用 Actor 模式确保线程安全的状态管理

#### 缓存策略
```swift
// 多级缓存机制
1. 布局缓存：缓存布局计算结果
2. 可见项缓存：缓存当前可见的项目
3. 空间分区：使用空间分区优化查询性能
```

#### 内存优化
```swift
// 自动内存管理
- 跨平台内存监控（iOS/macOS: mach API，其他平台: 估算）
- 渐进式清理：内存压力时自动清理缓存
- 容量限制：防止缓存无限增长
```

### 🔧 并发安全设计

#### Actor-based 并发控制
```swift
// 内部实现的并发控制器
private actor ConcurrencyController {
    private var isCalculating: Bool = false
    private var taskSequence: UInt64 = 0

    func startCalculation() -> UInt64? {
        guard !isCalculating else { return nil }
        isCalculating = true
        taskSequence += 1
        return taskSequence
    }
}
```

#### 任务序列化
- **序列号机制**：防止过期任务的结果被应用
- **取消检查**：支持任务取消和超时
- **状态验证**：确保数据一致性

### 📊 响应式系统

#### 断点系统
```swift
// 断点配置示例
let breakpoints: [CGFloat: MasonryConfiguration] = [
    0: .singleColumn,      // 手机竖屏
    480: .twoColumns,      // 手机横屏 / 小平板
    768: .threeColumns,    // 平板
    1024: .fourColumns     // 桌面
]
```

#### 平台适配
```swift
// 不同平台的默认断点
#if os(iOS)
static var deviceBreakpoints = [
    0: .singleColumn,      // iPhone 竖屏
    375: .twoColumns,      // iPhone 横屏
    768: .threeColumns     // iPad
]
#elseif os(macOS)
static var deviceBreakpoints = [
    0: .twoColumns,        // 小窗口
    800: .threeColumns,    // 中等窗口
    1200: .fourColumns     // 大窗口
]
#endif
```

## 性能优化

### ⚡ 性能基准

| 数据集大小 | 渲染时间 | 内存使用 | 缓存命中率 |
|-----------|---------|---------|-----------|
| < 100项   | < 16ms  | < 10MB  | 90%+     |
| 100-1000项| < 33ms  | < 50MB  | 85%+     |
| > 1000项  | 恒定    | < 100MB | 80%+     |

### 🎯 优化策略

#### 1. 选择合适的视图类型
```swift
// 根据数据量选择
if items.count < 100 {
    // 使用 MasonryView
    MasonryView.vertical(columns: .fixed(2)) { ... }
} else if items.count < 1000 {
    // 使用 DataMasonryView
    DataMasonryView.vertical(columns: .fixed(2), data: items, id: \.id) { ... }
} else {
    // 使用 LazyMasonryView
    LazyMasonryView.vertical(columns: .fixed(2), data: items, id: \.id) { ... }
}
```

#### 2. 优化预估尺寸
```swift
// ✅ 好的做法：提供准确的预估尺寸
struct PhotoItem {
    let aspectRatio: CGFloat

    var estimatedSize: CGSize {
        let width: CGFloat = 150
        return CGSize(width: width, height: width / aspectRatio)
    }
}

LazyMasonryView.vertical(
    columns: .fixed(2),
    data: photos,
    id: \.id,
    estimatedItemSize: photos.first?.estimatedSize ?? CGSize(width: 150, height: 200)
) { photo in
    PhotoView(photo: photo)
}

// ❌ 避免：预估尺寸差异过大
LazyMasonryView.vertical(
    estimatedItemSize: CGSize(width: 100, height: 100) // 实际尺寸可能是 200x300
)
```

#### 3. 数据源优化
```swift
// ✅ 使用稳定的 ID
struct Item: Identifiable {
    let id = UUID()  // 稳定的唯一 ID
    let content: String
}

// ❌ 避免：使用不稳定的 ID
struct Item {
    var id: Int { hashValue }  // 可能变化的 ID
}

// ✅ 批量数据更新
@State private var items: [Item] = []

func loadMoreItems() {
    let newItems = fetchNewItems()
    items.append(contentsOf: newItems)  // 批量添加
}

// ❌ 避免：频繁的单项更新
for item in newItems {
    items.append(item)  // 每次都触发重新布局
}
```

#### 4. 视图构建优化
```swift
// ✅ 避免在视图构建器中进行复杂计算
struct OptimizedView: View {
    let processedItems: [ProcessedItem]  // 预处理的数据

    var body: some View {
        MasonryView.vertical(columns: .fixed(2)) {
            ForEach(processedItems) { item in
                ItemView(data: item.processedData)  // 使用预处理的数据
            }
        }
    }
}

// ❌ 避免：在视图构建器中进行复杂计算
MasonryView.vertical(columns: .fixed(2)) {
    ForEach(items) { item in
        ItemView(data: performExpensiveCalculation(item))  // 每次重建都会计算
    }
}
```

### 📈 性能监控

#### 调试输出
```swift
// 在 DEBUG 模式下，库会自动输出性能信息
#if DEBUG
// 🎯 SwiftUIMasonryLayouts: 缓存命中，效率: 85.2%
// ⚠️ SwiftUIMasonryLayouts: 内存使用量(120MB)超过阈值(100MB)，执行内存清理
// ⚠️ SwiftUIMasonryLayouts: 项目数量(60000)超过最大缓存限制(50000)，可能影响性能
#endif
```

#### 性能测量
```swift
// 监控布局性能
let startTime = CFAbsoluteTimeGetCurrent()

MasonryView.vertical(columns: .fixed(2)) {
    // 布局内容
}
.onAppear {
    let endTime = CFAbsoluteTimeGetCurrent()
    print("布局时间: \((endTime - startTime) * 1000)ms")
}
```

## 最佳实践

### 🏗️ 数据模型设计

#### 推荐的数据模型
```swift
// ✅ 优秀的数据模型设计
struct PhotoItem: Identifiable, Hashable {
    let id = UUID()                    // 稳定的唯一标识
    let url: URL                       // 图片URL
    let aspectRatio: CGFloat           // 宽高比
    let title: String                  // 标题
    let tags: [String]                 // 标签

    // 提供预估尺寸有助于性能优化
    func estimatedSize(for width: CGFloat) -> CGSize {
        CGSize(width: width, height: width / aspectRatio)
    }

    // 实现 Hashable 以支持高效的集合操作
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        lhs.id == rhs.id
    }
}
```

#### 数据加载策略
```swift
// ✅ 分页加载大数据集
class PhotoViewModel: ObservableObject {
    @Published var photos: [PhotoItem] = []
    private var currentPage = 0
    private let pageSize = 50

    func loadMorePhotos() {
        Task {
            let newPhotos = await fetchPhotos(page: currentPage, size: pageSize)
            await MainActor.run {
                photos.append(contentsOf: newPhotos)
                currentPage += 1
            }
        }
    }
}
```

### 🎨 配置选择指南

#### 根据内容特点选择配置
```swift
// 图片内容：使用 .fill 模式，获得更紧凑的布局
MasonryView.vertical(
    columns: .adaptive(minSize: 150),
    placementMode: .fill
) {
    ForEach(photos) { photo in
        PhotoView(photo: photo)
    }
}

// 文本卡片：使用 .order 模式，保持阅读顺序
MasonryView.vertical(
    columns: .fixed(2),
    placementMode: .order
) {
    ForEach(articles) { article in
        ArticleCard(article: article)
    }
}

// 混合内容：使用 .fill 模式，获得最佳视觉效果
MasonryView.vertical(
    columns: .adaptive(minSize: 120),
    placementMode: .fill
) {
    ForEach(mixedItems) { item in
        MixedContentView(item: item)
    }
}
```

#### 响应式设计最佳实践
```swift
// ✅ 渐进式响应式设计
ResponsiveMasonryView(
    breakpoints: [
        0: .vertical(columns: .fixed(1)),      // 超小屏幕
        320: .vertical(columns: .fixed(2)),    // 小屏幕
        768: .vertical(columns: .fixed(3)),    // 中等屏幕
        1024: .vertical(columns: .fixed(4)),   // 大屏幕
        1440: .vertical(columns: .fixed(5))    // 超大屏幕
    ]
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// ✅ 使用预设断点（推荐）
ResponsiveMasonryView.withCommonBreakpoints {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

### 🔄 与其他SwiftUI组件集成

#### 导航集成
```swift
NavigationView {
    ScrollView {
        MasonryView.vertical(columns: .adaptive(minSize: 150)) {
            ForEach(items) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    ItemView(item: item)
                }
            }
        }
        .padding()
    }
    .navigationTitle("瀑布流")
}
```

#### 搜索集成
```swift
struct SearchableMasonryView: View {
    @State private var searchText = ""

    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyMasonryView.vertical(
                    columns: .adaptive(minSize: 150),
                    data: filteredItems,
                    id: \.id
                ) { item in
                    ItemView(item: item)
                }
                .padding()
            }
            .searchable(text: $searchText, prompt: "搜索内容...")
            .navigationTitle("搜索")
        }
    }
}
```

## 故障排除

### 🐛 常见问题及解决方案

#### 1. 布局不正确

**问题**：项目重叠或位置错误

**原因**：
- 容器尺寸不明确
- 子视图尺寸不稳定

**解决方案**：
```swift
// ✅ 确保容器有明确的尺寸
ScrollView {
    MasonryView.vertical(columns: .fixed(2)) {
        ForEach(items) { item in
            ItemView(item: item)
                .frame(height: item.height)  // 明确的高度
        }
    }
}
.frame(maxWidth: .infinity)  // 明确的容器宽度

// ✅ 使用 GeometryReader 获取准确尺寸
GeometryReader { geometry in
    ScrollView {
        MasonryView.vertical(columns: .adaptive(minSize: geometry.size.width / 3)) {
            ForEach(items) { item in
                ItemView(item: item)
            }
        }
    }
}
```

#### 2. 性能问题

**问题**：滚动卡顿或内存占用过高

**原因**：
- 使用了错误的视图类型
- 预估尺寸不准确
- 数据更新过于频繁

**解决方案**：
```swift
// ✅ 对大数据集使用 LazyMasonryView
if items.count > 1000 {
    LazyMasonryView.vertical(
        columns: .fixed(2),
        data: items,
        id: \.id,
        estimatedItemSize: CGSize(width: 150, height: 200)  // 准确的预估尺寸
    ) { item in
        ItemView(item: item)
    }
}

// ✅ 优化数据更新
@State private var items: [Item] = []

func loadMoreItems() {
    // 批量更新而不是逐个添加
    let newItems = fetchNewItems()
    items.append(contentsOf: newItems)
}
```

#### 3. 响应式布局不工作

**问题**：屏幕尺寸变化时布局没有更新

**原因**：
- 断点配置错误
- 断点值不合理

**解决方案**：
```swift
// ✅ 确保断点配置正确
ResponsiveMasonryView(
    breakpoints: [
        0: .vertical(columns: .fixed(1)),      // 从 0 开始
        400: .vertical(columns: .fixed(2)),    // 合理的断点值
        800: .vertical(columns: .fixed(3))     // 递增的断点值
    ]
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// ❌ 避免：断点配置错误
ResponsiveMasonryView(
    breakpoints: [
        100: .vertical(columns: .fixed(1)),    // 不从 0 开始
        300: .vertical(columns: .fixed(3)),    // 跳跃过大
        200: .vertical(columns: .fixed(2))     // 顺序错误
    ]
)
```

#### 4. 内存占用过高

**问题**：应用内存使用持续增长

**原因**：
- 内存泄漏
- 缓存过多

**解决方案**：
```swift
// ✅ 检查内存泄漏
class ItemViewModel: ObservableObject {
    // 避免强引用循环
    weak var delegate: ItemDelegate?

    // 使用 weak 或 unowned 引用
    private weak var parentView: UIView?
}

// ✅ 在极端情况下手动清理
// 注意：这会影响性能，仅在必要时使用
if memoryPressure {
    // 库会自动处理内存清理，通常不需要手动干预
}
```

#### 5. 虚拟化视图显示异常

**问题**：LazyMasonryView 中的项目显示不正确

**原因**：
- 预估尺寸与实际尺寸差异过大
- 数据源不稳定

**解决方案**：
```swift
// ✅ 提供准确的预估尺寸
struct DynamicItem {
    let content: String

    var estimatedHeight: CGFloat {
        // 根据内容计算预估高度
        let font = UIFont.systemFont(ofSize: 16)
        let size = content.boundingRect(
            with: CGSize(width: 150, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        ).size
        return size.height + 40  // 加上 padding
    }
}

LazyMasonryView.vertical(
    columns: .fixed(2),
    data: items,
    id: \.id,
    estimatedItemSize: CGSize(
        width: 150,
        height: items.first?.estimatedHeight ?? 200
    )
) { item in
    ItemView(item: item)
}
```

### 🔧 调试技巧

#### 1. 启用调试输出
```swift
// 在 DEBUG 模式下，库会自动输出调试信息
#if DEBUG
// 配置修正警告
// ⚠️ SwiftUIMasonryLayouts: 水平间距不能为负数，已自动修正为0

// 缓存效率统计
// 🎯 SwiftUIMasonryLayouts: 缓存命中，效率: 85.2%

// 内存使用警告
// ⚠️ SwiftUIMasonryLayouts: 内存使用量(120MB)超过阈值(100MB)，执行内存清理

// 性能警告
// ⚠️ SwiftUIMasonryLayouts: 项目数量(60000)超过最大缓存限制(50000)，可能影响性能
#endif
```

#### 2. 性能监控
```swift
// 监控布局性能
struct PerformanceMonitoredMasonryView: View {
    @State private var layoutTime: TimeInterval = 0

    var body: some View {
        MasonryView.vertical(columns: .fixed(2)) {
            ForEach(items) { item in
                ItemView(item: item)
            }
        }
        .onAppear {
            let startTime = CFAbsoluteTimeGetCurrent()
            DispatchQueue.main.async {
                let endTime = CFAbsoluteTimeGetCurrent()
                layoutTime = endTime - startTime
                print("布局时间: \(layoutTime * 1000)ms")
            }
        }
    }
}
```

#### 3. 内存监控
```swift
// 监控内存使用（仅供调试）
func logMemoryUsage() {
    #if DEBUG && os(iOS)
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }

    if result == KERN_SUCCESS {
        let memoryUsage = info.resident_size / (1024 * 1024)  // MB
        print("当前内存使用: \(memoryUsage)MB")
    }
    #endif
}
```

---

*本文档涵盖了SwiftUIMasonryLayouts库的所有功能和使用场景。*
