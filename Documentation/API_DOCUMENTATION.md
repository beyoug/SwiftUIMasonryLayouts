# SwiftUIMasonryLayouts API Documentation

## 概述

SwiftUIMasonryLayouts 是一个现代化的 SwiftUI 瀑布流布局库，基于 iOS 18.0+ Layout 协议构建，提供高性能、灵活的瀑布流布局解决方案。

### 系统要求
- iOS 18.0+ / macOS 15.0+ / tvOS 18.0+ / watchOS 11.0+ / visionOS 2.0+
- Swift 6.0+
- Xcode 16.0+

## 核心视图组件

### MasonryView

基础瀑布流视图，提供简洁的 API 和高性能布局。

```swift
public struct MasonryView<Content: View>: View
```

#### 初始化器

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

**参数:**
- `axis`: 布局轴向，默认为垂直
- `lines`: 行/列配置
- `horizontalSpacing`: 水平间距，默认为8
- `verticalSpacing`: 垂直间距，默认为8
- `placementMode`: 放置模式，默认为填充
- `content`: 视图内容构建器

#### 静态方法

##### vertical(columns:spacing:placementMode:content:)

创建垂直瀑布流。

```swift
static func vertical<C: View>(
    columns: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    @ViewBuilder content: @escaping () -> C
) -> MasonryView<C>
```

##### horizontal(rows:spacing:placementMode:content:)

创建水平瀑布流。

```swift
static func horizontal<C: View>(
    rows: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    @ViewBuilder content: @escaping () -> C
) -> MasonryView<C>
```

#### 使用示例

```swift
// 基础垂直瀑布流
MasonryView.vertical(columns: .fixed(2), spacing: 8) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// 水平瀑布流
MasonryView.horizontal(rows: .fixed(2)) {
    ForEach(items) { item in
        ItemView(item: item)
            .frame(width: CGFloat.random(in: 120...200))
    }
}
```

### DataMasonryView

基于数据集合的瀑布流视图，适用于数据驱动的场景。

```swift
public struct DataMasonryView<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View
```

#### 初始化器

```swift
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
```

#### 可识别数据扩展

对于实现了 `Identifiable` 协议的数据类型，提供简化的初始化器：

```swift
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

#### 静态方法

##### vertical(columns:spacing:placementMode:data:id:content:)

创建垂直数据驱动瀑布流。

```swift
static func vertical<D, I, C>(
    columns: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    data: D,
    id: KeyPath<D.Element, I>,
    @ViewBuilder content: @escaping (D.Element) -> C
) -> DataMasonryView<D, I, C>
where D: RandomAccessCollection, I: Hashable, C: View
```

#### 使用示例

```swift
// 数据驱动瀑布流
DataMasonryView.vertical(
    columns: .fixed(3),
    data: photoItems,
    id: \.id
) { photo in
    AsyncImage(url: photo.url) { image in
        image.resizable().aspectRatio(contentMode: .fit)
    } placeholder: {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 200)
    }
}
```

### LazyMasonryView

虚拟化懒加载瀑布流视图，适用于大型数据集，支持数万个项目的高性能渲染。

```swift
public struct LazyMasonryView<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View
```

#### 初始化器

```swift
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
```

**参数:**
- `estimatedItemSize`: 预估项目尺寸，用于虚拟化计算

#### 静态方法

##### vertical(columns:spacing:placementMode:data:id:estimatedItemSize:content:)

创建垂直懒加载瀑布流。

```swift
static func vertical<D, I, C>(
    columns: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill,
    data: D,
    id: KeyPath<D.Element, I>,
    estimatedItemSize: CGSize = CGSize(width: 150, height: 200),
    @ViewBuilder content: @escaping (D.Element) -> C
) -> LazyMasonryView<D, I, C>
where D: RandomAccessCollection, I: Hashable, C: View
```

#### 使用示例

```swift
// 虚拟化懒加载瀑布流
LazyMasonryView.vertical(
    columns: .adaptive(minSize: 150),
    data: largeDataSet,
    id: \.id,
    estimatedItemSize: CGSize(width: 150, height: 200)
) { item in
    ItemView(item: item)
}
```

### ResponsiveMasonryView

根据屏幕宽度自动调整布局的响应式瀑布流视图。

```swift
public struct ResponsiveMasonryView<Content: View>: View
```

#### 初始化器

```swift
public init(
    breakpoints: [CGFloat: MasonryConfiguration],
    @ViewBuilder content: @escaping () -> Content
)
```

**参数:**
- `breakpoints`: 响应式断点配置，键为屏幕宽度，值为对应的配置

#### 静态方法

##### withCommonBreakpoints(content:)

使用通用响应式断点创建响应式瀑布流。

```swift
static func withCommonBreakpoints<C: View>(
    @ViewBuilder content: @escaping () -> C
) -> ResponsiveMasonryView<C>
```

##### deviceAdaptive(content:)

使用设备特定断点创建响应式瀑布流。

```swift
static func deviceAdaptive<C: View>(
    @ViewBuilder content: @escaping () -> C
) -> ResponsiveMasonryView<C>
```

#### 使用示例

```swift
// 响应式瀑布流
ResponsiveMasonryView(
    breakpoints: [
        0: .vertical(columns: .fixed(1)),      // 小屏幕
        400: .vertical(columns: .fixed(2)),    // 中等屏幕
        800: .vertical(columns: .fixed(3))     // 大屏幕
    ]
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// 使用预设断点
ResponsiveMasonryView.withCommonBreakpoints {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

## 配置类型

### MasonryConfiguration

瀑布流布局的完整配置。

```swift
public struct MasonryConfiguration: Sendable
```

#### 属性

```swift
public let axis: Axis                           // 布局轴向
public let lines: MasonryLines                  // 行或列的配置
public let horizontalSpacing: CGFloat           // 水平间距
public let verticalSpacing: CGFloat             // 垂直间距
public let placementMode: MasonryPlacementMode  // 放置模式
```

#### 初始化器

```swift
public init(
    axis: Axis = .vertical,
    lines: MasonryLines,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill
)
```

#### 静态属性

```swift
public static let `default`: MasonryConfiguration  // 默认配置（2列垂直布局）
```

#### 静态方法

##### vertical(columns:spacing:placementMode:)

创建垂直瀑布流配置。

```swift
static func vertical(
    columns: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill
) -> MasonryConfiguration
```

##### horizontal(rows:spacing:placementMode:)

创建水平瀑布流配置。

```swift
static func horizontal(
    rows: MasonryLines,
    spacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill
) -> MasonryConfiguration
```

#### 实例方法

##### withSpacing(horizontal:vertical:)

修改间距。

```swift
func withSpacing(
    horizontal: CGFloat? = nil,
    vertical: CGFloat? = nil
) -> MasonryConfiguration
```

##### withPlacementMode(_:)

修改放置模式。

```swift
func withPlacementMode(_ mode: MasonryPlacementMode) -> MasonryConfiguration
```

### MasonryLines

定义瀑布流视图中行或列数量的配置。

```swift
public enum MasonryLines: Sendable, Equatable, Hashable
```

#### 枚举值

```swift
case adaptive(sizeConstraint: AdaptiveSizeConstraint)  // 可变数量的行或列
case fixed(Int)                                        // 固定数量的行或列
```

#### 嵌套类型

##### AdaptiveSizeConstraint

约束瀑布流视图中自适应行或列边界的常量。

```swift
public enum AdaptiveSizeConstraint: Equatable, Sendable, Hashable {
    case min(CGFloat)  // 给定轴上行或列的最小尺寸
    case max(CGFloat)  // 给定轴上行或列的最大尺寸
}
```

#### 静态方法

##### adaptive(minSize:)

创建具有最小尺寸约束的自适应配置。

```swift
static func adaptive(minSize: CGFloat) -> MasonryLines
```

##### adaptive(maxSize:)

创建具有最大尺寸约束的自适应配置。

```swift
static func adaptive(maxSize: CGFloat) -> MasonryLines
```

##### fixedCount(_:)

创建固定数量的行或列配置（带验证）。

```swift
static func fixedCount(_ count: Int) -> MasonryLines
```

#### 使用示例

```swift
.fixed(2)                    // 固定2列
.adaptive(minSize: 120)      // 自适应，最小宽度120
.adaptive(maxSize: 200)      // 自适应，最大宽度200
.fixedCount(3)              // 固定3列（带验证）
```

### MasonryPlacementMode

定义瀑布流子视图在可用空间中如何放置的模式。

```swift
public enum MasonryPlacementMode: Hashable, CaseIterable, Sendable
```

#### 枚举值

```swift
case fill   // 将每个子视图放置在可用空间最多的行或列中
case order  // 按视图树顺序放置每个子视图
```

#### 使用示例

```swift
.fill    // 填充模式：智能分配到空间最多的列
.order   // 顺序模式：按顺序依次放置
```

## 预设配置

### 基础预设

```swift
// 垂直布局预设
public static let singleColumn: MasonryConfiguration    // 单列垂直布局
public static let twoColumns: MasonryConfiguration      // 双列垂直布局
public static let threeColumns: MasonryConfiguration    // 三列垂直布局
public static let fourColumns: MasonryConfiguration     // 四列垂直布局
public static let adaptiveColumns: MasonryConfiguration // 自适应布局（最小120pt列宽）

// 水平布局预设
public static let singleRow: MasonryConfiguration       // 单行水平布局
public static let twoRows: MasonryConfiguration         // 双行水平布局
public static let threeRows: MasonryConfiguration       // 三行水平布局
```

### 响应式断点预设

```swift
// 通用响应式断点
public static let commonBreakpoints: [CGFloat: MasonryConfiguration]

// 设备特定响应式断点
public static var deviceBreakpoints: [CGFloat: MasonryConfiguration]

// 小屏幕紧凑断点
public static let compactBreakpoints: [CGFloat: MasonryConfiguration]

// 大屏幕扩展断点
public static let extendedBreakpoints: [CGFloat: MasonryConfiguration]
```

## 核心布局引擎

### MasonryLayout

基于 iOS 18.0+ Layout 协议的高性能瀑布流布局引擎。

```swift
public struct MasonryLayout: Layout
```

#### 初始化器

```swift
public init(
    axis: Axis = .vertical,
    lines: MasonryLines,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    placementMode: MasonryPlacementMode = .fill
)
```

#### Layout 协议实现

```swift
public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout LayoutCache
) -> CGSize

public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout LayoutCache
)

public func makeCache(subviews: Subviews) -> LayoutCache
```

## 便捷类型别名

为了提供更简洁的 API，库提供了以下类型别名：

```swift
public typealias Masonry = MasonryView              // 瀑布流视图的便捷别名
public typealias LazyMasonry = LazyMasonryView      // 懒加载瀑布流视图的便捷别名
public typealias ResponsiveMasonry = ResponsiveMasonryView  // 响应式瀑布流视图的便捷别名
```

#### 使用示例

```swift
// 使用别名的简洁语法
Masonry.vertical(columns: .fixed(2)) { ... }
LazyMasonry.vertical(columns: .fixed(2)) { ... }
ResponsiveMasonry.withCommonBreakpoints { ... }
```

## 库信息

### SwiftUIMasonryLayouts

库的主要命名空间和版本信息。

```swift
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum SwiftUIMasonryLayouts {
    /// 库版本号
    public static let version = "2.0.0"
}
```

## 最佳实践

### 性能优化建议

1. **选择合适的视图类型**：
   - 小数据集（< 100项）：使用 `MasonryView` 或 `DataMasonryView`
   - 大数据集（> 1000项）：使用 `LazyMasonryView`
   - 响应式需求：使用 `ResponsiveMasonryView`

2. **虚拟化配置**：
   - 为 `LazyMasonryView` 提供准确的 `estimatedItemSize`
   - 避免在虚拟化视图中使用复杂的动画

3. **布局配置**：
   - 使用预设配置提高开发效率
   - 根据内容特点选择合适的放置模式

### 常见用法模式

```swift
// 图片网格
LazyMasonryView.vertical(
    columns: .adaptive(minSize: 150),
    data: photos,
    id: \.id
) { photo in
    AsyncImage(url: photo.url)
        .aspectRatio(contentMode: .fit)
}

// 响应式卡片布局
ResponsiveMasonryView.withCommonBreakpoints {
    ForEach(articles) { article in
        ArticleCard(article: article)
    }
}

// 自定义间距的紧密布局
MasonryView.vertical(
    columns: .fixed(3),
    spacing: 4,
    placementMode: .fill
) {
    ForEach(items) { item in
        CompactItemView(item: item)
    }
}
```

## 高级特性

### 虚拟化机制

`LazyMasonryView` 实现了真正的虚拟化渲染：

- **智能缓存**：自动缓存布局计算结果，避免重复计算
- **增量更新**：只更新可见区域的变化，提升滚动性能
- **内存管理**：主动监控内存使用，自动清理过期缓存
- **并发安全**：使用 Actor 模式确保线程安全的状态管理

#### 虚拟化配置

```swift
LazyMasonryView(
    axis: .vertical,
    lines: .adaptive(minSize: 150),
    data: largeDataSet,
    id: \.id,
    estimatedItemSize: CGSize(width: 150, height: 200)  // 关键：准确的预估尺寸
) { item in
    ItemView(item: item)
}
```

### 缓存策略

库实现了多级缓存机制：

1. **布局缓存**：
   - 缓存布局计算结果
   - 基于配置参数的智能缓存键
   - 自动失效机制

2. **可见项缓存**：
   - 缓存当前可见的项目
   - 增量更新策略
   - 缓冲区优化

3. **空间分区**：
   - 使用空间分区优化查询性能
   - 二分查找算法
   - Y轴范围查询优化

#### 缓存效率监控

```swift
// 在 DEBUG 模式下，库会输出缓存效率信息
// 🎯 SwiftUIMasonryLayouts: 缓存命中，效率: 85.2%
```

### 内存优化

#### 自动内存管理

- **跨平台内存监控**：
  - iOS/macOS：使用 mach API 精确监控
  - watchOS/tvOS/visionOS：使用估算方法

- **渐进式清理**：
  - 内存压力时自动清理缓存
  - 保留最近使用的项目
  - 智能容量调整

- **容量限制**：
  - 默认最大缓存 50,000 项
  - 内存压力阈值 100MB
  - 防止缓存无限增长

#### 内存优化配置

```swift
// 库会根据设备内存自动调整缓存策略
// 小内存设备：更激进的清理策略
// 大内存设备：更宽松的缓存策略
```

### 并发安全设计

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

## 错误处理

### 自动修正机制

库会自动修正无效的配置参数：

```swift
// 负间距自动修正
MasonryConfiguration(
    lines: .fixed(2),
    horizontalSpacing: -10,  // ⚠️ 自动修正为 0
    verticalSpacing: -5      // ⚠️ 自动修正为 0
)

// 无效行列数自动修正
MasonryLines.fixedCount(0)           // ⚠️ 自动修正为 1
MasonryLines.adaptive(minSize: -100) // ⚠️ 自动修正为 1
```

### 调试支持

在 DEBUG 模式下，库提供详细的调试信息：

```swift
// 配置修正警告
⚠️ SwiftUIMasonryLayouts: 水平间距不能为负数，已自动修正为0

// 缓存效率统计
🎯 SwiftUIMasonryLayouts: 缓存命中，效率: 85.2%

// 内存使用警告
⚠️ SwiftUIMasonryLayouts: 内存使用量(120MB)超过阈值(100MB)，执行内存清理

// 性能警告
⚠️ SwiftUIMasonryLayouts: 项目数量(60000)超过最大缓存限制(50000)，可能影响性能
```

### 错误恢复策略

```swift
// 虚拟化错误类型
private enum VirtualizationError: Error, LocalizedError {
    case invalidContainerSize    // 容器尺寸无效
    case invalidEstimatedSize   // 估计项目尺寸无效
    case invalidLineCount       // 无效的行数配置
    case cancelled              // 布局计算被取消
    case memoryAllocationFailed // 内存分配失败
    case invalidConfiguration   // 无效的配置参数
    case dataCorruption        // 数据损坏或不一致
}
```

## 平台适配

### iOS 特性

- **完整手势支持**：支持所有 iOS 手势和交互
- **精确内存监控**：使用 mach API 进行内存监控
- **设备适配**：针对不同 iPhone/iPad 尺寸优化

#### iOS 响应式断点

```swift
static var deviceBreakpoints: [CGFloat: MasonryConfiguration] {
    [
        0: .singleColumn,      // iPhone 竖屏
        375: .twoColumns,      // iPhone 横屏
        768: .threeColumns     // iPad
    ]
}
```

### macOS 特性

- **窗口大小适配**：支持任意窗口尺寸
- **鼠标交互**：优化鼠标滚动和点击
- **多窗口支持**：每个窗口独立的布局状态

#### macOS 响应式断点

```swift
static var deviceBreakpoints: [CGFloat: MasonryConfiguration] {
    [
        0: .twoColumns,        // 小窗口
        800: .threeColumns,    // 中等窗口
        1200: .fourColumns     // 大窗口
    ]
}
```

### watchOS/tvOS/visionOS 适配

- **内存优化**：使用估算方法进行内存监控
- **性能调优**：针对平台特点优化参数
- **交互适配**：适配各平台的交互模式

## 性能指标

### 基准测试结果

| 数据集大小 | 渲染时间 | 内存使用 | 缓存命中率 |
|-----------|---------|---------|-----------|
| < 100项   | < 16ms  | < 10MB  | 90%+     |
| 100-1000项| < 33ms  | < 50MB  | 85%+     |
| > 1000项  | 恒定    | < 100MB | 80%+     |

### 性能优化技巧

1. **预估尺寸准确性**：
   ```swift
   // ✅ 好的做法：提供准确的预估尺寸
   LazyMasonryView(
       estimatedItemSize: CGSize(width: 150, height: 180) // 接近实际尺寸
   )

   // ❌ 避免：预估尺寸差异过大
   LazyMasonryView(
       estimatedItemSize: CGSize(width: 100, height: 100) // 实际尺寸 200x300
   )
   ```

2. **稳定的数据源**：
   ```swift
   // ✅ 好的做法：使用稳定的 ID
   struct Item: Identifiable {
       let id = UUID()  // 稳定的唯一 ID
   }

   // ❌ 避免：使用不稳定的 ID
   struct Item {
       var id: Int { hashValue }  // 可能变化的 ID
   }
   ```

3. **合理的更新频率**：
   ```swift
   // ✅ 好的做法：批量更新
   items.append(contentsOf: newItems)

   // ❌ 避免：频繁的单项更新
   for item in newItems {
       items.append(item)  // 每次都触发重新布局
   }
   ```

## 迁移指南

### 从 LazyVGrid 迁移

SwiftUI 的 `LazyVGrid` 可以轻松迁移到 `MasonryView`：

```swift
// 原来的 LazyVGrid
LazyVGrid(columns: [
    GridItem(.adaptive(minimum: 120)),
    GridItem(.adaptive(minimum: 120))
]) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// 迁移到 MasonryView
MasonryView.vertical(columns: .adaptive(minSize: 120)) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

#### 迁移对照表

| LazyVGrid | MasonryView |
|-----------|-------------|
| `GridItem(.fixed(width))` | `MasonryLines.fixed(count)` |
| `GridItem(.adaptive(minimum: size))` | `MasonryLines.adaptive(minSize: size)` |
| `GridItem(.flexible())` | `MasonryLines.adaptive(minSize: 120)` |
| `spacing` 参数 | `spacing` 参数 |

### 从其他瀑布流库迁移

#### 从 WaterfallGrid 迁移

```swift
// WaterfallGrid
WaterfallGrid(items) { item in
    ItemView(item: item)
}
.gridStyle(
    columnsInPortrait: 2,
    columnsInLandscape: 3,
    spacing: 8
)

// SwiftUIMasonryLayouts
ResponsiveMasonryView(
    breakpoints: [
        0: .vertical(columns: .fixed(2)),    // Portrait
        600: .vertical(columns: .fixed(3))   // Landscape
    ]
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

#### 从 ASCollectionNode 迁移

```swift
// ASCollectionNode (Texture)
let layout = ASCollectionLayout()
layout.scrollableDirections = [.up, .down]

// SwiftUIMasonryLayouts
LazyMasonryView.vertical(
    columns: .adaptive(minSize: 150),
    data: items,
    id: \.id
) { item in
    ItemView(item: item)
}
```

## 故障排除

### 常见问题及解决方案

#### 1. 布局不正确

**问题**：项目重叠或位置错误

**解决方案**：
```swift
// 检查容器是否有明确的尺寸
ScrollView {
    MasonryView.vertical(columns: .fixed(2)) {
        // 确保子视图有明确的尺寸
        ForEach(items) { item in
            ItemView(item: item)
                .frame(height: item.height) // ✅ 明确的高度
        }
    }
}
.frame(maxWidth: .infinity) // ✅ 明确的容器宽度
```

#### 2. 性能问题

**问题**：滚动卡顿或内存占用过高

**解决方案**：
```swift
// 对大数据集使用 LazyMasonryView
LazyMasonryView.vertical(
    columns: .fixed(2),
    data: largeDataSet,
    id: \.id,
    estimatedItemSize: CGSize(width: 150, height: 200) // ✅ 准确的预估尺寸
) { item in
    ItemView(item: item)
}
```

#### 3. 内存占用过高

**问题**：应用内存使用持续增长

**解决方案**：
```swift
// 检查是否有内存泄漏
class ItemViewModel: ObservableObject {
    // ❌ 避免：强引用循环
    var onUpdate: (() -> Void)?

    // ✅ 使用：弱引用
    weak var delegate: ItemDelegate?
}

// 考虑降低缓存限制（在极端情况下）
// 注意：这会影响性能，仅在必要时使用
```

#### 4. 响应式布局不工作

**问题**：屏幕尺寸变化时布局没有更新

**解决方案**：
```swift
// 确保断点配置正确
ResponsiveMasonryView(
    breakpoints: [
        0: .vertical(columns: .fixed(1)),      // ✅ 从 0 开始
        400: .vertical(columns: .fixed(2)),    // ✅ 合理的断点
        800: .vertical(columns: .fixed(3))     // ✅ 递增的断点
    ]
) {
    // 内容
}
```

### 调试技巧

#### 1. 启用调试输出

```swift
// 在 DEBUG 模式下，库会自动输出调试信息
#if DEBUG
// 无需额外配置，库会自动输出：
// - 配置修正警告
// - 缓存效率统计
// - 内存使用情况
// - 性能指标
#endif
```

#### 2. 性能监控

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

#### 3. 内存监控

```swift
// 监控内存使用
func logMemoryUsage() {
    let memoryInfo = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

    let result = withUnsafeMutablePointer(to: &memoryInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }

    if result == KERN_SUCCESS {
        let memoryUsage = memoryInfo.resident_size / (1024 * 1024) // MB
        print("内存使用: \(memoryUsage)MB")
    }
}
```

## 最佳实践总结

### 选择合适的视图类型

```swift
// 小数据集 (< 100项) - 使用 MasonryView
MasonryView.vertical(columns: .fixed(2)) {
    ForEach(smallDataSet) { item in
        ItemView(item: item)
    }
}

// 中等数据集 (100-1000项) - 使用 DataMasonryView
DataMasonryView.vertical(
    columns: .adaptive(minSize: 150),
    data: mediumDataSet,
    id: \.id
) { item in
    ItemView(item: item)
}

// 大数据集 (> 1000项) - 使用 LazyMasonryView
LazyMasonryView.vertical(
    columns: .fixed(3),
    data: largeDataSet,
    id: \.id,
    estimatedItemSize: CGSize(width: 120, height: 180)
) { item in
    ItemView(item: item)
}

// 响应式需求 - 使用 ResponsiveMasonryView
ResponsiveMasonryView.withCommonBreakpoints {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

### 配置优化

```swift
// ✅ 推荐的配置模式
let config = MasonryConfiguration.vertical(
    columns: .adaptive(minSize: 150),
    spacing: 12,
    placementMode: .fill
)

// 使用预设配置提高开发效率
let quickConfig = MasonryConfiguration.threeColumns
    .withSpacing(horizontal: 16, vertical: 20)
    .withPlacementMode(.order)
```

### 数据管理

```swift
// ✅ 好的数据模型设计
struct PhotoItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let aspectRatio: CGFloat

    // 提供尺寸信息有助于性能优化
    var estimatedSize: CGSize {
        CGSize(width: 150, height: 150 / aspectRatio)
    }
}

// ✅ 稳定的数据更新
@State private var items: [PhotoItem] = []

// 批量更新而不是逐个添加
func loadMoreItems() {
    let newItems = fetchNewItems()
    items.append(contentsOf: newItems)
}
```

## 版本历史

### v2.0.0 (当前版本)
- **重大更新**：基于 iOS 18.0+ Layout 协议完全重写
- **新增功能**：
  - 虚拟化懒加载支持 (`LazyMasonryView`)
  - 响应式布局支持 (`ResponsiveMasonryView`)
  - 改进的并发安全性
  - 增强的内存管理
  - 多级缓存机制
- **性能提升**：
  - 比 v1.x 性能提升 40-60%
  - 内存使用减少 30-50%
  - 更好的滚动流畅度
- **API 改进**：
  - 更简洁的 API 设计
  - 更好的类型安全
  - 更丰富的配置选项

### v1.x (已弃用)
- 基于传统布局方法
- 基础瀑布流功能
- 有限的性能优化

### 兼容性说明

- **向后兼容**：v1.x API 仍然可用但已标记为 deprecated
- **迁移建议**：新项目建议直接使用 v2.0 API
- **升级路径**：提供自动迁移工具和详细的迁移指南

## 社区与支持

### 获取帮助

1. **GitHub Issues**：报告 bug 和功能请求
2. **Discussions**：社区讨论和问答
3. **Stack Overflow**：使用 `swiftui-masonry-layouts` 标签

### 贡献指南

欢迎社区贡献！请遵循以下步骤：

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 创建 Pull Request

### 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

*本文档基于 SwiftUIMasonryLayouts v2.0.0 生成*
*最后更新：2025年*
