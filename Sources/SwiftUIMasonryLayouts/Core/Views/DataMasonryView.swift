//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 数据驱动的瀑布流视图

/// 基于数据集合的瀑布流视图
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct DataMasonryView<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View
{

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
    /// 数据集合
    private let data: Data
    /// ID键路径
    private let id: KeyPath<Data.Element, ID>
    /// 内容构建器
    private let content: (Data.Element) -> Content

    /// 初始化数据驱动的瀑布流视图
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    ///   - data: 数据集合
    ///   - id: 数据元素的ID键路径
    ///   - content: 数据元素的视图构建器
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.axis = axis
        self.lines = lines
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.placementMode = placementMode
        self.data = data
        self.id = id
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
            ForEach(data, id: id) { item in
                content(item)
            }
        }
    }
}

// MARK: - 可识别数据扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension DataMasonryView where Data.Element: Identifiable, ID == Data.Element.ID {

    /// 为可识别数据元素提供的便捷初始化器
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    ///   - data: 实现了Identifiable协议的数据集合
    ///   - content: 数据元素的视图构建器
    init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode,
            data: data,
            id: \.id,
            content: content
        )
    }
}

// MARK: - 数据瀑布流便捷构造器

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension DataMasonryView {

    /// 创建垂直数据驱动瀑布流
    /// - Parameters:
    ///   - columns: 列数配置
    ///   - spacing: 间距
    ///   - placementMode: 放置模式
    ///   - data: 数据集合
    ///   - id: 数据元素的ID键路径
    ///   - content: 内容构建器
    /// - Returns: 垂直数据瀑布流视图
    static func vertical<D, I, C>(
        columns: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: D,
        id: KeyPath<D.Element, I>,
        @ViewBuilder content: @escaping (D.Element) -> C
    ) -> DataMasonryView<D, I, C>
    where D: RandomAccessCollection, I: Hashable, C: View {
        DataMasonryView<D, I, C>(
            axis: .vertical,
            lines: columns,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode,
            data: data,
            id: id,
            content: content
        )
    }

    /// 创建水平数据驱动瀑布流
    /// - Parameters:
    ///   - rows: 行数配置
    ///   - spacing: 间距
    ///   - placementMode: 放置模式
    ///   - data: 数据集合
    ///   - id: 数据元素的ID键路径
    ///   - content: 内容构建器
    /// - Returns: 水平数据瀑布流视图
    static func horizontal<D, I, C>(
        rows: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: D,
        id: KeyPath<D.Element, I>,
        @ViewBuilder content: @escaping (D.Element) -> C
    ) -> DataMasonryView<D, I, C>
    where D: RandomAccessCollection, I: Hashable, C: View {
        DataMasonryView<D, I, C>(
            axis: .horizontal,
            lines: rows,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode,
            data: data,
            id: id,
            content: content
        )
    }
}
