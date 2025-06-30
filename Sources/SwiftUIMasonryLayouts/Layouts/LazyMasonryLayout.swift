//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 懒加载瀑布流布局

/// 基于Layout协议的懒加载瀑布流布局
/// 专注于高性能的懒加载渲染和可见性检测
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyMasonryLayout: Layout {

    public typealias Cache = LazyLayoutCache
    
    // MARK: - 属性
    
    /// 布局配置
    private let configuration: MasonryConfiguration
    /// 数据项目数量
    private let itemCount: Int
    /// 项目尺寸计算器
    private let itemSizeCalculator: ((Int, CGFloat) -> CGSize)?
    /// 可见范围
    private let visibleRange: Range<Int>?
    /// 视口信息
    private let viewportInfo: LazyViewportInfo?
    /// 布局结果回调
    private let onLayoutResult: ((LazyLayoutResult) -> Void)?
    
    // MARK: - 初始化
    
    /// 创建懒加载瀑布流布局
    /// - Parameters:
    ///   - configuration: 布局配置
    ///   - itemCount: 数据项目数量
    ///   - itemSizeCalculator: 项目尺寸计算器
    ///   - visibleRange: 可见范围
    ///   - viewportInfo: 视口信息
    ///   - onLayoutResult: 布局结果回调
    public init(
        configuration: MasonryConfiguration,
        itemCount: Int,
        itemSizeCalculator: ((Int, CGFloat) -> CGSize)? = nil,
        visibleRange: Range<Int>? = nil,
        viewportInfo: LazyViewportInfo? = nil,
        onLayoutResult: ((LazyLayoutResult) -> Void)? = nil
    ) {
        self.configuration = configuration
        self.itemCount = itemCount
        self.itemSizeCalculator = itemSizeCalculator
        self.visibleRange = visibleRange
        self.viewportInfo = viewportInfo
        self.onLayoutResult = onLayoutResult
    }
    
    // MARK: - Layout协议实现

    /// 创建缓存
    public func makeCache(subviews: Subviews) -> LazyLayoutCache {
        return LazyLayoutCache()
    }

    /// 计算布局尺寸
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout LazyLayoutCache) -> CGSize {
        let containerSize = determineContainerSize(from: proposal, subviews: subviews)

        // 只要求宽度有效，高度可以为0（由布局计算）
        guard containerSize.width > 0 else {
            return .zero
        }

        guard subviews.count > 0 else {
            return .zero
        }

        // 使用实际子视图数量
        let actualItemCount = subviews.count

        // 生成缓存键
        let cacheKey = generateCacheKey(containerSize: containerSize, itemCount: actualItemCount)

        // 检查缓存
        if let cachedResult = cache.getCachedLayoutResult(for: cacheKey) {
            return cachedResult.totalSize
        }

        // 计算布局
        let result = calculateLazyLayout(
            containerSize: containerSize,
            subviews: subviews,
            cache: &cache
        )

        // 缓存结果
        cache.cacheLayoutResult(for: cacheKey, result: result)

        // 触发布局结果回调
        onLayoutResult?(result)

        return result.totalSize
    }
    
    /// 放置子视图
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout LazyLayoutCache) {
        let containerSize = bounds.size

        guard containerSize.width > 0 && containerSize.height > 0 else {
            return
        }

        guard subviews.count > 0 else {
            return
        }

        // 生成缓存键
        let cacheKey = generateCacheKey(containerSize: containerSize, itemCount: subviews.count)

        // 获取或计算布局结果
        let result: LazyLayoutResult
        if let cachedResult = cache.getCachedLayoutResult(for: cacheKey) {
            result = cachedResult
        } else {
            result = calculateLazyLayout(
                containerSize: containerSize,
                subviews: subviews,
                cache: &cache
            )
            cache.cacheLayoutResult(for: cacheKey, result: result)
        }

        // 放置所有子视图（LazyMasonryView会处理可见性）
        for index in 0..<min(subviews.count, result.itemFrames.count) {
            let subview = subviews[index]
            let frame = result.itemFrames[index]

            let position = CGPoint(
                x: bounds.minX + frame.minX,
                y: bounds.minY + frame.minY
            )

            subview.place(at: position, proposal: ProposedViewSize(frame.size))
        }
    }
    
    // MARK: - 私有方法
    
    /// 确定容器尺寸
    private func determineContainerSize(from proposal: ProposedViewSize, subviews: LayoutSubviews) -> CGSize {
        let width = proposal.width ?? 0
        // 对于高度，如果没有指定，使用一个很大的值让布局自由计算
        let height = proposal.height ?? CGFloat.greatestFiniteMagnitude

        return CGSize(
            width: max(0, width),
            height: height == CGFloat.greatestFiniteMagnitude ? 0 : max(0, height)
        )
    }
    
    /// 生成缓存键
    private func generateCacheKey(containerSize: CGSize, itemCount: Int) -> String {
        return "\(configuration.hashValue)_\(Int(containerSize.width))x\(Int(containerSize.height))_\(itemCount)"
    }
    
    /// 计算懒加载布局
    private func calculateLazyLayout(
        containerSize: CGSize,
        subviews: LayoutSubviews,
        cache: inout LazyLayoutCache
    ) -> LazyLayoutResult {
        // 使用实际子视图数量
        let actualItemCount = subviews.count

        // 如果容器高度为0，使用一个很大的值让布局自由计算
        let effectiveContainerSize = CGSize(
            width: containerSize.width,
            height: containerSize.height == 0 ? CGFloat.greatestFiniteMagnitude : containerSize.height
        )

        // 使用布局引擎的新方法
        return MasonryLayoutEngine.calculateIndexBasedLazyLayout(
            containerSize: effectiveContainerSize,
            itemCount: actualItemCount,
            configuration: configuration,
            itemSizeCalculator: itemSizeCalculator,
            cache: &cache
        )
    }
    

}

// MARK: - 懒加载可见性检测扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension LazyMasonryLayout {

    /// 计算可见范围
    /// - Parameters:
    ///   - viewportRect: 视口矩形
    ///   - layoutResult: 布局结果
    ///   - bufferSize: 缓冲区大小
    /// - Returns: 可见项目的索引范围
    static func calculateVisibleRange(
        viewportRect: CGRect,
        layoutResult: LazyLayoutResult,
        bufferSize: CGFloat = 200
    ) -> Range<Int> {
        let expandedViewport = viewportRect.insetBy(dx: -bufferSize, dy: -bufferSize)

        var visibleIndices: [Int] = []

        for (index, frame) in layoutResult.itemFrames.enumerated() {
            if expandedViewport.intersects(frame) {
                visibleIndices.append(index)
            }
        }

        guard !visibleIndices.isEmpty else {
            return 0..<0
        }

        let sortedIndices = visibleIndices.sorted()
        return sortedIndices.first!..<(sortedIndices.last! + 1)
    }

    /// 优化的可见性检测（使用二分查找）
    /// - Parameters:
    ///   - viewportRect: 视口矩形
    ///   - layoutResult: 布局结果
    ///   - axis: 布局轴向
    ///   - bufferSize: 缓冲区大小
    /// - Returns: 可见项目的索引范围
    static func calculateVisibleRangeOptimized(
        viewportRect: CGRect,
        layoutResult: LazyLayoutResult,
        axis: Axis,
        bufferSize: CGFloat = 200
    ) -> Range<Int> {
        let frames = layoutResult.itemFrames
        guard !frames.isEmpty else { return 0..<0 }

        let expandedViewport = viewportRect.insetBy(dx: -bufferSize, dy: -bufferSize)

        // 根据轴向选择主要坐标
        let viewportStart: CGFloat
        let viewportEnd: CGFloat

        if axis == .vertical {
            viewportStart = expandedViewport.minY
            viewportEnd = expandedViewport.maxY
        } else {
            viewportStart = expandedViewport.minX
            viewportEnd = expandedViewport.maxX
        }

        // 二分查找第一个可见项目
        var startIndex = 0
        var endIndex = frames.count

        while startIndex < endIndex {
            let mid = (startIndex + endIndex) / 2
            let frame = frames[mid]
            let frameEnd = axis == .vertical ? frame.maxY : frame.maxX

            if frameEnd < viewportStart {
                startIndex = mid + 1
            } else {
                endIndex = mid
            }
        }

        let visibleStart = startIndex

        // 二分查找最后一个可见项目
        startIndex = visibleStart
        endIndex = frames.count

        while startIndex < endIndex {
            let mid = (startIndex + endIndex) / 2
            let frame = frames[mid]
            let frameStart = axis == .vertical ? frame.minY : frame.minX

            if frameStart <= viewportEnd {
                startIndex = mid + 1
            } else {
                endIndex = mid
            }
        }

        let visibleEnd = min(startIndex, frames.count)

        return visibleStart..<visibleEnd
    }
}

// MARK: - 懒加载性能优化扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension LazyMasonryLayout {

    /// 创建带有可见性优化的布局
    /// - Parameters:
    ///   - configuration: 布局配置
    ///   - itemCount: 项目数量
    ///   - visibleRange: 可见范围
    ///   - itemSizeCalculator: 项目尺寸计算器
    /// - Returns: 优化的懒加载布局
    static func optimized(
        configuration: MasonryConfiguration,
        itemCount: Int,
        visibleRange: Range<Int>?,
        itemSizeCalculator: ((Int, CGFloat) -> CGSize)? = nil
    ) -> LazyMasonryLayout {
        return LazyMasonryLayout(
            configuration: configuration,
            itemCount: itemCount,
            itemSizeCalculator: itemSizeCalculator,
            visibleRange: visibleRange,
            viewportInfo: nil
        )
    }

    /// 创建带有视口信息的布局
    /// - Parameters:
    ///   - configuration: 布局配置
    ///   - itemCount: 项目数量
    ///   - viewportInfo: 视口信息
    ///   - itemSizeCalculator: 项目尺寸计算器
    /// - Returns: 带有视口优化的懒加载布局
    static func withViewport(
        configuration: MasonryConfiguration,
        itemCount: Int,
        viewportInfo: LazyViewportInfo,
        itemSizeCalculator: ((Int, CGFloat) -> CGSize)? = nil
    ) -> LazyMasonryLayout {
        return LazyMasonryLayout(
            configuration: configuration,
            itemCount: itemCount,
            itemSizeCalculator: itemSizeCalculator,
            visibleRange: nil,
            viewportInfo: viewportInfo
        )
    }
}
