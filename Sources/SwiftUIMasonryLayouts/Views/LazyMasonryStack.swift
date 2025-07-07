//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 懒加载瀑布流

/// 懒加载瀑布流：高效的瀑布流布局组件
/// 🎯 核心功能：瀑布流布局 + 滚动事件检测 + Footer支持
@available(iOS 18.0, *)
public struct LazyMasonryStack<Data: RandomAccessCollection, ID: Hashable, Content: View>: View where Data.Element: Identifiable, Data.Element.ID == ID {

    // MARK: - 核心属性

    private let data: Data
    private let configuration: MasonryConfiguration
    private let content: (Data.Element) -> Content
    private let footer: AnyView?

    // MARK: - 状态管理

    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0
    @State private var lastBottomTriggerTime: TimeInterval = 0

    // 防抖状态
    @State private var isUpdatingLayout = false

    // MARK: - 回调

    private let onReachBottom: (() -> Void)?
    
    // MARK: - 初始化

    /// 创建懒加载瀑布流（无Footer）
    /// - Parameters:
    ///   - data: 数据源
    ///   - axis: 布局轴向
    ///   - lines: 行/列配置
    ///   - hSpacing: 水平间距
    ///   - vSpacing: 垂直间距
    ///   - placement: 放置模式
    ///   - bottomTriggerThreshold: 底部触发阈值 (0.0-1.0)
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
            debounceInterval: debounceInterval
        )
        self.content = content
        self.footer = nil
        self.onReachBottom = nil
    }

    /// 创建懒加载瀑布流（使用配置对象，无Footer）
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
        self.footer = nil
        self.onReachBottom = nil
    }

    /// 内部初始化方法（支持回调配置）
    private init(
        _ data: Data,
        configuration: MasonryConfiguration,
        @ViewBuilder content: @escaping (Data.Element) -> Content,
        footer: AnyView?,
        onReachBottom: (() -> Void)?
    ) {
        self.data = data
        self.configuration = configuration
        self.content = content
        self.footer = footer
        self.onReachBottom = onReachBottom
    }
    

    
    // MARK: - 视图主体

    public var body: some View {
        GeometryReader { geometry in
            ScrollView(configuration.axis == .vertical ? .vertical : .horizontal) {
                if configuration.axis == .vertical {
                    LazyVStack(spacing: configuration.vSpacing) {
                        masonryContent

                        // Footer支持：垂直布局时在底部显示
                        if let footer = footer {
                            footer
                                .frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    LazyHStack(spacing: configuration.hSpacing) {
                        masonryContent

                        // Footer支持：水平布局时在右侧显示
                        if let footer = footer {
                            footer
                                .frame(maxHeight: .infinity)
                        }
                    }
                }
            }
            .onAppear {
                updateViewport(size: geometry.size)
            }
            .onChange(of: geometry.size) { _, newSize in
                updateViewport(size: newSize)
            }
            .onScrollGeometryChange(for: CGFloat.self) { scrollGeometry in
                return configuration.axis == .vertical
                    ? scrollGeometry.contentOffset.y
                    : scrollGeometry.contentOffset.x
            } action: { oldValue, newValue in
                // 🚀 优化：防抖滚动处理
                handleScrollChangeWithDebounce(newValue)
            }
        }
    }

    // 瀑布流内容
    private var masonryContent: some View {
        MasonryLayout(
            axis: configuration.axis,
            lines: configuration.lines,
            hSpacing: configuration.hSpacing,
            vSpacing: configuration.vSpacing,
            placement: configuration.placement
        ) {
            ForEach(data, id: \.id) { item in
                content(item)
                    .fixedSize(
                        horizontal: configuration.axis == .horizontal,
                        vertical: configuration.axis == .vertical
                    )
            }
        }
        .background(
            GeometryReader { contentGeometry in
                Color.clear
                    .onAppear {
                        updateContentHeight(contentGeometry.size)
                    }
                    .onChange(of: contentGeometry.size) { _, newSize in
                        updateContentHeight(newSize)
                    }
            }
        )
    }
    
    // MARK: - 私有方法

    /// 更新视口尺寸
    private func updateViewport(size: CGSize) {
        viewportHeight = configuration.axis == .vertical ? size.height : size.width
    }

    /// 更新内容高度
    private func updateContentHeight(_ size: CGSize) {
        let newHeight = configuration.axis == .vertical ? size.height : size.width

        // 只有显著变化时才更新，避免频繁重绘
        if abs(newHeight - contentHeight) > 1.0 {
            contentHeight = newHeight
        }
    }

    /// 防抖滚动处理
    private func handleScrollChangeWithDebounce(_ newOffset: CGFloat) {
        scrollOffset = newOffset

        // 使用防抖避免过于频繁的触发检查
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.checkScrollTriggers()
        }
    }

    /// 检查滚动触发条件
    private func checkScrollTriggers() {
        guard contentHeight > 0 && viewportHeight > 0 else { return }
        guard !isUpdatingLayout else { return } // 避免在布局更新时触发

        let scrollProgress = max(0, scrollOffset) / max(contentHeight - viewportHeight, 1)

        // 底部触发检测
        if scrollProgress >= configuration.bottomTriggerThreshold {
            let currentTime = Date().timeIntervalSince1970
            let timeSinceLastTrigger = currentTime - lastBottomTriggerTime

            if timeSinceLastTrigger >= configuration.debounceInterval {
                lastBottomTriggerTime = currentTime
                isUpdatingLayout = true // 标记正在更新

                onReachBottom?()

                // 延迟重置更新标记
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isUpdatingLayout = false
                }
            }
        }
    }
}

// MARK: - 链式配置方法

@available(iOS 18.0, *)
public extension LazyMasonryStack {

    func onReachBottom(_ action: @escaping () -> Void) -> LazyMasonryStack<Data, ID, Content> {
        return LazyMasonryStack(
            data,
            configuration: configuration,
            content: content,
            footer: footer,
            onReachBottom: action
        )
    }

    func footer<FooterContent: View>(@ViewBuilder _ footerContent: @escaping () -> FooterContent) -> LazyMasonryStack<Data, ID, Content> {
        return LazyMasonryStack(
            data,
            configuration: configuration,
            content: content,
            footer: AnyView(footerContent()),
            onReachBottom: onReachBottom
        )
    }
}

// MARK: - 便捷初始化方法

@available(iOS 18.0, *)
public extension LazyMasonryStack {

    /// 创建列数配置的懒加载瀑布流
    /// - Parameters:
    ///   - data: 数据源
    ///   - columns: 列数
    ///   - spacing: 间距
    ///   - bottomTriggerThreshold: 底部触发阈值 (0.0-1.0)
    ///   - debounceInterval: 防抖间隔 (秒)
    ///   - content: 内容构建器
    init(
        _ data: Data,
        columns: Int,
        spacing: CGFloat = 8,
        bottomTriggerThreshold: CGFloat = 0.6,
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
    ///   - debounceInterval: 防抖间隔 (秒)
    ///   - content: 内容构建器
    init(
        _ data: Data,
        rows: Int,
        spacing: CGFloat = 8,
        bottomTriggerThreshold: CGFloat = 0.6,
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
    ///   - debounceInterval: 防抖间隔 (秒)
    ///   - content: 内容构建器
    init(
        _ data: Data,
        adaptiveColumns minColumnWidth: CGFloat,
        spacing: CGFloat = 8,
        bottomTriggerThreshold: CGFloat = 0.6,
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
    ///   - debounceInterval: 防抖间隔 (秒)
    ///   - content: 内容构建器
    init(
        _ data: Data,
        adaptiveRows minRowHeight: CGFloat,
        spacing: CGFloat = 8,
        bottomTriggerThreshold: CGFloat = 0.6,
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
                debounceInterval: debounceInterval
            ),
            content: content
        )
    }
}


