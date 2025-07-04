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

## 📱 示例预览

### 使用 Examples 文件夹

为了保持核心库的纯净性，`Examples` 文件夹默认位于项目根目录外部。如果您想要查看和运行示例代码：

1. **查看示例代码**：Examples 文件夹包含完整的示例实现
2. **运行示例预览**：将 `Examples` 文件夹移动到 `Sources/SwiftUIMasonryLayouts/` 目录下
3. **在 Xcode 中预览**：移动后即可在 Xcode 中查看 SwiftUI 预览

```bash
# 移动 Examples 到源码目录以启用预览
mv Examples Sources/SwiftUIMasonryLayouts/

# 在 Xcode 中打开项目并查看预览
open Package.swift
```

> **注意**：Examples 文件夹包含测试数据和示例视图，仅用于演示目的。在生产环境中使用时，建议将其保持在源码目录外部。

### 示例内容

- **LazyMasonryExample.swift** - 完整的瀑布流示例，包含垂直和水平布局
- **SampleTestData.swift** - 200条静态测试数据，用于演示各种布局场景
- **TestDataModels.swift** - 数据管理器，支持不同类型的测试数据加载

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

## ⚠️ 重要提醒

**本项目使用 AI 辅助开发**

本项目在设计和编码过程中使用了 AI 技术（Claude Sonnet 4）进行辅助开发。虽然所有代码都经过了编译测试和功能验证，但可能存在以下情况：

- 🔍 **测试覆盖不完整** - 某些边界情况可能未被充分测试
- 🐛 **潜在的逻辑缺陷** - AI 生成的代码可能包含人类开发者容易忽略的问题
- 📱 **设备兼容性** - 在不同设备和系统版本上的表现可能存在差异
- ⚡ **性能优化空间** - 某些实现可能不是最优解决方案

**我们强烈建议：**
- 在生产环境使用前进行充分测试
- 根据具体需求进行代码审查和优化
- 报告发现的任何问题或改进建议

## 🤝 贡献

我们热烈欢迎社区贡献！您的参与对于提升项目质量至关重要：

### 如何贡献
- 🐛 **报告问题** - 发现 bug 或不当行为请提交 Issue
- 💡 **功能建议** - 提出新功能或改进建议
- 🔧 **代码贡献** - 提交 Pull Request 修复问题或添加功能
- 📖 **文档改进** - 完善文档和示例代码
- 🧪 **测试补充** - 添加测试用例提高代码覆盖率

### 开发指南
- 遵循 Swift 编码规范
- 添加适当的文档注释
- 编写单元测试
- 确保 iOS 和 iPadOS 平台编译通过
- 在 iPhone 16 Pro 模拟器上进行测试验证


## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- 感谢 Apple 提供的 SwiftUI Layout 协议
- 感谢所有贡献者和用户的支持
- 特别感谢 SwiftUI 社区的宝贵建议
- 感谢 Anthropic 的 Claude Sonnet 4 模型在代码设计和实现中提供的 AI 辅助支持

## 📞 联系我们

- **GitHub Issues** - [提交问题](https://github.com/beyoug/SwiftUIMasonryLayouts/issues)
- **讨论** - [GitHub Discussions](https://github.com/beyoug/SwiftUIMasonryLayouts/discussions)

---

**SwiftUIMasonryLayouts** - 让瀑布流布局变得简单而强大 🚀
