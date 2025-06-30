//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 布局相关类型定义

/// 瀑布流布局结果
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LayoutResult {
    /// 每个项目的框架
    let itemFrames: [CGRect]
    /// 总尺寸
    let totalSize: CGSize
    /// 行/列数
    let lineCount: Int
}

/// 懒加载布局结果
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyLayoutResult {
    public let itemFrames: [CGRect]
    public let totalSize: CGSize
    public let lineCount: Int
    public let itemPositions: [AnyHashable: CGRect]
}

// MARK: - 滚动检测系统

/// 滚动视口信息
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct ScrollViewportInfo: Equatable, Sendable {
    /// 视口矩形（在内容坐标系中）
    public let viewportRect: CGRect
    /// 内容总尺寸
    public let contentSize: CGSize
    /// 滚动偏移
    public let scrollOffset: CGPoint
    /// 滚动方向
    public let scrollDirection: ScrollDirection?

    public init(
        viewportRect: CGRect,
        contentSize: CGSize,
        scrollOffset: CGPoint,
        scrollDirection: ScrollDirection? = nil
    ) {
        self.viewportRect = viewportRect
        self.contentSize = contentSize
        self.scrollOffset = scrollOffset
        self.scrollDirection = scrollDirection
    }

    /// 计算滚动进度（0.0 - 1.0）
    public var scrollProgress: CGFloat {
        guard contentSize.height > viewportRect.height else { return 0 }
        let maxOffset = contentSize.height - viewportRect.height
        return max(0, min(1, scrollOffset.y / maxOffset))
    }

    /// 是否接近顶部
    public func isNearTop(threshold: CGFloat = 100) -> Bool {
        return scrollOffset.y <= threshold
    }

    /// 是否接近底部
    public func isNearBottom(threshold: CGFloat = 100) -> Bool {
        let maxOffset = contentSize.height - viewportRect.height
        return scrollOffset.y >= maxOffset - threshold
    }
}

/// 滚动方向
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum ScrollDirection: Equatable, Sendable {
    case up
    case down
    case left
    case right
    case idle
}

/// 滚动偏移检测
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

/// 视口信息检测
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct ViewportInfoPreferenceKey: PreferenceKey {
    static let defaultValue: ScrollViewportInfo = ScrollViewportInfo(
        viewportRect: CGRect.zero,
        contentSize: CGSize.zero,
        scrollOffset: CGPoint.zero
    )

    static func reduce(value: inout ScrollViewportInfo, nextValue: () -> ScrollViewportInfo) {
        value = nextValue()
    }
}

/// 滚动检测管理器
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
internal class ScrollDetectionManager: ObservableObject {

    // MARK: - 状态属性

    private(set) var currentViewport: ScrollViewportInfo = ScrollViewportInfo(
        viewportRect: CGRect.zero,
        contentSize: CGSize.zero,
        scrollOffset: CGPoint.zero
    )

    private(set) var visibleItemIndices: Set<Int> = []
    private(set) var visibleRange: Range<Int> = 0..<0

    // MARK: - 配置

    private let configuration: ScrollDetectionConfiguration
    private var lastScrollOffset: CGPoint = .zero
    private var lastUpdateTime: TimeInterval = 0
    private var debounceTask: Task<Void, Never>?

    // MARK: - 回调

    var onVisibleRangeChanged: ((Range<Int>) -> Void)?
    var onReachTop: (() -> Void)?
    var onReachBottom: (() -> Void)?
    var onScrollDirectionChanged: ((ScrollDirection) -> Void)?

    // MARK: - 初始化

    init(configuration: ScrollDetectionConfiguration = .default) {
        self.configuration = configuration
    }

    // MARK: - 公共方法

    /// 更新视口信息
    func updateViewport(_ viewport: ScrollViewportInfo, layoutResult: LazyLayoutResult?) {
        let currentTime = CFAbsoluteTimeGetCurrent()

        // 简单的防抖检查
        guard currentTime - lastUpdateTime >= configuration.debounceInterval else {
            return
        }

        // 直接更新，不使用Task
        performViewportUpdate(viewport, layoutResult: layoutResult)
    }

    /// 执行视口更新
    private func performViewportUpdate(_ viewport: ScrollViewportInfo, layoutResult: LazyLayoutResult?) {
        let previousViewport = currentViewport
        currentViewport = viewport
        lastUpdateTime = CFAbsoluteTimeGetCurrent()

        // 检测滚动方向
        let direction = detectScrollDirection(from: previousViewport.scrollOffset, to: viewport.scrollOffset)
        if let direction = direction {
            onScrollDirectionChanged?(direction)
        }

        // 更新可见范围
        if let layoutResult = layoutResult {
            updateVisibleRange(viewport: viewport, layoutResult: layoutResult)
        }

        // 检查边界条件
        checkBoundaryConditions(viewport: viewport, previousViewport: previousViewport)
    }

    /// 检测滚动方向
    private func detectScrollDirection(from previous: CGPoint, to current: CGPoint) -> ScrollDirection? {
        let deltaY = current.y - previous.y
        let deltaX = current.x - previous.x

        let threshold: CGFloat = 5.0 // 最小滚动阈值

        if abs(deltaY) > abs(deltaX) {
            if deltaY > threshold {
                return .down
            } else if deltaY < -threshold {
                return .up
            }
        } else {
            if deltaX > threshold {
                return .right
            } else if deltaX < -threshold {
                return .left
            }
        }

        return nil
    }

    /// 更新可见范围
    private func updateVisibleRange(viewport: ScrollViewportInfo, layoutResult: LazyLayoutResult) {
        let newVisibleIndices = calculateVisibleIndices(viewport: viewport, layoutResult: layoutResult)

        if newVisibleIndices != visibleItemIndices {
            visibleItemIndices = newVisibleIndices

            if !newVisibleIndices.isEmpty {
                let sortedIndices = newVisibleIndices.sorted()
                let newRange = sortedIndices.first!..<(sortedIndices.last! + 1)

                if newRange != visibleRange {
                    visibleRange = newRange
                    onVisibleRangeChanged?(newRange)
                }
            }
        }
    }

    /// 计算可见项目索引
    private func calculateVisibleIndices(viewport: ScrollViewportInfo, layoutResult: LazyLayoutResult) -> Set<Int> {
        let expandedViewport = viewport.viewportRect.insetBy(
            dx: -configuration.bufferSize,
            dy: -configuration.bufferSize
        )

        var visibleIndices: Set<Int> = []

        for (index, frame) in layoutResult.itemFrames.enumerated() {
            if expandedViewport.intersects(frame) {
                visibleIndices.insert(index)
            }
        }

        return visibleIndices
    }

    /// 检查边界条件
    private func checkBoundaryConditions(viewport: ScrollViewportInfo, previousViewport: ScrollViewportInfo) {
        // 检查是否到达顶部
        if viewport.isNearTop(threshold: configuration.topThreshold) &&
           !previousViewport.isNearTop(threshold: configuration.topThreshold) {
            onReachTop?()
        }

        // 检查是否到达底部
        if viewport.isNearBottom(threshold: configuration.bottomThreshold) &&
           !previousViewport.isNearBottom(threshold: configuration.bottomThreshold) {
            onReachBottom?()
        }
    }

    /// 清理资源
    func cleanup() {
        debounceTask?.cancel()
        debounceTask = nil
    }
}

/// 滚动检测配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct ScrollDetectionConfiguration: Sendable {
    /// 防抖间隔（秒）
    public let debounceInterval: TimeInterval
    /// 缓冲区大小（像素）
    public let bufferSize: CGFloat
    /// 顶部阈值（像素）
    public let topThreshold: CGFloat
    /// 底部阈值（像素）
    public let bottomThreshold: CGFloat

    public init(
        debounceInterval: TimeInterval = 0.05,
        bufferSize: CGFloat = 200,
        topThreshold: CGFloat = 100,
        bottomThreshold: CGFloat = 100
    ) {
        self.debounceInterval = debounceInterval
        self.bufferSize = bufferSize
        self.topThreshold = topThreshold
        self.bottomThreshold = bottomThreshold
    }

    /// 默认配置 - 适用于大多数场景的平衡配置
    public static let `default` = ScrollDetectionConfiguration()

    // MARK: - 便捷配置方法

    /// 创建快速响应的配置（适用于需要快速反馈的场景）
    /// - Parameters:
    ///   - topThreshold: 顶部触发阈值，默认50px
    ///   - bottomThreshold: 底部触发阈值，默认50px
    /// - Returns: 快速响应配置
    public static func quickResponse(
        topThreshold: CGFloat = 50,
        bottomThreshold: CGFloat = 50
    ) -> ScrollDetectionConfiguration {
        return ScrollDetectionConfiguration(
            debounceInterval: 0.03,
            bufferSize: 100,
            topThreshold: topThreshold,
            bottomThreshold: bottomThreshold
        )
    }

    /// 创建性能优先的配置（适用于大数据量或性能敏感场景）
    /// - Parameters:
    ///   - topThreshold: 顶部触发阈值，默认150px
    ///   - bottomThreshold: 底部触发阈值，默认150px
    /// - Returns: 性能优先配置
    public static func performanceFirst(
        topThreshold: CGFloat = 150,
        bottomThreshold: CGFloat = 150
    ) -> ScrollDetectionConfiguration {
        return ScrollDetectionConfiguration(
            debounceInterval: 0.1,
            bufferSize: 300,
            topThreshold: topThreshold,
            bottomThreshold: bottomThreshold
        )
    }

    /// 创建自定义阈值的配置（保持默认的性能参数，只调整触发阈值）
    /// - Parameters:
    ///   - topThreshold: 顶部触发阈值
    ///   - bottomThreshold: 底部触发阈值
    /// - Returns: 自定义阈值配置
    public static func customThresholds(
        topThreshold: CGFloat,
        bottomThreshold: CGFloat
    ) -> ScrollDetectionConfiguration {
        return ScrollDetectionConfiguration(
            topThreshold: topThreshold,
            bottomThreshold: bottomThreshold
        )
    }
}

/// 布局计算参数
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct LayoutParameters {
    let containerSize: CGSize
    let axis: Axis
    let lines: MasonryLines
    let hSpacing: CGFloat
    let vSpacing: CGFloat
    let placement: MasonryPlacementMode
    let simpleSizing: SimpleSizingConfiguration?
    
    /// 计算行/列数
    func calculateLineCount() -> Int {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height
        let spacing = axis == .vertical ? hSpacing : vSpacing

        guard availableSize > 0 else {
            MasonryInternalConfig.Logger.warning("容器尺寸无效 (availableSize: \(availableSize))，使用默认单列布局")
            return 1
        }

        switch lines {
        case .fixed(let count):
            let validCount = max(1, count)
            if count <= 0 {
                MasonryInternalConfig.Logger.warning("固定列数无效 (\(count))，已修正为 \(validCount)")
            }
            return validCount

        case .adaptive(let constraint):
            switch constraint {
            case .min(let minSize):
                guard minSize > 0 else {
                    MasonryInternalConfig.Logger.warning("最小尺寸无效 (\(minSize))，使用默认单列布局")
                    return 1
                }
                let count = Int(floor((availableSize + spacing) / (minSize + spacing)))
                let validCount = max(1, count)
                if count <= 0 {
                    MasonryInternalConfig.Logger.warning("计算的自适应列数无效 (\(count))，已修正为 \(validCount)")
                }
                return validCount

            case .max(let maxSize):
                guard maxSize > 0 else {
                    MasonryInternalConfig.Logger.warning("最大尺寸无效 (\(maxSize))，使用默认单列布局")
                    return 1
                }
                let count = Int(ceil((availableSize + spacing) / (maxSize + spacing)))
                let validCount = max(1, count)
                if count <= 0 {
                    MasonryInternalConfig.Logger.warning("计算的自适应列数无效 (\(count))，已修正为 \(validCount)")
                }
                return validCount
            }
        }
    }
    
    /// 计算行/列尺寸
    func calculateLineSize(lineCount: Int) -> CGFloat {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height
        guard lineCount > 0 && availableSize > 0 else { return 0 }
        
        let totalSpacing = CGFloat(max(0, lineCount - 1)) * (axis == .vertical ? hSpacing : vSpacing)
        let lineSize = (availableSize - totalSpacing) / CGFloat(lineCount)
        
        return max(0, lineSize)
    }
    
    /// 选择放置的行/列索引
    func selectLineIndex(lineOffsets: [CGFloat], index: Int) -> Int {
        guard !lineOffsets.isEmpty else { return 0 }
        
        switch placement {
        case .fill:
            let selectedIndex = lineOffsets.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            return max(0, min(selectedIndex, lineOffsets.count - 1))
        case .order:
            return index % lineOffsets.count
        }
    }
    
    /// 计算总尺寸
    func calculateTotalSize(lineOffsets: [CGFloat], lineSize: CGFloat, lineCount: Int) -> CGSize {
        let maxOffset = lineOffsets.max() ?? 0
        
        if axis == .vertical {
            let totalHeight = max(0, maxOffset - vSpacing)
            let totalWidth = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * hSpacing
            return CGSize(width: totalWidth, height: totalHeight)
        } else {
            let totalWidth = max(0, maxOffset - hSpacing)
            let totalHeight = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * vSpacing
            return CGSize(width: totalWidth, height: totalHeight)
        }
    }
}

/// 项目布局信息
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct ItemLayoutInfo {
    let frame: CGRect
    let lineIndex: Int
    let itemIndex: Int
}

// MARK: - 懒加载布局相关类型

/// 懒加载布局缓存
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyLayoutCache {
    /// 缓存的项目尺寸 - 使用LRU缓存
    private var itemSizes: LRUCache<AnyHashable, CGSize>
    /// 缓存的布局结果 - 使用LRU缓存
    private var layoutResults: LRUCache<String, LazyLayoutResult>
    /// 可见范围缓存
    private var visibleRangeCache: [String: Range<Int>] = [:]
    /// 最大缓存大小
    private let maxCacheSize: Int = 50
    private let maxItemSizeCache: Int = 1000
    /// 内存压力监控
    private var memoryPressureCount: Int = 0
    private var lastCleanupTime: TimeInterval = 0

    /// 初始化缓存
    public init() {
        self.itemSizes = LRUCache<AnyHashable, CGSize>(maxSize: maxItemSizeCache)
        self.layoutResults = LRUCache<String, LazyLayoutResult>(maxSize: maxCacheSize)
        self.lastCleanupTime = CFAbsoluteTimeGetCurrent()
    }

    /// 缓存项目尺寸
    public mutating func cacheItemSize<ID: Hashable>(for id: ID, size: CGSize) {
        // 检查是否需要清理
        checkAndCleanupIfNeeded()
        itemSizes.set(AnyHashable(id), value: size)
    }

    /// 获取缓存的项目尺寸
    public func getCachedItemSize<ID: Hashable>(for id: ID) -> CGSize? {
        return itemSizes.get(AnyHashable(id))
    }

    /// 缓存布局结果
    public mutating func cacheLayoutResult(for key: String, result: LazyLayoutResult) {
        checkAndCleanupIfNeeded()
        layoutResults.set(key, value: result)
    }

    /// 获取缓存的布局结果
    public func getCachedLayoutResult(for key: String) -> LazyLayoutResult? {
        return layoutResults.get(key)
    }

    /// 缓存可见范围
    public mutating func cacheVisibleRange(for key: String, range: Range<Int>) {
        // 限制可见范围缓存大小
        if visibleRangeCache.count >= maxCacheSize {
            // 移除最旧的条目
            if let firstKey = visibleRangeCache.keys.first {
                visibleRangeCache.removeValue(forKey: firstKey)
            }
        }
        visibleRangeCache[key] = range
    }

    /// 获取缓存的可见范围
    public func getCachedVisibleRange(for key: String) -> Range<Int>? {
        return visibleRangeCache[key]
    }

    /// 清除所有缓存
    public mutating func invalidate() {
        itemSizes.clear()
        layoutResults.clear()
        visibleRangeCache.removeAll()
        memoryPressureCount += 1
        lastCleanupTime = CFAbsoluteTimeGetCurrent()
    }

    /// 智能清理检查
    private mutating func checkAndCleanupIfNeeded() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let timeSinceLastCleanup = currentTime - lastCleanupTime

        if timeSinceLastCleanup > 300 || memoryPressureCount > 0 {
            performSmartCleanup()
            lastCleanupTime = currentTime
        }
    }

    /// 执行智能清理
    private mutating func performSmartCleanup() {
        if visibleRangeCache.count > maxCacheSize / 2 {
            let keysToRemove = Array(visibleRangeCache.keys.prefix(visibleRangeCache.count / 4))
            for key in keysToRemove {
                visibleRangeCache.removeValue(forKey: key)
            }
        }

        // 重置内存压力计数
        if memoryPressureCount > 0 {
            memoryPressureCount = max(0, memoryPressureCount - 1)
        }
    }

    /// 处理内存压力
    public mutating func handleMemoryPressure() {
        memoryPressureCount += 1

        // 立即清理一部分缓存
        if itemSizes.count > maxItemSizeCache / 2 {
            // 清理一半的项目尺寸缓存
            itemSizes.clear()
        }

        if layoutResults.count > maxCacheSize / 2 {
            // 清理一半的布局结果缓存
            layoutResults.clear()
        }

        // 清理可见范围缓存
        visibleRangeCache.removeAll()

        lastCleanupTime = CFAbsoluteTimeGetCurrent()
    }

    /// 获取缓存统计信息
    public var statistics: (itemSizes: Int, layoutResults: Int, visibleRanges: Int, memoryPressure: Int) {
        return (itemSizes.count, layoutResults.count, visibleRangeCache.count, memoryPressureCount)
    }
}

/// 懒加载项目信息
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct LazyItemInfo {
    let id: AnyHashable
    let index: Int
    let estimatedSize: CGSize
    let isVisible: Bool
}

/// 懒加载视口信息
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyViewportInfo {
    public let visibleRect: CGRect
    public let bufferRect: CGRect
    public let scrollDirection: ScrollDirection
}
