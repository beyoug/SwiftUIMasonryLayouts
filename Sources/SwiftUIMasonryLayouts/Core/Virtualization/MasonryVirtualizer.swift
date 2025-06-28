//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

// MARK: - 瀑布流虚拟化器

/// 瀑布流虚拟化器，管理项目的虚拟化渲染
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@Observable @MainActor
class MasonryVirtualizer {

    /// 虚拟项目信息
    struct VirtualItem: Identifiable, Equatable {
        let id: AnyHashable
        let dataIndex: Int
        let frame: CGRect

        /// 稳定的视图ID，用于减少SwiftUI视图重建
        var stableViewID: String {
            return "item_\(dataIndex)"
        }

        static func == (lhs: VirtualItem, rhs: VirtualItem) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.dataIndex == rhs.dataIndex &&
                   abs(lhs.frame.minX - rhs.frame.minX) < 1.0 &&
                   abs(lhs.frame.minY - rhs.frame.minY) < 1.0 &&
                   abs(lhs.frame.width - rhs.frame.width) < 1.0 &&
                   abs(lhs.frame.height - rhs.frame.height) < 1.0
        }
    }

    /// 所有项目的布局信息
    internal var allItems: [VirtualItem] = []

    /// 公共访问器：所有项目的布局信息
    var allItemsCount: Int { allItems.count }
    var allItemsFrames: [CGRect] { allItems.map { $0.frame } }

    /// 当前可见的项目
    var visibleItems: [VirtualItem] = []

    /// 上次的可见区域（用于增量更新）
    internal var lastVisibleRect: CGRect = .zero

    /// 可见项目的索引集合（用于快速查找）
    internal var visibleItemIndices: Set<Int> = []

    /// 视图稳定性控制
    internal var isUpdating: Bool = false
    internal var pendingUpdateRect: CGRect?

    /// 总内容尺寸
    var totalSize: CGSize = .zero

    /// 缓冲区大小（屏幕尺寸的倍数）
    internal let bufferMultiplier: CGFloat = 1.5

    /// 最大缓存项目数量（防止内存泄漏）
    internal let maxCachedItems: Int = 50000

    /// 内存压力阈值（MB）
    internal let memoryPressureThreshold: Int = 100

    /// 布局缓存
    internal var layoutCache: VirtualLayoutCache = VirtualLayoutCache()

    /// 当前布局任务
    internal var currentLayoutTask: Task<Void, Never>?

    /// 并发控制 Actor
    internal actor ConcurrencyController {
        private var isCalculating: Bool = false
        private var taskSequence: UInt64 = 0

        internal func startCalculation() -> UInt64? {
            guard !isCalculating else { return nil }
            isCalculating = true
            taskSequence += 1
            return taskSequence
        }

        internal func finishCalculation() {
            isCalculating = false
        }

        internal func invalidateAllTasks() -> UInt64 {
            isCalculating = false
            taskSequence += 1
            return taskSequence
        }

        internal func getCurrentSequence() -> UInt64 {
            return taskSequence
        }

        internal func isValidSequence(_ sequence: UInt64) -> Bool {
            return taskSequence == sequence
        }
    }

    /// 并发控制器
    internal let concurrencyController = ConcurrencyController()

    /// 高效的缓存键结构
    internal struct CacheKey: Hashable {
        let dataCount: Int
        let axis: Axis
        let linesHash: Int
        let horizontalSpacing: Int // 使用整数避免浮点数精度问题
        let verticalSpacing: Int
        let placementMode: MasonryPlacementMode
        let estimatedWidth: Int
        let estimatedHeight: Int
        let containerWidth: Int
        let containerHeight: Int

        init(
            dataCount: Int,
            axis: Axis,
            lines: MasonryLines,
            horizontalSpacing: CGFloat,
            verticalSpacing: CGFloat,
            placementMode: MasonryPlacementMode,
            estimatedItemSize: CGSize,
            containerSize: CGSize
        ) {
            self.dataCount = dataCount
            self.axis = axis
            self.linesHash = lines.hashValue
            self.horizontalSpacing = Int(horizontalSpacing * 100) // 保留两位小数精度
            self.verticalSpacing = Int(verticalSpacing * 100)
            self.placementMode = placementMode
            self.estimatedWidth = Int(estimatedItemSize.width * 100)
            self.estimatedHeight = Int(estimatedItemSize.height * 100)
            self.containerWidth = Int(containerSize.width * 100)
            self.containerHeight = Int(containerSize.height * 100)
        }
    }

    /// 布局缓存结构
    internal struct VirtualLayoutCache {
        var containerSize: CGSize = .zero
        var dataCount: Int = 0
        var estimatedItemSize: CGSize = .zero
        var cachedItems: [VirtualItem] = []
        var cachedTotalSize: CGSize = .zero
        var cacheKey: CacheKey?
        var cacheHitCount: Int = 0
        var cacheMissCount: Int = 0
        var lastAccessTime: CFTimeInterval = 0

        mutating func invalidate() {
            cachedItems = []
            cachedTotalSize = .zero
            cacheKey = nil
            lastAccessTime = 0
        }

        func isValid(for newCacheKey: CacheKey) -> Bool {
            guard let currentKey = cacheKey else { return false }
            return currentKey == newCacheKey && !cachedItems.isEmpty
        }

        mutating func updateCache(items: [VirtualItem], totalSize: CGSize, cacheKey: CacheKey) {
            self.cachedItems = items
            self.cachedTotalSize = totalSize
            self.cacheKey = cacheKey
            self.lastAccessTime = CFAbsoluteTimeGetCurrent()
        }

        mutating func recordCacheHit() {
            cacheHitCount += 1
            lastAccessTime = CFAbsoluteTimeGetCurrent()
        }

        mutating func recordCacheMiss() {
            cacheMissCount += 1
        }

        var cacheEfficiency: Double {
            let total = cacheHitCount + cacheMissCount
            return total > 0 ? Double(cacheHitCount) / Double(total) : 0
        }
    }

    /// 初始化虚拟化器
    func initialize<Data: RandomAccessCollection, ID: Hashable>(
        data: Data,
        axis: Axis,
        lines: MasonryLines,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat,
        placementMode: MasonryPlacementMode,
        estimatedItemSize: CGSize,
        containerSize: CGSize,
        id: KeyPath<Data.Element, ID>
    ) {
        // 取消之前的布局任务
        currentLayoutTask?.cancel()

        // 对于中小数据集（< 200项），使用同步初始化以避免闪烁
        if data.count < 200 && containerSize.width > 0 && containerSize.height > 0 {
            initializeSynchronously(
                data: data,
                axis: axis,
                lines: lines,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                placementMode: placementMode,
                estimatedItemSize: estimatedItemSize,
                containerSize: containerSize,
                id: id
            )
            return
        }

        // 异步计算布局
        currentLayoutTask = Task { @MainActor [weak self] in
            guard let self = self else { return }

            // 尝试开始计算
            guard let currentSequence = await self.concurrencyController.startCalculation() else {
                return // 已经在计算中
            }

            // 确保在任务结束时清理状态
            defer {
                Task { @MainActor in
                    await self.concurrencyController.finishCalculation()
                }
            }

            // 生成缓存键
            let cacheKey = CacheKey(
                dataCount: data.count,
                axis: axis,
                lines: lines,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                placementMode: placementMode,
                estimatedItemSize: estimatedItemSize,
                containerSize: containerSize
            )

            // 检查缓存
            if self.layoutCache.isValid(for: cacheKey) {
                self.layoutCache.recordCacheHit()
                self.allItems = self.layoutCache.cachedItems
                self.totalSize = self.layoutCache.cachedTotalSize

                #if DEBUG
                print("🎯 SwiftUIMasonryLayouts: 缓存命中，效率: \(String(format: "%.1f", self.layoutCache.cacheEfficiency * 100))%")
                #endif

                // 关键修复：缓存命中后也需要更新可见项目
                let initialVisibleRect = CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height)
                self.updateVisibleItems(visibleRect: initialVisibleRect)
                return
            } else {
                self.layoutCache.recordCacheMiss()
            }

            await self.calculateLayoutAsync(
                data: data,
                axis: axis,
                lines: lines,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                placementMode: placementMode,
                estimatedItemSize: estimatedItemSize,
                containerSize: containerSize,
                id: id,
                cacheKey: cacheKey,
                taskSequence: currentSequence
            )
        }
    }

    /// 同步初始化（用于小数据集）
    internal func initializeSynchronously<Data: RandomAccessCollection, ID: Hashable>(
        data: Data,
        axis: Axis,
        lines: MasonryLines,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat,
        placementMode: MasonryPlacementMode,
        estimatedItemSize: CGSize,
        containerSize: CGSize,
        id: KeyPath<Data.Element, ID>
    ) {
        do {
            // 直接计算布局（同步）
            let result = try calculateLayoutSynchronously(
                data: data,
                axis: axis,
                lines: lines,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                placementMode: placementMode,
                estimatedItemSize: estimatedItemSize,
                containerSize: containerSize,
                id: id
            )

            // 更新状态
            self.allItems = result.items
            self.totalSize = result.totalSize

            #if DEBUG
            print("🚀 SwiftUIMasonryLayouts: 同步初始化完成 - \(result.items.count) 个项目, totalSize: \(result.totalSize)")
            #endif

            // 立即更新可见项目 - 使用正确的初始可见区域
            let initialVisibleRect = CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height)
            self.updateVisibleItems(visibleRect: initialVisibleRect)

            #if DEBUG
            print("📍 同步初始化后可见项目: \(self.visibleItems.count), 初始可见区域: \(initialVisibleRect)")
            #endif

        } catch {
            #if DEBUG
            print("❌ SwiftUIMasonryLayouts: 同步初始化失败: \(error)")
            #endif

            // 回退到异步初始化
            // 这里不调用完整的initialize以避免递归
            currentLayoutTask = Task { @MainActor in
                // 简化的异步初始化...
                // 设置安全的默认状态
                self.allItems = []
                self.totalSize = .zero
                self.visibleItems = []
            }
        }
    }

    /// 更新容器尺寸（激进模式，用于重大变化）
    func updateContainerSize(_ newSize: CGSize) {
        // 检查尺寸是否真的发生了变化
        guard layoutCache.containerSize != newSize else { return }

        // 取消当前计算
        currentLayoutTask?.cancel()
        currentLayoutTask = nil

        // 使所有正在运行的任务失效
        Task {
            await concurrencyController.invalidateAllTasks()
        }

        // 更新缓存
        layoutCache.invalidate()
        layoutCache.containerSize = newSize

        // 清理可见项目，等待重新计算
        visibleItems.removeAll()
    }

    /// 优雅地更新容器尺寸（避免闪烁）
    func updateContainerSizeGracefully(_ newSize: CGSize) {
        // 检查尺寸是否真的发生了变化
        guard layoutCache.containerSize != newSize else { return }

        #if DEBUG
        print("🔄 优雅更新容器尺寸 - 从 \(layoutCache.containerSize) 到 \(newSize)")
        #endif

        // 取消当前计算
        currentLayoutTask?.cancel()
        currentLayoutTask = nil

        // 使所有正在运行的任务失效
        Task {
            await concurrencyController.invalidateAllTasks()
        }

        // 更新缓存
        layoutCache.invalidate()
        layoutCache.containerSize = newSize

        // 保持当前可见项目，避免闪烁
        // 只在新的布局计算完成后才更新可见项目

        #if DEBUG
        print("✅ 容器尺寸更新完成，保持当前可见项目: \(visibleItems.count)")
        #endif
    }

    /// 同步计算所有项目的布局（保留用于兼容性）
    internal func calculateLayout<Data: RandomAccessCollection, ID: Hashable>(
        data: Data,
        axis: Axis,
        lines: MasonryLines,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat,
        placementMode: MasonryPlacementMode,
        estimatedItemSize: CGSize,
        containerSize: CGSize,
        id: KeyPath<Data.Element, ID>
    ) {
        guard !data.isEmpty && containerSize.width > 0 && containerSize.height > 0 else {
            allItems = []
            totalSize = .zero
            return
        }

        let lineCount = calculateLineCount(lines: lines, containerSize: containerSize, axis: axis, spacing: axis == .vertical ? horizontalSpacing : verticalSpacing)
        let lineSize = calculateLineSize(containerSize: containerSize, lineCount: lineCount, axis: axis, spacing: axis == .vertical ? horizontalSpacing : verticalSpacing)

        var items: [VirtualItem] = []
        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)

        for (index, dataItem) in data.enumerated() {
            // 使用动态尺寸估算进行布局计算
            let itemSize = estimateItemSizeForData(dataItem, estimatedSize: estimatedItemSize, lineSize: lineSize, axis: axis)
            let lineIndex = selectLineIndex(lineOffsets: lineOffsets, index: index, placementMode: placementMode)

            // 修复水平布局的坐标计算
            let frame: CGRect
            if axis == .vertical {
                // 垂直布局：x=列索引×列宽, y=累积高度
                frame = CGRect(
                    x: CGFloat(lineIndex) * (lineSize + horizontalSpacing),
                    y: lineOffsets[lineIndex],
                    width: lineSize,
                    height: itemSize.height
                )
            } else {
                // 水平布局：x=累积宽度, y=行索引×行高
                frame = CGRect(
                    x: lineOffsets[lineIndex],
                    y: CGFloat(lineIndex) * (lineSize + verticalSpacing),
                    width: itemSize.width,
                    height: lineSize
                )
            }

            let virtualItem = VirtualItem(
                id: AnyHashable(dataItem[keyPath: id]),
                dataIndex: index,
                frame: frame
            )

            items.append(virtualItem)

            // 更新行偏移
            if axis == .vertical {
                lineOffsets[lineIndex] += itemSize.height + verticalSpacing
            } else {
                lineOffsets[lineIndex] += itemSize.width + horizontalSpacing
            }
        }

        allItems = items
        totalSize = calculateTotalSize(lineOffsets: lineOffsets, lineSize: lineSize, lineCount: lineCount, axis: axis, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
    }
}
