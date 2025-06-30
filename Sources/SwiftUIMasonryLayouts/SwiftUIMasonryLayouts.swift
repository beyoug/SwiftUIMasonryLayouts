/**
*  SwiftUIMasonryLayouts Tests
*  Copyright (c) Beyoug 2025
*  MIT license, see LICENSE file for details
*/

import SwiftUI

// MARK: - 库信息

/// SwiftUIMasonryLayouts - 现代化的SwiftUI瀑布流布局库
///
/// SwiftUIMasonryLayouts为SwiftUI应用程序提供高性能、灵活的瀑布流布局。
/// 基于iOS 18.0+ Layout协议构建，提供最佳性能和原生SwiftUI集成。
///
/// ## 系统要求
/// - iOS 18.0+ / macOS 15.0+ / tvOS 18.0+ / watchOS 11.0+ / visionOS 2.0+
/// - Xcode 16.0+
/// - Swift 6.0+
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum SwiftUIMasonryLayouts {
    /// 库版本号
    public static let version = "1.0.0"
}

// MARK: - 便捷类型别名

/// 瀑布流视图的便捷别名
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public typealias Masonry = MasonryView

/// 懒加载瀑布流视图的便捷别名（推荐用于大数据集）
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public typealias LazyMasonry = LazyMasonryView
