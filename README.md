# SwiftUIMasonryLayouts

`SwiftUIMasonryLayouts` 是一个面向 `iOS 26` 的 SwiftUI 瀑布流布局库，提供保持 SwiftUI 原生感的 `MasonryStack` 与 `MasonryLayout` 两层入口。

## 项目定位

- 面向 `iOS 26` 的纯布局核心
- 优先保持 SwiftUI 原生 API 体验
- 已针对测量语义、缓存语义与桥接契约进行稳定性优化

## 环境要求

- iOS 26.0+
- Swift 6.0+

## 安装

在 Xcode 中添加 Swift Package 地址：

```text
https://github.com/beyoug/SwiftUIMasonryLayouts.git
```

## 快速开始

```swift
import SwiftUIMasonryLayouts

MasonryStack(columns: 2, spacing: 12) {
    ForEach(items) { item in
        ItemCard(item)
    }
}
```

`MasonryStack` 是首选的视图层入口；`columns` 与 `adaptiveColumns` 映射到纵向瀑布流，`rows` 与 `adaptiveRows` 映射到横向瀑布流。

### 直接使用 `MasonryLayout`

当你需要原始 `Layout` 类型时，可以直接使用 `MasonryLayout`：

```swift
MasonryLayout(
    axis: .vertical,
    tracks: .adaptive(min: 160),
    spacing: 12,
    placement: .shortestFirst
) {
    // subviews
}
```

## 核心能力

- `MasonryStack`：面向大多数页面场景的原生风格视图入口
- `MasonryLayout`：面向高级组合场景的底层 `Layout` 入口
- `MasonryTracks`：统一 `.fixed` 与 `.adaptive` 的轨道配置语义
- `MasonryPlacement`：支持 `.shortestFirst` 与 `.sequential`

## API

### `MasonryStack`

```swift
public struct MasonryStack<Content: View>: View {
    public init(
        axis: Axis = .vertical,
        tracks: MasonryTracks = .fixed(2),
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

- `MasonryStack` 是首选视图入口
- 显式初始化器会直接将 `axis`、`tracks`、`spacing`、`placement` 转发给 `MasonryLayout`

便捷初始化器：

```swift
public init(columns: Int, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
public init(rows: Int, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
public init(adaptiveColumns minimum: CGFloat, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
public init(adaptiveRows minimum: CGFloat, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
```

### `MasonryLayout`

```swift
public struct MasonryLayout: Layout {
    public init(
        axis: Axis = .vertical,
        tracks: MasonryTracks = .fixed(2),
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst
    )
}
```

- 适用于需要原始 `Layout` 值的高级组合场景

### `MasonryTracks`

```swift
public enum MasonryTracks: Hashable, Sendable {
    case fixed(Int)
    case adaptive(min: CGFloat)
}
```

### `MasonryPlacement`

```swift
public enum MasonryPlacement: Hashable, Sendable {
    case shortestFirst
    case sequential
}
```

- `.shortestFirst`：优先将元素放到当前最短的列或行
- `.sequential`：按输入顺序轮转分配列或行

## 配置说明

- `axis`：`.vertical` 表示列布局，`.horizontal` 表示行布局
- `tracks`：`.fixed(Int)` 表示固定数量，`.adaptive(min:)` 表示在满足最小轨道尺寸前提下尽可能解析更多轨道
- `spacing`：控制轨道之间与元素之间的间距
- `placement`：`.shortestFirst` 用于更均衡的分布，`.sequential` 用于按输入顺序分配

便捷初始化器映射：

- `MasonryStack(columns:)`：对应纵向 + 固定轨道
- `MasonryStack(rows:)`：对应横向 + 固定轨道
- `MasonryStack(adaptiveColumns:)`：对应纵向 + 自适应轨道
- `MasonryStack(adaptiveRows:)`：对应横向 + 自适应轨道

## 示例

仓库中附带本地示例应用，可用于预览和验证主要布局场景：

- 打开 `ExamplesApp/SwiftUIMasonryLayoutsExamplesApp.xcodeproj`
- 选择 `SwiftUIMasonryLayoutsExamplesApp` 运行方案
- 运行到 iOS 模拟器，或直接预览 `ExamplesHomeView.swift`

示例应用仅用于本地演示与验证，不属于发布库产物的一部分。
