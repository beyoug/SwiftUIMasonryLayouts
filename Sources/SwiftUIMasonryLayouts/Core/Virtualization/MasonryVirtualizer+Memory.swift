//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

// MARK: - MasonryVirtualizer 内存管理扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension MasonryVirtualizer {

    /// 检查内存压力并进行清理
    func checkMemoryPressure() {
        let memoryUsage = getMemoryUsage()

        if memoryUsage > memoryPressureThreshold {
            #if DEBUG
            print("⚠️ SwiftUIMasonryLayouts: 内存使用量(\(memoryUsage)MB)超过阈值(\(memoryPressureThreshold)MB)，执行内存清理")
            #endif

            // 清理不必要的缓存
            performMemoryCleanup()
        }
    }

    /// 获取当前内存使用量（MB）- 跨平台实现
    internal func getMemoryUsage() -> Int {
        #if os(macOS) || os(iOS)
        // macOS 和 iOS 使用 mach API
        return getMachMemoryUsage()
        #elseif os(watchOS) || os(tvOS) || os(visionOS)
        // 其他平台使用估算方法
        return getEstimatedMemoryUsage()
        #else
        // 未知平台，返回保守估计
        return 50 // 50MB 保守估计
        #endif
    }

    #if os(macOS) || os(iOS)
    /// macOS/iOS 平台的内存检测
    internal func getMachMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Int(info.resident_size) / (1024 * 1024) // 转换为MB
        }

        return 0
    }
    #endif

    #if os(watchOS) || os(tvOS) || os(visionOS)
    /// 其他平台的内存估算
    internal func getEstimatedMemoryUsage() -> Int {
        // 基于数据结构大小估算内存使用
        let itemCount = allItems.count
        let visibleItemCount = visibleItems.count

        // 每个 VirtualItem 大约 64 字节
        let itemsMemory = (itemCount + visibleItemCount) * 64

        // 缓存和其他数据结构大约 1MB
        let baseMemory = 1024 * 1024

        let totalBytes = itemsMemory + baseMemory
        return totalBytes / (1024 * 1024) // 转换为MB
    }
    #endif

    /// 执行内存清理
    internal func performMemoryCleanup() {
        // 清理过期的缓存项目
        layoutCache.invalidate()

        // 如果项目数量过多，保留最近的项目
        if allItems.count > maxCachedItems / 2 {
            let keepCount = maxCachedItems / 2
            allItems = Array(allItems.suffix(keepCount))

            // 重新计算可见项目
            visibleItems = visibleItems.filter { item in
                allItems.contains { $0.id == item.id }
            }
        }
    }

    /// 清理资源
    func cleanup() {
        // 取消当前任务
        currentLayoutTask?.cancel()
        currentLayoutTask = nil

        // 使所有正在运行的任务失效
        Task {
            await concurrencyController.invalidateAllTasks()
        }

        // 清理缓存和数据
        layoutCache.invalidate()
        allItems.removeAll()
        visibleItems.removeAll()
        totalSize = .zero
    }
}
