# SwiftUIMasonryLayouts

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018%2B%20%7C%20macOS%2015%2B%20%7C%20tvOS%2018%2B%20%7C%20watchOS%2011%2B%20%7C%20visionOS%202%2B-blue.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

现代化的 SwiftUI 瀑布流布局库，基于 iOS 18.0+ Layout 协议构建，提供高性能、灵活的瀑布流布局解决方案。

## ✨ 特性

- 🚀 **高性能**: 基于原生 Layout 协议，智能缓存机制
- 📱 **多平台支持**: iOS、macOS、tvOS、watchOS、visionOS 全平台兼容
- 🔄 **双轴布局**: 支持垂直和水平瀑布流布局
- 📐 **响应式设计**: 内置断点系统，根据屏幕尺寸自动调整布局
- 🔄 **懒加载渲染**: 只渲染可见区域，大幅减少内存占用
- 🔌 **可扩展接口**: 提供回调钩子，业务层可灵活实现复杂功能

## 📋 系统要求

- iOS 18.0+ / macOS 15.0+ / tvOS 18.0+ / watchOS 11.0+ / visionOS 2.0+
- Swift 6.0+
- Xcode 16.0+

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


## 📚 文档

详细的API文档和使用指南请参阅：

- **[API 接口文档](Documentation/API.md)** - 完整的API参考和使用说明
- **[示例集合](Documentation/Examples.md)** - 丰富的使用示例和集成案例



## 🤝 贡献

欢迎贡献代码！部分代码由AI完成，可能存在并未覆盖到的特殊场景，如有任何问题欢迎pr。

## 📄 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

## 👨‍💻 作者

**Beyoug** - [GitHub](https://github.com/beyoug)

## 🌟 致谢

特别感谢：
- **SwiftUI 团队** - 提供强大的 Layout 协议基础
- **Augment Code** - 提供 Claude Sonnet 4 AI 助手协助开发和文档编写
- **开源社区** - 提供灵感和反馈

---

**SwiftUIMasonryLayouts** - 让瀑布流布局变得简单而强大 🚀
