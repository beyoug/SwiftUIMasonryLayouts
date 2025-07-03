# SwiftUIMasonryLayouts

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018%2B%20%7C%20iPadOS%2018%2B-blue.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

现代化的 SwiftUI 瀑布流布局库，专为 iOS 18.0+ 和 iPadOS 18.0+ 设计，基于最新 Layout 协议构建，提供高性能、灵活的瀑布流布局解决方案。

## ✨ 核心特性

### 🚀 高性能架构
- **原生 Layout 协议** - 基于 SwiftUI Layout 协议，获得最佳性能
- **智能缓存系统** - 自动缓存布局计算结果，避免重复计算
- **响应式设计** - 支持断点配置，自适应不同屏幕尺寸

### 📐 灵活布局配置
- **多轴向支持** - 支持垂直和水平布局
- **固定/自适应列宽** - 支持固定列数或基于最小宽度的自适应列
- **智能填充模式** - 自动选择最短列进行填充

### 🔄 懒加载支持
- **滚动触发** - 支持顶部和底部滚动触发事件
- **防抖机制** - 内置防抖功能，避免频繁触发
- **分页加载** - 完美支持分页数据加载场景

## 📋 系统要求

- **iOS 18.0+ / iPadOS 18.0+**
- **Xcode 16.0+**
- **Swift 6.0+**

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

### 基础瀑布流

```swift
import SwiftUIMasonryLayouts

MasonryStack(columns: 2, spacing: 8) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

### 懒加载瀑布流

```swift
LazyMasonryStack(items, columns: 2, spacing: 8) { item in
    ItemView(item: item)
}
.onReachBottom {
    loadMoreData()
}
```

### 自适应列宽

```swift
MasonryStack(adaptiveColumns: 120, spacing: 8) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

### 响应式布局

```swift
MasonryStack(
    phoneColumns: 2,
    tabletColumns: 3,
    spacing: 8
) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

## 📚 核心组件

### MasonryStack
基础瀑布流视图，适用于静态内容和简单布局场景。

### LazyMasonryStack
懒加载瀑布流视图，支持滚动事件检测，适用于分页加载场景。

### MasonryConfiguration
完整的配置对象，包含所有布局参数和滚动配置。

## 📖 完整文档

详细的 API 文档请查看：
- [API 参考文档](Documents/API-Reference.md)
- [配置指南](Documents/Configuration-Guide.md)
- [性能优化](Documents/Performance-Guide.md)

## 🤝 贡献

我们欢迎社区贡献！

### 开发指南
- 遵循 Swift 编码规范
- 添加适当的文档注释
- 编写单元测试
- 确保 iOS 和 iPadOS 平台编译通过

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