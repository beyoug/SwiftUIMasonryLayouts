//
// Copyright (c) Beyoug
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - 滚动几何信息

/// 滚动几何信息，用于iOS 18的onScrollGeometryChange
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct ScrollGeometryInfo: Equatable {
    /// 可见矩形
    let visibleRect: CGRect
    /// 内容尺寸
    let contentSize: CGSize

    /// 创建滚动几何信息
    /// - Parameters:
    ///   - visibleRect: 可见矩形
    ///   - contentSize: 内容尺寸
    init(visibleRect: CGRect, contentSize: CGSize) {
        self.visibleRect = visibleRect
        self.contentSize = contentSize
    }
}

// MARK: - 滚动检测辅助方法

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal extension ScrollViewportInfo {
    /// 从滚动几何信息创建视口信息
    /// - Parameter geometryInfo: 滚动几何信息
    /// - Returns: 视口信息
    static func from(_ geometryInfo: ScrollGeometryInfo) -> ScrollViewportInfo {
        return ScrollViewportInfo(
            viewportRect: geometryInfo.visibleRect,
            contentSize: geometryInfo.contentSize,
            scrollOffset: CGPoint(
                x: geometryInfo.visibleRect.minX,
                y: geometryInfo.visibleRect.minY
            )
        )
    }
}

// MARK: - 懒加载瀑布流视图

/// 专注于布局性能的懒加载瀑布流视图
/// 只关注数据绑定、布局计算和渲染优化，不涉及业务逻辑
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyMasonryView<Data: RandomAccessCollection, ID: Hashable, Content: View>: View where Data.Element: Identifiable, Data.Element.ID == ID {
    
    // MARK: - 核心属性
    
    /// 数据源
    private let data: Data
    /// 布局配置
    private let configuration: MasonryConfiguration
    /// 响应式断点配置（可选）
    private let breakpoints: [CGFloat: MasonryConfiguration]?
    /// 内容构建器
    private let content: (Data.Element) -> Content
    /// 项目尺寸计算器（可选，提供时确保布局准确性）
    private let sizeCalculator: ((Data.Element, CGFloat) -> CGSize)?
    
    // MARK: - 可扩展回调
    
    /// 可见范围变化回调
    private let onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?
    /// 滚动到底部回调（垂直布局）或右边回调（水平布局）
    private let onReachBottom: (() -> Void)?
    /// 滚动到顶部回调（垂直布局）或左边回调（水平布局）
    private let onReachTop: (() -> Void)?
    
    // MARK: - 状态管理

    @State private var currentConfiguration: MasonryConfiguration?
    @State private var layoutCache: LazyLayoutCache = LazyLayoutCache()

    @State private var currentLayoutResult: LazyLayoutResult?
    @State private var lastTopTriggerTime: TimeInterval = 0
    @State private var lastBottomTriggerTime: TimeInterval = 0


    // 滚动检测配置
    private let scrollDetectionConfig: ScrollDetectionConfiguration
    
    // MARK: - 初始化方法
    
    /// 创建懒加载瀑布流视图（核心初始化方法）
    /// - Parameters:
    ///   - data: 数据源
    ///   - configuration: 瀑布流配置
    ///   - sizeCalculator: 尺寸计算器（可选，提供时确保布局准确性）
    ///   - content: 内容构建器
    public init(
        _ data: Data,
        configuration: MasonryConfiguration,
        sizeCalculator: ((Data.Element, CGFloat) -> CGSize)? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = configuration
        self.breakpoints = nil
        self.sizeCalculator = sizeCalculator
        self.content = content
        self.onVisibleRangeChanged = nil
        self.onReachBottom = nil
        self.onReachTop = nil
        self.scrollDetectionConfig = .default
    }

    /// 创建最简单的懒加载瀑布流视图（使用默认配置）
    /// - Parameters:
    ///   - data: 数据源
    ///   - content: 内容构建器
    /// - Note: 使用智能默认尺寸计算，基于视图的固有尺寸
    public init(
        _ data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(2),
            hSpacing: 8,
            vSpacing: 8
        )
        self.breakpoints = nil
        self.sizeCalculator = nil
        self.content = content
        self.onVisibleRangeChanged = nil
        self.onReachBottom = nil
        self.onReachTop = nil
        self.scrollDetectionConfig = .default
    }

    /// 创建基于列配置的懒加载瀑布流视图
    /// - Parameters:
    ///   - data: 数据源
    ///   - columns: 列配置（使用 MasonryLines）
    ///   - spacing: 间距
    ///   - content: 内容构建器
    /// - Note: 使用智能默认尺寸计算，基于视图的固有尺寸
    public init(
        _ data: Data,
        columns: MasonryLines,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = MasonryConfiguration(
            axis: .vertical,
            lines: columns,
            hSpacing: spacing,
            vSpacing: spacing
        )
        self.breakpoints = nil
        self.sizeCalculator = nil
        self.content = content
        self.onVisibleRangeChanged = nil
        self.onReachBottom = nil
        self.onReachTop = nil
        self.scrollDetectionConfig = .default
    }

    /// 创建简单懒加载瀑布流视图（便捷方法）
    /// - Parameters:
    ///   - data: 数据源
    ///   - columns: 列数
    ///   - spacing: 间距
    ///   - content: 内容构建器
    /// - Note: 使用智能默认尺寸计算，基于视图的固有尺寸
    public init(
        _ data: Data,
        columns: Int = 2,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(columns),
            hSpacing: spacing,
            vSpacing: spacing
        )
        self.breakpoints = nil
        self.sizeCalculator = nil
        self.content = content
        self.onVisibleRangeChanged = nil
        self.onReachBottom = nil
        self.onReachTop = nil
        self.scrollDetectionConfig = .default
    }

    /// 创建懒加载瀑布流视图（支持不同间距）
    /// - Parameters:
    ///   - data: 数据源
    ///   - columns: 列数
    ///   - hSpacing: 水平间距
    ///   - vSpacing: 垂直间距
    ///   - content: 内容构建器
    /// - Note: 使用智能默认尺寸计算，基于视图的固有尺寸
    public init(
        _ data: Data,
        columns: Int = 2,
        hSpacing: CGFloat = 8,
        vSpacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(columns),
            hSpacing: hSpacing,
            vSpacing: vSpacing
        )
        self.breakpoints = nil
        self.sizeCalculator = nil
        self.content = content
        self.onVisibleRangeChanged = nil
        self.onReachBottom = nil
        self.onReachTop = nil
        self.scrollDetectionConfig = .default
    }

    /// 创建响应式懒加载瀑布流视图
    /// - Parameters:
    ///   - data: 数据源
    ///   - breakpoints: 响应式断点配置
    ///   - sizeCalculator: 尺寸计算器（可选，提供时确保布局准确性）
    ///   - content: 内容构建器
    /// - Note: 使用智能默认尺寸计算，基于视图的固有尺寸
    public init(
        _ data: Data,
        breakpoints: [CGFloat: MasonryConfiguration],
        sizeCalculator: ((Data.Element, CGFloat) -> CGSize)? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = .default
        self.breakpoints = breakpoints
        self.sizeCalculator = sizeCalculator
        self.content = content
        self.onVisibleRangeChanged = nil
        self.onReachBottom = nil
        self.onReachTop = nil
        self.scrollDetectionConfig = .default
    }
    
    // MARK: - 视图主体
    
    public var body: some View {
        ScrollViewReader { scrollProxy in
            GeometryReader { scrollViewGeometry in
                ScrollView {
                    LazyMasonryLayout(
                        configuration: effectiveConfiguration,
                        itemCount: data.count,
                        itemSizeCalculator: { index, lineSize in
                            if let calculator = sizeCalculator {
                                guard index >= 0 && index < data.count else {
                                    MasonryInternalConfig.Logger.warning("索引越界 - 索引: \(index), 数据总数: \(data.count)")
                                    let defaultHeight = max(50, lineSize * 0.6)
                                    return CGSize(width: lineSize, height: defaultHeight)
                                }

                                guard let dataIndex = data.index(data.startIndex, offsetBy: index, limitedBy: data.endIndex) else {
                                    MasonryInternalConfig.Logger.warning("无法计算数据索引 - 索引: \(index)")
                                    let defaultHeight = max(50, lineSize * 0.6)
                                    return CGSize(width: lineSize, height: defaultHeight)
                                }

                                return calculator(data[dataIndex], lineSize)
                            }

                            // 智能默认尺寸计算：基于黄金比例和合理的高度范围
                            let aspectRatio: CGFloat = 1.618 // 黄金比例
                            let minHeight: CGFloat = 80
                            let maxHeight: CGFloat = lineSize * 1.5
                            let calculatedHeight = lineSize / aspectRatio
                            let finalHeight = max(minHeight, min(maxHeight, calculatedHeight))

                            return CGSize(width: lineSize, height: finalHeight)
                        },
                        onLayoutResult: { result in
                            currentLayoutResult = result
                        }
                    ) {
                        ForEach(Array(data), id: \.id) { item in
                            content(item)
                        }
                    }
                    .background(
                        GeometryReader { contentGeometry in
                            Color.clear
                                .preference(
                                    key: ViewportInfoPreferenceKey.self,
                                    value: ScrollViewportInfo(
                                        viewportRect: CGRect(
                                            origin: CGPoint(x: 0, y: -contentGeometry.frame(in: .named("scrollView")).minY),
                                            size: scrollViewGeometry.size
                                        ),
                                        contentSize: contentGeometry.size,
                                        scrollOffset: CGPoint(x: 0, y: -contentGeometry.frame(in: .named("scrollView")).minY)
                                    )
                                )
                                .onAppear {
                                    // 延迟一点时间，确保布局完成后再发送视口信息
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        let viewportInfo = ScrollViewportInfo(
                                            viewportRect: CGRect(
                                                origin: CGPoint(x: 0, y: -contentGeometry.frame(in: .named("scrollView")).minY),
                                                size: scrollViewGeometry.size
                                            ),
                                            contentSize: contentGeometry.size,
                                            scrollOffset: CGPoint(x: 0, y: -contentGeometry.frame(in: .named("scrollView")).minY)
                                        )
                                        handleViewportChange(viewportInfo)
                                    }
                                }
                        }
                    )
                }
                .coordinateSpace(name: "scrollView")
                .onScrollGeometryChange(for: ScrollGeometryInfo.self) { geometry in
                    return ScrollGeometryInfo(
                        visibleRect: geometry.visibleRect,
                        contentSize: geometry.contentSize
                    )
                } action: { _, newValue in
                    let viewportInfo = ScrollViewportInfo.from(newValue)
                    handleViewportChange(viewportInfo)
                }
            }
            .onPreferenceChange(ViewportInfoPreferenceKey.self) { viewportInfo in
                handleViewportChange(viewportInfo)
            }
        }

#if canImport(UIKit)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            handleMemoryPressure()
        }
#endif
    }
    
    // MARK: - 私有辅助方法

    /// 检查是否有滚动回调
    private var hasScrollCallbacks: Bool {
        onReachTop != nil || onReachBottom != nil || onVisibleRangeChanged != nil
    }

    // MARK: - 布局结果管理

    /// 获取或估算布局结果
    /// - Parameter viewportInfo: 视口信息
    /// - Returns: 布局结果，如果无法获取或估算则返回nil
    private func getOrEstimateLayoutResult(from viewportInfo: ScrollViewportInfo) -> LazyLayoutResult? {
        if let cached = currentLayoutResult {
            return cached
        }

        // 使用视口信息来估算布局结果
        let estimatedHeight = viewportInfo.contentSize.height
        guard estimatedHeight > 0 else { return nil }

        let estimatedResult = LazyLayoutResult(
            itemFrames: [],
            totalSize: CGSize(width: viewportInfo.viewportRect.width, height: estimatedHeight),
            lineCount: 0,
            itemPositions: [:]
        )

        return estimatedResult
    }

    // MARK: - 滚动检测核心逻辑

    /// 执行滚动检测
    /// - Parameters:
    ///   - viewportInfo: 视口信息
    ///   - layoutResult: 布局结果
    private func performScrollDetection(viewportInfo: ScrollViewportInfo, layoutResult: LazyLayoutResult) {
        let scrollY = viewportInfo.scrollOffset.y
        let viewportHeight = viewportInfo.viewportRect.height
        let contentHeight = layoutResult.totalSize.height
        let currentTime = CFAbsoluteTimeGetCurrent()



        let debounceInterval = scrollDetectionConfig.debounceInterval

        // 检查顶部
        checkTopReached(scrollY: scrollY, currentTime: currentTime, debounceInterval: debounceInterval)

        // 检查底部
        checkBottomReached(
            scrollY: scrollY,
            viewportHeight: viewportHeight,
            contentHeight: contentHeight,
            currentTime: currentTime,
            debounceInterval: debounceInterval
        )
    }

    /// 检查是否到达顶部
    private func checkTopReached(scrollY: CGFloat, currentTime: TimeInterval, debounceInterval: TimeInterval) {
        guard let topCallback = onReachTop, scrollY <= scrollDetectionConfig.topThreshold else { return }

        if currentTime - lastTopTriggerTime >= debounceInterval {
            lastTopTriggerTime = currentTime
            topCallback()
        }
    }

    /// 检查是否到达底部
    private func checkBottomReached(
        scrollY: CGFloat,
        viewportHeight: CGFloat,
        contentHeight: CGFloat,
        currentTime: TimeInterval,
        debounceInterval: TimeInterval
    ) {
        guard let bottomCallback = onReachBottom else { return }

        let bottomPosition = scrollY + viewportHeight
        let bottomThreshold = contentHeight - scrollDetectionConfig.bottomThreshold

        guard bottomPosition >= bottomThreshold && contentHeight > viewportHeight else { return }

        if currentTime - lastBottomTriggerTime >= debounceInterval {
            lastBottomTriggerTime = currentTime
            bottomCallback()
        }
    }

    /// 获取有效配置
    private var effectiveConfiguration: MasonryConfiguration {
        if breakpoints != nil {
            return currentConfiguration ?? .default
        }
        return configuration
    }

    // MARK: - 滚动检测

    /// 处理视口变化
    private func handleViewportChange(_ viewportInfo: ScrollViewportInfo) {
        guard hasScrollCallbacks else { return }
        guard let layoutResult = getOrEstimateLayoutResult(from: viewportInfo) else {
            MasonryInternalConfig.Logger.warning("布局结果为空且无法估算，跳过滚动检测")
            return
        }

        performScrollDetection(viewportInfo: viewportInfo, layoutResult: layoutResult)
    }

    /// 处理可见范围变化
    private func handleVisibleRangeChanged(_ range: Range<Int>) {
        guard !data.isEmpty else { return }


        let startIndex = data.index(data.startIndex, offsetBy: max(0, range.lowerBound), limitedBy: data.endIndex) ?? data.startIndex
        let endIndex = data.index(data.startIndex, offsetBy: min(data.count, range.upperBound), limitedBy: data.endIndex) ?? data.endIndex

        let dataRange = startIndex..<endIndex
        onVisibleRangeChanged?(dataRange)
    }


    /// 处理内存压力
    private func handleMemoryPressure() {
        layoutCache.handleMemoryPressure()
    }
}

// MARK: - 可扩展接口

/// 懒加载瀑布流的回调配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyMasonryCallbacks<Data: RandomAccessCollection> {
    /// 可见范围变化回调
    public let onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?
    /// 滚动到底部回调（垂直布局）或右边回调（水平布局）
    public let onReachBottom: (() -> Void)?
    /// 滚动到顶部回调（垂直布局）或左边回调（水平布局）
    public let onReachTop: (() -> Void)?

    /// 创建回调配置
    public init(
        onVisibleRangeChanged: ((Range<Data.Index>) -> Void)? = nil,
        onReachBottom: (() -> Void)? = nil,
        onReachTop: (() -> Void)? = nil
    ) {
        self.onVisibleRangeChanged = onVisibleRangeChanged
        self.onReachBottom = onReachBottom
        self.onReachTop = onReachTop
    }

    /// 创建回调配置（使用通用命名）
    public init(
        onVisibleRangeChanged: ((Range<Data.Index>) -> Void)? = nil,
        onReachEnd: (() -> Void)? = nil,
        onReachStart: (() -> Void)? = nil
    ) {
        self.onVisibleRangeChanged = onVisibleRangeChanged
        self.onReachBottom = onReachEnd
        self.onReachTop = onReachStart
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension LazyMasonryView {

    /// 配置回调（推荐方式，避免多次实例创建）
    /// - Parameter callbacks: 回调配置
    /// - Returns: 配置了回调的视图
    func callbacks(_ callbacks: LazyMasonryCallbacks<Data>) -> LazyMasonryView {
        LazyMasonryView(
            data: data,
            configuration: configuration,
            breakpoints: breakpoints,
            sizeCalculator: sizeCalculator,
            content: content,
            onVisibleRangeChanged: callbacks.onVisibleRangeChanged,
            onReachBottom: callbacks.onReachBottom,
            onReachTop: callbacks.onReachTop
        )
    }

    /// 添加可见范围变化监听（用于业务层实现分页等逻辑）
    func onVisibleRangeChanged(_ action: @escaping (Range<Data.Index>) -> Void) -> LazyMasonryView {
        LazyMasonryView(
            data: data,
            configuration: configuration,
            breakpoints: breakpoints,
            sizeCalculator: sizeCalculator,
            content: content,
            onVisibleRangeChanged: action,
            onReachBottom: onReachBottom,
            onReachTop: onReachTop,
            scrollDetectionConfig: scrollDetectionConfig
        )
    }

    /// 添加滚动到底部监听
    func onReachBottom(_ action: @escaping () -> Void) -> LazyMasonryView {
        LazyMasonryView(
            data: data,
            configuration: configuration,
            breakpoints: breakpoints,
            sizeCalculator: sizeCalculator,
            content: content,
            onVisibleRangeChanged: onVisibleRangeChanged,
            onReachBottom: action,
            onReachTop: onReachTop,
            scrollDetectionConfig: scrollDetectionConfig
        )
    }

    /// 添加滚动到顶部监听
    func onReachTop(_ action: @escaping () -> Void) -> LazyMasonryView {
        LazyMasonryView(
            data: data,
            configuration: configuration,
            breakpoints: breakpoints,
            sizeCalculator: sizeCalculator,
            content: content,
            onVisibleRangeChanged: onVisibleRangeChanged,
            onReachBottom: onReachBottom,
            onReachTop: action,
            scrollDetectionConfig: scrollDetectionConfig
        )
    }

    /// 添加滚动到起始位置监听（垂直布局的顶部，水平布局的左边）
    func onReachStart(_ action: @escaping () -> Void) -> LazyMasonryView {
        onReachTop(action)
    }

    /// 添加滚动到结束位置监听（垂直布局的底部，水平布局的右边）
    func onReachEnd(_ action: @escaping () -> Void) -> LazyMasonryView {
        onReachBottom(action)
    }

    /// 启用滚动检测（使用默认配置）
    /// - Returns: 启用了滚动检测的视图
    func scrollDetection() -> LazyMasonryView {
        return scrollDetection(.default)
    }

    /// 配置滚动检测参数
    /// - Parameter config: 滚动检测配置
    /// - Returns: 配置了滚动检测的视图
    func scrollDetection(_ config: ScrollDetectionConfiguration) -> LazyMasonryView {
        // 创建一个新的实例，使用新的配置
        return LazyMasonryView(
            data: data,
            configuration: configuration,
            breakpoints: breakpoints,
            sizeCalculator: sizeCalculator,
            content: content,
            onVisibleRangeChanged: onVisibleRangeChanged,
            onReachBottom: onReachBottom,
            onReachTop: onReachTop,
            scrollDetectionConfig: config
        )
    }

    /// 配置滚动检测参数（便捷方法）
    /// - Parameters:
    ///   - debounceInterval: 防抖间隔
    ///   - bufferSize: 缓冲区大小
    ///   - topThreshold: 顶部阈值
    ///   - bottomThreshold: 底部阈值
    /// - Returns: 配置了滚动检测的视图
    func scrollDetection(
        debounceInterval: TimeInterval = 0.05,
        bufferSize: CGFloat = 200,
        topThreshold: CGFloat = 100,
        bottomThreshold: CGFloat = 100
    ) -> LazyMasonryView {
        let config = ScrollDetectionConfiguration(
            debounceInterval: debounceInterval,
            bufferSize: bufferSize,
            topThreshold: topThreshold,
            bottomThreshold: bottomThreshold
        )
        return scrollDetection(config)
    }
}

// MARK: - 内部初始化器

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private extension LazyMasonryView {

    /// 私有的完整初始化方法
    private init(
        data: Data,
        configuration: MasonryConfiguration,
        breakpoints: [CGFloat: MasonryConfiguration]?,
        sizeCalculator: ((Data.Element, CGFloat) -> CGSize)?,
        content: @escaping (Data.Element) -> Content,
        onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?,
        onReachBottom: (() -> Void)?,
        onReachTop: (() -> Void)?,
        scrollDetectionConfig: ScrollDetectionConfiguration
    ) {
        self.data = data
        self.configuration = configuration
        self.breakpoints = breakpoints
        self.sizeCalculator = sizeCalculator
        self.content = content
        self.onVisibleRangeChanged = onVisibleRangeChanged
        self.onReachBottom = onReachBottom
        self.onReachTop = onReachTop
        self.scrollDetectionConfig = scrollDetectionConfig
    }
    
    init(
        data: Data,
        configuration: MasonryConfiguration,
        breakpoints: [CGFloat: MasonryConfiguration]?,
        sizeCalculator: ((Data.Element, CGFloat) -> CGSize)?,
        content: @escaping (Data.Element) -> Content,
        onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?,
        onReachBottom: (() -> Void)?,
        onReachTop: (() -> Void)?
    ) {
        self.data = data
        self.configuration = configuration
        self.breakpoints = breakpoints
        self.sizeCalculator = sizeCalculator
        self.content = content
        self.onVisibleRangeChanged = onVisibleRangeChanged
        self.onReachBottom = onReachBottom
        self.onReachTop = onReachTop
        self.scrollDetectionConfig = .default
    }
}

// MARK: - 链式配置扩展（现代SwiftUI风格）

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension LazyMasonryView {

    /// 配置间距（链式调用）
    /// - Parameter spacing: 统一间距
    /// - Returns: 新的视图实例
    public func spacing(_ spacing: CGFloat) -> LazyMasonryView {
        let newConfig = MasonryConfiguration(
            axis: configuration.axis,
            lines: configuration.lines,
            hSpacing: spacing,
            vSpacing: spacing,
            placement: configuration.placement
        )
        return LazyMasonryView(
            data,
            configuration: newConfig,
            sizeCalculator: sizeCalculator,
            content: content
        )
    }

    /// 配置不同的水平和垂直间距（链式调用）
    /// - Parameters:
    ///   - horizontal: 水平间距
    ///   - vertical: 垂直间距
    /// - Returns: 新的视图实例
    public func spacing(horizontal: CGFloat, vertical: CGFloat) -> LazyMasonryView {
        let newConfig = MasonryConfiguration(
            axis: configuration.axis,
            lines: configuration.lines,
            hSpacing: horizontal,
            vSpacing: vertical,
            placement: configuration.placement
        )
        return LazyMasonryView(
            data,
            configuration: newConfig,
            sizeCalculator: sizeCalculator,
            content: content
        )
    }
}




