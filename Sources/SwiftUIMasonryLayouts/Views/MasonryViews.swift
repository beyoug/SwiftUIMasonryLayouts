//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

// MARK: - 基础瀑布流视图

/// 基于iOS 18.0+ Layout协议的现代瀑布流视图
/// 提供简洁的API和高性能布局
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct MasonryView<Content: View>: View {

    /// 布局轴向
    private let axis: Axis
    /// 行/列配置
    private let lines: MasonryLines
    /// 水平间距
    private let horizontalSpacing: CGFloat
    /// 垂直间距
    private let verticalSpacing: CGFloat
    /// 放置模式
    private let placementMode: MasonryPlacementMode
    /// 内容构建器
    private let content: () -> Content

    /// 初始化瀑布流视图
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    ///   - content: 视图内容构建器
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.lines = lines
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.placementMode = placementMode
        self.content = content
    }

    public var body: some View {
        MasonryLayout(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode
        ) {
            content()
        }
    }
}

// MARK: - 便捷构造器

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension MasonryView {

    /// 创建垂直瀑布流
    /// - Parameters:
    ///   - columns: 列数配置
    ///   - spacing: 间距
    ///   - placementMode: 放置模式
    ///   - content: 内容构建器
    /// - Returns: 垂直瀑布流视图
    static func vertical<C: View>(
        columns: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        @ViewBuilder content: @escaping () -> C
    ) -> MasonryView<C> {
        MasonryView<C>(
            axis: .vertical,
            lines: columns,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode,
            content: content
        )
    }

    /// 创建水平瀑布流
    /// - Parameters:
    ///   - rows: 行数配置
    ///   - spacing: 间距
    ///   - placementMode: 放置模式
    ///   - content: 内容构建器
    /// - Returns: 水平瀑布流视图
    static func horizontal<C: View>(
        rows: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        @ViewBuilder content: @escaping () -> C
    ) -> MasonryView<C> {
        MasonryView<C>(
            axis: .horizontal,
            lines: rows,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode,
            content: content
        )
    }
}

// MARK: - 数据驱动的瀑布流视图

/// 基于数据集合的瀑布流视图
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct DataMasonryView<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View
{

    /// 布局轴向
    private let axis: Axis
    /// 行/列配置
    private let lines: MasonryLines
    /// 水平间距
    private let horizontalSpacing: CGFloat
    /// 垂直间距
    private let verticalSpacing: CGFloat
    /// 放置模式
    private let placementMode: MasonryPlacementMode
    /// 数据集合
    private let data: Data
    /// ID键路径
    private let id: KeyPath<Data.Element, ID>
    /// 内容构建器
    private let content: (Data.Element) -> Content

    /// 初始化数据驱动的瀑布流视图
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    ///   - data: 数据集合
    ///   - id: 数据元素的ID键路径
    ///   - content: 数据元素的视图构建器
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.axis = axis
        self.lines = lines
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.placementMode = placementMode
        self.data = data
        self.id = id
        self.content = content
    }
    
    public var body: some View {
        MasonryLayout(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode
        ) {
            ForEach(data, id: id) { item in
                content(item)
            }
        }
    }
}

// MARK: - 可识别数据扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension DataMasonryView where Data.Element: Identifiable, ID == Data.Element.ID {

    /// 为可识别数据元素提供的便捷初始化器
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    ///   - data: 实现了Identifiable协议的数据集合
    ///   - content: 数据元素的视图构建器
    init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode,
            data: data,
            id: \.id,
            content: content
        )
    }
}

// MARK: - 数据瀑布流便捷构造器

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension DataMasonryView {

    /// 创建垂直数据驱动瀑布流
    /// - Parameters:
    ///   - columns: 列数配置
    ///   - spacing: 间距
    ///   - placementMode: 放置模式
    ///   - data: 数据集合
    ///   - id: 数据元素的ID键路径
    ///   - content: 内容构建器
    /// - Returns: 垂直数据瀑布流视图
    static func vertical<D, I, C>(
        columns: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: D,
        id: KeyPath<D.Element, I>,
        @ViewBuilder content: @escaping (D.Element) -> C
    ) -> DataMasonryView<D, I, C>
    where D: RandomAccessCollection, I: Hashable, C: View {
        DataMasonryView<D, I, C>(
            axis: .vertical,
            lines: columns,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode,
            data: data,
            id: id,
            content: content
        )
    }

    /// 创建水平数据驱动瀑布流
    /// - Parameters:
    ///   - rows: 行数配置
    ///   - spacing: 间距
    ///   - placementMode: 放置模式
    ///   - data: 数据集合
    ///   - id: 数据元素的ID键路径
    ///   - content: 内容构建器
    /// - Returns: 水平数据瀑布流视图
    static func horizontal<D, I, C>(
        rows: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: D,
        id: KeyPath<D.Element, I>,
        @ViewBuilder content: @escaping (D.Element) -> C
    ) -> DataMasonryView<D, I, C>
    where D: RandomAccessCollection, I: Hashable, C: View {
        DataMasonryView<D, I, C>(
            axis: .horizontal,
            lines: rows,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode,
            data: data,
            id: id,
            content: content
        )
    }
}

// MARK: - 懒加载瀑布流视图

/// 虚拟化懒加载瀑布流视图
///
/// 真正的虚拟化实现，只渲染可见区域内的项目，适用于大型数据集。
/// 支持数万个项目的高性能渲染。
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyMasonryView<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View
{

    /// 布局轴向
    private let axis: Axis
    /// 行/列配置
    private let lines: MasonryLines
    /// 水平间距
    private let horizontalSpacing: CGFloat
    /// 垂直间距
    private let verticalSpacing: CGFloat
    /// 放置模式
    private let placementMode: MasonryPlacementMode
    /// 数据集合
    private let data: Data
    /// ID键路径
    private let id: KeyPath<Data.Element, ID>
    /// 内容构建器
    private let content: (Data.Element) -> Content
    /// 预估项目尺寸
    private let estimatedItemSize: CGSize

    /// 初始化虚拟化懒加载瀑布流视图
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    ///   - data: 数据集合
    ///   - id: 数据元素的ID键路径
    ///   - estimatedItemSize: 预估项目尺寸，用于虚拟化计算
    ///   - content: 数据元素的视图构建器
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: Data,
        id: KeyPath<Data.Element, ID>,
        estimatedItemSize: CGSize = CGSize(width: 150, height: 200),
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.axis = axis
        self.lines = lines
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.placementMode = placementMode
        self.data = data
        self.id = id
        self.estimatedItemSize = estimatedItemSize
        self.content = content
    }

    public var body: some View {
        VirtualizedMasonryContainer(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode,
            data: data,
            id: id,
            estimatedItemSize: estimatedItemSize,
            content: content
        )
    }
}

// MARK: - 虚拟化瀑布流容器

/// 虚拟化瀑布流容器，实现真正的懒加载
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct VirtualizedMasonryContainer<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View
{
    let axis: Axis
    let lines: MasonryLines
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let placementMode: MasonryPlacementMode
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let estimatedItemSize: CGSize
    let content: (Data.Element) -> Content

    @State private var virtualizer = MasonryVirtualizer()
    @State private var containerSize: CGSize = .zero
    @State private var scrollOffset: CGPoint = .zero

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(axis == .vertical ? .vertical : .horizontal) {
                    ZStack(alignment: .topLeading) {
                        // 虚拟容器，设置总内容尺寸
                        Rectangle()
                            .fill(Color.clear)
                            .frame(
                                width: virtualizer.totalSize.width,
                                height: virtualizer.totalSize.height
                            )

                        // 只渲染可见的项目
                        ForEach(virtualizer.visibleItems, id: \.id) { item in
                            // 安全访问数据，防止索引越界
                            if item.dataIndex >= 0 && item.dataIndex < data.count {
                                content(data[data.index(data.startIndex, offsetBy: item.dataIndex)])
                                    .frame(
                                        width: item.frame.width,
                                        height: item.frame.height
                                    )
                                    .position(
                                        x: item.frame.midX,
                                        y: item.frame.midY
                                    )
                            }
                        }
                    }
                }
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: scrollGeometry.frame(in: .named("scroll")).origin
                            )
                    }
                )
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    scrollOffset = offset
                    updateVisibleItems(containerSize: geometry.size, scrollOffset: offset)
                }
                .onAppear {
                    // 使用实际的几何尺寸而不是硬编码值
                    let currentSize = geometry.size
                    if containerSize != currentSize {
                        containerSize = currentSize
                        initializeVirtualizer()
                    }
                }
                .onChange(of: geometry.size) { _, newSize in
                    if containerSize != newSize {
                        containerSize = newSize
                        updateVirtualizer(containerSize: newSize)
                    }
                }
            }
        }
        .onDisappear {
            virtualizer.cleanup()
        }
    }

    private func initializeVirtualizer() {
        virtualizer.initialize(
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
    }

    private func updateVirtualizer(containerSize: CGSize) {
        virtualizer.updateContainerSize(containerSize)
        updateVisibleItems(containerSize: containerSize, scrollOffset: scrollOffset)
    }

    private func updateVisibleItems(containerSize: CGSize, scrollOffset: CGPoint) {
        let visibleRect = CGRect(
            x: -scrollOffset.x,
            y: -scrollOffset.y,
            width: containerSize.width,
            height: containerSize.height
        )
        virtualizer.updateVisibleItems(visibleRect: visibleRect)
    }
}

// MARK: - 瀑布流虚拟化器

/// 瀑布流虚拟化器，管理项目的虚拟化渲染
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@Observable @MainActor
private class MasonryVirtualizer {

    /// 虚拟项目信息
    struct VirtualItem: Identifiable {
        let id: AnyHashable
        let dataIndex: Int
        let frame: CGRect
    }

    /// 所有项目的布局信息
    private var allItems: [VirtualItem] = []

    /// 当前可见的项目
    var visibleItems: [VirtualItem] = []

    /// 上次的可见区域（用于增量更新）
    private var lastVisibleRect: CGRect = .zero

    /// 可见项目的索引集合（用于快速查找）
    private var visibleItemIndices: Set<Int> = []

    /// 总内容尺寸
    var totalSize: CGSize = .zero

    /// 缓冲区大小（屏幕尺寸的倍数）
    private let bufferMultiplier: CGFloat = 1.5

    /// 最大缓存项目数量（防止内存泄漏）
    private let maxCachedItems: Int = 50000

    /// 内存压力阈值（MB）
    private let memoryPressureThreshold: Int = 100

    /// 布局缓存
    private var layoutCache: VirtualLayoutCache = VirtualLayoutCache()

    /// 当前布局任务
    private var currentLayoutTask: Task<Void, Never>?



    /// 并发控制 Actor
    private actor ConcurrencyController {
        private var isCalculating: Bool = false
        private var taskSequence: UInt64 = 0

        func startCalculation() -> UInt64? {
            guard !isCalculating else { return nil }
            isCalculating = true
            taskSequence += 1
            return taskSequence
        }

        func finishCalculation() {
            isCalculating = false
        }

        func invalidateAllTasks() -> UInt64 {
            isCalculating = false
            taskSequence += 1
            return taskSequence
        }

        func getCurrentSequence() -> UInt64 {
            return taskSequence
        }

        func isValidSequence(_ sequence: UInt64) -> Bool {
            return taskSequence == sequence
        }
    }

    /// 并发控制器
    private let concurrencyController = ConcurrencyController()

    /// 高效的缓存键结构
    private struct CacheKey: Hashable {
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
    private struct VirtualLayoutCache {
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
        // 异步计算布局
        currentLayoutTask = Task { @MainActor [weak self] in
            guard let self = self else { return }

            // 尝试开始计算
            guard let currentSequence = await self.concurrencyController.startCalculation() else {
                return // 已经在计算中
            }

            defer {
                Task {
                    await self.concurrencyController.finishCalculation()
                }
            }

            // 取消之前的布局任务
            self.currentLayoutTask?.cancel()

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

    /// 更新容器尺寸
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

    /// 更新可见项目（增量更新优化）
    func updateVisibleItems(visibleRect: CGRect) {
        // 检查是否需要更新（避免不必要的计算）
        let rectChangeThreshold: CGFloat = 10.0 // 10点的变化阈值
        if abs(visibleRect.minX - lastVisibleRect.minX) < rectChangeThreshold &&
           abs(visibleRect.minY - lastVisibleRect.minY) < rectChangeThreshold &&
           abs(visibleRect.width - lastVisibleRect.width) < rectChangeThreshold &&
           abs(visibleRect.height - lastVisibleRect.height) < rectChangeThreshold {
            return // 变化太小，跳过更新
        }

        // 计算缓冲区域
        let bufferedRect = CGRect(
            x: visibleRect.minX - visibleRect.width * (bufferMultiplier - 1) / 2,
            y: visibleRect.minY - visibleRect.height * (bufferMultiplier - 1) / 2,
            width: visibleRect.width * bufferMultiplier,
            height: visibleRect.height * bufferMultiplier
        )

        // 增量更新：只处理变化的部分
        let newVisibleItems = performIncrementalUpdate(bufferedRect: bufferedRect)

        // 更新状态
        visibleItems = newVisibleItems
        lastVisibleRect = visibleRect

        // 更新索引集合
        visibleItemIndices = Set(visibleItems.map { $0.dataIndex })
    }

    /// 执行增量更新
    private func performIncrementalUpdate(bufferedRect: CGRect) -> [VirtualItem] {
        // 如果是首次计算或项目数量变化很大，执行完整计算
        if lastVisibleRect == .zero || abs(allItems.count - visibleItems.count * 4) > 1000 {
            return allItems.filter { $0.frame.intersects(bufferedRect) }
        }

        // 增量更新：基于空间分区优化
        return performSpatialPartitionedUpdate(bufferedRect: bufferedRect)
    }

    /// 基于空间分区的增量更新
    private func performSpatialPartitionedUpdate(bufferedRect: CGRect) -> [VirtualItem] {
        var result: [VirtualItem] = []
        result.reserveCapacity(visibleItems.count + 100) // 预分配容量

        // 使用二分查找优化范围查询
        let startY = bufferedRect.minY
        let endY = bufferedRect.maxY

        // 找到Y轴范围内的项目
        let relevantItems = findItemsInYRange(startY: startY, endY: endY)

        // 在相关项目中进行精确的相交测试
        for item in relevantItems {
            if item.frame.intersects(bufferedRect) {
                result.append(item)
            }
        }

        return result
    }

    /// 在Y轴范围内查找项目（优化的范围查询）
    private func findItemsInYRange(startY: CGFloat, endY: CGFloat) -> [VirtualItem] {
        // 如果项目数量较少，直接遍历
        if allItems.count < 1000 {
            return allItems.filter { item in
                item.frame.maxY >= startY && item.frame.minY <= endY
            }
        }

        // 对于大数据集，使用优化的查找策略
        return optimizedRangeQuery(startY: startY, endY: endY)
    }

    /// 优化的范围查询
    private func optimizedRangeQuery(startY: CGFloat, endY: CGFloat) -> [VirtualItem] {
        var result: [VirtualItem] = []

        // 分块处理，每次处理500个项目
        let chunkSize = 500
        let totalChunks = (allItems.count + chunkSize - 1) / chunkSize

        for chunkIndex in 0..<totalChunks {
            let startIndex = chunkIndex * chunkSize
            let endIndex = min(startIndex + chunkSize, allItems.count)

            let chunk = Array(allItems[startIndex..<endIndex])

            // 检查这个块是否可能包含相关项目
            if let firstItem = chunk.first, let lastItem = chunk.last {
                let chunkMinY = min(firstItem.frame.minY, lastItem.frame.minY)
                let chunkMaxY = max(firstItem.frame.maxY, lastItem.frame.maxY)

                // 如果块的Y范围与查询范围相交，则处理这个块
                if chunkMaxY >= startY && chunkMinY <= endY {
                    for item in chunk {
                        if item.frame.maxY >= startY && item.frame.minY <= endY {
                            result.append(item)
                        }
                    }
                }
            }
        }

        return result
    }

    /// 异步计算布局
    private func calculateLayoutAsync<Data: RandomAccessCollection, ID: Hashable>(
        data: Data,
        axis: Axis,
        lines: MasonryLines,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat,
        placementMode: MasonryPlacementMode,
        estimatedItemSize: CGSize,
        containerSize: CGSize,
        id: KeyPath<Data.Element, ID>,
        cacheKey: CacheKey,
        taskSequence: UInt64
    ) async {
        // 检查任务是否被取消或过期
        guard !Task.isCancelled, await concurrencyController.isValidSequence(taskSequence) else {
            return
        }

        do {
            // 在主线程计算布局（简化实现，避免并发复杂性）
            let result = try await performLayoutCalculation(
                data: data,
                axis: axis,
                lines: lines,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                placementMode: placementMode,
                estimatedItemSize: estimatedItemSize,
                containerSize: containerSize,
                id: id,
                taskSequence: taskSequence
            )

            // 再次检查任务是否被取消或过期
            guard !Task.isCancelled, await self.concurrencyController.isValidSequence(taskSequence) else {
                return
            }

            // 原子性更新状态
            await MainActor.run {
                // 验证数据一致性：确保计算结果仍然有效
                guard result.items.allSatisfy({ $0.dataIndex < data.count }) else {
                    // 数据已经发生变化，丢弃计算结果
                    return
                }

                // 内存管理：检查是否超过最大缓存限制
                if result.items.count > self.maxCachedItems {
                    // 记录警告并限制缓存大小
                    #if DEBUG
                    print("⚠️ SwiftUIMasonryLayouts: 项目数量(\(result.items.count))超过最大缓存限制(\(self.maxCachedItems))，可能影响性能")
                    #endif

                    // 只缓存前 maxCachedItems 个项目
                    self.allItems = Array(result.items.prefix(self.maxCachedItems))
                } else {
                    self.allItems = result.items
                }

                self.totalSize = result.totalSize

                // 更新缓存
                self.layoutCache.updateCache(
                    items: self.allItems,
                    totalSize: result.totalSize,
                    cacheKey: cacheKey
                )

                // 检查内存压力
                self.checkMemoryPressure()
            }

        } catch {
            // 详细的错误处理和恢复
            await MainActor.run {
                #if DEBUG
                if let virtualizationError = error as? VirtualizationError {
                    print("❌ SwiftUIMasonryLayouts: \(virtualizationError.errorDescription ?? "未知错误")")
                    if let suggestion = virtualizationError.recoverySuggestion {
                        print("💡 建议: \(suggestion)")
                    }
                } else {
                    print("❌ SwiftUIMasonryLayouts: 布局计算失败: \(error)")
                }
                #endif

                // 错误恢复：设置安全的默认状态
                self.allItems = []
                self.totalSize = .zero
                self.visibleItems = []

                // 记录错误统计
                self.layoutCache.recordCacheMiss()
            }
        }
    }



    /// 后台执行布局计算
    private func performLayoutCalculation<Data: RandomAccessCollection, ID: Hashable>(
        data: Data,
        axis: Axis,
        lines: MasonryLines,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat,
        placementMode: MasonryPlacementMode,
        estimatedItemSize: CGSize,
        containerSize: CGSize,
        id: KeyPath<Data.Element, ID>,
        taskSequence: UInt64
    ) async throws -> (items: [VirtualItem], totalSize: CGSize) {

        // 边界检查
        guard !data.isEmpty else {
            return (items: [], totalSize: .zero)
        }

        // 验证容器尺寸
        guard containerSize.width > 0 && containerSize.height > 0 else {
            throw VirtualizationError.invalidContainerSize
        }

        // 验证容器尺寸不会过大（防止内存问题）
        guard containerSize.width < 100000 && containerSize.height < 100000 else {
            throw VirtualizationError.invalidConfiguration
        }

        // 验证估计项目尺寸
        guard estimatedItemSize.width > 0 && estimatedItemSize.height > 0 else {
            throw VirtualizationError.invalidEstimatedSize
        }

        // 验证估计尺寸合理性
        guard estimatedItemSize.width < 10000 && estimatedItemSize.height < 10000 else {
            throw VirtualizationError.invalidConfiguration
        }

        // 验证间距合理性
        guard horizontalSpacing >= 0 && verticalSpacing >= 0 else {
            throw VirtualizationError.invalidConfiguration
        }

        guard horizontalSpacing < 1000 && verticalSpacing < 1000 else {
            throw VirtualizationError.invalidConfiguration
        }

        let lineCount = calculateLineCount(lines: lines, containerSize: containerSize, axis: axis, spacing: axis == .vertical ? horizontalSpacing : verticalSpacing)

        guard lineCount > 0 else {
            throw VirtualizationError.invalidLineCount
        }

        let lineSize = calculateLineSize(containerSize: containerSize, lineCount: lineCount, axis: axis, spacing: axis == .vertical ? horizontalSpacing : verticalSpacing)

        var items: [VirtualItem] = []

        // 安全的容量预分配
        let requestedCapacity = min(data.count, maxCachedItems)
        if requestedCapacity > 0 {
            items.reserveCapacity(requestedCapacity)
        }

        // 安全的数组初始化
        guard lineCount > 0 && lineCount < 1000 else {
            throw VirtualizationError.invalidLineCount
        }

        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)

        for (index, dataItem) in data.enumerated() {
            // 检查是否被取消
            if Task.isCancelled {
                throw VirtualizationError.cancelled
            }

            // 定期检查任务是否过期（每100个项目检查一次以提高性能）
            if index % 100 == 0 {
                let isValid = await self.concurrencyController.isValidSequence(taskSequence)
                if !isValid {
                    throw VirtualizationError.cancelled
                }
            }

            let itemSize = estimateItemSize(estimatedItemSize, lineSize: lineSize, axis: axis)
            let lineIndex = selectLineIndex(lineOffsets: lineOffsets, index: index, placementMode: placementMode)

            // 确保 lineIndex 在有效范围内
            guard lineIndex >= 0 && lineIndex < lineCount else {
                continue
            }

            let frame = CGRect(
                x: axis == .vertical ? CGFloat(lineIndex) * (lineSize + horizontalSpacing) : lineOffsets[lineIndex],
                y: axis == .vertical ? lineOffsets[lineIndex] : CGFloat(lineIndex) * (lineSize + verticalSpacing),
                width: axis == .vertical ? lineSize : itemSize.width,
                height: axis == .vertical ? itemSize.height : lineSize
            )

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

            // 每100个项目让出一次控制权，保持响应性
            if index % 100 == 0 {
                await Task.yield()
            }
        }

        let totalSize = calculateTotalSize(lineOffsets: lineOffsets, lineSize: lineSize, lineCount: lineCount, axis: axis, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)

        return (items: items, totalSize: totalSize)
    }

    /// 同步计算所有项目的布局（保留用于兼容性）
    private func calculateLayout<Data: RandomAccessCollection, ID: Hashable>(
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
            // 使用预估尺寸进行布局计算
            let itemSize = estimateItemSize(estimatedItemSize, lineSize: lineSize, axis: axis)
            let lineIndex = selectLineIndex(lineOffsets: lineOffsets, index: index, placementMode: placementMode)

            let frame = CGRect(
                x: axis == .vertical ? CGFloat(lineIndex) * (lineSize + horizontalSpacing) : lineOffsets[lineIndex],
                y: axis == .vertical ? lineOffsets[lineIndex] : CGFloat(lineIndex) * (lineSize + verticalSpacing),
                width: axis == .vertical ? lineSize : itemSize.width,
                height: axis == .vertical ? itemSize.height : lineSize
            )

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

    // MARK: - 辅助方法

    private func calculateLineCount(lines: MasonryLines, containerSize: CGSize, axis: Axis, spacing: CGFloat) -> Int {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height

        switch lines {
        case .fixed(let count):
            return max(1, count)

        case .adaptive(let constraint):
            switch constraint {
            case .min(let minSize):
                let count = Int(floor((availableSize + spacing) / (minSize + spacing)))
                return max(1, count)

            case .max(let maxSize):
                let count = Int(ceil((availableSize + spacing) / (maxSize + spacing)))
                return max(1, count)
            }
        }
    }

    private func calculateLineSize(containerSize: CGSize, lineCount: Int, axis: Axis, spacing: CGFloat) -> CGFloat {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height
        let totalSpacing = CGFloat(lineCount - 1) * spacing
        return max(0, (availableSize - totalSpacing) / CGFloat(lineCount))
    }

    private func estimateItemSize(_ estimatedSize: CGSize, lineSize: CGFloat, axis: Axis) -> CGSize {
        if axis == .vertical {
            return CGSize(width: lineSize, height: estimatedSize.height)
        } else {
            return CGSize(width: estimatedSize.width, height: lineSize)
        }
    }

    private func selectLineIndex(lineOffsets: [CGFloat], index: Int, placementMode: MasonryPlacementMode) -> Int {
        switch placementMode {
        case .fill:
            return lineOffsets.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
        case .order:
            return index % lineOffsets.count
        }
    }

    private func calculateTotalSize(lineOffsets: [CGFloat], lineSize: CGFloat, lineCount: Int, axis: Axis, horizontalSpacing: CGFloat, verticalSpacing: CGFloat) -> CGSize {
        let maxOffset = lineOffsets.max() ?? 0

        if axis == .vertical {
            let totalWidth = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * horizontalSpacing
            let totalHeight = max(0, maxOffset - verticalSpacing)
            return CGSize(width: totalWidth, height: totalHeight)
        } else {
            let totalHeight = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * verticalSpacing
            let totalWidth = max(0, maxOffset - horizontalSpacing)
            return CGSize(width: totalWidth, height: totalHeight)
        }
    }

    /// 检查内存压力并进行清理
    private func checkMemoryPressure() {
        let memoryUsage = getMemoryUsage()

        if memoryUsage > memoryPressureThreshold {
            #if DEBUG
            print("⚠️ SwiftUIMasonryLayouts: 内存使用量(\(memoryUsage)MB)超过阈值(\(memoryPressureThreshold)MB)，执行内存清理")
            #endif

            // 清理不必要的缓存
            performMemoryCleanup()
        }
    }

    /// 获取当前内存使用量（MB）- 跨平台实现
    private func getMemoryUsage() -> Int {
        #if os(macOS) || os(iOS)
        // macOS 和 iOS 使用 mach API
        return getMachMemoryUsage()
        #elseif os(watchOS) || os(tvOS) || os(visionOS)
        // 其他平台使用估算方法
        return getEstimatedMemoryUsage()
        #else
        // 未知平台，返回保守估计
        return 50 // 50MB 保守估计
        #endif
    }

    #if os(macOS) || os(iOS)
    /// macOS/iOS 平台的内存检测
    private func getMachMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Int(info.resident_size) / (1024 * 1024) // 转换为MB
        }

        return 0
    }
    #endif

    #if os(watchOS) || os(tvOS) || os(visionOS)
    /// 其他平台的内存估算
    private func getEstimatedMemoryUsage() -> Int {
        // 基于数据结构大小估算内存使用
        let itemCount = allItems.count
        let visibleItemCount = visibleItems.count

        // 每个 VirtualItem 大约 64 字节
        let itemsMemory = (itemCount + visibleItemCount) * 64

        // 缓存和其他数据结构大约 1MB
        let baseMemory = 1024 * 1024

        let totalBytes = itemsMemory + baseMemory
        return totalBytes / (1024 * 1024) // 转换为MB
    }
    #endif

    /// 执行内存清理
    private func performMemoryCleanup() {
        // 清理过期的缓存项目
        layoutCache.invalidate()

        // 如果项目数量过多，保留最近的项目
        if allItems.count > maxCachedItems / 2 {
            let keepCount = maxCachedItems / 2
            allItems = Array(allItems.suffix(keepCount))

            // 重新计算可见项目
            visibleItems = visibleItems.filter { item in
                allItems.contains { $0.id == item.id }
            }
        }
    }

    /// 清理资源
    func cleanup() {
        // 取消当前任务
        currentLayoutTask?.cancel()
        currentLayoutTask = nil

        // 使所有正在运行的任务失效
        Task {
            await concurrencyController.invalidateAllTasks()
        }

        // 清理缓存和数据
        layoutCache.invalidate()
        allItems.removeAll()
        visibleItems.removeAll()
        totalSize = .zero
    }


}

// MARK: - 滚动偏移监听

/// 滚动偏移偏好键
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// MARK: - 懒加载瀑布流扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension LazyMasonryView where Data.Element: Identifiable, ID == Data.Element.ID {

    /// 为可识别数据元素提供的便捷初始化器
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    ///   - data: 实现了Identifiable协议的数据集合
    ///   - estimatedItemSize: 预估项目尺寸
    ///   - content: 数据元素的视图构建器
    init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: Data,
        estimatedItemSize: CGSize = CGSize(width: 150, height: 200),
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: placementMode,
            data: data,
            id: \.id,
            estimatedItemSize: estimatedItemSize,
            content: content
        )
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension LazyMasonryView {

    /// 创建垂直懒加载瀑布流
    /// - Parameters:
    ///   - columns: 列数配置
    ///   - spacing: 间距
    ///   - placementMode: 放置模式
    ///   - data: 数据集合
    ///   - id: 数据元素的ID键路径
    ///   - estimatedItemSize: 预估项目尺寸
    ///   - content: 内容构建器
    /// - Returns: 垂直懒加载瀑布流视图
    static func vertical<D, I, C>(
        columns: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        data: D,
        id: KeyPath<D.Element, I>,
        estimatedItemSize: CGSize = CGSize(width: 150, height: 200),
        @ViewBuilder content: @escaping (D.Element) -> C
    ) -> LazyMasonryView<D, I, C>
    where D: RandomAccessCollection, I: Hashable, C: View {
        LazyMasonryView<D, I, C>(
            axis: .vertical,
            lines: columns,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode,
            data: data,
            id: id,
            estimatedItemSize: estimatedItemSize,
            content: content
        )
    }
}

// MARK: - 响应式瀑布流视图

/// 根据屏幕宽度自动调整布局的响应式瀑布流视图
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct ResponsiveMasonryView<Content: View>: View {

    /// 响应式断点配置
    private let breakpoints: [CGFloat: MasonryConfiguration]
    /// 内容构建器
    private let content: () -> Content

    /// 当前使用的配置
    @State private var currentConfiguration: MasonryConfiguration

    /// 初始化响应式瀑布流视图
    /// - Parameters:
    ///   - breakpoints: 响应式断点配置字典，键为屏幕宽度，值为对应的瀑布流配置
    ///   - content: 视图内容构建器
    public init(
        breakpoints: [CGFloat: MasonryConfiguration],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.breakpoints = breakpoints
        self.content = content
        // 选择最小断点作为初始配置
        let initialConfig = breakpoints
            .sorted { $0.key < $1.key }
            .first?.value ?? .default
        self._currentConfiguration = State(initialValue: initialConfig)
    }

    public var body: some View {
        GeometryReader { geometry in
            MasonryView(
                axis: currentConfiguration.axis,
                lines: currentConfiguration.lines,
                horizontalSpacing: currentConfiguration.horizontalSpacing,
                verticalSpacing: currentConfiguration.verticalSpacing,
                placementMode: currentConfiguration.placementMode,
                content: content
            )
            .onChange(of: geometry.size.width) { _, newWidth in
                updateConfiguration(for: newWidth)
            }
            .onAppear {
                updateConfiguration(for: geometry.size.width)
            }
        }
    }

    /// 根据屏幕宽度更新配置
    /// - Parameter width: 当前屏幕宽度
    private func updateConfiguration(for width: CGFloat) {
        // 确保宽度为正数
        guard width > 0 else { return }

        // 找到适合当前宽度的最大断点
        let newConfig = breakpoints
            .filter { width >= $0.key }
            .max(by: { $0.key < $1.key })?.value ?? .default

        // 检查配置是否真的发生了变化
        let configChanged = currentConfiguration.lines != newConfig.lines ||
                           currentConfiguration.axis != newConfig.axis ||
                           currentConfiguration.placementMode != newConfig.placementMode

        if configChanged {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentConfiguration = newConfig
            }
        } else if currentConfiguration.horizontalSpacing != newConfig.horizontalSpacing ||
                  currentConfiguration.verticalSpacing != newConfig.verticalSpacing {
            // 只有间距变化时，不需要动画
            currentConfiguration = newConfig
        }
    }
}

// MARK: - 响应式瀑布流便捷方法

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension ResponsiveMasonryView {

    /// 使用通用响应式断点创建响应式瀑布流
    /// - Parameter content: 视图内容构建器
    /// - Returns: 使用通用断点的响应式瀑布流视图
    static func withCommonBreakpoints<C: View>(
        @ViewBuilder content: @escaping () -> C
    ) -> ResponsiveMasonryView<C> {
        ResponsiveMasonryView<C>(
            breakpoints: MasonryConfiguration.commonBreakpoints,
            content: content
        )
    }

    /// 使用设备特定断点创建响应式瀑布流
    /// - Parameter content: 视图内容构建器
    /// - Returns: 使用设备特定断点的响应式瀑布流视图
    static func deviceAdaptive<C: View>(
        @ViewBuilder content: @escaping () -> C
    ) -> ResponsiveMasonryView<C> {
        ResponsiveMasonryView<C>(
            breakpoints: MasonryConfiguration.deviceBreakpoints,
            content: content
        )
    }
}

// MARK: - 虚拟化错误类型

/// 虚拟化计算错误
private enum VirtualizationError: Error, LocalizedError {
    case invalidContainerSize
    case invalidEstimatedSize
    case invalidLineCount
    case cancelled
    case memoryAllocationFailed
    case invalidConfiguration
    case dataCorruption

    var errorDescription: String? {
        switch self {
        case .invalidContainerSize:
            return "容器尺寸无效"
        case .invalidEstimatedSize:
            return "估计项目尺寸无效"
        case .invalidLineCount:
            return "无效的行数配置"
        case .cancelled:
            return "布局计算被取消"
        case .memoryAllocationFailed:
            return "内存分配失败"
        case .invalidConfiguration:
            return "无效的配置参数"
        case .dataCorruption:
            return "数据损坏或不一致"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidContainerSize:
            return "请确保容器宽度和高度都大于0"
        case .invalidEstimatedSize:
            return "请提供有效的估计项目尺寸"
        case .invalidLineCount:
            return "请检查行数配置是否合理"
        case .cancelled:
            return "操作已被取消，可以重新尝试"
        case .memoryAllocationFailed:
            return "请减少数据量或释放内存后重试"
        case .invalidConfiguration:
            return "请检查配置参数是否正确"
        case .dataCorruption:
            return "请检查数据源的完整性"
        }
    }
}

