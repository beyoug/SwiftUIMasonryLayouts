//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

// MARK: - MasonryVirtualizer 布局计算扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension MasonryVirtualizer {

    /// 异步计算布局
    func calculateLayoutAsync<Data: RandomAccessCollection, ID: Hashable>(
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

                // 关键修复：异步初始化完成后立即更新可见项目
                let initialVisibleRect = CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height)
                self.updateVisibleItems(visibleRect: initialVisibleRect)

                #if DEBUG
                print("📍 异步初始化后可见项目: \(self.visibleItems.count), totalSize: \(self.totalSize)")
                #endif
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

    /// 同步计算布局（用于小数据集）
    func calculateLayoutSynchronously<Data: RandomAccessCollection, ID: Hashable>(
        data: Data,
        axis: Axis,
        lines: MasonryLines,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat,
        placementMode: MasonryPlacementMode,
        estimatedItemSize: CGSize,
        containerSize: CGSize,
        id: KeyPath<Data.Element, ID>
    ) throws -> (items: [VirtualItem], totalSize: CGSize) {

        // 重用现有的布局计算逻辑，但是同步执行
        return try performLayoutCalculationSync(
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

    /// 同步执行布局计算（用于小数据集）
    internal func performLayoutCalculationSync<Data: RandomAccessCollection, ID: Hashable>(
        data: Data,
        axis: Axis,
        lines: MasonryLines,
        horizontalSpacing: CGFloat,
        verticalSpacing: CGFloat,
        placementMode: MasonryPlacementMode,
        estimatedItemSize: CGSize,
        containerSize: CGSize,
        id: KeyPath<Data.Element, ID>
    ) throws -> (items: [VirtualItem], totalSize: CGSize) {

        // 边界检查
        guard !data.isEmpty else {
            return (items: [], totalSize: .zero)
        }

        // 验证容器尺寸
        guard containerSize.width > 0 && containerSize.height > 0 else {
            throw VirtualizationError.invalidContainerSize
        }

        // 验证估计项目尺寸
        guard estimatedItemSize.width > 0 && estimatedItemSize.height > 0 else {
            throw VirtualizationError.invalidEstimatedSize
        }

        // 计算行/列数
        let lineCount = calculateLineCount(lines: lines, containerSize: containerSize, axis: axis, spacing: axis == .vertical ? horizontalSpacing : verticalSpacing)
        guard lineCount > 0 && lineCount < 1000 else {
            throw VirtualizationError.invalidLineCount
        }

        let lineSize = calculateLineSize(containerSize: containerSize, lineCount: lineCount, axis: axis, spacing: axis == .vertical ? horizontalSpacing : verticalSpacing)

        var items: [VirtualItem] = []
        items.reserveCapacity(min(data.count, 1000)) // 限制小数据集

        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)

        for (index, dataItem) in data.enumerated() {
            // 使用动态尺寸估算，提高布局准确性
            let itemSize = estimateItemSizeForData(dataItem, estimatedSize: estimatedItemSize, lineSize: lineSize, axis: axis)
            let lineIndex = selectLineIndex(lineOffsets: lineOffsets, index: index, placementMode: placementMode)

            guard lineIndex >= 0 && lineIndex < lineCount else {
                continue
            }

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

        // 计算总尺寸
        let totalSize = CGSize(
            width: axis == .vertical ? CGFloat(lineCount) * lineSize + CGFloat(lineCount - 1) * horizontalSpacing : lineOffsets.max() ?? 0,
            height: axis == .vertical ? lineOffsets.max() ?? 0 : CGFloat(lineCount) * lineSize + CGFloat(lineCount - 1) * verticalSpacing
        )

        return (items: items, totalSize: totalSize)
    }
}
