//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 布局缓存系统

/// 瀑布流布局缓存
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LayoutCache {
    /// 缓存的布局结果
    var cachedResult: LayoutResult?
    /// 上次计算的容器尺寸
    var lastContainerSize: CGSize = .zero
    /// 上次计算的配置哈希值
    var lastConfigurationHash: Int = 0
    /// 子视图数量
    var subviewCount: Int = 0
    /// 上次计算时间
    var lastCalculationTime: TimeInterval = 0
    /// 缓存命中次数
    private var cacheHits: Int = 0
    /// 缓存未命中次数
    private var cacheMisses: Int = 0
    
    /// 清除缓存
    mutating func invalidate() {
        cachedResult = nil
        lastContainerSize = .zero
        lastConfigurationHash = 0
        subviewCount = 0
        lastCalculationTime = 0
    }
    
    /// 检查尺寸是否兼容（允许小幅度变化）
    func isSizeCompatible(with size: CGSize) -> Bool {
        let tolerance: CGFloat = 1.0
        return abs(lastContainerSize.width - size.width) <= tolerance &&
               abs(lastContainerSize.height - size.height) <= tolerance
    }

    mutating func recordCacheHit() {
        cacheHits += 1
    }

    mutating func recordCacheMiss() {
        cacheMisses += 1
    }
    
    /// 获取缓存命中率
    var cacheHitRate: Double {
        let total = cacheHits + cacheMisses
        return total > 0 ? Double(cacheHits) / Double(total) : 0
    }

    /// 获取缓存统计信息
    var statistics: CacheStatistics {
        CacheStatistics(
            hits: cacheHits,
            misses: cacheMisses,
            hitRate: cacheHitRate,
            lastCalculationTime: lastCalculationTime
        )
    }
}

/// 缓存统计信息
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct CacheStatistics {
    /// 缓存命中次数
    public let hits: Int
    /// 缓存未命中次数
    public let misses: Int
    /// 缓存命中率
    public let hitRate: Double
    /// 上次计算时间（秒）
    public let lastCalculationTime: TimeInterval

    /// 总请求次数
    public var totalRequests: Int { hits + misses }
}

/// 专门为懒加载场景优化的布局缓存
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct LazyLayoutCache {
    private var itemSizes: [AnyHashable: CGSize] = [:]
    private var layoutResults: [String: LazyLayoutResult] = [:]
    private let maxCacheSize: Int = 50
    private let maxItemSizeCache: Int = 1000
    
    /// 缓存项目尺寸
    mutating func cacheItemSize<ID: Hashable>(for id: ID, size: CGSize) {
        // 防止无限增长
        if itemSizes.count >= maxItemSizeCache {
            // 智能清理：优先保留最近使用的缓存
            cleanupOldCache()
        }
        itemSizes[AnyHashable(id)] = size
    }

    /// 智能清理旧缓存
    private mutating func cleanupOldCache() {
        let targetSize = maxItemSizeCache * 3 / 4 // 保留75%的缓存
        let removeCount = itemSizes.count - targetSize

        guard removeCount > 0 else { return }

        // 随机移除一部分缓存，避免总是移除相同的项目
        let keysToRemove = Array(itemSizes.keys.shuffled().prefix(removeCount))
        for key in keysToRemove {
            itemSizes.removeValue(forKey: key)
        }


    }
    
    /// 获取缓存的项目尺寸
    func getCachedItemSize<ID: Hashable>(for id: ID) -> CGSize? {
        return itemSizes[AnyHashable(id)]
    }
    
    /// 缓存布局结果
    mutating func cacheLayoutResult(for key: String, result: LazyLayoutResult) {
        if layoutResults.count >= maxCacheSize {
            if let firstKey = layoutResults.keys.first {
                layoutResults.removeValue(forKey: firstKey)
            }
        }
        layoutResults[key] = result
    }
    
    /// 获取缓存的布局结果
    func getCachedLayoutResult(for key: String) -> LazyLayoutResult? {
        return layoutResults[key]
    }
    
    /// 清除所有缓存
    mutating func invalidate() {
        itemSizes.removeAll()
        layoutResults.removeAll()
    }

    /// 清理过期的项目尺寸缓存
    mutating func cleanupItemSizes<ID: Hashable>(validIds: Set<ID>) {
        let validHashableIds = Set(validIds.map { AnyHashable($0) })
        itemSizes = itemSizes.filter { validHashableIds.contains($0.key) }
    }
}

// MARK: - 缓存管理器

/// 布局缓存管理器
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct CacheManager {
    
    /// 生成配置哈希值
    static func generateConfigurationHash(
        axis: Axis,
        lines: MasonryLines,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat,
        placementMode: MasonryPlacementMode
    ) -> Int {
        var hasher = Hasher()
        hasher.combine(axis)
        hasher.combine(lines)
        hasher.combine(horizontalSpacing)
        hasher.combine(verticalSpacing)
        hasher.combine(placementMode)
        return hasher.finalize()
    }
    
    /// 生成懒加载缓存键
    static func generateLazyCacheKey(
        configuration: MasonryConfiguration,
        containerSize: CGSize,
        itemCount: Int
    ) -> String {
        return "\(configuration.hashValue)_\(Int(containerSize.width))x\(Int(containerSize.height))_\(itemCount)"
    }
    
    /// 检查缓存是否有效
    static func isCacheValid(
        cache: LayoutCache,
        containerSize: CGSize,
        configurationHash: Int,
        subviewCount: Int
    ) -> Bool {
        guard let cachedResult = cache.cachedResult else { return false }
        
        return cache.isSizeCompatible(with: containerSize) &&
               cache.lastConfigurationHash == configurationHash &&
               cachedResult.itemFrames.count == subviewCount
    }
}
