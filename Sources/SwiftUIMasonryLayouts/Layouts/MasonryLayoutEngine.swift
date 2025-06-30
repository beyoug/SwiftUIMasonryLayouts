//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 瀑布流布局引擎

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
            
            let lineIndex = parameters.selectLineIndex(lineOffsets: lineOffsets, index: index)

            guard lineIndex >= 0 && lineIndex < lineOffsets.count else {
                continue
            }
            
            let frame = calculateItemFrame(
                itemSize: itemSize,
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
                itemSize: itemSize,
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
    ///   - itemSizeCalculator: 项目尺寸计算器
    ///   - cache: 懒加载缓存
    /// - Returns: 懒加载布局结果
    static func calculateLazyLayout<Data: RandomAccessCollection, ID: Hashable>(
        containerSize: CGSize,
        items: Data,
        configuration: MasonryConfiguration,
        itemSizeCalculator: ((Data.Element, CGFloat) -> CGSize)?,
        cache: inout LazyLayoutCache
    ) -> LazyLayoutResult where Data.Element: Identifiable, Data.Element.ID == ID {
        
        let parameters = LayoutParameters(
            containerSize: containerSize,
            axis: configuration.axis,
            lines: configuration.lines,
            horizontalSpacing: configuration.horizontalSpacing,
            verticalSpacing: configuration.verticalSpacing,
            placementMode: configuration.placementMode
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
                itemSizeCalculator: itemSizeCalculator,
                cache: &cache
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

            cache.cacheItemSize(for: item.id, size: itemSize)
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
        if parameters.axis == .vertical {
            return CGRect(
                x: CGFloat(lineIndex) * lineSize + CGFloat(lineIndex) * parameters.horizontalSpacing,
                y: lineOffset,
                width: lineSize,
                height: itemSize.height
            )
        } else {
            return CGRect(
                x: lineOffset,
                y: CGFloat(lineIndex) * lineSize + CGFloat(lineIndex) * parameters.verticalSpacing,
                width: itemSize.width,
                height: lineSize
            )
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
            lineOffsets[lineIndex] += itemSize.height + parameters.verticalSpacing
        } else {
            lineOffsets[lineIndex] += itemSize.width + parameters.horizontalSpacing
        }
    }
    
    /// 计算懒加载项目尺寸
    private static func calculateItemSize<Item: Identifiable>(
        item: Item,
        lineSize: CGFloat,
        configuration: MasonryConfiguration,
        itemSizeCalculator: ((Item, CGFloat) -> CGSize)?,
        cache: inout LazyLayoutCache
    ) -> CGSize {
        
        // 首先检查缓存
        if let cachedSize = cache.getCachedItemSize(for: item.id) {
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
}
