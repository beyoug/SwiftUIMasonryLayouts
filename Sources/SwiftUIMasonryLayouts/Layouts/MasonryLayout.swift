//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 瀑布流布局协议实现

/// 瀑布流布局的核心实现
/// 基于SwiftUI的Layout协议，专注于Layout协议的实现
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct MasonryLayout: Layout, Sendable {

    // MARK: - 属性

    /// 布局轴向
    public let axis: Axis
    /// 行/列配置
    public let lines: MasonryLines
    /// 水平间距
    public let horizontalSpacing: CGFloat
    /// 垂直间距
    public let verticalSpacing: CGFloat
    /// 放置模式
    public let placementMode: MasonryPlacementMode

    // MARK: - 初始化

    /// 创建瀑布流布局
    /// - Parameters:
    ///   - axis: 布局轴向
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距
    ///   - verticalSpacing: 垂直间距
    ///   - placementMode: 放置模式
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill
    ) {
        // 使用配置类的验证逻辑，避免重复
        let config = MasonryConfiguration(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode
        )

        self.axis = config.axis
        self.lines = config.lines
        self.horizontalSpacing = config.horizontalSpacing
        self.verticalSpacing = config.verticalSpacing
        self.placementMode = config.placementMode
    }

    /// 从配置创建布局
    /// - Parameter configuration: 瀑布流配置
    public init(configuration: MasonryConfiguration) {
        self.axis = configuration.axis
        self.lines = configuration.lines
        self.horizontalSpacing = configuration.horizontalSpacing
        self.verticalSpacing = configuration.verticalSpacing
        self.placementMode = configuration.placementMode
    }

    // MARK: - Layout协议实现

    /// 计算布局尺寸
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) -> CGSize {
        let containerSize = CGSize(
            width: proposal.width ?? 0,
            height: proposal.height ?? 0
        )

        // 验证容器尺寸的合理性
        guard containerSize.width > 0 && containerSize.height > 0 else {
            return .zero
        }

        // 更新缓存
        updateCache(&cache, subviews: subviews)

        // 使用布局引擎计算
        let result = performLayoutCalculation(containerSize: containerSize, subviews: subviews, cache: &cache)

        return result.totalSize
    }
    
    /// 放置子视图
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) {
        let containerSize = bounds.size

        // 验证容器尺寸的合理性
        guard containerSize.width > 0 && containerSize.height > 0 else {
            return
        }

        // 更新缓存
        updateCache(&cache, subviews: subviews)

        // 使用布局引擎计算
        let result = performLayoutCalculation(containerSize: containerSize, subviews: subviews, cache: &cache)

        // 放置子视图
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
        let currentConfigHash = CacheManager.generateConfigurationHash(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode
        )

        if cache.subviewCount != subviews.count || cache.lastConfigurationHash != currentConfigHash {
            cache.invalidate()
            cache.subviewCount = subviews.count
            cache.lastConfigurationHash = currentConfigHash
        }
    }

    // MARK: - 私有方法

    /// 执行布局计算
    private func performLayoutCalculation(containerSize: CGSize, subviews: Subviews, cache: inout LayoutCache) -> LayoutResult {
        let startTime = CFAbsoluteTimeGetCurrent()

        // 检查缓存
        let currentConfigHash = CacheManager.generateConfigurationHash(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode
        )

        if CacheManager.isCacheValid(
            cache: cache,
            containerSize: containerSize,
            configurationHash: currentConfigHash,
            subviewCount: subviews.count
        ) {
            cache.recordCacheHit()
            return cache.cachedResult!
        }

        cache.recordCacheMiss()
        let parameters = LayoutParameters(
            containerSize: containerSize,
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode
        )

        let result = MasonryLayoutEngine.calculateLayout(
            containerSize: containerSize,
            subviews: subviews,
            parameters: parameters
        )

        // 缓存结果
        let endTime = CFAbsoluteTimeGetCurrent()
        cache.lastCalculationTime = endTime - startTime
        cache.cachedResult = result
        cache.lastContainerSize = containerSize
        cache.lastConfigurationHash = currentConfigHash

        return result
    }
}
