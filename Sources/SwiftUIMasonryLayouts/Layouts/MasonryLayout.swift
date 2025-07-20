//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 瀑布流布局协议实现

/// 瀑布流布局的核心实现
/// 基于 SwiftUI Layout 协议，提供高性能的瀑布流布局
@available(iOS 18.0, *)
public struct MasonryLayout: Layout, Sendable {

    // MARK: - 属性

    /// 布局轴向
    public let axis: Axis
    /// 行/列配置
    public let lines: MasonryLines
    /// 水平间距
    public let hSpacing: CGFloat
    /// 垂直间距
    public let vSpacing: CGFloat
    /// 放置模式
    public let placement: MasonryPlacementMode

    /// 缓存的配置哈希值（避免重复计算）
    private let configurationHash: Int

    // MARK: - 初始化

    /// 创建瀑布流布局
    /// - Parameters:
    ///   - axis: 布局轴向
    ///   - lines: 行/列配置
    ///   - hSpacing: 水平间距
    ///   - vSpacing: 垂直间距
    ///   - placement: 放置模式
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        hSpacing: CGFloat = 8,
        vSpacing: CGFloat = 8,
        placement: MasonryPlacementMode = .fill
    ) {
        let config = MasonryConfiguration(
            axis: axis,
            lines: lines,
            hSpacing: hSpacing,
            vSpacing: vSpacing,
            placement: placement
        )

        self.axis = config.axis
        self.lines = config.lines
        self.hSpacing = config.hSpacing
        self.vSpacing = config.vSpacing
        self.placement = config.placement

        // 预计算配置哈希值
        self.configurationHash = CacheManager.generateConfigurationHash(
            axis: config.axis,
            lines: config.lines,
            hSpacing: config.hSpacing,
            vSpacing: config.vSpacing,
            placement: config.placement
        )
    }

    /// 从配置创建布局
    /// - Parameter configuration: 瀑布流配置
    public init(configuration: MasonryConfiguration) {
        self.axis = configuration.axis
        self.lines = configuration.lines
        self.hSpacing = configuration.hSpacing
        self.vSpacing = configuration.vSpacing
        self.placement = configuration.placement

        self.configurationHash = CacheManager.generateConfigurationHash(
            axis: configuration.axis,
            lines: configuration.lines,
            hSpacing: configuration.hSpacing,
            vSpacing: configuration.vSpacing,
            placement: configuration.placement
        )
    }

    // MARK: - Layout协议实现

    /// 计算布局尺寸
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) -> CGSize {
        let containerSize = determineContainerSize(from: proposal, subviews: subviews)

        guard containerSize.width > 0 else {
            return .zero
        }

        updateCache(&cache, subviews: subviews)
        let result = performLayoutCalculation(containerSize: containerSize, subviews: subviews, cache: &cache)

        return result.totalSize
    }

    /// 智能确定容器尺寸，处理各种嵌套布局场景
    private func determineContainerSize(from proposal: ProposedViewSize, subviews: Subviews) -> CGSize {
        // 预计算轴向判断，避免重复访问
        let isVertical = axis == .vertical

        // 处理宽度，减少可选值解包
        let width: CGFloat
        if let proposedWidth = proposal.width, proposedWidth > 0 {
            width = proposedWidth
        } else {
            width = inferReasonableWidth(from: subviews)
        }

        // 处理高度，使用预计算的轴向判断
        let height: CGFloat
        if let proposedHeight = proposal.height, proposedHeight > 0 {
            height = proposedHeight
        } else {
            if isVertical {
                height = 10000 // 允许垂直扩展
            } else {
                height = inferReasonableHeight(from: subviews)
            }
        }

        return CGSize(width: width, height: height)
    }

    /// 从子视图推断合理的宽度
    private func inferReasonableWidth(from subviews: Subviews) -> CGFloat {
        guard !subviews.isEmpty else { return MasonryInternalConfig.minimumInferredWidth }

        // 减少采样数量，提升性能
        let sampleCount = min(2, subviews.count)
        var totalWidth: CGFloat = 0

        // 使用直接循环替代reduce，避免闭包开销
        for i in 0..<sampleCount {
            let size = subviews[i].sizeThatFits(.unspecified)
            totalWidth += size.width
        }

        let averageWidth = totalWidth / CGFloat(sampleCount)

        // 预计算线数和间距
        let lineCount = max(1, lines.fixedCount ?? 2)
        let totalSpacing = CGFloat(lineCount - 1) * hSpacing
        let minWidth = averageWidth * CGFloat(lineCount) + totalSpacing

        return max(MasonryInternalConfig.minimumInferredWidth, minWidth)
    }

    /// 从子视图推断合理的高度
    private func inferReasonableHeight(from subviews: Subviews) -> CGFloat {
        guard !subviews.isEmpty else { return MasonryInternalConfig.minimumInferredHeight }

        // 减少采样数量，提升性能
        let sampleCount = min(2, subviews.count)
        var totalHeight: CGFloat = 0

        // 使用直接循环替代reduce，避免闭包开销
        for i in 0..<sampleCount {
            let size = subviews[i].sizeThatFits(.unspecified)
            totalHeight += size.height
        }

        let averageHeight = totalHeight / CGFloat(sampleCount)

        // 预计算线数和间距
        let lineCount = max(1, lines.fixedCount ?? 2)
        let totalSpacing = CGFloat(lineCount - 1) * vSpacing
        let minHeight = averageHeight * CGFloat(lineCount) + totalSpacing

        return max(MasonryInternalConfig.minimumInferredHeight, minHeight)
    }
    
    /// 放置子视图
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) {
        let containerSize = bounds.size

        guard containerSize.width > 0 else {
            return
        }

        let result = performLayoutCalculation(containerSize: containerSize, subviews: subviews, cache: &cache)
        for (index, subview) in subviews.enumerated() {
            guard index < result.itemFrames.count else { continue }

            let frame = result.itemFrames[index]
            let position = CGPoint(
                x: bounds.minX + frame.minX,
                y: bounds.minY + frame.minY
            )

            subview.place(at: position, proposal: ProposedViewSize(frame.size))
        }
    }
    
    /// 创建缓存
    public func makeCache(subviews: Subviews) -> LayoutCache {
        return LayoutCache()
    }
    
    /// 更新缓存
    public func updateCache(_ cache: inout LayoutCache, subviews: Subviews) {
        // 精确的失效条件检查
        let needsInvalidation = cache.subviewCount != subviews.count ||
                               cache.lastConfigurationHash != configurationHash ||
                               cache.lastAxis != axis

        if needsInvalidation {
            cache.invalidate()
            cache.subviewCount = subviews.count
            cache.lastConfigurationHash = configurationHash
            cache.lastAxis = axis // 记录轴向信息
        }
    }

    // MARK: - 私有方法

    /// 执行布局计算
    private func performLayoutCalculation(containerSize: CGSize, subviews: Subviews, cache: inout LayoutCache) -> LayoutResult {
        // 确保缓存是最新的
        updateCache(&cache, subviews: subviews)

        // 检查缓存
        if CacheManager.isCacheValid(
            cache: cache,
            containerSize: containerSize,
            configurationHash: configurationHash,
            subviewCount: subviews.count
        ), let cachedResult = cache.cachedResult {
            cache.recordCacheHit()
            return cachedResult
        }

        cache.recordCacheMiss()
        let parameters = LayoutParameters(
            containerSize: containerSize,
            axis: axis,
            lines: lines,
            hSpacing: hSpacing,
            vSpacing: vSpacing,
            placement: placement
        )

        let result = MasonryLayoutEngine.calculateLayout(
            containerSize: containerSize,
            subviews: subviews,
            parameters: parameters
        )

        // 缓存结果时记录完整信息
        cache.cachedResult = result
        cache.lastContainerSize = containerSize
        cache.lastConfigurationHash = configurationHash
        cache.lastAxis = axis

        return result
    }
}
