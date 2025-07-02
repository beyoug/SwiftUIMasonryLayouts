//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 懒加载瀑布流

/// 懒加载瀑布流：高效的瀑布流布局组件
/// 🎯 核心功能：瀑布流布局 + 滚动事件检测
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyMasonryStack<Data: RandomAccessCollection, ID: Hashable, Content: View>: View where Data.Element: Identifiable, Data.Element.ID == ID {
    
    // MARK: - 核心属性

    private let data: Data
    private let configuration: MasonryConfiguration
    private let content: (Data.Element) -> Content


    
    // MARK: - 状态管理

    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0
    @State private var lastBottomTriggerTime: TimeInterval = 0

    // MARK: - 回调

    private let onReachBottom: (() -> Void)?
    private let onReachTop: (() -> Void)?
    
    // MARK: - 初始化
    
    /// 创建懒加载瀑布流
    /// - Parameters:
    ///   - data: 数据源
    ///   - axis: 布局轴向
    ///   - lines: 行/列配置
    ///   - hSpacing: 水平间距
    ///   - vSpacing: 垂直间距
    ///   - placement: 放置模式
    ///   - bottomTriggerThreshold: 底部触发阈值 (0.0-1.0)
    ///   - topTriggerThreshold: 顶部触发阈值 (像素值)
    ///   - debounceInterval: 防抖间隔 (秒)
    ///   - content: 内容构建器
    public init(
        _ data: Data,
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        hSpacing: CGFloat = 8,
        vSpacing: CGFloat = 8,
        placement: MasonryPlacementMode = .fill,
        bottomTriggerThreshold: CGFloat = 0.6,
        topTriggerThreshold: CGFloat = 0,
        debounceInterval: TimeInterval = 1.0,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = MasonryConfiguration(
            axis: axis,
            lines: lines,
            hSpacing: hSpacing,
            vSpacing: vSpacing,
            placement: placement,
            bottomTriggerThreshold: bottomTriggerThreshold,
            topTriggerThreshold: topTriggerThreshold,
            debounceInterval: debounceInterval
        )
        self.content = content
        self.onReachBottom = nil
        self.onReachTop = nil
    }
    
    /// 创建懒加载瀑布流（使用配置对象）
    /// - Parameters:
    ///   - data: 数据源
    ///   - configuration: 完整配置对象
    ///   - content: 内容构建器
    public init(
        _ data: Data,
        configuration: MasonryConfiguration,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = configuration
        self.content = content
        self.onReachBottom = nil
        self.onReachTop = nil
    }

    /// 内部初始化方法（支持回调配置）
    private init(
        _ data: Data,
        configuration: MasonryConfiguration,
        @ViewBuilder content: @escaping (Data.Element) -> Content,
        onReachBottom: (() -> Void)?,
        onReachTop: (() -> Void)?
    ) {
        self.data = data
        self.configuration = configuration
        self.content = content
        self.onReachBottom = onReachBottom
        self.onReachTop = onReachTop
    }
    
    // MARK: - 计算属性
    
    /// 当前显示的项目
    private var visibleItems: [Data.Element] {
        return Array(data)
    }
    
    // MARK: - 视图主体
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                MasonryLayout(
                    axis: configuration.axis,
                    lines: configuration.lines,
                    hSpacing: configuration.hSpacing,
                    vSpacing: configuration.vSpacing,
                    placement: configuration.placement
                ) {
                    ForEach(visibleItems, id: \.id) { item in
                        content(item)
                            .fixedSize(horizontal: false, vertical: true)
                    }


                }
                .background(
                    GeometryReader { contentGeometry in
                        Color.clear
                            .onAppear {
                                contentHeight = contentGeometry.size.height
                            }
                            .onChange(of: contentGeometry.size.height) { _, newHeight in
                                contentHeight = newHeight
                            }
                    }
                )
            }
            .onAppear {
                viewportHeight = geometry.size.height
            }
            .onChange(of: geometry.size.height) { _, newHeight in
                viewportHeight = newHeight
            }
            .onScrollGeometryChange(for: CGFloat.self) { scrollGeometry in
                return scrollGeometry.contentOffset.y
            } action: { oldValue, newValue in
                handleScrollChange(newValue)
            }

        }
    }
    
    // MARK: - 私有方法

    /// 处理滚动变化
    private func handleScrollChange(_ newOffset: CGFloat) {
        scrollOffset = newOffset
        checkScrollTriggers()
    }

    /// 检查滚动触发条件
    private func checkScrollTriggers() {
        guard contentHeight > 0 && viewportHeight > 0 else { return }

        let scrollProgress = max(0, scrollOffset) / max(contentHeight - viewportHeight, 1)

        // 底部触发检测
        if scrollProgress >= configuration.bottomTriggerThreshold {
            let currentTime = Date().timeIntervalSince1970
            let timeSinceLastTrigger = currentTime - lastBottomTriggerTime

            if timeSinceLastTrigger >= configuration.debounceInterval {
                lastBottomTriggerTime = currentTime
                onReachBottom?()
            }
        }

        // 顶部触发检测
        if scrollOffset <= configuration.topTriggerThreshold {
            onReachTop?()
        }
    }










}

// MARK: - 链式配置方法

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension LazyMasonryStack {

    func onReachBottom(_ action: @escaping () -> Void) -> LazyMasonryStack {
        return LazyMasonryStack(
            data,
            configuration: configuration,
            content: content,
            onReachBottom: action,
            onReachTop: onReachTop
        )
    }
    
    func onReachTop(_ action: @escaping () -> Void) -> LazyMasonryStack {
        return LazyMasonryStack(
            data,
            configuration: configuration,
            content: content,
            onReachBottom: onReachBottom,
            onReachTop: action
        )
    }
}

// MARK: - 便捷初始化方法

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension LazyMasonryStack {

    /// 创建列数配置的懒加载瀑布流
    /// - Parameters:
    ///   - data: 数据源
    ///   - columns: 列数
    ///   - spacing: 间距
    ///   - bottomTriggerThreshold: 底部触发阈值 (0.0-1.0)
    ///   - topTriggerThreshold: 顶部触发阈值 (像素值)
    ///   - debounceInterval: 防抖间隔 (秒)
    ///   - content: 内容构建器
    init(
        _ data: Data,
        columns: Int,
        spacing: CGFloat = 8,
        bottomTriggerThreshold: CGFloat = 0.6,
        topTriggerThreshold: CGFloat = 0,
        debounceInterval: TimeInterval = 1.0,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data,
            axis: .vertical,
            lines: .fixed(columns),
            hSpacing: spacing,
            vSpacing: spacing,
            placement: .fill,
            bottomTriggerThreshold: bottomTriggerThreshold,
            topTriggerThreshold: topTriggerThreshold,
            debounceInterval: debounceInterval,
            content: content
        )
    }

    /// 创建行数配置的懒加载瀑布流
    /// - Parameters:
    ///   - data: 数据源
    ///   - rows: 行数
    ///   - spacing: 间距
    ///   - bottomTriggerThreshold: 底部触发阈值 (0.0-1.0)
    ///   - topTriggerThreshold: 顶部触发阈值 (像素值)
    ///   - debounceInterval: 防抖间隔 (秒)
    ///   - content: 内容构建器
    init(
        _ data: Data,
        rows: Int,
        spacing: CGFloat = 8,
        bottomTriggerThreshold: CGFloat = 0.6,
        topTriggerThreshold: CGFloat = 0,
        debounceInterval: TimeInterval = 1.0,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data,
            axis: .horizontal,
            lines: .fixed(rows),
            hSpacing: spacing,
            vSpacing: spacing,
            placement: .fill,
            bottomTriggerThreshold: bottomTriggerThreshold,
            topTriggerThreshold: topTriggerThreshold,
            debounceInterval: debounceInterval,
            content: content
        )
    }

    /// 创建自适应列懒加载瀑布流
    /// - Parameters:
    ///   - data: 数据源
    ///   - minColumnWidth: 最小列宽
    ///   - spacing: 间距
    ///   - bottomTriggerThreshold: 底部触发阈值 (0.0-1.0)
    ///   - topTriggerThreshold: 顶部触发阈值 (像素值)
    ///   - debounceInterval: 防抖间隔 (秒)
    ///   - content: 内容构建器
    init(
        _ data: Data,
        adaptiveColumns minColumnWidth: CGFloat,
        spacing: CGFloat = 8,
        bottomTriggerThreshold: CGFloat = 0.6,
        topTriggerThreshold: CGFloat = 0,
        debounceInterval: TimeInterval = 1.0,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data,
            configuration: MasonryConfiguration(
                axis: .vertical,
                lines: .adaptive(minSize: minColumnWidth),
                hSpacing: spacing,
                vSpacing: spacing,
                placement: .fill,
                bottomTriggerThreshold: bottomTriggerThreshold,
                topTriggerThreshold: topTriggerThreshold,
                debounceInterval: debounceInterval
            ),
            content: content
        )
    }

    /// 创建自适应行懒加载瀑布流
    /// - Parameters:
    ///   - data: 数据源
    ///   - minRowHeight: 最小行高
    ///   - spacing: 间距
    ///   - bottomTriggerThreshold: 底部触发阈值 (0.0-1.0)
    ///   - topTriggerThreshold: 顶部触发阈值 (像素值)
    ///   - debounceInterval: 防抖间隔 (秒)
    ///   - content: 内容构建器
    init(
        _ data: Data,
        adaptiveRows minRowHeight: CGFloat,
        spacing: CGFloat = 8,
        bottomTriggerThreshold: CGFloat = 0.6,
        topTriggerThreshold: CGFloat = 0,
        debounceInterval: TimeInterval = 1.0,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data,
            configuration: MasonryConfiguration(
                axis: .horizontal,
                lines: .adaptive(minSize: minRowHeight),
                hSpacing: spacing,
                vSpacing: spacing,
                placement: .fill,
                bottomTriggerThreshold: bottomTriggerThreshold,
                topTriggerThreshold: topTriggerThreshold,
                debounceInterval: debounceInterval
            ),
            content: content
        )
    }
}


