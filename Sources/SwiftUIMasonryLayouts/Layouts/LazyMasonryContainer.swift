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
    let overrideContainerSize: CGSize? // 新增：覆盖容器尺寸
    @Binding var visibleRange: Range<Data.Index>?
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
    @State private var lastBottomTriggerTime: TimeInterval = 0
    @State private var wasNearBottomBeforeUpdate: Bool = false  // 🎯 记录更新前是否接近底部
    @State private var lastBottomProtectionTime: TimeInterval = 0
    @State private var isLayoutReady: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.clear)
                .frame(
                    width: totalContentSize.width,
                    height: totalContentSize.height
                )
                .onAppear {
                    MasonryLogger.info("🏗️ 容器尺寸: \(totalContentSize)")
                    MasonryLogger.info("🏗️ 几何尺寸: \(geometry.size)")
                    MasonryLogger.info("🏗️ 可见项目数: \(visibleItems.count)")
                }

            if isLayoutReady {
                ForEach(visibleItems, id: \.id) { item in
                    if let frame = itemPositions[item.id] {
                        content(item)
                            .frame(width: frame.width, height: frame.height)
                            .offset(
                                x: frame.minX,
                                y: frame.minY
                            )
                    } else {
                        // 调试：检查哪些项目缺少位置信息
                        Text("缺少位置: \(item.id)")
                            .foregroundColor(.red)
                            .onAppear {
                                MasonryLogger.error("项目 \(item.id) 缺少位置信息")
                            }
                    }
                }
            } else {
                // 布局未准备好时显示占位符
                Text("布局计算中...")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        // 如果布局未准备好，不返回任何项目
        guard isLayoutReady else { return [] }

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
        let containerSize = overrideContainerSize ?? geometry.size
        MasonryLogger.debug("🏗️ 容器尺寸: \(containerSize)")

        // 🎯 零尺寸容错机制：延迟重试而不是直接跳过
        guard containerSize.width > 0 else {
            MasonryLogger.warning("Container: LazyMasonryContainer 容器宽度无效: \(containerSize.width)，延迟重试")
            // 延迟重试，避免SwiftUI布局过程中的瞬间零尺寸问题
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.calculateLayout()
            }
            return
        }

        let currentDataCount = data.count

        // 检查数据是否发生变化
        if currentDataCount != lastDataCount {
            // 数据变化时，清理无效的位置信息
            cleanupInvalidPositions()

            // 检查是否为数据重置（数量大幅减少或ID不连续）
            if isDataReset(newDataCount: currentDataCount) {
                // 数据重置时，强制完整重新计算
                MasonryLogger.info("检测到数据重置，执行完整重新计算")
                itemPositions.removeAll()
                isIncrementalUpdateAvailable = false
                isLayoutReady = false // 重置布局状态
                visibleRange = nil // 重置可见范围，避免使用旧的范围
            }

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

    /// 检测是否为数据重置
    private func isDataReset(newDataCount: Int) -> Bool {
        // 数据数量大幅减少（超过50%）
        if newDataCount < lastDataCount / 2 {
            return true
        }

        // 检查ID连续性（如果前几个项目的ID发生了变化，可能是重置）
        if data.count >= 3 {
            let firstThreeIds = Array(data.prefix(3)).map { $0.id }
            let existingPositions = firstThreeIds.compactMap { itemPositions[$0] }

            // 如果前三个项目中有超过一半没有位置信息，可能是新数据
            if existingPositions.count < firstThreeIds.count / 2 {
                return true
            }
        }

        return false
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
        guard isIncrementalUpdateAvailable &&
              newDataCount > lastDataCount &&
              newDataCount - lastDataCount <= 50 && // 限制增量更新的数量
              !itemPositions.isEmpty else {
            return false
        }

        // 额外检查：确保现有数据的位置信息完整
        let existingDataIds = Array(data.prefix(lastDataCount)).map { $0.id }
        let existingPositions = existingDataIds.compactMap { itemPositions[$0] }

        // 如果现有数据的位置信息不完整，不能进行增量更新
        return existingPositions.count == existingDataIds.count
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

        // 使用布局引擎计算
        let result = MasonryLayoutEngine.calculateLazyLayout(
            containerSize: containerSize,
            items: data,
            configuration: configuration,
            sizeCalculator: sizeCalculator
        )

        // 应用结果
        applyLayoutResult(result)
    }

    /// 计算增量布局
    private func calculateIncrementalLayout(for newItems: [Data.Element], startingFromIndex: Int) -> LazyLayoutResult {
        // 为了确保数据一致性，对所有数据进行完整计算
        // 这样可以避免位置信息不匹配的问题
        MasonryLogger.debug("执行增量布局计算，新增\(newItems.count)个项目")

        return MasonryLayoutEngine.calculateLazyLayout(
            containerSize: overrideContainerSize ?? geometry.size,
            items: data,
            configuration: configuration,
            sizeCalculator: sizeCalculator
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

        // 🎯 在更新总尺寸前检查是否接近底部
        let wasNearBottom = isNearBottom(scrollOffset: previousScrollOffset)

        // 更新总尺寸
        totalContentSize = incrementalResult.totalSize

        // 验证数据一致性
        if itemPositions.count != data.count {
            MasonryLogger.warning("增量更新后位置数量不匹配! 位置:\(itemPositions.count), 数据:\(data.count)")
        } else {
            MasonryLogger.debug("增量更新成功，位置信息已同步")
        }

        // 🎯 如果更新前接近底部，检查是否需要继续加载
        if wasNearBottom {
            checkContinuousLoadingAfterUpdate()
        }

        // 更新可见范围
        if visibleRange == nil {
            updateVisibleRange(scrollOffset: previousScrollOffset)
        }
    }

    /// 计算项目尺寸
    private func calculateItemSize(item: Data.Element, lineSize: CGFloat) -> CGSize {
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
        // 🎯 如果布局结果为空且当前有数据，则跳过应用，保持现有状态
        if result.itemPositions.isEmpty && !data.isEmpty {
            MasonryLogger.warning("跳过应用空布局结果，保持现有位置信息")
            return
        }

        // 转换位置字典，只保留当前数据中存在的项目
        let currentDataIds = Set(data.map { $0.id })
        var convertedPositions: [Data.Element.ID: CGRect] = [:]

        for (key, value) in result.itemPositions {
            if let id = key as? Data.Element.ID, currentDataIds.contains(id) {
                convertedPositions[id] = value
            }
        }

        // 在主线程上更新状态并进行验证
        DispatchQueue.main.async {
            // 🎯 在更新状态前检查是否接近底部
            let wasNearBottom = self.isNearBottom(scrollOffset: self.previousScrollOffset)

            // 更新状态
            self.itemPositions = convertedPositions
            self.totalContentSize = result.totalSize

            // 验证更新后的状态
            if convertedPositions.count != self.data.count {
                MasonryLogger.warning("项目位置数量与数据项目数量不匹配! 位置:\(convertedPositions.count), 数据:\(self.data.count)")
                self.isLayoutReady = false

                // 详细分析不匹配的原因
                let dataIds = Set(self.data.map { $0.id })
                let positionIds = Set(convertedPositions.keys)
                let missingIds = dataIds.subtracting(positionIds)
                let extraIds = positionIds.subtracting(dataIds)

                if !missingIds.isEmpty {
                    MasonryLogger.warning("缺少位置信息的项目ID: \(missingIds)")
                    // 延迟重新计算，避免无限循环
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.forceRecalculateLayout()
                    }
                }
                if !extraIds.isEmpty {
                    MasonryLogger.warning("多余的位置信息ID: \(extraIds)")
                }
            } else {
                MasonryLogger.debug("布局计算完成，位置信息已同步 (\(convertedPositions.count)项)")
                self.isLayoutReady = true // 布局准备完成

                // 🎯 如果更新前接近底部，检查是否需要继续加载
                if wasNearBottom {
                    self.checkContinuousLoadingAfterUpdate()
                } else {
                    // 🎯 布局完成后主动检查是否需要加载更多（解决初始内容不足一屏的问题）
                    self.checkInitialLoadingAfterLayout()
                }
            }
        }

        // 初始化可见范围 - 使用更保守的初始计算
        if visibleRange == nil {
            updateInitialVisibleRange()
        }
    }

    /// 检查数据更新后是否需要继续加载
    private func checkContinuousLoadingAfterUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let currentlyNearBottom = self.isNearBottom(scrollOffset: self.previousScrollOffset)

            if currentlyNearBottom {
                self.lastBottomTriggerTime = 0
                self.checkVerticalScrollBoundaries(offset: self.previousScrollOffset)
            }
        }
    }

    /// 🎯 检查初始布局完成后是否需要加载更多（解决内容不足一屏的问题）
    private func checkInitialLoadingAfterLayout() {
        // 延迟一小段时间，确保布局完全更新
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let contentHeight = self.totalContentSize.height
            let viewportHeight = self.geometry.size.height

            // 🎯 修复逻辑：初始加载时，如果用户在顶部且内容不足2倍屏幕高度，就主动加载
            // 这样可以确保用户有足够的内容可以滚动，从而触发后续的分页
            guard contentHeight > 0 && viewportHeight > 0 else {
                MasonryLogger.debug("🚫 初始检查跳过: contentHeight=\(contentHeight), viewportHeight=\(viewportHeight)")
                return
            }

            let currentScrollY = -self.previousScrollOffset.y  // 🎯 保持与主检测逻辑一致
            let isAtTop = currentScrollY <= 50 // 用户基本在顶部（允许50px的误差）

            // 🎯 简化的初始内容检查：只有内容真正不足一屏时才自动加载
            let contentToViewportRatio = contentHeight / viewportHeight
            let needsMoreContent = contentToViewportRatio < 1.0  // 内容不足一屏时自动加载

            if isAtTop && needsMoreContent {
                MasonryLogger.debug("🚀 内容不足一屏，自动加载更多")
                self.lastBottomTriggerTime = 0
                self.onReachBottom?()
            }
        }
    }

    /// 强制重新计算布局（用于修复数据不一致问题）
    private func forceRecalculateLayout() {
        MasonryLogger.info("强制重新计算布局")

        // 清理状态
        itemPositions.removeAll()
        isIncrementalUpdateAvailable = false

        // 重新计算
        performFullLayoutCalculation(containerSize: overrideContainerSize ?? geometry.size)

        // 重置状态
        lastDataCount = data.count
        isIncrementalUpdateAvailable = true
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
            MasonryLogger.debug("🔒 底部保护触发 - 数据量: \(data.count), 窗口: \(windowStart)..<\(windowEnd)")
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

        // 计算最终范围
        let finalStart = max(0, expandedStart)
        let finalEnd = min(data.count, expandedEnd)

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
        let scrollY = scrollOffset.y  // 🎯 修复：与主检测逻辑保持一致
        let contentHeight = totalContentSize.height
        let viewportHeight = geometry.size.height

        // 防止在布局未完成时错误触发
        guard contentHeight > 0 && viewportHeight > 0 && isLayoutReady else {
            return false
        }

        // 统一底部检测逻辑
        let bottomThreshold = min(viewportHeight * 1.5, 300)
        return scrollY + viewportHeight >= contentHeight - bottomThreshold
    }

    /// 用于底部保护的更严格的检测（减少误触发）
    private func isNearBottomForProtection(scrollOffset: CGPoint) -> Bool {
        let scrollY = scrollOffset.y
        let contentHeight = totalContentSize.height
        let viewportHeight = geometry.size.height

        // 🎯 防止在布局未完成时错误触发
        guard contentHeight > 0 && viewportHeight > 0 && isLayoutReady else {
            return false
        }

        // 使用更小的缓冲区，只在真正接近底部时才保护
        let protectionBuffer = viewportHeight * 0.2 // 20%视口高度
        let bottomThreshold = contentHeight - viewportHeight - protectionBuffer

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

        // 如果数据量很少，不需要保护（避免小数据集的过度保护）
        if data.count <= 30 {
            return false
        }

        // 防抖机制：避免过度触发
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastProtection = currentTime - lastBottomProtectionTime

        // 如果刚刚触发过保护，且时间间隔很短，则跳过
        if timeSinceLastProtection < 0.5 { // 增加到500ms防抖
            return false
        }

        // 1. 如果最后一个项目仍在视口内，则保护
        if let lastItemPosition = getLastItemPosition() {
            let viewportTop = scrollOffset.y
            let viewportBottom = viewportTop + geometry.size.height

            // 最后一个项目的顶部是否仍在视口内
            let lastItemTop = lastItemPosition.minY
            if lastItemTop <= viewportBottom {
                lastBottomProtectionTime = currentTime
                MasonryLogger.debug("🔒 保护原因: 最后项目在视口内")
                return true
            }
        }

        // 2. 接近底部时保护（使用更严格的条件）
        let shouldProtect = isNearBottomForProtection(scrollOffset: scrollOffset)
        if shouldProtect {
            lastBottomProtectionTime = currentTime
            MasonryLogger.debug("🔒 保护原因: 接近底部")
        }
        return shouldProtect
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

        // 清除状态
        isIncrementalUpdateAvailable = false

        // 重新计算完整布局
        performFullLayoutCalculation(containerSize: overrideContainerSize ?? geometry.size)
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
        let scrollY = offset.y  // 🎯 修复：不要取负号！向下滚动时offset.y是正数

        // 动态计算边界阈值 - 🎯 优化分页触发阈值
        let topThreshold = min(viewportHeight * 0.1, 100) // 视口高度的10%或100px
        let bottomThreshold = min(viewportHeight * 1.5, 300) // 🎯 调整为1.5倍视口高度或300px，更适合分页

        // 检查是否到达顶部（向上滚动）
        if scrollY <= topThreshold && previousScrollOffset.y > offset.y {
            onReachTop?()
        }

        // 防止在布局未完成时错误触发底部回调
        guard contentHeight > 0 && isLayoutReady else {
            return
        }

        // 检查是否到达底部
        let isNearBottom = scrollY + viewportHeight >= contentHeight - bottomThreshold

        // 防止重复触发
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastTrigger = currentTime - lastBottomTriggerTime

        // 触发底部回调
        if isNearBottom && timeSinceLastTrigger > 0.2 {
            lastBottomTriggerTime = currentTime
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

