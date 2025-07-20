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
        let proposedWidth = proposal.width
        let proposedHeight = proposal.height

        // 处理宽度
        let width: CGFloat
        if let proposedWidth = proposedWidth, proposedWidth > 0 {
            width = proposedWidth
        } else {
            // 当没有明确宽度时，尝试从子视图推断合理的宽度
            width = inferReasonableWidth(from: subviews)
        }

        // 处理高度
        let height: CGFloat
        if let proposedHeight = proposedHeight, proposedHeight > 0 {
            height = proposedHeight
        } else {
            // 对于垂直布局，高度应该自适应内容
            // 对于水平布局，需要推断合理的高度
            if axis == .vertical {
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

        // 计算子视图的理想宽度
        let sampleSize = subviews.prefix(min(3, subviews.count))
        let averageWidth = sampleSize.reduce(0) { sum, subview in
            let size = subview.sizeThatFits(.unspecified)
            return sum + size.width
        } / CGFloat(sampleSize.count)

        // 根据列数计算合理的容器宽度
        let lineCount = max(1, lines.fixedCount ?? 2)
        let totalSpacing = CGFloat(lineCount - 1) * hSpacing
        let minWidth = averageWidth * CGFloat(lineCount) + totalSpacing

        return max(MasonryInternalConfig.minimumInferredWidth, minWidth)
    }

    /// 从子视图推断合理的高度
    private func inferReasonableHeight(from subviews: Subviews) -> CGFloat {
        guard !subviews.isEmpty else { return MasonryInternalConfig.minimumInferredHeight }

        // 计算子视图的理想高度
        let sampleSize = subviews.prefix(min(3, subviews.count))
        let averageHeight = sampleSize.reduce(0) { sum, subview in
            let size = subview.sizeThatFits(.unspecified)
            return sum + size.height
        } / CGFloat(sampleSize.count)

        // 根据行数计算合理的容器高度
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
        // 当子视图数量或配置变化时清除缓存
        let needsInvalidation = cache.subviewCount != subviews.count || cache.lastConfigurationHash != configurationHash

        if needsInvalidation {
            cache.invalidate()
            cache.subviewCount = subviews.count
            cache.lastConfigurationHash = configurationHash
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

        // 缓存结果
        cache.cachedResult = result
        cache.lastContainerSize = containerSize
        cache.lastConfigurationHash = configurationHash

        return result
    }
}
