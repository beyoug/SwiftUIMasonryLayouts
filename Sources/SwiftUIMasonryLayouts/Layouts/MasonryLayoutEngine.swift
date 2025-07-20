//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 瀑布流布局引擎和缓存系统

/// 瀑布流布局的核心计算引擎
/// 专注于布局算法的实现，不涉及视图渲染
@available(iOS 18.0, *)
internal struct MasonryLayoutEngine {
    
    // MARK: - 核心布局计算
    
    /// 计算标准布局
    /// - Parameters:
    ///   - containerSize: 容器尺寸
    ///   - subviews: 子视图集合
    ///   - parameters: 布局参数
    /// - Returns: 布局结果
    static func calculateLayout(
        containerSize: CGSize,
        subviews: LayoutSubviews,
        parameters: LayoutParameters
    ) -> LayoutResult {
        // 预计算常用值，避免重复计算
        let lineCount = parameters.lineCount
        let lineSize = parameters.lineSize
        let isVertical = parameters.axis == .vertical
        let spacing = isVertical ? parameters.vSpacing : parameters.hSpacing
        let crossSpacing = isVertical ? parameters.hSpacing : parameters.vSpacing

        // 预分配数组容量，减少内存重分配
        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)
        var itemFrames: [CGRect] = []
        itemFrames.reserveCapacity(subviews.count)

        // 预计算ProposedViewSize，避免重复创建
        let proposedSize = ProposedViewSize(
            width: isVertical ? lineSize : nil,
            height: isVertical ? nil : lineSize
        )

        for (index, subview) in subviews.enumerated() {
            let itemSize = subview.sizeThatFits(proposedSize)

            // 内联尺寸验证，减少函数调用开销
            let validatedItemSize = CGSize(
                width: max(0, itemSize.width.isFinite ? itemSize.width : 0),
                height: max(0, itemSize.height.isFinite ? itemSize.height : 0)
            )

            let lineIndex = parameters.selectLineIndex(lineOffsets: lineOffsets, index: index)

            guard lineIndex >= 0 && lineIndex < lineOffsets.count else {
                continue
            }

            // 内联帧计算，减少函数调用
            let frame: CGRect
            if isVertical {
                let x = CGFloat(lineIndex) * (lineSize + crossSpacing)
                frame = CGRect(
                    x: x,
                    y: lineOffsets[lineIndex],
                    width: lineSize,
                    height: validatedItemSize.height
                )
            } else {
                let y = CGFloat(lineIndex) * (lineSize + crossSpacing)
                frame = CGRect(
                    x: lineOffsets[lineIndex],
                    y: y,
                    width: validatedItemSize.width,
                    height: lineSize
                )
            }

            itemFrames.append(frame)

            // 内联行偏移更新，减少函数调用
            if isVertical {
                lineOffsets[lineIndex] += validatedItemSize.height + spacing
            } else {
                lineOffsets[lineIndex] += validatedItemSize.width + spacing
            }
        }

        // 内联总尺寸计算，避免方法调用开销
        let maxOffset = lineOffsets.max() ?? 0
        let totalSize: CGSize
        if isVertical {
            let totalWidth = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * crossSpacing
            let totalHeight = maxOffset > 0 ? max(0, maxOffset - spacing) : 0
            totalSize = CGSize(width: totalWidth, height: totalHeight)
        } else {
            let totalHeight = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * crossSpacing
            let totalWidth = maxOffset > 0 ? max(0, maxOffset - spacing) : 0
            totalSize = CGSize(width: totalWidth, height: totalHeight)
        }

        return LayoutResult(
            itemFrames: itemFrames,
            totalSize: totalSize,
            lineCount: lineCount
        )
    }
    
    /// 计算懒加载布局
    /// - Parameters:
    ///   - containerSize: 容器尺寸
    ///   - items: 数据项目
    ///   - configuration: 布局配置
    ///   - sizeCalculator: 项目尺寸计算器
    /// - Returns: 懒加载布局结果
    static func calculateLazyLayout<Data: RandomAccessCollection, ID: Hashable>(
        containerSize: CGSize,
        items: Data,
        configuration: MasonryConfiguration,
        sizeCalculator: ((Data.Element, CGFloat) -> CGSize)?
    ) -> LazyLayoutResult where Data.Element: Identifiable, Data.Element.ID == ID {

        // 🎯 布局引擎层面的零尺寸保护
        guard containerSize.width > 0 && containerSize.height > 0 else {
            return LazyLayoutResult(
                itemFrames: [],
                totalSize: .zero,
                lineCount: 0,
                itemPositions: [:]
            )
        }

        let parameters = LayoutParameters(
            containerSize: containerSize,
            axis: configuration.axis,
            lines: configuration.lines,
            hSpacing: configuration.hSpacing,
            vSpacing: configuration.vSpacing,
            placement: configuration.placement
        )

        // 预计算常用值
        let lineCount = parameters.lineCount
        let lineSize = parameters.lineSize
        let isVertical = configuration.axis == .vertical
        let spacing = isVertical ? configuration.vSpacing : configuration.hSpacing
        let crossSpacing = isVertical ? configuration.hSpacing : configuration.vSpacing

        // 预分配容量，减少内存重分配
        let itemCount = items.count
        var itemFrames: [CGRect] = []
        itemFrames.reserveCapacity(itemCount)
        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)
        var positions: [AnyHashable: CGRect] = [:]
        positions.reserveCapacity(itemCount)

        for (index, item) in items.enumerated() {
            // 内联尺寸计算，减少函数调用
            let itemSize: CGSize
            if let calculator = sizeCalculator {
                itemSize = calculator(item, lineSize)
            } else {
                // 简化默认尺寸计算
                let hashValue = abs(item.id.hashValue)
                if isVertical {
                    let heightVariation = CGFloat(hashValue % 180) + 120
                    itemSize = CGSize(width: lineSize, height: heightVariation)
                } else {
                    let widthVariation = CGFloat(hashValue % 180) + 120
                    itemSize = CGSize(width: widthVariation, height: lineSize)
                }
            }

            let lineIndex = parameters.selectLineIndex(lineOffsets: lineOffsets, index: index)

            guard lineIndex >= 0 && lineIndex < lineOffsets.count else { continue }

            // 内联帧计算
            let frame: CGRect
            if isVertical {
                let x = CGFloat(lineIndex) * (lineSize + crossSpacing)
                frame = CGRect(
                    x: x,
                    y: lineOffsets[lineIndex],
                    width: lineSize,
                    height: itemSize.height
                )
            } else {
                let y = CGFloat(lineIndex) * (lineSize + crossSpacing)
                frame = CGRect(
                    x: lineOffsets[lineIndex],
                    y: y,
                    width: itemSize.width,
                    height: lineSize
                )
            }

            itemFrames.append(frame)
            positions[AnyHashable(item.id)] = frame

            // 内联行偏移更新
            if isVertical {
                lineOffsets[lineIndex] += itemSize.height + spacing
            } else {
                lineOffsets[lineIndex] += itemSize.width + spacing
            }
        }

        // 内联总尺寸计算
        let maxOffset = lineOffsets.max() ?? 0
        let totalSize: CGSize
        if isVertical {
            let totalWidth = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * crossSpacing
            let totalHeight = maxOffset > 0 ? max(0, maxOffset - spacing) : 0
            totalSize = CGSize(width: totalWidth, height: totalHeight)
        } else {
            let totalHeight = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * crossSpacing
            let totalWidth = maxOffset > 0 ? max(0, maxOffset - spacing) : 0
            totalSize = CGSize(width: totalWidth, height: totalHeight)
        }

        return LazyLayoutResult(
            itemFrames: itemFrames,
            totalSize: totalSize,
            lineCount: lineCount,
            itemPositions: positions
        )
    }
    
    // MARK: - 辅助方法

    /// 计算总尺寸（优化版本，避免方法调用开销）
    private static func calculateTotalSize(
        lineOffsets: [CGFloat],
        lineSize: CGFloat,
        lineCount: Int,
        parameters: LayoutParameters
    ) -> CGSize {
        // 确保参数有效性
        guard lineCount > 0, lineSize >= 0 else {
            return .zero
        }

        let maxOffset = lineOffsets.max() ?? 0
        let safeLineCount = max(1, lineCount)
        let safeLineSize = max(0, lineSize)

        if parameters.axis == .vertical {
            // 垂直布局：宽度由列数决定，高度由内容决定
            let totalWidth = CGFloat(safeLineCount) * safeLineSize + CGFloat(max(0, safeLineCount - 1)) * parameters.hSpacing
            let totalHeight = maxOffset > 0 ? max(0, maxOffset - parameters.vSpacing) : 0
            return CGSize(width: totalWidth, height: totalHeight)
        } else {
            // 水平布局：高度由行数决定，宽度由内容决定
            let totalHeight = CGFloat(safeLineCount) * safeLineSize + CGFloat(max(0, safeLineCount - 1)) * parameters.vSpacing
            let totalWidth = maxOffset > 0 ? max(0, maxOffset - parameters.hSpacing) : 0
            return CGSize(width: totalWidth, height: totalHeight)
        }
    }

    /// 计算项目框架
    private static func calculateItemFrame(
        itemSize: CGSize,
        lineIndex: Int,
        lineSize: CGFloat,
        lineOffset: CGFloat,
        parameters: LayoutParameters
    ) -> CGRect {
        // 确保所有值都是有效的
        let safeLineIndex = max(0, lineIndex)
        let safeLineSize = max(0, lineSize)
        let safeLineOffset = max(0, lineOffset)

        if parameters.axis == .vertical {
            let x = CGFloat(safeLineIndex) * safeLineSize + CGFloat(safeLineIndex) * parameters.hSpacing
            let frame = CGRect(
                x: x,
                y: safeLineOffset,
                width: safeLineSize,
                height: max(0, itemSize.height)
            )
            return frame
        } else {
            let y = CGFloat(safeLineIndex) * safeLineSize + CGFloat(safeLineIndex) * parameters.vSpacing
            let frame = CGRect(
                x: safeLineOffset,
                y: y,
                width: max(0, itemSize.width),
                height: safeLineSize
            )
            return frame
        }
    }
    
    /// 更新行偏移
    private static func updateLineOffset(
        _ lineOffsets: inout [CGFloat],
        lineIndex: Int,
        itemSize: CGSize,
        parameters: LayoutParameters
    ) {
        if parameters.axis == .vertical {
            lineOffsets[lineIndex] += itemSize.height + parameters.vSpacing
        } else {
            lineOffsets[lineIndex] += itemSize.width + parameters.hSpacing
        }
    }
    
    /// 计算懒加载项目尺寸
    private static func calculateItemSize<Item: Identifiable>(
        item: Item,
        lineSize: CGFloat,
        configuration: MasonryConfiguration,
        sizeCalculator: ((Item, CGFloat) -> CGSize)?
    ) -> CGSize {

        // 使用自定义计算器
        if let calculator = sizeCalculator {
            return calculator(item, lineSize)
        }

        // 智能默认尺寸计算
        return calculateIntelligentDefaultSize(
            item: item,
            lineSize: lineSize,
            configuration: configuration
        )
    }

    /// 智能默认尺寸计算
    /// 根据项目的属性智能推断合适的尺寸，避免所有项目使用相同尺寸
    /// 🎯 优先支持内容自适应，不依赖数据模型的固定尺寸
    private static func calculateIntelligentDefaultSize<Item: Identifiable>(
        item: Item,
        lineSize: CGFloat,
        configuration: MasonryConfiguration
    ) -> CGSize {

        // 🎯 注释掉反射提取，优先使用内容自适应
        // 这样可以让视图根据实际内容计算高度，而不是使用数据模型中的固定值
        // if let sizeFromReflection = extractSizeFromItem(item, lineSize: lineSize, configuration: configuration) {
        //     return sizeFromReflection
        // }

        // 基础尺寸范围
        let minHeight: CGFloat = 120
        let minWidth: CGFloat = 120

        // 使用项目ID的哈希值来生成伪随机但一致的尺寸
        let hashValue = abs(item.id.hashValue)

        if configuration.axis == .vertical {
            // 垂直布局：固定宽度，变化高度
            let heightVariation = CGFloat(hashValue % 180) + minHeight // 120-300范围
            return CGSize(width: lineSize, height: heightVariation)
        } else {
            // 水平布局：固定高度，变化宽度
            let widthVariation = CGFloat(hashValue % 180) + minWidth // 120-300范围
            return CGSize(width: widthVariation, height: lineSize)
        }
    }

    /// 通过反射尝试从项目中提取尺寸信息
    private static func extractSizeFromItem<Item: Identifiable>(
        _ item: Item,
        lineSize: CGFloat,
        configuration: MasonryConfiguration
    ) -> CGSize? {
        let mirror = Mirror(reflecting: item)

        var width: CGFloat?
        var height: CGFloat?

        // 查找常见的尺寸属性
        for child in mirror.children {
            guard let label = child.label else { continue }

            switch label.lowercased() {
            case "width":
                if let value = child.value as? CGFloat {
                    width = value
                } else if let value = child.value as? Double {
                    width = CGFloat(value)
                } else if let value = child.value as? Int {
                    width = CGFloat(value)
                }
            case "height":
                if let value = child.value as? CGFloat {
                    height = value
                } else if let value = child.value as? Double {
                    height = CGFloat(value)
                } else if let value = child.value as? Int {
                    height = CGFloat(value)
                }
            default:
                break
            }
        }

        // 根据配置轴向返回合适的尺寸
        if configuration.axis == .vertical {
            // 垂直布局：使用lineSize作为宽度，height属性作为高度
            if let h = height, h > 0 {
                return CGSize(width: lineSize, height: h)
            }
        } else {
            // 水平布局：使用width属性作为宽度，lineSize作为高度
            if let w = width, w > 0 {
                return CGSize(width: w, height: lineSize)
            }
        }

        return nil
    }
}

// MARK: - 布局缓存系统

/// 瀑布流布局缓存
@available(iOS 18.0, *)
public struct LayoutCache {
    /// 缓存的布局结果
    var cachedResult: LayoutResult?
    /// 上次计算的容器尺寸
    var lastContainerSize: CGSize = .zero
    /// 上次计算的配置哈希值
    var lastConfigurationHash: Int = 0
    /// 子视图数量
    var subviewCount: Int = 0

    // 添加轴向信息以支持更智能的缓存策略
    var lastAxis: Axis = .vertical

    // 仅在DEBUG模式下统计缓存性能
    #if DEBUG
    /// 缓存命中次数
    private var cacheHits: Int = 0
    /// 缓存未命中次数
    private var cacheMisses: Int = 0
    #endif

    /// 清除缓存
    /// 只重置必要的字段，减少内存分配
    mutating func invalidate() {
        cachedResult = nil
        lastContainerSize = .zero
        lastConfigurationHash = 0
        subviewCount = 0
        // 保留轴向信息，避免不必要的重置
    }

    /// 尺寸兼容性检查
    /// 使用CacheManager的算法
    func isSizeCompatible(with size: CGSize) -> Bool {
        return CacheManager.isSizeCompatible(
            lastSize: lastContainerSize,
            currentSize: size,
            axis: lastAxis
        )
    }

    // 🚀 优化：仅在DEBUG模式下记录缓存统计
    mutating func recordCacheHit() {
        #if DEBUG
        cacheHits += 1
        #endif
    }

    mutating func recordCacheMiss() {
        #if DEBUG
        cacheMisses += 1
        #endif
    }

    /// 获取缓存命中率
    var cacheHitRate: Double {
        #if DEBUG
        let total = cacheHits + cacheMisses
        return total > 0 ? Double(cacheHits) / Double(total) : 0
        #else
        return 0
        #endif
    }

    /// 获取缓存统计信息
    var statistics: CacheStatistics {
        #if DEBUG
        CacheStatistics(
            hits: cacheHits,
            misses: cacheMisses,
            hitRate: cacheHitRate
        )
        #else
        CacheStatistics(
            hits: 0,
            misses: 0,
            hitRate: 0
        )
        #endif
    }
}

/// 缓存统计信息
@available(iOS 18.0, *)
public struct CacheStatistics {
    /// 缓存命中次数
    public let hits: Int
    /// 缓存未命中次数
    public let misses: Int
    /// 缓存命中率
    public let hitRate: Double

    /// 总请求次数
    public var totalRequests: Int { hits + misses }
}

/// 专门为懒加载场景的布局缓存
@available(iOS 18.0, *)
internal struct LazyLayoutCache {
    private var itemSizes: [AnyHashable: CGSize] = [:]
    private var layoutResults: [Int: LazyLayoutResult] = [:] // 使用Int键替代String
    private let maxCacheSize: Int = 30 // 减少缓存大小，降低内存占用
    private let maxItemSizeCache: Int = 500 // 减少项目尺寸缓存

    /// 缓存项目尺寸
    mutating func cacheItemSize<ID: Hashable>(for id: ID, size: CGSize) {
        // 激进的内存管理策略
        if itemSizes.count >= maxItemSizeCache {
            cleanupOldCache()
        }
        itemSizes[AnyHashable(id)] = size
    }

    /// 高效的缓存清理算法
    private mutating func cleanupOldCache() {
        let targetSize = maxItemSizeCache * 3 / 4 // 保留75%，减少清理频率
        guard itemSizes.count > targetSize else { return }

        // 批量移除，减少字典操作次数
        let removeCount = itemSizes.count - targetSize
        let keysToRemove = Array(itemSizes.keys.prefix(removeCount))

        // 使用removeValue批量操作
        for key in keysToRemove {
            itemSizes.removeValue(forKey: key)
        }

        // 同时清理布局结果缓存
        if layoutResults.count > maxCacheSize {
            let layoutKeysToRemove = Array(layoutResults.keys.prefix(layoutResults.count - maxCacheSize / 2))
            for key in layoutKeysToRemove {
                layoutResults.removeValue(forKey: key)
            }
        }
    }

    /// 获取缓存的项目尺寸
    func getCachedItemSize<ID: Hashable>(for id: ID) -> CGSize? {
        return itemSizes[AnyHashable(id)]
    }

    /// 缓存布局结果
    mutating func cacheLayoutResult(for key: Int, result: LazyLayoutResult) {
        if layoutResults.count >= maxCacheSize {
            if let firstKey = layoutResults.keys.first {
                layoutResults.removeValue(forKey: firstKey)
            }
        }
        layoutResults[key] = result
    }

    /// 获取缓存的布局结果
    func getCachedLayoutResult(for key: Int) -> LazyLayoutResult? {
        return layoutResults[key]
    }

    /// 清除所有缓存
    mutating func invalidate() {
        itemSizes.removeAll()
        layoutResults.removeAll()
    }

    /// 清除特定项目的缓存
    mutating func invalidateItem<ID: Hashable>(for id: ID) {
        itemSizes.removeValue(forKey: AnyHashable(id))
    }

    /// 清除布局结果缓存（保留项目尺寸缓存）
    mutating func invalidateLayoutResults() {
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
@available(iOS 18.0, *)
internal struct CacheManager {

    /// 生成配置哈希值
    /// 使用高效的哈希算法，减少冲突
    static func generateConfigurationHash(
        axis: Axis,
        lines: MasonryLines,
        hSpacing: CGFloat,
        vSpacing: CGFloat,
        placement: MasonryPlacementMode
    ) -> Int {
        // 使用位运算和预计算减少哈希冲突
        var hash = axis == .vertical ? 1 : 2

        // 对lines进行更精确的哈希
        switch lines {
        case .fixed(let count):
            hash = hash &* 31 &+ count &* 3
        case .adaptive(let constraint):
            switch constraint {
            case .min(let size):
                hash = hash &* 31 &+ Int(size * 100) &* 5
            case .max(let size):
                hash = hash &* 31 &+ Int(size * 100) &* 7
            }
        }

        // 对间距进行优化的哈希处理
        hash = hash &* 31 &+ Int(hSpacing * 10)
        hash = hash &* 31 &+ Int(vSpacing * 10)

        // 放置模式哈希
        hash = hash &* 31 &+ (placement == .fill ? 11 : 13)

        return hash
    }

    /// 生成懒加载缓存键
    /// 减少字符串拼接，使用高效的键生成
    static func generateLazyCacheKey(
        configuration: MasonryConfiguration,
        containerSize: CGSize,
        itemCount: Int
    ) -> Int {
        // 使用整数键替代字符串，提升性能
        var key = configuration.hashValue
        key = key &* 31 &+ Int(containerSize.width)
        key = key &* 31 &+ Int(containerSize.height)
        key = key &* 31 &+ itemCount
        return key
    }

    /// 缓存有效性检查
    /// 精确的失效判断，减少不必要的重计算
    static func isCacheValid(
        cache: LayoutCache,
        containerSize: CGSize,
        configurationHash: Int,
        subviewCount: Int
    ) -> Bool {
        guard let cachedResult = cache.cachedResult else { return false }

        // 先检查最容易失效的条件，提前返回
        guard cachedResult.itemFrames.count == subviewCount else { return false }
        guard cache.lastConfigurationHash == configurationHash else { return false }

        // 最后检查尺寸兼容性（相对耗时的操作）
        return cache.isSizeCompatible(with: containerSize)
    }

    /// 尺寸兼容性检查
    /// 使用智能的容差算法
    static func isSizeCompatible(
        lastSize: CGSize,
        currentSize: CGSize,
        axis: Axis
    ) -> Bool {
        // 根据轴向使用不同的容差策略
        let tolerance: CGFloat = 0.5 // 减少容差，提高缓存精度

        if axis == .vertical {
            // 垂直布局：宽度变化敏感，高度可以有更大容差
            return abs(lastSize.width - currentSize.width) <= tolerance &&
                   abs(lastSize.height - currentSize.height) <= tolerance * 2
        } else {
            // 水平布局：高度变化敏感，宽度可以有更大容差
            return abs(lastSize.width - currentSize.width) <= tolerance * 2 &&
                   abs(lastSize.height - currentSize.height) <= tolerance
        }
    }
}

// MARK: - 内部扩展

@available(iOS 18.0, *)
internal extension CGSize {
    /// 检查尺寸是否有效
    var isValid: Bool {
        return width >= 0 && height >= 0 && width.isFinite && height.isFinite
    }

    /// 获取安全的尺寸（确保非负且有限）
    var safe: CGSize {
        return MasonryInternal.validateSize(self)
    }
}

@available(iOS 18.0, *)
internal extension CGFloat {
    /// 检查数值是否有效
    var isValid: Bool {
        return isFinite && !isNaN
    }

    /// 获取安全的数值（确保有限且非NaN）
    var safe: CGFloat {
        return isValid ? self : 0
    }
}

@available(iOS 18.0, *)
internal extension Array where Element == CGFloat {
    /// 安全地获取最小值索引
    var safeMinIndex: Int? {
        guard !isEmpty else { return nil }
        return enumerated().min(by: { $0.element < $1.element })?.offset
    }

    /// 安全地获取最大值
    var safeMax: CGFloat {
        return self.max() ?? 0
    }
}
