# SwiftUIMasonryLayouts

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018%2B%20%7C%20macOS%2015%2B%20%7C%20tvOS%2018%2B%20%7C%20watchOS%2011%2B%20%7C%20visionOS%202%2B-blue.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

现代化的SwiftUI瀑布流布局库，基于iOS 18.0+ Layout协议构建，提供高性能、灵活的瀑布流布局解决方案。

## ✨ 特性

- 🚀 **高性能**: 基于原生Layout协议，提供最佳性能
- 📱 **多平台支持**: iOS、macOS、tvOS、watchOS、visionOS
- 🎯 **灵活配置**: 支持固定列数和自适应列数
- 🔄 **多种布局模式**: 垂直、水平瀑布流
- 💾 **懒加载支持**: 适用于大数据集的虚拟化渲染
- 📐 **响应式设计**: 根据屏幕尺寸自动调整布局
- 🎨 **易于使用**: 简洁的API设计，与SwiftUI完美集成

## 📋 系统要求

- iOS 18.0+ / macOS 15.0+ / tvOS 18.0+ / watchOS 11.0+ / visionOS 2.0+
- Swift 6.0+
- Xcode 16.0+

## 📦 安装

### Swift Package Manager

在Xcode中添加包依赖：

```
https://github.com/beyoug/SwiftUIMasonryLayouts.git
```

或在`Package.swift`中添加：

```swift
dependencies: [
    .package(url: "https://github.com/beyoug/SwiftUIMasonryLayouts.git", from: "1.0.0")
]
```

## 🚀 快速开始

### 基础用法

最简单的瀑布流布局：

```swift
import SwiftUI
import SwiftUIMasonryLayouts

struct ContentView: View {
    let items = Array(1...20)

    var body: some View {
        ScrollView {
            MasonryView.vertical(columns: .fixed(2), spacing: 8) {
                ForEach(items, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.7))
                        .frame(height: CGFloat.random(in: 100...300))
                        .overlay(Text("\(item)").foregroundColor(.white))
                }
            }
            .padding()
        }
    }
}
```

### 更多用法

查看 [API文档](Documentation/API_DOCUMENTATION.md) 了解：
- 自适应列数配置
- 数据驱动布局 (`DataMasonryView`)
- 大数据集虚拟化 (`LazyMasonryView`)
- 响应式布局 (`ResponsiveMasonryView`)
- 水平瀑布流
- 性能优化技巧
- 完整配置选项

## 📖 API文档

查看 [完整API文档](Documentation/API_DOCUMENTATION.md) 了解：

- **所有视图类型详解**：MasonryView、DataMasonryView、LazyMasonryView、ResponsiveMasonryView
- **配置选项**：MasonryConfiguration、MasonryLines、MasonryPlacementMode
- **高级用法**：水平瀑布流、性能优化、与其他组件集成
- **选择指南**：何时使用哪种视图类型
- **最佳实践**：数据模型设计、性能优化技巧
- **故障排除**：常见问题解答和调试技巧



## 📄 许可证

本项目采用MIT许可证。详情请参阅[LICENSE](LICENSE)文件。

## 👨‍💻 作者

Beyoug - [GitHub](https://github.com/beyoug)

## 🌟 致谢

特别感谢：
- SwiftUI团队提供的Layout协议
- Augment Code 提供的 Claude Sonnet 4 AI 助手协助开发和文档编写

---

如果这个库对你有帮助，请给个⭐️支持一下！
