# 性能优化指南

## 概述

SwiftUIMasonryLayouts 基于 SwiftUI Layout 协议构建，内置了多项性能优化机制。本指南将帮助您充分利用这些优化特性，并提供额外的性能优化建议。

## 内置性能优化

### 智能缓存系统
库内置了智能缓存系统，自动缓存布局计算结果，避免重复计算。

#### 缓存机制
- **布局结果缓存**：缓存完整的布局计算结果
- **容器尺寸检测**：容器尺寸变化时自动失效缓存
- **配置哈希验证**：配置变化时自动重新计算
- **子视图数量检测**：数据变化时智能更新缓存

#### 缓存性能指标
在 DEBUG 模式下，库会自动统计缓存性能：
- 缓存命中次数
- 缓存未命中次数
- 缓存命中率
- 计算耗时统计

### 预计算优化
关键布局参数在初始化时预计算，避免运行时重复计算：
- 行/列数量预计算
- 行/列尺寸预计算
- 间距分布预计算

### 防抖机制
内置防抖机制避免频繁的布局更新和回调触发：
- 响应式布局防抖（50ms）
- 滚动事件防抖（可配置）
- 数据更新防抖

## 组件选择策略

### MasonryStack vs LazyMasonryStack

#### 使用 MasonryStack 的场景
- **静态内容**：数据不会动态变化
- **小数据集**：项目数量 < 100
- **简单布局**：不需要滚动事件检测
- **性能要求极高**：需要最小的内存占用

```swift
// 适合静态内容
MasonryStack(columns: 2) {
    ForEach(staticItems) { item in
        StaticItemView(item: item)
    }
}
```

#### 使用 LazyMasonryStack 的场景
- **动态内容**：需要分页加载或实时更新
- **大数据集**：项目数量 > 100
- **滚动交互**：需要检测滚动事件
- **分页场景**：需要触发加载更多数据

```swift
// 适合动态内容
LazyMasonryStack(items, columns: 2) { item in
    DynamicItemView(item: item)
}
.onReachBottom {
    loadMoreData()
}
```

## 配置优化

### 列宽/行高配置优化

#### 固定数量 vs 自适应
- **固定数量**：性能最佳，计算简单
- **自适应**：灵活性高，但计算复杂度稍高

```swift
// 性能最佳：固定列数
MasonryStack(columns: 2) { /* 内容 */ }

// 灵活性高：自适应列宽
MasonryStack(adaptiveColumns: 120) { /* 内容 */ }
```

#### 自适应配置优化
选择合理的最小尺寸值，避免过小导致列数过多：

```swift
// 推荐：合理的最小列宽
MasonryStack(adaptiveColumns: 120) { /* 内容 */ }

// 避免：过小的最小列宽可能导致性能问题
MasonryStack(adaptiveColumns: 50) { /* 内容 */ }
```

### 间距配置优化
统一间距比分别设置水平和垂直间距性能更好：

```swift
// 推荐：统一间距
MasonryStack(columns: 2, spacing: 8) { /* 内容 */ }

// 可接受：分别设置间距
MasonryStack(lines: .fixed(2), hSpacing: 8, vSpacing: 12) { /* 内容 */ }
```

### 触发阈值优化

#### 底部触发阈值
根据数据加载速度调整触发时机：

```swift
// 快速网络：早期触发
LazyMasonryStack(items, bottomTriggerThreshold: 0.5) { /* 内容 */ }

// 慢速网络：延迟触发
LazyMasonryStack(items, bottomTriggerThreshold: 0.8) { /* 内容 */ }
```

#### 防抖间隔
根据使用场景调整防抖间隔：

```swift
// 实时场景：短防抖
LazyMasonryStack(items, debounceInterval: 0.3) { /* 内容 */ }

// 批量处理：长防抖
LazyMasonryStack(items, debounceInterval: 2.0) { /* 内容 */ }
```

## 数据优化

### 数据结构优化

#### 实现 Identifiable
确保数据模型正确实现 Identifiable 协议：

```swift
struct Item: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}
```

#### 使用稳定的 ID
避免使用数组索引作为 ID，使用稳定的唯一标识符：

```swift
// 推荐：稳定的 ID
struct Item: Identifiable {
    let id: String  // 来自服务器的唯一 ID
    let title: String
}

// 避免：不稳定的 ID
struct Item: Identifiable {
    var id: Int { hashValue }  // 可能变化的 ID
    let title: String
}
```

### 数据加载优化

#### 分页加载
实现高效的分页加载机制：

```swift
class DataLoader: ObservableObject {
    @Published var items: [Item] = []
    private var isLoading = false
    
    func loadMore() {
        guard !isLoading else { return }
        isLoading = true
        
        // 异步加载数据
        Task {
            let newItems = await fetchNextPage()
            await MainActor.run {
                self.items.append(contentsOf: newItems)
                self.isLoading = false
            }
        }
    }
}
```

#### 预加载策略
根据滚动速度调整预加载时机：

```swift
LazyMasonryStack(
    items,
    bottomTriggerThreshold: 0.6  // 60% 时开始预加载
) { item in
    ItemView(item: item)
}
.onReachBottom {
    dataLoader.loadMore()
}
```

## 视图优化

### 子视图优化

#### 避免复杂的子视图
保持子视图简单，避免过度嵌套：

```swift
// 推荐：简单的子视图
struct ItemView: View {
    let item: Item
    
    var body: some View {
        VStack {
            AsyncImage(url: item.imageURL)
            Text(item.title)
        }
    }
}

// 避免：过度复杂的子视图
struct ComplexItemView: View {
    let item: Item
    
    var body: some View {
        VStack {
            // 多层嵌套的复杂视图
            // 大量的修饰符
            // 复杂的动画
        }
    }
}
```

#### 使用 LazyVStack/LazyHStack
在子视图内部使用懒加载容器：

```swift
struct ItemView: View {
    let item: Item
    
    var body: some View {
        LazyVStack {
            AsyncImage(url: item.imageURL)
            Text(item.title)
            // 其他内容
        }
    }
}
```

### 图片优化

#### 使用 AsyncImage
利用 SwiftUI 的 AsyncImage 进行图片异步加载：

```swift
AsyncImage(url: item.imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    Rectangle()
        .fill(Color.gray.opacity(0.3))
}
```

#### 图片尺寸优化
根据显示尺寸请求合适的图片：

```swift
// 根据列宽计算合适的图片尺寸
let imageSize = Int(columnWidth * UIScreen.main.scale)
let imageURL = URL(string: "https://example.com/image?w=\(imageSize)")
```

## 内存优化

### 避免内存泄漏

#### 正确使用回调
避免在回调中创建强引用循环：

```swift
LazyMasonryStack(items, columns: 2) { item in
    ItemView(item: item)
}
.onReachBottom { [weak self] in
    self?.loadMoreData()
}
```

#### 及时清理资源
在视图消失时清理不必要的资源：

```swift
struct ContentView: View {
    @StateObject private var dataLoader = DataLoader()
    
    var body: some View {
        LazyMasonryStack(dataLoader.items, columns: 2) { item in
            ItemView(item: item)
        }
        .onDisappear {
            dataLoader.cleanup()
        }
    }
}
```

## 性能监控

### 使用 Instruments
使用 Xcode Instruments 监控性能：
- **Time Profiler**：检查 CPU 使用情况
- **Allocations**：监控内存使用
- **Core Animation**：检查渲染性能

### 性能基准测试
库提供了性能测试套件，可以作为基准：

```swift
// 运行性能测试
xcodebuild test -scheme SwiftUIMasonryLayouts -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### 自定义性能监控
在关键路径添加性能监控：

```swift
func loadMoreData() {
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // 数据加载逻辑
    
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("数据加载耗时: \(timeElapsed)s")
}
```

## 最佳实践总结

1. **选择合适的组件**：根据使用场景选择 MasonryStack 或 LazyMasonryStack
2. **优化配置参数**：使用合理的列宽、间距和触发阈值
3. **简化子视图**：保持子视图简单，避免过度复杂
4. **高效数据加载**：实现分页加载和预加载策略
5. **监控性能**：定期使用 Instruments 检查性能
6. **测试不同场景**：在不同数据量和设备上测试性能
