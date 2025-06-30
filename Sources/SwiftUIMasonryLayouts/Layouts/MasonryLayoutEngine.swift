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
            // 安全地调用用户自定义视图的sizeThatFits
            let itemSize = safelyCalculateItemSize(
                subview: subview,
                lineSize: lineSize,
                axis: parameters.axis,
                simpleSizing: parameters.simpleSizing
            )

            // 验证计算出的尺寸是否合理
            let validatedSize = validateItemSize(itemSize, lineSize: lineSize, axis: parameters.axis)

            let lineIndex = parameters.selectLineIndex(lineOffsets: lineOffsets, index: index)

            guard lineIndex >= 0 && lineIndex < lineOffsets.count else {
                MasonryInternalConfig.Logger.warning("无效的行索引 - 行索引: \(lineIndex), 总行数: \(lineOffsets.count)")
                continue
            }
            
            let frame = calculateItemFrame(
                itemSize: validatedSize,
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
                itemSize: validatedSize,
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
    



    /// 计算基于索引的懒加载布局（用于新的LazyMasonryLayout）
    /// - Parameters:
    ///   - containerSize: 容器尺寸
    ///   - itemCount: 项目数量
    ///   - configuration: 布局配置
    ///   - itemSizeCalculator: 项目尺寸计算器
    ///   - cache: 懒加载缓存
    /// - Returns: 懒加载布局结果
    static func calculateIndexBasedLazyLayout(
        containerSize: CGSize,
        itemCount: Int,
        configuration: MasonryConfiguration,
        itemSizeCalculator: ((Int, CGFloat) -> CGSize)?,
        cache: inout LazyLayoutCache
    ) -> LazyLayoutResult {

        let parameters = LayoutParameters(
            containerSize: containerSize,
            axis: configuration.axis,
            lines: configuration.lines,
            hSpacing: configuration.hSpacing,
            vSpacing: configuration.vSpacing,
            placement: configuration.placement,
            simpleSizing: configuration.simpleSizing
        )

        let lineCount = parameters.calculateLineCount()
        let lineSize = parameters.calculateLineSize(lineCount: lineCount)

        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)
        var itemFrames: [CGRect] = []
        var positions: [AnyHashable: CGRect] = [:]

        for index in 0..<itemCount {
            let itemSize = calculateIndexBasedItemSize(
                index: index,
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
            positions[AnyHashable(index)] = frame

            cache.cacheItemSize(for: index, size: itemSize)
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
                x: CGFloat(lineIndex) * lineSize + CGFloat(lineIndex) * parameters.hSpacing,
                y: lineOffset,
                width: lineSize,
                height: itemSize.height
            )
        } else {
            return CGRect(
                x: lineOffset,
                y: CGFloat(lineIndex) * lineSize + CGFloat(lineIndex) * parameters.vSpacing,
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
            lineOffsets[lineIndex] += itemSize.height + parameters.vSpacing
        } else {
            lineOffsets[lineIndex] += itemSize.width + parameters.hSpacing
        }
    }
    


    /// 计算基于索引的项目尺寸（带缓存优化）
    private static func calculateIndexBasedItemSize(
        index: Int,
        lineSize: CGFloat,
        configuration: MasonryConfiguration,
        itemSizeCalculator: ((Int, CGFloat) -> CGSize)?,
        cache: inout LazyLayoutCache
    ) -> CGSize {
        // 检查缓存
        if let cachedSize = cache.getCachedItemSize(for: index) {
            return validateItemSize(cachedSize, lineSize: lineSize, axis: configuration.axis)
        }

        let itemSize: CGSize

        if let calculator = itemSizeCalculator {
            // 使用自定义计算器
            itemSize = calculator(index, lineSize)
        } else {
            // 使用简化的智能尺寸计算器
            let mode = configuration.simpleSizing?.mode ?? .golden
            itemSize = SimpleSizeCalculator.calculateSize(
                index: index,
                lineSize: lineSize,
                axis: configuration.axis,
                mode: mode
            )
        }

        // 验证并缓存结果
        let validatedSize = validateItemSize(itemSize, lineSize: lineSize, axis: configuration.axis)
        cache.cacheItemSize(for: index, size: validatedSize)

        return validatedSize
    }

    // MARK: - 验证和错误处理

    /// 安全地计算用户自定义视图的尺寸
    private static func safelyCalculateItemSize(
        subview: LayoutSubview,
        lineSize: CGFloat,
        axis: Axis,
        simpleSizing: SimpleSizingConfiguration? = nil
    ) -> CGSize {
        // 确定使用的模式
        let mode = simpleSizing?.mode ?? .adaptive

        // 使用简化的智能尺寸计算器
        let calculatedSize = SimpleSizeCalculator.calculateSizeForSubview(
            subview: subview,
            lineSize: lineSize,
            axis: axis,
            mode: mode
        )

        // 验证计算结果
        if calculatedSize.width.isFinite && calculatedSize.height.isFinite &&
           calculatedSize.width > 0 && calculatedSize.height > 0 {
            return calculatedSize
        }

        // 如果计算失败，使用传统方法
        let proposedSize = ProposedViewSize(
            width: axis == .vertical ? lineSize : nil,
            height: axis == .horizontal ? lineSize : nil
        )

        let itemSize = subview.sizeThatFits(proposedSize)

        // 立即进行基本检查
        if itemSize.width.isNaN || itemSize.height.isNaN ||
           itemSize.width.isInfinite || itemSize.height.isInfinite {
            let fallbackSize = SimpleSizeCalculator.createFallbackSize(lineSize: lineSize, axis: axis)
            MasonryInternalConfig.Logger.warning("用户自定义视图返回无效尺寸，使用回退尺寸: \(fallbackSize)")
            return fallbackSize
        }

        return itemSize
    }

    /// 验证项目尺寸的合理性（简化版）
    private static func validateItemSize(_ size: CGSize, lineSize: CGFloat, axis: Axis) -> CGSize {
        let minSize: CGFloat = 1.0
        let maxSize: CGFloat = lineSize * 5 // 最大不超过行尺寸的5倍

        // 首先检查是否为无效值（NaN、无限大等）
        if !size.width.isFinite || !size.height.isFinite ||
           size.width.isNaN || size.height.isNaN ||
           size.width.isInfinite || size.height.isInfinite {

            let fallbackSize = SimpleSizeCalculator.createFallbackSize(lineSize: lineSize, axis: axis)
            MasonryInternalConfig.Logger.warning("检测到无效尺寸，使用回退尺寸: \(fallbackSize)")
            return fallbackSize
        }

        var validatedSize = size

        // 验证宽度
        if validatedSize.width <= 0 {
            validatedSize.width = minSize
        } else if validatedSize.width > maxSize {
            validatedSize.width = maxSize
        }

        // 验证高度
        if validatedSize.height <= 0 {
            validatedSize.height = minSize
        } else if validatedSize.height > maxSize {
            validatedSize.height = maxSize
        }

        return validatedSize
    }
}
