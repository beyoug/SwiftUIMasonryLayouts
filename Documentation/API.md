# API 接口文档

## 目录

- [核心组件](#核心组件)
  - [MasonryView](#masonryview)
  - [LazyMasonryView](#lazymasonryview)
- [配置类型](#配置类型)
  - [MasonryConfiguration](#masonryconfiguration)
  - [MasonryLines](#masonrylines)
  - [MasonryPlacementMode](#masonryplacementmode)
- [回调接口](#回调接口)
  - [LazyMasonryCallbacks](#lazymasonrycallbacks)
- [类型别名](#类型别名)

---

## 核心组件

### MasonryView

基础瀑布流视图组件，适用于静态内容和简单布局场景。

#### 初始化方法

```swift
public init(
    axis: Axis = .vertical,
    lines: MasonryLines = .fixed(2),
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    @ViewBuilder content: () -> Content
)
```

**参数说明：**
- `axis`: 布局轴向，`.vertical`（垂直）或 `.horizontal`（水平）
- `lines`: 行/列配置，支持固定数量和自适应
- `horizontalSpacing`: 水平间距，默认8pt
- `verticalSpacing`: 垂直间距，默认8pt
- `placementMode`: 放置模式，`.fill`（智能填充）或 `.order`（顺序放置）
- `content`: 视图内容构建器

#### 响应式初始化

```swift
public init(
    breakpoints: [CGFloat: MasonryConfiguration],
    @ViewBuilder content: @escaping () -> Content
)
```

**参数说明：**
- `breakpoints`: 响应式断点配置字典，键为屏幕宽度阈值，值为对应配置
- `content`: 视图内容构建器

#### 使用示例

```swift
// 基础使用
MasonryView(
    axis: .vertical,
    lines: .fixed(2),
    horizontalSpacing: 8,
    verticalSpacing: 8
) {
    ForEach(items, id: \.self) { item in
        ItemView(item: item)
    }
}

// 响应式布局
let breakpoints: [CGFloat: MasonryConfiguration] = [
    0: .columns(1),
    480: .columns(2),
    768: .columns(3)
]

MasonryView(breakpoints: breakpoints) {
    ForEach(items, id: \.self) { item in
        ItemView(item: item)
    }
}
```

---

### LazyMasonryView

懒加载瀑布流视图组件，专为大数据集和高性能场景设计。

#### 基础初始化

```swift
public init(
    _ data: Data,
    configuration: MasonryConfiguration,
    itemSizeCalculator: ((Data.Element, CGFloat) -> CGSize)? = nil,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

**参数说明：**
- `data`: 数据源，必须遵循 `RandomAccessCollection` 协议
- `configuration`: 布局配置
- `itemSizeCalculator`: 可选的项目尺寸计算器，用于性能优化
- `content`: 内容构建器，接收数据元素返回视图

#### 便捷初始化

```swift
public init(
    _ data: Data,
    columns: Int = 2,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

#### 响应式初始化

```swift
public init(
    _ data: Data,
    breakpoints: [CGFloat: MasonryConfiguration],
    itemSizeCalculator: ((Data.Element, CGFloat) -> CGSize)? = nil,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

#### 回调方法

```swift
// 可见范围变化监听
func onVisibleRangeChanged(_ action: @escaping (Range<Data.Index>) -> Void) -> LazyMasonryView

// 滚动到底部监听
func onReachBottom(_ action: @escaping () -> Void) -> LazyMasonryView

// 滚动到顶部监听
func onReachTop(_ action: @escaping () -> Void) -> LazyMasonryView

// 通用位置监听（推荐）
func onReachStart(_ action: @escaping () -> Void) -> LazyMasonryView  // 起始位置
func onReachEnd(_ action: @escaping () -> Void) -> LazyMasonryView    // 结束位置

// 回调配置
func callbacks(_ callbacks: LazyMasonryCallbacks<Data>) -> LazyMasonryView
```

#### 使用示例

```swift
// 基础使用
LazyMasonryView(
    photos,
    configuration: .columns(2)
) { photo in
    PhotoCard(photo: photo)
}

// 带回调的使用
LazyMasonryView(photos, configuration: .columns(2)) { photo in
    PhotoCard(photo: photo)
}
.onReachBottom {
    Task { await loadMorePhotos() }
}
.onVisibleRangeChanged { range in
    analytics.trackVisibleItems(range)
}

// 使用回调配置
let callbacks = LazyMasonryCallbacks(
    onVisibleRangeChanged: { range in
        print("可见范围: \(range)")
    },
    onReachEnd: {
        Task { await loadMoreData() }
    },
    onReachStart: {
        Task { await refreshData() }
    }
)

LazyMasonryView(photos, configuration: .columns(2)) { photo in
    PhotoCard(photo: photo)
}
.callbacks(callbacks)
```

---

## 配置类型

### MasonryConfiguration

瀑布流布局配置结构体。

#### 属性

```swift
public let axis: Axis                           // 布局轴向
public let lines: MasonryLines                  // 行/列配置
public let horizontalSpacing: CGFloat           // 水平间距
public let verticalSpacing: CGFloat             // 垂直间距
public let placementMode: MasonryPlacementMode  // 放置模式
```

#### 初始化

```swift
public init(
    axis: Axis = .vertical,
    lines: MasonryLines = .fixed(2),
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill
)
```

#### 预设配置

```swift
// 核心预设
static let `default`: MasonryConfiguration        // 默认配置（垂直双列）
static let adaptiveColumns: MasonryConfiguration  // 自适应列
static let twoRows: MasonryConfiguration          // 水平双行
```

#### 便捷方法

```swift
// 创建列布局
static func columns(_ count: Int, spacing: CGFloat = 8) -> MasonryConfiguration

// 创建行布局
static func rows(_ count: Int, spacing: CGFloat = 8) -> MasonryConfiguration

// 创建自适应配置
static func adaptive(minColumnWidth: CGFloat, spacing: CGFloat = 8) -> MasonryConfiguration

// 修改配置
func withSpacing(horizontal: CGFloat, vertical: CGFloat) -> MasonryConfiguration
func withPlacementMode(_ mode: MasonryPlacementMode) -> MasonryConfiguration
```

#### 使用示例

```swift
// 使用预设配置
let config = MasonryConfiguration.adaptiveColumns

// 自定义配置
let customConfig = MasonryConfiguration(
    axis: .vertical,
    lines: .adaptive(minSize: 120),
    horizontalSpacing: 12,
    verticalSpacing: 16,
    placementMode: .fill
)

// 使用便捷方法
let columnConfig = MasonryConfiguration.columns(3, spacing: 10)
let adaptiveConfig = MasonryConfiguration.adaptive(minColumnWidth: 150, spacing: 12)
let modifiedConfig = MasonryConfiguration.columns(2)
    .withSpacing(horizontal: 12, vertical: 16)
    .withPlacementMode(.order)
```

---

### MasonryLines

行/列数配置枚举。

#### 枚举值

```swift
public enum MasonryLines: Sendable {
    case fixed(Int)                                        // 固定数量
    case adaptive(sizeConstraint: AdaptiveSizeConstraint)  // 自适应数量
}
```

#### AdaptiveSizeConstraint

```swift
public enum AdaptiveSizeConstraint: Sendable {
    case min(CGFloat)  // 最小尺寸约束
    case max(CGFloat)  // 最大尺寸约束
}
```

#### 便捷方法

```swift
// 创建自适应配置
static func adaptive(minSize: CGFloat) -> MasonryLines
static func adaptive(maxSize: CGFloat) -> MasonryLines
```

#### 使用示例

```swift
// 固定数量
let fixedLines = MasonryLines.fixed(3)

// 自适应（最小尺寸）
let adaptiveMin = MasonryLines.adaptive(minSize: 120)

// 自适应（最大尺寸）
let adaptiveMax = MasonryLines.adaptive(maxSize: 200)

// 使用便捷方法
let adaptiveLines = MasonryLines.adaptive(minSize: 150)
```

---

### MasonryPlacementMode

项目放置模式枚举。

#### 枚举值

```swift
public enum MasonryPlacementMode: Sendable {
    case fill   // 智能填充模式：放置到当前最短的列/行
    case order  // 顺序模式：按顺序循环放置到各列/行
}
```

#### 使用示例

```swift
// 智能填充（推荐）
MasonryView(placementMode: .fill) { ... }

// 顺序放置
MasonryView(placementMode: .order) { ... }
```

---

## 回调接口

### LazyMasonryCallbacks

懒加载瀑布流的回调配置结构体。

#### 属性

```swift
public let onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?  // 可见范围变化回调
public let onReachBottom: (() -> Void)?                          // 滚动到底部回调
public let onReachTop: (() -> Void)?                             // 滚动到顶部回调
```

#### 初始化

```swift
// 传统命名初始化
public init(
    onVisibleRangeChanged: ((Range<Data.Index>) -> Void)? = nil,
    onReachBottom: (() -> Void)? = nil,
    onReachTop: (() -> Void)? = nil
)

// 通用命名初始化
public init(
    onVisibleRangeChanged: ((Range<Data.Index>) -> Void)? = nil,
    onReachEnd: (() -> Void)? = nil,
    onReachStart: (() -> Void)? = nil
)
```

#### 使用示例

```swift
// 创建回调配置
let callbacks = LazyMasonryCallbacks(
    onVisibleRangeChanged: { range in
        print("可见范围: \(range)")
    },
    onReachBottom: {
        Task { await loadMoreData() }
    },
    onReachTop: {
        Task { await refreshData() }
    }
)

// 使用通用命名
let callbacks2 = LazyMasonryCallbacks(
    onVisibleRangeChanged: { range in
        analytics.trackVisibleItems(range)
    },
    onReachEnd: {
        Task { await loadMoreData() }
    },
    onReachStart: {
        Task { await refreshData() }
    }
)
```

---

## 类型别名

为了提供更直观的API，库提供了以下类型别名：

```swift
// 数据驱动瀑布流视图的便捷别名
public typealias DataMasonry = LazyMasonryView
```

#### 使用示例

```swift
// 使用类型别名
DataMasonry(photos, configuration: .columns(2)) { photo in
    PhotoCard(photo: photo)
}

// 等价于
LazyMasonryView(photos, configuration: .columns(2)) { photo in
    PhotoCard(photo: photo)
}
```

---

## 注意事项

### 数据要求

- `LazyMasonryView` 的数据源必须遵循 `RandomAccessCollection` 协议
- 数据元素必须遵循 `Identifiable` 协议
- 确保数据元素的 `id` 属性唯一且稳定

### 性能建议

- 对于大数据集，推荐使用 `LazyMasonryView`
- 提供 `itemSizeCalculator` 可以显著提升性能
- 合理使用回调，避免在回调中执行耗时操作
- 使用预设配置可以减少配置错误

### 平台兼容性

- 所有API都支持iOS 18.0+、macOS 15.0+、tvOS 18.0+、watchOS 11.0+、visionOS 2.0+
- 内存警告处理仅在iOS平台可用
- 滚动回调在所有平台都可用，但在不同平台上的触发时机可能略有差异
