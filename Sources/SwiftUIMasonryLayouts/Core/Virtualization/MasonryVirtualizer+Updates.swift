//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

// MARK: - MasonryVirtualizer 可见项目更新扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension MasonryVirtualizer {

    /// 更新可见项目（增量更新优化）
    func updateVisibleItems(visibleRect: CGRect) {
        // 防止并发更新导致的状态不一致
        if isUpdating {
            pendingUpdateRect = visibleRect
            return
        }

        // 检查是否需要更新（避免不必要的计算）
        let rectChangeThreshold: CGFloat = 20.0 // 增加阈值，减少微小滚动的更新

        // 修复：如果是初始状态、allItems为空或visibleItems为空，强制更新
        let isInitialState = lastVisibleRect == .zero || allItems.isEmpty || visibleItems.isEmpty
        let hasSignificantChange = abs(visibleRect.minX - lastVisibleRect.minX) >= rectChangeThreshold ||
                                  abs(visibleRect.minY - lastVisibleRect.minY) >= rectChangeThreshold ||
                                  abs(visibleRect.width - lastVisibleRect.width) >= rectChangeThreshold ||
                                  abs(visibleRect.height - lastVisibleRect.height) >= rectChangeThreshold

        if !isInitialState && !hasSignificantChange {
            return // 变化太小，跳过更新
        }

        performVisibleItemsUpdate(visibleRect: visibleRect)
    }

    /// 执行实际的可见项目更新
    internal func performVisibleItemsUpdate(visibleRect: CGRect) {
        isUpdating = true
        defer {
            isUpdating = false
            // 处理待处理的更新
            if let pending = pendingUpdateRect {
                pendingUpdateRect = nil
                DispatchQueue.main.async {
                    self.updateVisibleItems(visibleRect: pending)
                }
            }
        }

        // 计算稳定的缓冲区域，减少边界抖动
        let bufferSize = min(visibleRect.width, visibleRect.height) * 0.5 // 固定缓冲大小
        let bufferedRect = CGRect(
            x: visibleRect.minX - bufferSize,
            y: visibleRect.minY - bufferSize,
            width: visibleRect.width + bufferSize * 2,
            height: visibleRect.height + bufferSize * 2
        )

        // 增量更新：只处理变化的部分
        let newVisibleItems = performIncrementalUpdate(bufferedRect: bufferedRect)

        // 智能更新：只有在实际发生变化时才更新状态
        if !areVisibleItemsEqual(visibleItems, newVisibleItems) {
            visibleItems = newVisibleItems
            lastVisibleRect = visibleRect

            // 更新索引集合
            visibleItemIndices = Set(visibleItems.map { $0.dataIndex })
        }

        #if DEBUG
        // 详细的调试信息，帮助诊断可见项目问题
        if visibleItems.isEmpty && !allItems.isEmpty {
            print("⚠️ SwiftUIMasonryLayouts: 可见项目为空但allItems不为空")
            print("   - allItems: \(allItems.count)")
            print("   - visibleRect: \(visibleRect)")
            print("   - bufferedRect: \(bufferedRect)")
            print("   - 前5个allItems的frame: \(allItems.prefix(5).map { $0.frame })")
        } else if !visibleItems.isEmpty {
            print("✅ SwiftUIMasonryLayouts: 找到 \(visibleItems.count)/\(allItems.count) 个可见项目")
        }
        #endif
    }

    /// 智能比较可见项目列表，避免不必要的更新
    internal func areVisibleItemsEqual(_ oldItems: [VirtualItem], _ newItems: [VirtualItem]) -> Bool {
        // 快速检查：数量不同则肯定不同
        guard oldItems.count == newItems.count else { return false }

        // 检查每个项目是否相等（使用我们定义的Equatable）
        for (old, new) in zip(oldItems, newItems) {
            if old != new {
                return false
            }
        }

        return true
    }

    /// 执行增量更新
    internal func performIncrementalUpdate(bufferedRect: CGRect) -> [VirtualItem] {
        // 修复：如果allItems为空，直接返回空数组
        guard !allItems.isEmpty else {
            return []
        }

        // 如果是首次计算、visibleItems为空或项目数量变化很大，执行完整计算
        if lastVisibleRect == .zero || visibleItems.isEmpty || abs(allItems.count - visibleItems.count * 4) > 1000 {
            let result = allItems.filter { $0.frame.intersects(bufferedRect) }
            return result
        }

        // 增量更新：基于空间分区优化
        return performSpatialPartitionedUpdate(bufferedRect: bufferedRect)
    }

    /// 基于空间分区的增量更新
    internal func performSpatialPartitionedUpdate(bufferedRect: CGRect) -> [VirtualItem] {
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
    internal func findItemsInYRange(startY: CGFloat, endY: CGFloat) -> [VirtualItem] {
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
    internal func optimizedRangeQuery(startY: CGFloat, endY: CGFloat) -> [VirtualItem] {
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
}
