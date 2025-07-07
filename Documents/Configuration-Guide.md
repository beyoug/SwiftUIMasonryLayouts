# 配置指南

## 概述

SwiftUIMasonryLayouts 提供了灵活的配置系统，支持多种布局模式和响应式设计。本指南将详细介绍各种配置选项的使用方法。

## 轴向配置

### 垂直布局（默认）
垂直布局是最常见的瀑布流形式，项目从上到下排列，分布在多个列中。

```swift
MasonryStack(axis: .vertical, lines: .fixed(2)) {
    // 内容
}
```

### 水平布局
水平布局将项目从左到右排列，分布在多个行中。

```swift
MasonryStack(axis: .horizontal, lines: .fixed(3)) {
    // 内容
}
```

## 列宽/行高配置

### 固定数量

#### 固定列数
```swift
// 2列布局
MasonryStack(columns: 2) {
    // 内容
}

// 等价于
MasonryStack(lines: .fixed(2)) {
    // 内容
}
```

#### 固定行数
```swift
// 3行布局
MasonryStack(rows: 3) {
    // 内容
}

// 等价于
MasonryStack(axis: .horizontal, lines: .fixed(3)) {
    // 内容
}
```

### 自适应尺寸

#### 自适应列宽
根据容器宽度和最小列宽自动计算列数。

```swift
// 最小列宽120，自动计算列数
MasonryStack(adaptiveColumns: 120) {
    // 内容
}

// 等价于
MasonryStack(lines: .adaptive(minSize: 120)) {
    // 内容
}
```

#### 自适应行高
根据容器高度和最小行高自动计算行数。

```swift
// 最小行高100，自动计算行数
MasonryStack(adaptiveRows: 100) {
    // 内容
}

// 等价于
MasonryStack(
    axis: .horizontal,
    lines: .adaptive(minSize: 100)
) {
    // 内容
}
```

## 间距配置

### 统一间距
```swift
MasonryStack(columns: 2, spacing: 12) {
    // 内容
}
```

### 分别设置水平和垂直间距
```swift
MasonryStack(
    lines: .fixed(2),
    hSpacing: 16,  // 水平间距
    vSpacing: 12   // 垂直间距
) {
    // 内容
}
```

## 放置模式

### 智能填充（默认）
自动选择最短的列进行填充，保持布局平衡。

```swift
MasonryStack(placement: .fill) {
    // 内容
}
```

### 顺序填充
按顺序填充每一列，适用于需要保持特定顺序的场景。

```swift
MasonryStack(placement: .order) {
    // 内容
}
```

## 懒加载配置

### 滚动触发阈值

#### 底部触发阈值
控制何时触发底部回调，值为0.0-1.0，表示滚动进度百分比。

```swift
LazyMasonryStack(
    items,
    columns: 2,
    bottomTriggerThreshold: 0.8  // 滚动到80%时触发
) { item in
    ItemView(item: item)
}
.onReachBottom {
    loadMoreData()
}
```

### 防抖配置
避免频繁触发回调，设置防抖间隔。

```swift
LazyMasonryStack(
    items,
    columns: 2,
    debounceInterval: 0.5  // 0.5秒防抖
) { item in
    ItemView(item: item)
}
```

## Footer视图配置

### 添加Footer视图
为懒加载瀑布流添加Footer视图，用于显示加载状态或其他信息。

```swift
LazyMasonryStack(items, columns: 2) { item in
    ItemView(item: item)
}
.footer {
    if isLoading {
        HStack {
            ProgressView()
            Text("加载中...")
        }
        .padding()
    } else if !hasMoreData {
        Text("没有更多内容")
            .foregroundColor(.secondary)
            .padding()
    }
}
.onReachBottom {
    loadMoreData()
}
```

### Footer布局行为
- **垂直布局**：Footer显示在瀑布流底部，占据全宽
- **水平布局**：Footer显示在瀑布流右侧，占据全高

## 响应式布局

### 断点配置
根据屏幕宽度使用不同的布局配置。

```swift
let breakpoints: [CGFloat: MasonryConfiguration] = [
    0: .columns(1, spacing: 8),      // 小屏幕：1列
    480: .columns(2, spacing: 12),   // 中等屏幕：2列
    768: .columns(3, spacing: 16),   // 大屏幕：3列
    1024: .columns(4, spacing: 20)   // 超大屏幕：4列
]

MasonryStack(breakpoints: breakpoints) {
    // 内容
}
```

### 简化响应式配置
针对手机和平板的简化配置。

```swift
MasonryStack(
    phoneColumns: 2,    // 手机端2列
    tabletColumns: 3    // 平板端3列
) {
    // 内容
}
```

## 预设配置

### 使用预设配置
```swift
// 默认配置
MasonryStack(configuration: .default) {
    // 内容
}

// 自适应列配置
MasonryStack(configuration: .adaptiveColumns) {
    // 内容
}

// 水平双行配置
MasonryStack(configuration: .twoRows) {
    // 内容
}

// 早期触发配置（适合快速加载）
LazyMasonryStack(items, configuration: .earlyTrigger) { item in
    ItemView(item: item)
}

// 延迟触发配置（适合节省资源）
LazyMasonryStack(items, configuration: .lateTrigger) { item in
    ItemView(item: item)
}

// 快速响应配置（适合实时场景）
LazyMasonryStack(items, configuration: .fastResponse) { item in
    ItemView(item: item)
}

// 慢速响应配置（适合避免频繁请求）
LazyMasonryStack(items, configuration: .slowResponse) { item in
    ItemView(item: item)
}
```

### 自定义配置
```swift
let customConfig = MasonryConfiguration(
    axis: .vertical,
    lines: .adaptive(minSize: 150),
    hSpacing: 20,
    vSpacing: 16,
    placement: .fill,
    bottomTriggerThreshold: 0.7,
    debounceInterval: 1.5
)

LazyMasonryStack(items, configuration: customConfig) { item in
    ItemView(item: item)
}
```

## 最佳实践

### 选择合适的组件
- **MasonryStack**：适用于静态内容，数据量较小的场景
- **LazyMasonryStack**：适用于动态内容，需要分页加载的场景

### Footer使用建议
- 使用Footer显示加载状态，提升用户体验
- 在Footer中提供明确的状态反馈（加载中、无更多内容等）
- 保持Footer设计简洁，避免影响主要内容的展示
- 考虑不同轴向下Footer的布局表现

### 性能优化
- 使用自适应列宽时，选择合理的最小宽度值
- 设置适当的防抖间隔，避免频繁触发
- 在大数据量场景下优先使用 LazyMasonryStack

### 响应式设计
- 根据目标设备设置合适的断点
- 考虑不同屏幕尺寸下的用户体验
- 测试各种屏幕尺寸下的布局效果

### 触发阈值设置
- **早期触发**（0.5-0.6）：适合快速加载，提升用户体验
- **标准触发**（0.6-0.8）：平衡性能和用户体验
- **延迟触发**（0.8-0.9）：适合节省资源，减少不必要的请求
