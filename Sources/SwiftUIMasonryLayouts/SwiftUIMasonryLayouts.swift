//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 库信息

/// SwiftUIMasonryLayouts - 现代化的SwiftUI瀑布流布局库
///
/// SwiftUIMasonryLayouts为SwiftUI应用程序提供高性能、灵活的瀑布流布局。
/// 基于iOS 18.0+ Layout协议构建，提供最佳性能和原生SwiftUI集成。
///
/// ## 基本用法
/// ```swift
/// import SwiftUIMasonryLayouts
///
/// // 基础瀑布流
/// MasonryView.vertical(columns: .fixed(2), spacing: 8) {
///     ForEach(items) { item in
///         ItemView(item: item)
///     }
/// }
///
/// // 自适应列数
/// MasonryView.vertical(columns: .adaptive(minSize: 120)) {
///     ForEach(items) { item in
///         ItemView(item: item)
///     }
/// }
///
/// // 数据驱动
/// DataMasonryView.vertical(
///     columns: .fixed(3),
///     data: items,
///     id: \.id
/// ) { item in
///     ItemView(item: item)
/// }
///
/// // 虚拟化懒加载（适用于大数据集）
/// LazyMasonryView.vertical(
///     columns: .adaptive(minSize: 150),
///     data: largeDataSet,
///     id: \.id,
///     estimatedItemSize: CGSize(width: 150, height: 200)
/// ) { item in
///     ItemView(item: item)
/// }
///
/// // 响应式设计
/// ResponsiveMasonryView.withCommonBreakpoints {
///     ForEach(items) { item in
///         ItemView(item: item)
///     }
/// }
/// ```
///
/// ## 系统要求
/// - iOS 18.0+ / macOS 15.0+ / tvOS 18.0+ / watchOS 11.0+ / visionOS 2.0+
/// - Xcode 16.0+
/// - Swift 6.0+
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum SwiftUIMasonryLayouts {
    /// 库版本号
    public static let version = "2.0.0"
}

// MARK: - 便捷类型别名

/// 瀑布流视图的便捷别名
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public typealias Masonry = MasonryView

/// 懒加载瀑布流视图的便捷别名
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public typealias LazyMasonry = LazyMasonryView

/// 响应式瀑布流视图的便捷别名
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public typealias ResponsiveMasonry = ResponsiveMasonryView
