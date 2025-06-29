# SwiftUIMasonryLayouts 示例

这个目录包含了 SwiftUIMasonryLayouts 库的各种使用示例和演示代码。

## 📁 文件说明

### `BusinessIntegrationExamples.swift`
**完整的业务集成示例** - 展示如何在实际业务场景中使用瀑布流布局

包含以下完整示例：
- **分页加载示例** - 展示如何实现无限滚动和分页数据加载
- **下拉刷新示例** - 展示如何集成SwiftUI原生下拉刷新
- **搜索过滤示例** - 展示如何实现实时搜索和数据过滤
- **状态管理示例** - 展示如何处理加载、错误、空状态等
- **性能监控示例** - 展示如何监控布局性能和内存使用

**特点：**
- 完整的业务逻辑实现
- 遵循MVVM架构模式
- 展示业务层和布局层的分离
- 包含错误处理和边界情况
- 涵盖了从基础到高级的所有使用场景

## 🚀 如何使用

### 1. 导入库
```swift
import SwiftUIMasonryLayouts
```

### 2. 运行示例
这些示例可以直接在你的项目中运行，或者作为参考来实现自己的功能。

### 3. 业务集成参考
`BusinessIntegrationExamples.swift` 中的代码展示了最佳实践：

```swift
// 基础用法
LazyMasonryView(items, columns: 2) { item in
    ItemView(item: item)
}
.onReachBottom {
    // 业务层处理分页
    Task { await loadMoreItems() }
}

// 下拉刷新
.refreshable {
    await refreshData()
}
```

### 4. 配置测试
如果需要快速测试不同配置，可以参考以下代码片段：

```swift
// 测试不同列数配置
let configurations = [
    MasonryConfiguration.columns(1),
    MasonryConfiguration.columns(2),
    MasonryConfiguration.columns(3)
]

// 测试响应式布局
let breakpoints: [CGFloat: MasonryConfiguration] = [
    0: .columns(1),
    400: .columns(2),
    800: .columns(3)
]
```

## 📋 示例特点

### ✅ 遵循最佳实践
- 职责分离：布局组件只关注布局，业务逻辑在业务层处理
- 性能优化：使用懒加载和缓存机制
- 错误处理：包含完整的错误处理逻辑

### ✅ 真实场景
- 模拟真实的网络请求延迟
- 处理各种边界情况
- 包含用户交互反馈

### ✅ 易于理解
- 详细的代码注释
- 清晰的组件结构
- 渐进式的复杂度

## 🎯 学习路径

1. **从基础配置开始**
   - 了解 `MasonryConfiguration` 的各种选项
   - 熟悉固定列数和自适应布局
   - 测试不同的间距和放置模式

2. **深入 `BusinessIntegrationExamples.swift`**
   - 学习完整的业务集成模式
   - 理解数据流管理和状态处理
   - 掌握性能优化技巧

3. **自定义实现**
   - 基于示例创建自己的组件
   - 根据业务需求调整配置
   - 实现特定的交互逻辑

## 📝 注意事项

- 这些示例仅用于演示，不是库的公共API
- 示例中的数据模型和业务逻辑可以根据实际需求调整
- 建议在实际项目中根据具体需求进行适配

## 🔗 相关文档

- [纯粹设计理念](../Documentation/PureMasonryDesign.md)
- [项目结构指南](../Documentation/ProjectStructureGuide.md)
- [主要README](../README.md)

---

这些示例展示了 SwiftUIMasonryLayouts 库的强大功能和灵活性，帮助你快速上手并在实际项目中应用。
