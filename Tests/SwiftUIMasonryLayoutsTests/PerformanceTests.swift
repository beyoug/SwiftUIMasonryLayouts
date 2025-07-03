//
// Copyright (c) Beyoug
//

import XCTest
import SwiftUI
@testable import SwiftUIMasonryLayouts

// MARK: - 性能测试

/// 性能测试套件 - 验证布局计算和缓存系统的性能
@available(iOS 18.0, *)
final class PerformanceTests: XCTestCase {
    
    // MARK: - 布局性能测试
    
    /// 测试基本布局计算性能
    func testBasicLayoutPerformance() {
        let containerSize = CGSize(width: 400, height: 600)
        let config = MasonryConfiguration.columns(2)
        
        measure {
            // 执行100次布局计算
            for _ in 0..<100 {
                let parameters = LayoutParameters(
                    containerSize: containerSize,
                    axis: config.axis,
                    lines: config.lines,
                    hSpacing: config.hSpacing,
                    vSpacing: config.vSpacing,
                    placement: config.placement
                )
                
                // 访问预计算的值
                _ = parameters.lineCount
                _ = parameters.lineSize
                
                // 模拟行选择操作
                let lineOffsets: [CGFloat] = Array(repeating: 0, count: parameters.lineCount)
                for i in 0..<10 {
                    _ = parameters.selectLineIndex(lineOffsets: lineOffsets, index: i)
                }
            }
        }
    }
    
    /// 测试自适应布局性能
    func testAdaptiveLayoutPerformance() {
        let containerSize = CGSize(width: 400, height: 600)
        let config = MasonryConfiguration.adaptive(minColumnWidth: 120)
        
        measure {
            for _ in 0..<100 {
                let parameters = LayoutParameters(
                    containerSize: containerSize,
                    axis: config.axis,
                    lines: config.lines,
                    hSpacing: config.hSpacing,
                    vSpacing: config.vSpacing,
                    placement: config.placement
                )
                
                _ = parameters.lineCount
                _ = parameters.lineSize
            }
        }
    }
    
    /// 测试不同配置的性能对比
    func testConfigurationPerformanceComparison() {
        let containerSize = CGSize(width: 400, height: 600)
        let configurations = [
            MasonryConfiguration.columns(2),
            MasonryConfiguration.columns(3),
            MasonryConfiguration.adaptive(minColumnWidth: 120),
            MasonryConfiguration.rows(2)
        ]

        // 只测试一个配置的性能，避免多个measure调用
        let config = configurations[0]
        measure(metrics: [XCTClockMetric()]) {
            for _ in 0..<200 { // 增加循环次数补偿只测试一个配置
                let parameters = LayoutParameters(
                    containerSize: containerSize,
                    axis: config.axis,
                    lines: config.lines,
                    hSpacing: config.hSpacing,
                    vSpacing: config.vSpacing,
                    placement: config.placement
                )

                _ = parameters.lineCount
                _ = parameters.lineSize
            }
        }
    }
    
    // MARK: - 缓存性能测试
    
    /// 测试缓存命中性能
    func testCacheHitPerformance() {
        var cache = LayoutCache()
        let containerSize = CGSize(width: 400, height: 600)
        let configHash = 12345
        
        // 设置缓存
        let result = LayoutResult(
            itemFrames: [CGRect(x: 0, y: 0, width: 100, height: 100)],
            totalSize: CGSize(width: 375, height: 100),
            lineCount: 2
        )
        cache.cachedResult = result
        cache.lastContainerSize = containerSize
        cache.lastConfigurationHash = configHash
        cache.subviewCount = 1
        
        measure {
            for _ in 0..<1000 {
                let isValid = CacheManager.isCacheValid(
                    cache: cache,
                    containerSize: containerSize,
                    configurationHash: configHash,
                    subviewCount: 1
                )
                if isValid {
                    cache.recordCacheHit()
                }
            }
        }
    }
    
    /// 测试缓存未命中性能
    func testCacheMissPerformance() {
        var cache = LayoutCache()
        let containerSize = CGSize(width: 400, height: 600)
        
        measure {
            for i in 0..<1000 {
                let isValid = CacheManager.isCacheValid(
                    cache: cache,
                    containerSize: containerSize,
                    configurationHash: i, // 每次都不同，确保缓存未命中
                    subviewCount: 1
                )
                if !isValid {
                    cache.recordCacheMiss()
                }
            }
        }
    }
    
    // MARK: - 内存性能测试
    
    /// 测试大量数据的内存使用
    func testMemoryUsageWithLargeDataset() {
        let containerSize = CGSize(width: 400, height: 600)
        _ = MasonryConfiguration.columns(2)
        
        measure(metrics: [XCTMemoryMetric()]) {
            var caches: [LayoutCache] = []
            
            // 创建大量缓存对象
            for i in 0..<100 {
                var cache = LayoutCache()
                let result = LayoutResult(
                    itemFrames: Array(0..<50).map { _ in 
                        CGRect(x: 0, y: 0, width: 100, height: 100) 
                    },
                    totalSize: CGSize(width: 375, height: 5000),
                    lineCount: 2
                )
                cache.cachedResult = result
                cache.lastContainerSize = containerSize
                cache.lastConfigurationHash = i
                cache.subviewCount = 50
                
                caches.append(cache)
            }
            
            // 清理
            caches.removeAll()
        }
    }
    
    // MARK: - 辅助方法
    
    /// 获取配置描述（用于调试）
    private func configDescription(_ config: MasonryConfiguration) -> String {
        switch config.lines {
        case .fixed(let count):
            return "\(config.axis == .vertical ? "垂直" : "水平")\(count)\(config.axis == .vertical ? "列" : "行")"
        case .adaptive(let constraint):
            switch constraint {
            case .min(let size):
                return "自适应(最小\(Int(size)))"
            case .max(let size):
                return "自适应(最大\(Int(size)))"
            }
        }
    }
}

// MARK: - 性能基准测试

/// 性能基准测试 - 用于建立性能基准线
@available(iOS 18.0, *)
final class PerformanceBenchmarkTests: XCTestCase {
    
    /// 基准测试：布局计算
    func testLayoutCalculationBenchmark() {
        let containerSize = CGSize(width: 400, height: 600)
        let config = MasonryConfiguration.columns(2)
        
        // 使用measure直接测试性能
        measure {
            // 执行1000次布局计算
            for _ in 0..<1000 {
                let parameters = LayoutParameters(
                    containerSize: containerSize,
                    axis: config.axis,
                    lines: config.lines,
                    hSpacing: config.hSpacing,
                    vSpacing: config.vSpacing,
                    placement: config.placement
                )

                _ = parameters.lineCount
                _ = parameters.lineSize
            }
        }
    }
}
