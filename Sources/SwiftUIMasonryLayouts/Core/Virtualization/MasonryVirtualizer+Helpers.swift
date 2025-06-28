//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

// MARK: - MasonryVirtualizer 辅助方法扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension MasonryVirtualizer {

    /// 后台执行布局计算
    func performLayoutCalculation<Data: RandomAccessCollection, ID: Hashable>(
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

            // 使用动态尺寸估算，提高布局准确性
            let itemSize = estimateItemSizeForData(dataItem, estimatedSize: estimatedItemSize, lineSize: lineSize, axis: axis)
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

    // MARK: - 辅助方法

    internal func calculateLineCount(lines: MasonryLines, containerSize: CGSize, axis: Axis, spacing: CGFloat) -> Int {
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

    internal func calculateLineSize(containerSize: CGSize, lineCount: Int, axis: Axis, spacing: CGFloat) -> CGFloat {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height
        let totalSpacing = CGFloat(lineCount - 1) * spacing
        return max(0, (availableSize - totalSpacing) / CGFloat(lineCount))
    }

    internal func estimateItemSize(_ estimatedSize: CGSize, lineSize: CGFloat, axis: Axis) -> CGSize {
        if axis == .vertical {
            return CGSize(width: lineSize, height: estimatedSize.height)
        } else {
            return CGSize(width: estimatedSize.width, height: lineSize)
        }
    }

    /// 根据数据项动态估算项目尺寸（用于更准确的布局）
    internal func estimateItemSizeForData<T>(_ dataItem: T, estimatedSize: CGSize, lineSize: CGFloat, axis: Axis) -> CGSize {
        // 如果数据项有高度信息，尝试使用它
        if axis == .vertical {
            var height = estimatedSize.height

            // 尝试从数据中提取高度信息
            if let previewItem = dataItem as? any PreviewItemProtocol {
                // 计算更准确的高度：内容高度 + 文本高度 + padding
                let contentHeight = previewItem.contentHeight
                let textHeight: CGFloat = 50 // 估算文本和badge的高度
                let padding: CGFloat = 16 // 估算padding
                height = contentHeight + textHeight + padding
            }

            return CGSize(width: lineSize, height: height)
        } else {
            var width = estimatedSize.width

            // 对于水平布局，可以类似地处理宽度
            if let previewItem = dataItem as? any PreviewItemProtocol {
                width = previewItem.contentWidth + 32 // 内容宽度 + padding
            }

            return CGSize(width: width, height: lineSize)
        }
    }

    internal func selectLineIndex(lineOffsets: [CGFloat], index: Int, placementMode: MasonryPlacementMode) -> Int {
        let selectedIndex: Int
        switch placementMode {
        case .fill:
            selectedIndex = lineOffsets.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
        case .order:
            selectedIndex = index % lineOffsets.count
        }

        return selectedIndex
    }

    internal func calculateTotalSize(lineOffsets: [CGFloat], lineSize: CGFloat, lineCount: Int, axis: Axis, horizontalSpacing: CGFloat, verticalSpacing: CGFloat) -> CGSize {
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
}
