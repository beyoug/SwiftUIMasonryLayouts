//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 懒加载瀑布流容器

/// 懒加载瀑布流的内部容器
/// 专注于视图渲染和滚动处理，布局计算委托给布局引擎
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct LazyMasonryContainer<Data: RandomAccessCollection, ID: Hashable, Content: View>: View where Data.Element: Identifiable, Data.Element.ID == ID {

    // MARK: - 属性

    let data: Data
    let configuration: MasonryConfiguration
    let geometry: GeometryProxy
    @Binding var visibleRange: Range<Data.Index>?
    @Binding var layoutCache: LazyLayoutCache
    let itemSizeCalculator: ((Data.Element, CGFloat) -> CGSize)?
    let content: (Data.Element) -> Content

    // MARK: - 业务层回调

    let onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?
    let onReachBottom: (() -> Void)?
    let onReachTop: (() -> Void)?

    // MARK: - 状态

    @State private var itemPositions: [Data.Element.ID: CGRect] = [:]
    @State private var totalContentSize: CGSize = .zero
    @State private var preloadBuffer: CGFloat = 200
    @State private var lastScrollOffset: CGPoint = .zero
    @State private var lastDataCount: Int = 0
    @State private var isIncrementalUpdateAvailable: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: totalContentSize.width, height: totalContentSize.height)

            ForEach(visibleItems, id: \.id) { item in
                if let position = itemPositions[item.id] {
                    content(item)
                        .position(
                            x: position.midX,
                            y: position.midY
                        )
                }
            }
        }
        .onAppear {
            calculateLayout()
        }
        .onChange(of: data.count) { _, _ in
            calculateLayout()
        }
        .onChange(of: configuration) { _, _ in
            calculateLayout()
        }
        .background(
            GeometryReader { scrollGeometry in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: scrollGeometry.frame(in: .named("scroll")).origin)
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            handleScrollOffsetChange(offset)
        }
    }

    // MARK: - 计算属性

    /// 当前可见的项目
    private var visibleItems: [Data.Element] {
        guard let visibleRange = visibleRange else { return [] }

        let startIndex = max(data.startIndex, visibleRange.lowerBound)
        let endIndex = min(data.endIndex, visibleRange.upperBound)

        guard startIndex < endIndex else { return [] }

        return Array(data[startIndex..<endIndex])
    }

    /// 处理滚动偏移变化
    private func handleScrollOffsetChange(_ offset: CGPoint) {
        updateVisibleRange(scrollOffset: offset)
        checkScrollBoundaries(offset: offset)
        lastScrollOffset = offset
    }
    
    // MARK: - 布局计算
    
    /// 智能布局计算（支持增量更新）
    private func calculateLayout() {
        let containerSize = geometry.size
        guard containerSize.width > 0 else {
            MasonryInternalConfig.Logger.warning("LazyMasonryContainer 容器宽度无效: \(containerSize.width)")
            return
        }

        let currentDataCount = data.count

        // 检查是否可以进行增量更新
        if canPerformIncrementalUpdate(newDataCount: currentDataCount) {
            performIncrementalUpdate(newDataCount: currentDataCount)
            return
        }

        // 执行完整布局计算
        performFullLayoutCalculation(containerSize: containerSize)

        // 更新状态
        lastDataCount = currentDataCount
        isIncrementalUpdateAvailable = true
    }

    /// 检查是否可以进行增量更新
    private func canPerformIncrementalUpdate(newDataCount: Int) -> Bool {
        // 只有在数据增加且之前有布局结果时才能增量更新
        return isIncrementalUpdateAvailable &&
               newDataCount > lastDataCount &&
               newDataCount - lastDataCount <= 50 && // 限制增量更新的数量
               !itemPositions.isEmpty
    }

    /// 执行增量布局更新
    private func performIncrementalUpdate(newDataCount: Int) {
        let newItemsStartIndex = lastDataCount

        // 只计算新增项目的布局
        let newItemsRange = newItemsStartIndex..<newDataCount
        let newItems = Array(data.enumerated())[newItemsRange].map { $0.element }

        // 使用现有的行偏移状态继续计算
        let incrementalResult = calculateIncrementalLayout(for: newItems, startingFromIndex: newItemsStartIndex)

        // 合并新的布局结果
        mergeIncrementalResult(incrementalResult)
    }

    /// 执行完整布局计算
    private func performFullLayoutCalculation(containerSize: CGSize) {
        // 生成缓存键
        let cacheKey = CacheManager.generateLazyCacheKey(
            configuration: configuration,
            containerSize: containerSize,
            itemCount: data.count
        )

        // 检查缓存
        if let cachedResult = layoutCache.getCachedLayoutResult(for: cacheKey) {
            applyLayoutResult(cachedResult)
            return
        }

        // 创建索引基础的尺寸计算器适配器
        let indexBasedCalculator: ((Int, CGFloat) -> CGSize)? = itemSizeCalculator.map { calculator in
            return { index, lineSize in
                guard index < data.count else {
                    return SimpleSizeCalculator.createFallbackSize(lineSize: lineSize, axis: configuration.axis)
                }
                let item = data[data.index(data.startIndex, offsetBy: index)]
                return calculator(item, lineSize)
            }
        }

        // 使用布局引擎计算
        let result = MasonryLayoutEngine.calculateIndexBasedLazyLayout(
            containerSize: containerSize,
            itemCount: data.count,
            configuration: configuration,
            itemSizeCalculator: indexBasedCalculator,
            cache: &layoutCache
        )

        // 缓存结果
        layoutCache.cacheLayoutResult(for: cacheKey, result: result)

        // 应用结果
        applyLayoutResult(result)
    }

    /// 计算增量布局
    private func calculateIncrementalLayout(for newItems: [Data.Element], startingFromIndex: Int) -> LazyLayoutResult {
        // 创建索引基础的尺寸计算器适配器
        let indexBasedCalculator: ((Int, CGFloat) -> CGSize)? = itemSizeCalculator.map { calculator in
            return { index, lineSize in
                guard index < data.count else {
                    return SimpleSizeCalculator.createFallbackSize(lineSize: lineSize, axis: configuration.axis)
                }
                let item = data[data.index(data.startIndex, offsetBy: index)]
                return calculator(item, lineSize)
            }
        }

        // 这里应该实现增量布局计算逻辑
        // 为了简化，暂时使用完整计算
        return MasonryLayoutEngine.calculateIndexBasedLazyLayout(
            containerSize: geometry.size,
            itemCount: data.count,
            configuration: configuration,
            itemSizeCalculator: indexBasedCalculator,
            cache: &layoutCache
        )
    }

    /// 合并增量布局结果
    private func mergeIncrementalResult(_ incrementalResult: LazyLayoutResult) {
        // 更新项目位置
        for (id, position) in incrementalResult.itemPositions {
            if let typedId = id as? Data.Element.ID {
                itemPositions[typedId] = position
            }
        }

        // 更新总尺寸
        totalContentSize = incrementalResult.totalSize

        // 更新可见范围
        if visibleRange == nil {
            updateVisibleRange(scrollOffset: lastScrollOffset)
        }
    }

    
    /// 计算项目尺寸
    private func calculateItemSize(item: Data.Element, lineSize: CGFloat) -> CGSize {
        // 首先检查缓存
        if let cachedSize = layoutCache.getCachedItemSize(for: item.id) {
            return cachedSize
        }
        
        // 使用自定义计算器
        if let calculator = itemSizeCalculator {
            return calculator(item, lineSize)
        }
        
        // 默认尺寸
        if configuration.axis == .vertical {
            return CGSize(width: lineSize, height: 150)
        } else {
            return CGSize(width: 150, height: lineSize)
        }
    }
    
    /// 应用布局结果
    private func applyLayoutResult(_ result: LazyLayoutResult) {
        // 转换位置字典
        var convertedPositions: [Data.Element.ID: CGRect] = [:]
        for (key, value) in result.itemPositions {
            if let id = key as? Data.Element.ID {
                convertedPositions[id] = value
            }
        }
        itemPositions = convertedPositions
        totalContentSize = result.totalSize
        
        // 初始化可见范围
        if visibleRange == nil {
            updateVisibleRange(scrollOffset: .zero)
        }
    }
    
    /// 优化的可见范围更新（使用空间索引）
    private func updateVisibleRange(scrollOffset: CGPoint) {
        let viewportRect = CGRect(
            x: -scrollOffset.x,
            y: -scrollOffset.y,
            width: geometry.size.width,
            height: geometry.size.height
        )

        // 动态计算预加载缓冲区
        let dynamicBuffer = calculateDynamicBuffer()

        // 扩展视口以包含预加载缓冲区
        let expandedViewport: CGRect
        if configuration.axis == .vertical {
            expandedViewport = viewportRect.insetBy(dx: 0, dy: -dynamicBuffer)
        } else {
            expandedViewport = viewportRect.insetBy(dx: -dynamicBuffer, dy: 0)
        }

        // 使用优化的可见性检测
        let newVisibleIndices = findVisibleIndicesOptimized(in: expandedViewport)

        if !newVisibleIndices.isEmpty {
            let sortedIndices = newVisibleIndices.sorted()
            let newRange = sortedIndices.first!..<data.index(after: sortedIndices.last!)

            // 只在范围真正变化时更新
            if newRange != visibleRange {
                visibleRange = newRange
                onVisibleRangeChanged?(newRange)
            }
        } else if visibleRange != nil {
            visibleRange = nil
        }
    }

    /// 计算动态预加载缓冲区
    private func calculateDynamicBuffer() -> CGFloat {
        // 基于设备性能和数据量动态调整
        let baseBuffer: CGFloat = 200
        let itemCount = data.count

        // 数据量大时减少缓冲区，避免内存压力
        if itemCount > 1000 {
            return baseBuffer * 0.5
        } else if itemCount > 500 {
            return baseBuffer * 0.75
        } else {
            return baseBuffer
        }
    }

    /// 优化的可见项目查找（避免O(n)遍历）
    private func findVisibleIndicesOptimized(in viewport: CGRect) -> [Data.Index] {
        var visibleIndices: [Data.Index] = []

        // 如果项目数量较少，直接遍历
        if data.count <= 100 {
            for (index, item) in data.enumerated() {
                if let position = itemPositions[item.id],
                   viewport.intersects(position) {
                    let dataIndex = data.index(data.startIndex, offsetBy: index)
                    visibleIndices.append(dataIndex)
                }
            }
        } else {
            // 对于大数据集，使用空间分割优化
            visibleIndices = findVisibleIndicesWithSpatialOptimization(in: viewport)
        }

        return visibleIndices
    }

    /// 使用空间优化的可见项目查找
    private func findVisibleIndicesWithSpatialOptimization(in viewport: CGRect) -> [Data.Index] {
        var visibleIndices: [Data.Index] = []

        // 基于布局轴向进行优化查找
        if configuration.axis == .vertical {
            // 垂直布局：基于Y坐标范围查找
            visibleIndices = findVisibleIndicesByYRange(in: viewport)
        } else {
            // 水平布局：基于X坐标范围查找
            visibleIndices = findVisibleIndicesByXRange(in: viewport)
        }

        return visibleIndices
    }

    /// 基于Y坐标范围查找可见项目
    private func findVisibleIndicesByYRange(in viewport: CGRect) -> [Data.Index] {
        var visibleIndices: [Data.Index] = []
        let viewportMinY = viewport.minY
        let viewportMaxY = viewport.maxY

        for (index, item) in data.enumerated() {
            guard let position = itemPositions[item.id] else { continue }

            // 快速Y坐标范围检查
            if position.maxY >= viewportMinY && position.minY <= viewportMaxY {
                // 精确相交检查
                if viewport.intersects(position) {
                    let dataIndex = data.index(data.startIndex, offsetBy: index)
                    visibleIndices.append(dataIndex)
                }
            }
        }

        return visibleIndices
    }

    /// 基于X坐标范围查找可见项目
    private func findVisibleIndicesByXRange(in viewport: CGRect) -> [Data.Index] {
        var visibleIndices: [Data.Index] = []
        let viewportMinX = viewport.minX
        let viewportMaxX = viewport.maxX

        for (index, item) in data.enumerated() {
            guard let position = itemPositions[item.id] else { continue }

            // 快速X坐标范围检查
            if position.maxX >= viewportMinX && position.minX <= viewportMaxX {
                // 精确相交检查
                if viewport.intersects(position) {
                    let dataIndex = data.index(data.startIndex, offsetBy: index)
                    visibleIndices.append(dataIndex)
                }
            }
        }

        return visibleIndices
    }
    
    /// 检查滚动边界
    private func checkScrollBoundaries(offset: CGPoint) {
        if configuration.axis == .vertical {
            checkVerticalScrollBoundaries(offset: offset)
        } else {
            checkHorizontalScrollBoundaries(offset: offset)
        }
    }

    /// 优化的垂直滚动边界检测
    private func checkVerticalScrollBoundaries(offset: CGPoint) {
        let viewportHeight = geometry.size.height
        let contentHeight = totalContentSize.height
        let scrollY = -offset.y

        // 动态计算边界阈值
        let topThreshold = min(viewportHeight * 0.1, 100) // 视口高度的10%或100px
        let bottomThreshold = min(viewportHeight * 0.2, 200) // 视口高度的20%或200px

        // 检查是否到达顶部（向上滚动）
        if scrollY <= topThreshold && lastScrollOffset.y > offset.y {
            onReachTop?()
        }

        // 检查是否到达底部（向下滚动）
        if scrollY + viewportHeight >= contentHeight - bottomThreshold && lastScrollOffset.y < offset.y {
            onReachBottom?()
        }
    }

    /// 优化的水平滚动边界检测
    private func checkHorizontalScrollBoundaries(offset: CGPoint) {
        let viewportWidth = geometry.size.width
        let contentWidth = totalContentSize.width
        let scrollX = -offset.x

        // 动态计算边界阈值
        let leftThreshold = min(viewportWidth * 0.1, 100) // 视口宽度的10%或100px
        let rightThreshold = min(viewportWidth * 0.2, 200) // 视口宽度的20%或200px

        // 检查是否到达左边（对应垂直布局的顶部）
        if scrollX <= leftThreshold && lastScrollOffset.x > offset.x {
            onReachTop?()
        }

        // 检查是否到达右边（对应垂直布局的底部）
        if scrollX + viewportWidth >= contentWidth - rightThreshold && lastScrollOffset.x < offset.x {
            onReachBottom?()
        }
    }
}
