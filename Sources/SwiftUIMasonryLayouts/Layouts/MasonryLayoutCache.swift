//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - LRU缓存实现

/// LRU (Least Recently Used) 缓存实现
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal final class LRUCache<Key: Hashable, Value>: @unchecked Sendable {
    private let maxSize: Int
    private var cache: [Key: Node] = [:]
    private var head: Node?
    private var tail: Node?
    private let lock = NSLock()

    private final class Node {
        let key: Key
        var value: Value
        var prev: Node?
        var next: Node?

        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }

    init(maxSize: Int) {
        self.maxSize = max(1, maxSize)
    }

    func get(_ key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }

        guard let node = cache[key] else { return nil }
        moveToHead(node)
        return node.value
    }

    func set(_ key: Key, value: Value) {
        lock.lock()
        defer { lock.unlock() }

        if let existingNode = cache[key] {
            existingNode.value = value
            moveToHead(existingNode)
            return
        }

        let newNode = Node(key: key, value: value)
        cache[key] = newNode
        addToHead(newNode)

        if cache.count > maxSize {
            removeLeastUsed()
        }
    }

    func remove(_ key: Key) {
        lock.lock()
        defer { lock.unlock() }

        guard let node = cache[key] else { return }
        cache.removeValue(forKey: key)
        removeNode(node)
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }

        cache.removeAll()
        head = nil
        tail = nil
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return cache.count
    }

    // MARK: - Private Methods

    private func addToHead(_ node: Node) {
        node.prev = nil
        node.next = head
        head?.prev = node
        head = node

        if tail == nil {
            tail = node
        }
    }

    private func removeNode(_ node: Node) {
        if node.prev != nil {
            node.prev?.next = node.next
        } else {
            head = node.next
        }

        if node.next != nil {
            node.next?.prev = node.prev
        } else {
            tail = node.prev
        }
    }

    private func moveToHead(_ node: Node) {
        removeNode(node)
        addToHead(node)
    }

    private func removeLeastUsed() {
        guard let lastNode = tail else { return }
        cache.removeValue(forKey: lastNode.key)
        removeNode(lastNode)
    }
}

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
        // 使用相对容差而不是固定容差，适应不同屏幕尺寸
        let relativeTolerance: CGFloat = 0.001 // 0.1%的相对容差
        let minAbsoluteTolerance: CGFloat = 0.5 // 最小绝对容差

        let widthTolerance = max(minAbsoluteTolerance, lastContainerSize.width * relativeTolerance)
        let heightTolerance = max(minAbsoluteTolerance, lastContainerSize.height * relativeTolerance)

        let widthCompatible = abs(lastContainerSize.width - size.width) <= widthTolerance
        let heightCompatible = abs(lastContainerSize.height - size.height) <= heightTolerance

        return widthCompatible && heightCompatible
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

// LazyLayoutCache 现在定义在 MasonryLayoutTypes.swift 中

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
    
    /// 生成懒加载缓存键（改进版本）
    static func generateLazyCacheKey(
        configuration: MasonryConfiguration,
        containerSize: CGSize,
        itemCount: Int
    ) -> String {
        // 使用更精确的尺寸表示，但保持合理的精度
        let widthKey = String(format: "%.1f", containerSize.width)
        let heightKey = String(format: "%.1f", containerSize.height)

        return "\(configuration.hashValue)_\(widthKey)x\(heightKey)_\(itemCount)"
    }

    /// 生成更稳定的配置哈希值
    static func generateStableConfigurationHash(
        axis: Axis,
        lines: MasonryLines,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat,
        placementMode: MasonryPlacementMode
    ) -> Int {
        var hasher = Hasher()

        // 使用稳定的哈希策略
        hasher.combine(axis.hashValue)
        hasher.combine(lines.hashValue)

        // 对间距进行舍入以提高缓存命中率
        let roundedHSpacing = (horizontalSpacing * 10).rounded() / 10
        let roundedVSpacing = (verticalSpacing * 10).rounded() / 10

        hasher.combine(roundedHSpacing)
        hasher.combine(roundedVSpacing)
        hasher.combine(placementMode.hashValue)

        return hasher.finalize()
    }
    
    /// 检查缓存是否有效（增强版本）
    static func isCacheValid(
        cache: LayoutCache,
        containerSize: CGSize,
        configurationHash: Int,
        subviewCount: Int
    ) -> Bool {
        guard let cachedResult = cache.cachedResult else { return false }

        // 基本有效性检查
        let basicValid = cache.isSizeCompatible(with: containerSize) &&
                        cache.lastConfigurationHash == configurationHash &&
                        cachedResult.itemFrames.count == subviewCount

        if !basicValid {
            return false
        }

        // 检查缓存是否过期（可选的时间基础失效）
        let currentTime = CFAbsoluteTimeGetCurrent()
        let cacheAge = currentTime - cache.lastCalculationTime
        let maxCacheAge: TimeInterval = 300 // 5分钟缓存有效期

        if cacheAge > maxCacheAge {
            return false
        }

        return true
    }

    /// 获取缓存性能报告
    static func getCachePerformanceReport(cache: LayoutCache) -> String {
        let stats = cache.statistics
        let hitRate = stats.hitRate * 100
        let avgCalculationTime = stats.lastCalculationTime * 1000

        return """
        缓存性能报告:
        - 命中率: \(String(format: "%.1f", hitRate))%
        - 命中次数: \(stats.hits)
        - 未命中次数: \(stats.misses)
        - 上次计算耗时: \(String(format: "%.2f", avgCalculationTime))ms
        """
    }
}
