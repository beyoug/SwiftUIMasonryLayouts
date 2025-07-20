# API 参考文档

## 概述

SwiftUIMasonryLayouts 提供两个核心组件和一套完整的配置系统，用于创建高性能的瀑布流布局。

## 核心组件

### MasonryStack

基础瀑布流视图组件，适用于静态内容和简单布局场景。

#### 初始化方法

##### 基础初始化
```swift
public init(
    axis: Axis = .vertical,
    lines: MasonryLines = .fixed(2),
    hSpacing: CGFloat = 8,
    vSpacing: CGFloat = 8,
    placement: MasonryPlacementMode = .fill,
    @ViewBuilder content: @escaping () -> Content
)
```

##### 配置对象初始化
```swift
public init(
    configuration: MasonryConfiguration,
    @ViewBuilder content: @escaping () -> Content
)
```

##### 响应式初始化
```swift
public init(
    breakpoints: [CGFloat: MasonryConfiguration],
    @ViewBuilder content: @escaping () -> Content
)
```

#### 便捷初始化方法

##### 列数配置
```swift
init(
    columns: Int,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping () -> Content
)
```

##### 行数配置
```swift
init(
    rows: Int,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping () -> Content
)
```

##### 自适应列
```swift
init(
    adaptiveColumns minWidth: CGFloat,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping () -> Content
)
```

##### 自适应行
```swift
init(
    adaptiveRows minHeight: CGFloat,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping () -> Content
)
```

##### 响应式布局
```swift
init(
    compactColumns: Int,
    regularColumns: Int,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping () -> Content
)
```

### LazyMasonryStack

懒加载瀑布流视图组件，支持滚动事件检测，适用于分页加载场景。

#### 类型约束
```swift
public struct LazyMasonryStack<Data: RandomAccessCollection, ID: Hashable, Content: View>: View 
where Data.Element: Identifiable, Data.Element.ID == ID
```

#### 初始化方法

##### 完整参数初始化
```swift
public init(
    _ data: Data,
    axis: Axis = .vertical,
    lines: MasonryLines = .fixed(2),
    hSpacing: CGFloat = 8,
    vSpacing: CGFloat = 8,
    placement: MasonryPlacementMode = .fill,
    bottomTriggerThreshold: CGFloat = 0.6,
    debounceInterval: TimeInterval = 1.0,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

##### 配置对象初始化
```swift
public init(
    _ data: Data,
    configuration: MasonryConfiguration,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

#### 便捷初始化方法

##### 列数配置（简洁版）
```swift
init(
    _ data: Data,
    columns: Int,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

##### 列数配置（完整版）
```swift
init(
    _ data: Data,
    columns: Int,
    spacing: CGFloat,
    bottomTriggerThreshold: CGFloat,
    debounceInterval: TimeInterval,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

##### 行数配置（简洁版）
```swift
init(
    _ data: Data,
    rows: Int,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

##### 行数配置（完整版）
```swift
init(
    _ data: Data,
    rows: Int,
    spacing: CGFloat,
    bottomTriggerThreshold: CGFloat,
    debounceInterval: TimeInterval,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

##### 自适应列（简洁版）
```swift
init(
    _ data: Data,
    adaptiveColumns minWidth: CGFloat,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

##### 自适应列（完整版）
```swift
init(
    _ data: Data,
    adaptiveColumns minWidth: CGFloat,
    spacing: CGFloat,
    bottomTriggerThreshold: CGFloat,
    debounceInterval: TimeInterval,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

##### 自适应行（简洁版）
```swift
init(
    _ data: Data,
    adaptiveRows minHeight: CGFloat,
    spacing: CGFloat = 8,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

##### 自适应行（完整版）
```swift
init(
    _ data: Data,
    adaptiveRows minHeight: CGFloat,
    spacing: CGFloat,
    bottomTriggerThreshold: CGFloat,
    debounceInterval: TimeInterval,
    @ViewBuilder content: @escaping (Data.Element) -> Content
)
```

#### 链式配置方法

##### 底部触发回调
```swift
func onReachBottom(_ action: @escaping () -> Void) -> LazyMasonryStack<Data, ID, Content>
```

设置当滚动到底部时的回调函数。当滚动进度达到 `bottomTriggerThreshold` 时触发。

**参数：**
- `action`: 触发时执行的回调函数

**返回值：**
- 配置了底部触发回调的新实例

##### Footer视图支持
```swift
func footer<FooterContent: View>(@ViewBuilder _ footerContent: @escaping () -> FooterContent) -> LazyMasonryStack<Data, ID, Content>
```

为瀑布流添加Footer视图，用于显示加载状态、无更多内容提示等。

**参数：**
- `footerContent`: Footer视图构建器

**返回值：**
- 配置了Footer视图的新实例

**布局行为：**
- 垂直布局：Footer显示在底部，占据全宽
- 水平布局：Footer显示在右侧，占据全高

**使用示例：**
```swift
LazyMasonryStack(items, columns: 2) { item in
    ItemView(item: item)
}
.footer {
    if isLoading {
        ProgressView("加载中...")
    } else if !hasMoreData {
        Text("没有更多内容")
    }
}
.onReachBottom {
    loadMoreData()
}
```

## 配置系统

### MasonryConfiguration

完整的瀑布流布局配置对象。

#### 属性

```swift
public struct MasonryConfiguration: Sendable, Equatable, Hashable {
    /// 布局轴向
    public let axis: Axis
    /// 行/列配置
    public let lines: MasonryLines
    /// 水平间距
    public let hSpacing: CGFloat
    /// 垂直间距
    public let vSpacing: CGFloat
    /// 放置模式
    public let placement: MasonryPlacementMode
    /// 底部触发阈值 (0.0-1.0，表示滚动进度百分比)
    public let bottomTriggerThreshold: CGFloat
    /// 防抖间隔 (秒，避免重复触发)
    public let debounceInterval: TimeInterval
}
```

#### 初始化
```swift
public init(
    axis: Axis = .vertical,
    lines: MasonryLines = .fixed(2),
    hSpacing: CGFloat = 8,
    vSpacing: CGFloat = 8,
    placement: MasonryPlacementMode = .fill,
    bottomTriggerThreshold: CGFloat = 0.6,
    debounceInterval: TimeInterval = 1.0
)
```

#### 预设配置

```swift
/// 默认配置：垂直2列，间距8
static let `default` = MasonryConfiguration()

/// 自适应列配置（最小列宽120）
static let adaptiveColumns = adaptive(minColumnWidth: 120)

/// 水平双行配置
static let twoRows = rows(2)

/// 早期触发配置（滚动到50%时触发，适合快速加载）
static let earlyTrigger = MasonryConfiguration(bottomTriggerThreshold: 0.5)

/// 延迟触发配置（滚动到90%时触发，适合节省资源）
static let lateTrigger = MasonryConfiguration(bottomTriggerThreshold: 0.9)

/// 快速响应配置（0.5秒防抖，适合实时场景）
static let fastResponse = MasonryConfiguration(debounceInterval: 0.5)

/// 慢速响应配置（2秒防抖，适合避免频繁请求）
static let slowResponse = MasonryConfiguration(debounceInterval: 2.0)
```

#### 便捷方法

```swift
/// 创建列数配置
static func columns(_ count: Int, spacing: CGFloat = 8) -> MasonryConfiguration

/// 创建行数配置
static func rows(_ count: Int, spacing: CGFloat = 8) -> MasonryConfiguration

/// 创建自适应列配置
static func adaptive(minColumnWidth: CGFloat, spacing: CGFloat = 8) -> MasonryConfiguration
```

### MasonryLines

定义瀑布流视图中行或列数量的配置。

```swift
public enum MasonryLines: Sendable, Equatable, Hashable {
    /// 固定数量的行或列
    case fixed(Int)
    
    /// 可变数量的行或列
    case adaptive(sizeConstraint: AdaptiveSizeConstraint)
    
    /// 约束瀑布流视图中自适应行或列边界的常量
    public enum AdaptiveSizeConstraint: Equatable, Sendable, Hashable {
        /// 给定轴上行或列的最小尺寸
        case min(CGFloat)
        /// 给定轴上行或列的最大尺寸
        case max(CGFloat)
    }
}
```

#### 便捷方法

```swift
/// 创建自适应配置（最小尺寸）
static func adaptive(minSize: CGFloat) -> MasonryLines

/// 创建自适应配置（最大尺寸）
static func adaptive(maxSize: CGFloat) -> MasonryLines
```

### MasonryPlacementMode

定义项目在瀑布流中的放置策略。

```swift
public enum MasonryPlacementMode: Sendable, Equatable, Hashable {
    /// 智能填充模式：自动选择最短的列进行填充
    case fill

    /// 顺序放置模式：按顺序填充每一列
    case order
}
```

## 类型别名

为了简化使用，库提供了便捷的类型别名：

```swift
/// 基础瀑布流视图的便捷别名
public typealias Masonry = MasonryStack

/// 懒加载瀑布流视图的便捷别名
public typealias LazyMasonry = LazyMasonryStack
```

## 库信息

```swift
public enum SwiftUIMasonryLayouts {
    /// 库版本号
    public static let version = "1.2.0"
}
```
