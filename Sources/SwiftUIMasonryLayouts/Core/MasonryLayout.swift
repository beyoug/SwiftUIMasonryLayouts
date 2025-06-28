//
// Copyright (c) Beyoug
//

import SwiftUI

/// 基于iOS 18.0+ Layout协议的高性能瀑布流布局
/// 专注于布局计算，不处理数据管理和并发
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct MasonryLayout: Layout {
    
    // MARK: - 配置属性
    
    /// 布局轴向
    public let axis: Axis
    
    /// 行/列数配置
    public let lines: MasonryLines
    
    /// 水平间距
    public let horizontalSpacing: CGFloat
    
    /// 垂直间距
    public let verticalSpacing: CGFloat
    
    /// 放置模式
    public let placementMode: MasonryPlacementMode
    
    // MARK: - 初始化
    
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill
    ) {
        self.axis = axis
        self.lines = lines
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.placementMode = placementMode
    }
    
    // MARK: - Layout协议实现
    
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout LayoutCache
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let containerSize = proposal.replacingUnspecifiedDimensions()

        // 验证容器尺寸的合理性
        guard containerSize.width > 0 && containerSize.height > 0 else {
            #if DEBUG
            print("⚠️ SwiftUIMasonryLayouts: 无效的容器尺寸: \(containerSize)")
            #endif
            return .zero
        }

        // 防止极端大小导致性能问题
        let safeContainerSize = CGSize(
            width: min(containerSize.width, 100000),
            height: min(containerSize.height, 100000)
        )

        let layoutResult = calculateLayout(
            subviews: subviews,
            containerSize: safeContainerSize,
            cache: &cache
        )

        return layoutResult.totalSize
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout LayoutCache
    ) {
        guard !subviews.isEmpty else { return }
        
        let layoutResult = calculateLayout(
            subviews: subviews,
            containerSize: bounds.size,
            cache: &cache
        )
        
        for (index, subview) in subviews.enumerated() {
            guard index < layoutResult.itemFrames.count else { continue }
            
            let frame = layoutResult.itemFrames[index]
            subview.place(
                at: CGPoint(
                    x: bounds.minX + frame.minX,
                    y: bounds.minY + frame.minY
                ),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
    
    public func makeCache(subviews: Subviews) -> LayoutCache {
        LayoutCache()
    }
    
    public func updateCache(_ cache: inout LayoutCache, subviews: Subviews) {
        // 当子视图数量变化时清除缓存
        if cache.subviewCount != subviews.count {
            cache.invalidate()
            cache.subviewCount = subviews.count
        }
    }
}

// MARK: - 布局缓存

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension MasonryLayout {
    
    /// 高效的布局缓存
    public struct LayoutCache {
        var subviewCount: Int = 0
        var lastContainerSize: CGSize = .zero
        var cachedResult: LayoutResult?
        var lastCalculationTime: CFTimeInterval = 0
        var cacheHitCount: Int = 0
        var cacheMissCount: Int = 0

        mutating func invalidate() {
            cachedResult = nil
            lastContainerSize = .zero
            lastCalculationTime = 0
        }

        mutating func recordCacheHit() {
            cacheHitCount += 1
        }

        mutating func recordCacheMiss() {
            cacheMissCount += 1
        }

        var cacheEfficiency: Double {
            let total = cacheHitCount + cacheMissCount
            return total > 0 ? Double(cacheHitCount) / Double(total) : 0
        }
    }
    
    /// 布局计算结果
    struct LayoutResult {
        let itemFrames: [CGRect]
        let totalSize: CGSize
        let lineCount: Int
    }
}

// MARK: - 核心布局算法

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension MasonryLayout {
    
    /// 计算布局 - 纯函数，线程安全
    private func calculateLayout(
        subviews: Subviews,
        containerSize: CGSize,
        cache: inout LayoutCache
    ) -> LayoutResult {

        // 边界情况：没有子视图
        guard !subviews.isEmpty else {
            let emptyResult = LayoutResult(itemFrames: [], totalSize: .zero, lineCount: 0)
            cache.cachedResult = emptyResult
            cache.lastContainerSize = containerSize
            return emptyResult
        }

        // 边界情况：容器尺寸无效
        guard containerSize.width > 0 && containerSize.height > 0 else {
            let emptyResult = LayoutResult(itemFrames: [], totalSize: .zero, lineCount: 0)
            cache.cachedResult = emptyResult
            cache.lastContainerSize = containerSize
            return emptyResult
        }

        // 检查缓存
        if let cachedResult = cache.cachedResult,
           cache.lastContainerSize == containerSize {
            cache.recordCacheHit()
            return cachedResult
        }

        cache.recordCacheMiss()
        let startTime = CFAbsoluteTimeGetCurrent()

        let lineCount = calculateLineCount(containerSize: containerSize)
        let lineSize = calculateLineSize(containerSize: containerSize, lineCount: lineCount)

        var itemFrames: [CGRect] = []
        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)

        for (index, subview) in subviews.enumerated() {
            let itemSize = measureSubview(subview, lineSize: lineSize)
            let lineIndex = selectLineIndex(lineOffsets: lineOffsets, index: index)

            // 确保 lineIndex 在有效范围内
            guard lineIndex >= 0 && lineIndex < lineOffsets.count else {
                continue
            }

            let frame = CGRect(
                x: axis == .vertical ? CGFloat(lineIndex) * (lineSize + horizontalSpacing) : lineOffsets[lineIndex],
                y: axis == .vertical ? lineOffsets[lineIndex] : CGFloat(lineIndex) * (lineSize + verticalSpacing),
                width: axis == .vertical ? lineSize : itemSize.width,
                height: axis == .vertical ? itemSize.height : lineSize
            )

            itemFrames.append(frame)

            // 更新行偏移
            if axis == .vertical {
                lineOffsets[lineIndex] += itemSize.height + verticalSpacing
            } else {
                lineOffsets[lineIndex] += itemSize.width + horizontalSpacing
            }
        }

        let totalSize = calculateTotalSize(lineOffsets: lineOffsets, lineSize: lineSize, lineCount: lineCount)

        let result = LayoutResult(
            itemFrames: itemFrames,
            totalSize: totalSize,
            lineCount: lineCount
        )
        
        // 缓存结果
        let endTime = CFAbsoluteTimeGetCurrent()
        cache.lastCalculationTime = endTime - startTime
        cache.cachedResult = result
        cache.lastContainerSize = containerSize

        return result
    }
    
    /// 计算行/列数
    private func calculateLineCount(containerSize: CGSize) -> Int {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height
        let spacing = axis == .vertical ? horizontalSpacing : verticalSpacing

        // 边界检查
        guard availableSize > 0 else { return 1 }

        switch lines {
        case .fixed(let count):
            return max(1, count)

        case .adaptive(let constraint):
            switch constraint {
            case .min(let minSize):
                guard minSize > 0 else { return 1 }
                let count = Int(floor((availableSize + spacing) / (minSize + spacing)))
                return max(1, count)

            case .max(let maxSize):
                guard maxSize > 0 else { return 1 }
                let count = Int(ceil((availableSize + spacing) / (maxSize + spacing)))
                return max(1, count)
            }
        }
    }
    
    /// 计算行/列尺寸
    private func calculateLineSize(containerSize: CGSize, lineCount: Int) -> CGFloat {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height

        // 边界检查
        guard lineCount > 0 && availableSize > 0 else { return 0 }

        let totalSpacing = CGFloat(max(0, lineCount - 1)) * (axis == .vertical ? horizontalSpacing : verticalSpacing)
        let lineSize = (availableSize - totalSpacing) / CGFloat(lineCount)

        return max(0, lineSize)
    }
    
    /// 测量子视图尺寸
    private func measureSubview(_ subview: LayoutSubview, lineSize: CGFloat) -> CGSize {
        let proposal = axis == .vertical 
            ? ProposedViewSize(width: lineSize, height: nil)
            : ProposedViewSize(width: nil, height: lineSize)
        
        return subview.sizeThatFits(proposal)
    }
    
    /// 选择放置的行/列索引
    private func selectLineIndex(lineOffsets: [CGFloat], index: Int) -> Int {
        // 边界检查
        guard !lineOffsets.isEmpty else { return 0 }

        switch placementMode {
        case .fill:
            // 选择当前偏移最小的行（最短的行）
            let selectedIndex = lineOffsets.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            return max(0, min(selectedIndex, lineOffsets.count - 1))

        case .order:
            // 按顺序放置
            return index % lineOffsets.count
        }
    }
    
    /// 计算总尺寸
    private func calculateTotalSize(lineOffsets: [CGFloat], lineSize: CGFloat, lineCount: Int) -> CGSize {
        let maxOffset = lineOffsets.max() ?? 0

        if axis == .vertical {
            // 垂直布局：宽度由列数决定，高度由最长列决定
            let totalWidth = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * horizontalSpacing
            let totalHeight = max(0, maxOffset - verticalSpacing)
            return CGSize(width: totalWidth, height: totalHeight)
        } else {
            // 水平布局：高度由行数决定，宽度由最长行决定
            let totalHeight = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * verticalSpacing
            let totalWidth = max(0, maxOffset - horizontalSpacing)
            return CGSize(width: totalWidth, height: totalHeight)
        }
    }
}
