# SwiftUIMasonryLayouts

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018%2B%20%7C%20macOS%2015%2B%20%7C%20tvOS%2018%2B%20%7C%20watchOS%2011%2B%20%7C%20visionOS%202%2B-blue.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

现代化的 SwiftUI 瀑布流布局库，基于 iOS 18.0+ Layout 协议构建，提供高性能、灵活的瀑布流布局解决方案。

## ✨ 核心特性

### 🚀 高性能架构
- **原生 Layout 协议** - 基于 SwiftUI Layout 协议，获得最佳性能
- **智能缓存系统** - 自动缓存布局计算结果，避免重复计算
- **懒加载渲染** - 只渲染可见区域，大幅减少内存占用
- **优化的滚动性能** - 流畅的滚动体验，无卡顿


### 🎨 灵活布局
- **双轴布局** - 支持垂直和水平瀑布流
- **响应式设计** - 内置断点系统，自动适配不同屏幕尺寸
- **自适应列数** - 根据内容宽度自动调整列数
- **智能间距** - 自动计算最佳间距

### 🔌 智能交互
- **滚动回调** - 到达顶部/底部时的智能回调
- **分页加载** - 内置分页加载机制，支持无限滚动
- **可配置触发** - 灵活的触发阈值配置
- **防抖机制** - 避免频繁触发，优化性能

## 📋 系统要求

- **iOS 18.0+** /
- **Xcode 16.0+**

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

## 🤝 贡献

我们欢迎社区贡献！
### 开发指南

- 遵循 Swift 编码规范
- 添加适当的文档注释
- 编写单元测试
- 确保所有平台编译通过

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