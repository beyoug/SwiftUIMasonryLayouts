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
    let sizeCalculator: ((Data.Element, CGFloat) -> CGSize)?
    let content: (Data.Element) -> Content
    let externalScrollOffset: CGPoint? // 新增：外部滚动偏移

    // MARK: - 业务层回调

    let onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?
    let onReachBottom: (() -> Void)?
    let onReachTop: (() -> Void)?

    // MARK: - 状态

    @State private var itemPositions: [Data.Element.ID: CGRect] = [:]
    @State private var totalContentSize: CGSize = .zero
    @State private var preloadBuffer: CGFloat = 200
    @State private var lastDataCount: Int = 0
    @State private var isIncrementalUpdateAvailable: Bool = false
    @State private var previousScrollOffset: CGPoint = .zero
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: totalContentSize.width, height: totalContentSize.height)
                .onAppear {
                    MasonryLogger.info("容器尺寸: \(totalContentSize)")
                }

            ForEach(visibleItems, id: \.id) { item in
                if let frame = itemPositions[item.id] {
                    content(item)
                        .frame(width: frame.width, height: frame.height)
                        .offset(x: frame.minX, y: frame.minY)
                } else {
                    // 调试：检查哪些项目缺少位置信息
                    Text("缺少位置: \(item.id)")
                        .foregroundColor(.red)
                        .onAppear {
                            MasonryLogger.error("项目 \(item.id) 缺少位置信息")
                        }
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
        .onChange(of: externalScrollOffset) { _, newOffset in
            // 当外部滚动偏移变化时，使用它来更新可见范围
            if let offset = newOffset {
                updateVisibleRange(scrollOffset: offset)
                checkScrollBoundaries(offset: offset)
                previousScrollOffset = offset
            }
        }
        // 移除旧的滚动监听机制，完全依赖 iOS 18 API
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

    // 移除旧的滚动处理方法，使用 iOS 18 API
    
    // MARK: - 布局计算
    
    /// 智能布局计算（支持增量更新）
    private func calculateLayout() {
        let containerSize = geometry.size
        guard containerSize.width > 0 else {
            MasonryLogger.warning("Container: LazyMasonryContainer 容器宽度无效: \(containerSize.width)")
            return
        }

        let currentDataCount = data.count

        // 检查数据是否发生变化
        if currentDataCount != lastDataCount {
            // 数据变化时，清理无效的位置信息
            cleanupInvalidPositions()

            // 检查是否可以进行增量更新
            if canPerformIncrementalUpdate(newDataCount: currentDataCount) {
                performIncrementalUpdate(newDataCount: currentDataCount)
                return
            }
        }

        // 执行完整布局计算
        performFullLayoutCalculation(containerSize: containerSize)

        // 更新状态
        lastDataCount = currentDataCount
        isIncrementalUpdateAvailable = true
    }

    /// 清理无效的位置信息
    private func cleanupInvalidPositions() {
        let currentIds = Set(data.map { $0.id })
        let positionIds = Set(itemPositions.keys)

        // 移除不再存在的项目位置
        let invalidIds = positionIds.subtracting(currentIds)
        for invalidId in invalidIds {
            itemPositions.removeValue(forKey: invalidId)
        }

        if !invalidIds.isEmpty {
            MasonryLogger.debug("清理了\(invalidIds.count)个无效位置信息")
        }
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

        // 使用布局引擎计算
        let result = MasonryLayoutEngine.calculateLazyLayout(
            containerSize: containerSize,
            items: data,
            configuration: configuration,
            sizeCalculator: sizeCalculator,
            cache: &layoutCache
        )

        // 缓存结果
        layoutCache.cacheLayoutResult(for: cacheKey, result: result)

        // 应用结果
        applyLayoutResult(result)
    }

    /// 计算增量布局
    private func calculateIncrementalLayout(for newItems: [Data.Element], startingFromIndex: Int) -> LazyLayoutResult {
        // 为了确保数据一致性，对所有数据进行完整计算
        // 这样可以避免位置信息不匹配的问题
        MasonryLogger.debug("执行增量布局计算，新增\(newItems.count)个项目")

        return MasonryLayoutEngine.calculateLazyLayout(
            containerSize: geometry.size,
            items: data,
            configuration: configuration,
            sizeCalculator: sizeCalculator,
            cache: &layoutCache
        )
    }

    /// 合并增量布局结果
    private func mergeIncrementalResult(_ incrementalResult: LazyLayoutResult) {
        // 完全替换项目位置信息，确保数据一致性
        var newPositions: [Data.Element.ID: CGRect] = [:]
        for (id, position) in incrementalResult.itemPositions {
            if let typedId = id as? Data.Element.ID {
                newPositions[typedId] = position
            }
        }
        itemPositions = newPositions

        // 更新总尺寸
        totalContentSize = incrementalResult.totalSize

        // 验证数据一致性
        if itemPositions.count != data.count {
            MasonryLogger.warning("增量更新后位置数量不匹配! 位置:\(itemPositions.count), 数据:\(data.count)")
        } else {
            MasonryLogger.debug("增量更新成功，位置信息已同步")
        }

        // 更新可见范围
        if visibleRange == nil {
            updateVisibleRange(scrollOffset: previousScrollOffset)
        }
    }

    /// 计算项目尺寸
    private func calculateItemSize(item: Data.Element, lineSize: CGFloat) -> CGSize {
        // 首先检查缓存
        if let cachedSize = layoutCache.getCachedItemSize(for: item.id) {
            return cachedSize
        }
        
        // 使用自定义计算器
        if let calculator = sizeCalculator {
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

        // 调试信息：检查是否所有项目都有位置
        if convertedPositions.count != data.count {
            MasonryLogger.warning("项目位置数量与数据项目数量不匹配! 位置:\(convertedPositions.count), 数据:\(data.count)")

            // 详细分析不匹配的原因
            let dataIds = Set(data.map { $0.id })
            let positionIds = Set(convertedPositions.keys)
            let missingIds = dataIds.subtracting(positionIds)
            let extraIds = positionIds.subtracting(dataIds)

            if !missingIds.isEmpty {
                MasonryLogger.warning("缺少位置信息的项目ID: \(missingIds)")
            }
            if !extraIds.isEmpty {
                MasonryLogger.warning("多余的位置信息ID: \(extraIds)")
            }
        } else {
            MasonryLogger.debug("布局计算完成，位置信息已同步 (\(convertedPositions.count)项)")
        }

        // 初始化可见范围 - 使用更保守的初始计算
        if visibleRange == nil {
            updateInitialVisibleRange()
        }
    }

    /// 初始化可见范围（真正的懒加载实现）
    private func updateInitialVisibleRange() {
        // 初始化可见范围

        // 真正的懒加载：基于视口大小计算初始可见项目
        let viewportRect = CGRect(
            x: 0,
            y: 0,
            width: geometry.size.width,
            height: geometry.size.height
        )

        // 添加适当的预加载缓冲区
        let buffer: CGFloat = 200
        let expandedViewport = viewportRect.insetBy(dx: 0, dy: -buffer)

        // 查找初始可见的项目
        let initialVisibleIndices = findVisibleIndicesOptimized(in: expandedViewport)

        if !initialVisibleIndices.isEmpty {
            let sortedIndices = initialVisibleIndices.sorted()
            guard let firstIndex = sortedIndices.first,
                  let lastIndex = sortedIndices.last else { return }

            let initialRange = firstIndex..<data.index(after: lastIndex)
            visibleRange = initialRange
            onVisibleRangeChanged?(initialRange)
            MasonryLogger.info("初始可见范围: \(initialRange) (\(initialVisibleIndices.count)项)")
        } else {
            // 如果没有找到可见项目，显示前几个作为备选
            let fallbackCount = min(data.count, 10)
            if fallbackCount > 0 {
                let endIndex = data.index(data.startIndex, offsetBy: fallbackCount)
                let fallbackRange = data.startIndex..<endIndex
                visibleRange = fallbackRange
                onVisibleRangeChanged?(fallbackRange)
                MasonryLogger.info("备选范围: \(fallbackRange) (\(fallbackCount)项)")
            }
        }
    }

    /// 优化的可见范围更新（使用空间索引）
    private func updateVisibleRange(scrollOffset: CGPoint) {
        // 确保有项目位置信息
        guard !itemPositions.isEmpty else { return }

        // 计算视口在内容坐标系中的位置
        // 修正：scrollOffset.y 正值表示向下滚动的距离
        let viewportRect = CGRect(
            x: 0,
            y: max(0, scrollOffset.y), // 确保不为负值
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
            guard let firstIndex = sortedIndices.first,
                  let lastIndex = sortedIndices.last else { return }

            let newRange = firstIndex..<data.index(after: lastIndex)

            // 使用扩展策略更新可见范围
            updateVisibleRangeWithExpansion(newRange: newRange, scrollOffset: scrollOffset)
        } else {
            // 未找到可见项目时，基于滚动位置计算范围
            calculateRangeBasedOnScrollPosition(scrollOffset: scrollOffset)
        }
        // 注意：不要将 visibleRange 设为 nil，这会导致所有项目消失
    }

    /// 懒加载滑动窗口策略（带边界保护）
    private func updateVisibleRangeWithExpansion(newRange: Range<Data.Index>, scrollOffset: CGPoint) {
        guard let currentRange = visibleRange else {
            visibleRange = newRange
            onVisibleRangeChanged?(newRange)
            return
        }

        let newStart = data.distance(from: data.startIndex, to: newRange.lowerBound)
        let newEnd = data.distance(from: data.startIndex, to: newRange.upperBound)

        // 滑动窗口：最多同时显示20个项目
        let maxWindowSize = 20
        let newCenter = (newStart + newEnd) / 2
        var windowStart = max(0, newCenter - maxWindowSize / 2)
        var windowEnd = min(data.count, windowStart + maxWindowSize)

        // 智能边界保护

        // 智能第一个项目保护
        if shouldProtectFirstItem(scrollOffset: scrollOffset, proposedWindowStart: windowStart) {
            windowStart = 0
            windowEnd = min(data.count, maxWindowSize)
            MasonryLogger.debug("🔒 顶部保护触发")
        }

        // 智能最后一个项目保护
        if shouldProtectLastItem(scrollOffset: scrollOffset, proposedWindowEnd: windowEnd) {
            windowEnd = data.count
            windowStart = max(0, windowEnd - maxWindowSize)
            MasonryLogger.debug("🔒 底部保护触发")
        }

        let startIndex = data.index(data.startIndex, offsetBy: windowStart)
        let endIndex = data.index(data.startIndex, offsetBy: windowEnd)
        let windowRange = startIndex..<endIndex

        if windowRange != currentRange {
            visibleRange = windowRange
            onVisibleRangeChanged?(windowRange)

            // 记录可视项目更新
            let startIdx = data.distance(from: data.startIndex, to: windowRange.lowerBound)
            let endIdx = data.distance(from: data.startIndex, to: windowRange.upperBound)
            MasonryLogger.info("📱 可视范围: \(startIdx)..<\(endIdx)")
        }
    }

    /// 智能的可见范围更新策略
    private func updateVisibleRangeIntelligently(newRange: Range<Data.Index>) {
        guard let currentRange = visibleRange else {
            // 首次设置可见范围
            visibleRange = newRange
            onVisibleRangeChanged?(newRange)
            MasonryLogger.info("首次设置可见范围: \(newRange)")
            return
        }

        // 如果新范围为空，说明当前视口没有找到项目
        // 这种情况下我们需要扩展当前范围来包含可能的项目
        if newRange.isEmpty {
            MasonryLogger.warning("新范围为空，尝试扩展当前范围")
            expandRangeToIncludeViewport(currentRange: currentRange)
            return
        }

        // 计算范围变化
        let currentStart = data.distance(from: data.startIndex, to: currentRange.lowerBound)
        let currentEnd = data.distance(from: data.startIndex, to: currentRange.upperBound)
        let newStart = data.distance(from: data.startIndex, to: newRange.lowerBound)
        let newEnd = data.distance(from: data.startIndex, to: newRange.upperBound)

        // 使用扩展策略：只扩展范围，不收缩
        let expandedStart = min(currentStart, newStart)
        let expandedEnd = max(currentEnd, newEnd)

        // 限制最大范围，避免内存问题
        let maxRangeSize = min(data.count, 40) // 最多显示40个项目
        let finalStart = max(0, expandedStart)
        let finalEnd = min(data.count, max(expandedEnd, finalStart + maxRangeSize))

        // 创建最终范围
        let startIndex = data.index(data.startIndex, offsetBy: finalStart)
        let endIndex = data.index(data.startIndex, offsetBy: finalEnd)
        let finalRange = startIndex..<endIndex

        // 只在范围真正变化时更新
        if finalRange != currentRange {
            visibleRange = finalRange
            onVisibleRangeChanged?(finalRange)
            MasonryLogger.info("智能更新可见范围: \(currentRange) → \(finalRange)")
        } else {
            MasonryLogger.debug("可见范围未变化，跳过更新")
        }
    }

    /// 当视口没有找到项目时，扩展范围来包含可能的项目
    private func expandRangeToIncludeViewport(currentRange: Range<Data.Index>) {
        let _ = data.distance(from: data.startIndex, to: currentRange.lowerBound)
        let currentEnd = data.distance(from: data.startIndex, to: currentRange.upperBound)

        // 尝试向后扩展范围，包含更多项目
        let maxRangeSize = min(data.count, 40)
        let newEnd = min(data.count, currentEnd + 10) // 每次扩展10个项目
        let newStart = max(0, newEnd - maxRangeSize)

        let startIndex = data.index(data.startIndex, offsetBy: newStart)
        let endIndex = data.index(data.startIndex, offsetBy: newEnd)
        let expandedRange = startIndex..<endIndex

        if expandedRange != currentRange {
            visibleRange = expandedRange
            onVisibleRangeChanged?(expandedRange)
            MasonryLogger.info("扩展范围: \(expandedRange)")
        }
    }

    /// 基于滚动位置计算应该显示的范围
    private func calculateRangeBasedOnScrollPosition(scrollOffset: CGPoint) {
        let scrollY = -scrollOffset.y
        let totalHeight = totalContentSize.height

        // 如果滚动位置超过了内容高度的一定比例，显示后面的项目
        let scrollProgress = scrollY / max(totalHeight, 1)

        // 移除详细的滚动调试信息

        // 根据滚动进度计算应该显示的项目范围
        let maxRangeSize = min(data.count, 40)
        let totalItems = data.count

        // 计算中心项目索引
        let centerItemIndex = Int(scrollProgress * Double(totalItems))
        let clampedCenterIndex = max(0, min(totalItems - 1, centerItemIndex))

        // 计算范围的开始和结束
        let halfRange = maxRangeSize / 2
        let startIndex = max(0, clampedCenterIndex - halfRange)
        let endIndex = min(totalItems, startIndex + maxRangeSize)

        // 创建新的范围
        let newStartIndex = data.index(data.startIndex, offsetBy: startIndex)
        let newEndIndex = data.index(data.startIndex, offsetBy: endIndex)
        let newRange = newStartIndex..<newEndIndex

        visibleRange = newRange
        onVisibleRangeChanged?(newRange)
        MasonryLogger.info("滚动范围: \(newRange)")
    }

    /// 计算动态预加载缓冲区
    private func calculateDynamicBuffer() -> CGFloat {
        // 使用1个视口高度作为缓冲区，实现懒加载
        return geometry.size.height
    }

    /// 智能检测是否接近底部
    private func isNearBottom(scrollOffset: CGPoint) -> Bool {
        let scrollY = scrollOffset.y
        let contentHeight = totalContentSize.height
        let viewportHeight = geometry.size.height

        // 动态计算底部阈值：使用半个视口高度作为缓冲区
        let dynamicBuffer = viewportHeight * 0.5
        let bottomThreshold = contentHeight - viewportHeight - dynamicBuffer

        return scrollY >= bottomThreshold
    }

    /// 智能检测是否应该保护第一个项目
    private func shouldProtectFirstItem(scrollOffset: CGPoint, proposedWindowStart: Int) -> Bool {
        // 1. 顶部下拉时始终保护
        if scrollOffset.y < 0 {
            return true
        }

        // 2. 如果第一个项目仍在视口内，则保护
        if let firstItemPosition = getFirstItemPosition() {
            let viewportTop = scrollOffset.y

            // 第一个项目的底部是否仍在视口内
            let firstItemBottom = firstItemPosition.maxY
            if firstItemBottom >= viewportTop {
                return true
            }
        }

        // 3. 如果滑动窗口会排除第一个项目，但滚动距离很小，则保护
        if proposedWindowStart > 0 {
            let viewportHeight = geometry.size.height
            // 使用四分之一视口高度作为保护区域
            let protectionZone = viewportHeight * 0.25
            return scrollOffset.y <= protectionZone
        }

        return false
    }

    /// 智能检测是否应该保护最后一个项目
    private func shouldProtectLastItem(scrollOffset: CGPoint, proposedWindowEnd: Int) -> Bool {
        // 检查数据一致性
        if itemPositions.count != data.count {
            MasonryLogger.warning("底部保护检测时发现数据不一致，触发强制同步")
            forceSyncDataAndPositions()
            return false // 同步后重新计算
        }

        // 1. 如果最后一个项目仍在视口内，则保护
        if let lastItemPosition = getLastItemPosition() {
            let viewportTop = scrollOffset.y
            let viewportBottom = viewportTop + geometry.size.height

            // 最后一个项目的顶部是否仍在视口内
            let lastItemTop = lastItemPosition.minY
            if lastItemTop <= viewportBottom {
                return true
            }
        }

        // 2. 接近底部时保护
        return isNearBottom(scrollOffset: scrollOffset)
    }

    /// 获取第一个项目的位置
    private func getFirstItemPosition() -> CGRect? {
        guard !data.isEmpty else { return nil }
        let firstItem = data.first!
        return itemPositions[firstItem.id]
    }

    /// 获取最后一个项目的位置
    private func getLastItemPosition() -> CGRect? {
        guard !data.isEmpty else { return nil }
        let lastItem = data.last!
        return itemPositions[lastItem.id]
    }

    /// 强制同步数据和位置信息
    private func forceSyncDataAndPositions() {
        MasonryLogger.info("强制同步数据和位置信息")

        // 清除所有缓存
        layoutCache.invalidate()
        isIncrementalUpdateAvailable = false

        // 重新计算完整布局
        performFullLayoutCalculation(containerSize: geometry.size)
    }

    /// 优化的可见项目查找（避免O(n)遍历）
    private func findVisibleIndicesOptimized(in viewport: CGRect) -> [Data.Index] {
        var visibleIndices: [Data.Index] = []

        // 如果项目数量较少，直接遍历
        if data.count <= 100 {
            for (index, item) in data.enumerated() {
                if let position = itemPositions[item.id] {
                    // 使用更宽松的相交检测，确保边界项目不会被遗漏
                    let expandedPosition = position.insetBy(dx: -1, dy: -1)
                    if viewport.intersects(expandedPosition) {
                        let dataIndex = data.index(data.startIndex, offsetBy: index)
                        visibleIndices.append(dataIndex)
                    }
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
        if scrollY <= topThreshold && previousScrollOffset.y > offset.y {
            onReachTop?()
        }

        // 检查是否到达底部（向下滚动）
        if scrollY + viewportHeight >= contentHeight - bottomThreshold && previousScrollOffset.y < offset.y {
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
        if scrollX <= leftThreshold && previousScrollOffset.x > offset.x {
            onReachTop?()
        }

        // 检查是否到达右边（对应垂直布局的底部）
        if scrollX + viewportWidth >= contentWidth - rightThreshold && previousScrollOffset.x < offset.x {
            onReachBottom?()
        }
    }
}