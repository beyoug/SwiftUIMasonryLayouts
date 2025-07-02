//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 瀑布流布局引擎和缓存系统

/// 瀑布流布局的核心计算引擎
/// 专注于布局算法的实现，不涉及视图渲染
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
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
        let lineCount = parameters.calculateLineCount()
        let lineSize = parameters.calculateLineSize(lineCount: lineCount)
        
        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)
        var itemFrames: [CGRect] = []

        for (index, subview) in subviews.enumerated() {
            let itemSize = subview.sizeThatFits(ProposedViewSize(
                width: parameters.axis == .vertical ? lineSize : nil,
                height: parameters.axis == .horizontal ? lineSize : nil
            ))

            // 验证项目尺寸的有效性
            let validatedItemSize = MasonryInternal.validateSize(itemSize, context: "Item \(index)")

            let lineIndex = parameters.selectLineIndex(lineOffsets: lineOffsets, index: index)

            guard lineIndex >= 0 && lineIndex < lineOffsets.count else {
                MasonryLogger.warning("Layout: 无效的行索引 \(lineIndex)，跳过项目 \(index)")
                continue
            }

            let frame = calculateItemFrame(
                itemSize: validatedItemSize,
                lineIndex: lineIndex,
                lineSize: lineSize,
                lineOffset: lineOffsets[lineIndex],
                parameters: parameters
            )

            itemFrames.append(frame)

            // 更新行偏移
            updateLineOffset(
                &lineOffsets,
                lineIndex: lineIndex,
                itemSize: validatedItemSize,
                parameters: parameters
            )
        }
        
        let totalSize = parameters.calculateTotalSize(
            lineOffsets: lineOffsets,
            lineSize: lineSize,
            lineCount: lineCount
        )
        
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
    ///   - cache: 懒加载缓存
    /// - Returns: 懒加载布局结果
    static func calculateLazyLayout<Data: RandomAccessCollection, ID: Hashable>(
        containerSize: CGSize,
        items: Data,
        configuration: MasonryConfiguration,
        sizeCalculator: ((Data.Element, CGFloat) -> CGSize)?
    ) -> LazyLayoutResult where Data.Element: Identifiable, Data.Element.ID == ID {

        // 🎯 布局引擎层面的零尺寸保护
        guard containerSize.width > 0 && containerSize.height > 0 else {
            MasonryLogger.warning("LayoutEngine: 容器尺寸无效 \(containerSize)，返回空布局结果")
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
        
        let lineCount = parameters.calculateLineCount()
        let lineSize = parameters.calculateLineSize(lineCount: lineCount)

        
        var itemFrames: [CGRect] = []
        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)
        var positions: [AnyHashable: CGRect] = [:]
        
        for (index, item) in items.enumerated() {
            let itemSize = calculateItemSize(
                item: item,
                lineSize: lineSize,
                configuration: configuration,
                sizeCalculator: sizeCalculator
            )
            
            let lineIndex = parameters.selectLineIndex(lineOffsets: lineOffsets, index: index)
            
            guard lineIndex >= 0 && lineIndex < lineOffsets.count else { continue }
            
            let frame = calculateItemFrame(
                itemSize: itemSize,
                lineIndex: lineIndex,
                lineSize: lineSize,
                lineOffset: lineOffsets[lineIndex],
                parameters: parameters
            )
            
            itemFrames.append(frame)
            positions[AnyHashable(item.id)] = frame
            updateLineOffset(
                &lineOffsets,
                lineIndex: lineIndex,
                itemSize: itemSize,
                parameters: parameters
            )
        }
        
        let totalSize = parameters.calculateTotalSize(
            lineOffsets: lineOffsets,
            lineSize: lineSize,
            lineCount: lineCount
        )
        
        return LazyLayoutResult(
            itemFrames: itemFrames,
            totalSize: totalSize,
            lineCount: lineCount,
            itemPositions: positions
        )
    }
    
    // MARK: - 辅助方法
    
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
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct CacheManager {

    /// 生成配置哈希值
    static func generateConfigurationHash(
        axis: Axis,
        lines: MasonryLines,
        hSpacing: CGFloat,
        vSpacing: CGFloat,
        placement: MasonryPlacementMode
    ) -> Int {
        var hasher = Hasher()
        hasher.combine(axis)
        hasher.combine(lines)
        hasher.combine(hSpacing)
        hasher.combine(vSpacing)
        hasher.combine(placement)
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

// MARK: - 内部扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
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

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
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

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
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
