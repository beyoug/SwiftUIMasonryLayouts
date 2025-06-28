//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 基础瀑布流视图

/// 基于iOS 18.0+ Layout协议的现代瀑布流视图
/// 提供简洁的API和高性能布局
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct MasonryView<Content: View>: View {

    /// 布局轴向
    private let axis: Axis
    /// 行/列配置
    private let lines: MasonryLines
    /// 水平间距
    private let horizontalSpacing: CGFloat
    /// 垂直间距
    private let verticalSpacing: CGFloat
    /// 放置模式
    private let placementMode: MasonryPlacementMode
    /// 内容构建器
    private let content: () -> Content

    /// 初始化瀑布流视图
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    ///   - content: 视图内容构建器
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.lines = lines
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.placementMode = placementMode
        self.content = content
    }

    public var body: some View {
        MasonryLayout(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode
        ) {
            content()
        }
    }
}

// MARK: - 便捷构造器

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension MasonryView {

    /// 创建垂直瀑布流
    /// - Parameters:
    ///   - columns: 列数配置
    ///   - spacing: 间距
    ///   - placementMode: 放置模式
    ///   - content: 内容构建器
    /// - Returns: 垂直瀑布流视图
    static func vertical<C: View>(
        columns: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        @ViewBuilder content: @escaping () -> C
    ) -> MasonryView<C> {
        MasonryView<C>(
            axis: .vertical,
            lines: columns,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode,
            content: content
        )
    }

    /// 创建水平瀑布流
    /// - Parameters:
    ///   - rows: 行数配置
    ///   - spacing: 间距
    ///   - placementMode: 放置模式
    ///   - content: 内容构建器
    /// - Returns: 水平瀑布流视图
    static func horizontal<C: View>(
        rows: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        @ViewBuilder content: @escaping () -> C
    ) -> MasonryView<C> {
        MasonryView<C>(
            axis: .horizontal,
            lines: rows,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode,
            content: content
        )
    }
}
