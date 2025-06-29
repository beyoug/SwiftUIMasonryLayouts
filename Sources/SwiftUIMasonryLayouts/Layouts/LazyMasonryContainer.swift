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
    
    /// 计算整体布局
    private func calculateLayout() {
        let containerSize = geometry.size
        guard containerSize.width > 0 && containerSize.height > 0 else { return }

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
            itemSizeCalculator: itemSizeCalculator,
            cache: &layoutCache
        )

        // 缓存结果
        layoutCache.cacheLayoutResult(for: cacheKey, result: result)

        // 应用结果
        applyLayoutResult(result)
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
    
    /// 更新可见范围
    private func updateVisibleRange(scrollOffset: CGPoint) {
        let viewportRect = CGRect(
            x: -scrollOffset.x,
            y: -scrollOffset.y,
            width: geometry.size.width,
            height: geometry.size.height
        )
        
        // 扩展视口以包含预加载缓冲区
        let expandedViewport: CGRect
        if configuration.axis == .vertical {
            // 垂直布局：主要在垂直方向预加载
            expandedViewport = viewportRect.insetBy(dx: 0, dy: -preloadBuffer)
        } else {
            // 水平布局：主要在水平方向预加载
            expandedViewport = viewportRect.insetBy(dx: -preloadBuffer, dy: 0)
        }
        
        var newVisibleIndices: [Data.Index] = []
        
        for (index, item) in data.enumerated() {
            if let position = itemPositions[item.id],
               expandedViewport.intersects(position) {
                newVisibleIndices.append(data.index(data.startIndex, offsetBy: index))
            }
        }
        
        if !newVisibleIndices.isEmpty {
            let newRange = newVisibleIndices.min()!..<data.index(after: newVisibleIndices.max()!)
            if newRange != visibleRange {
                visibleRange = newRange
                onVisibleRangeChanged?(newRange)
            }
        } else if visibleRange != nil {
            visibleRange = nil
        }
    }
    
    /// 检查滚动边界
    private func checkScrollBoundaries(offset: CGPoint) {
        if configuration.axis == .vertical {
            checkVerticalScrollBoundaries(offset: offset)
        } else {
            checkHorizontalScrollBoundaries(offset: offset)
        }
    }

    /// 检查垂直滚动边界
    private func checkVerticalScrollBoundaries(offset: CGPoint) {
        let viewportHeight = geometry.size.height
        let contentHeight = totalContentSize.height
        let scrollY = -offset.y

        // 检查是否到达顶部
        if scrollY <= 50 && lastScrollOffset.y > offset.y {
            onReachTop?()
        }

        // 检查是否到达底部
        if scrollY + viewportHeight >= contentHeight - 100 && lastScrollOffset.y < offset.y {
            onReachBottom?()
        }
    }

    /// 检查水平滚动边界
    private func checkHorizontalScrollBoundaries(offset: CGPoint) {
        let viewportWidth = geometry.size.width
        let contentWidth = totalContentSize.width
        let scrollX = -offset.x

        // 检查是否到达左边（对应垂直布局的顶部）
        if scrollX <= 50 && lastScrollOffset.x > offset.x {
            onReachTop?()
        }

        // 检查是否到达右边（对应垂直布局的底部）
        if scrollX + viewportWidth >= contentWidth - 100 && lastScrollOffset.x < offset.x {
            onReachBottom?()
        }
    }
}
