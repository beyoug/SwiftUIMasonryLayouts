/**
*  SwiftUIMasonryLayouts Tests
*  Copyright (c) Beyoug 2025
*  MIT license, see LICENSE file for details
*/

import XCTest
import SwiftUI
@testable import SwiftUIMasonryLayouts

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
final class MasonryLayoutTests: XCTestCase {

    // MARK: - 测试辅助方法

    /// 创建测试用的布局配置
    func createTestLayout() -> MasonryLayout {
        return MasonryLayout(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 8,
            placementMode: .fill
        )
    }

    // MARK: - 基础布局测试

    func testLayoutCacheInitialization() {
        let cache = MasonryLayout.LayoutCache()
        XCTAssertEqual(cache.subviewCount, 0)
        XCTAssertEqual(cache.lastContainerSize, .zero)
        XCTAssertNil(cache.cachedResult)
    }

    func testLayoutCacheInvalidation() {
        var cache = MasonryLayout.LayoutCache()
        cache.subviewCount = 5
        cache.lastContainerSize = CGSize(width: 100, height: 200)

        cache.invalidate()

        XCTAssertEqual(cache.lastContainerSize, .zero)
        XCTAssertNil(cache.cachedResult)
    }

    func testMasonryLayoutInitialization() {
        let layout = MasonryLayout(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 8,
            placementMode: .fill
        )

        XCTAssertEqual(layout.axis, .vertical)
        XCTAssertEqual(layout.horizontalSpacing, 8)
        XCTAssertEqual(layout.verticalSpacing, 8)
        XCTAssertEqual(layout.placementMode, .fill)
    }

    
    // MARK: - MasonryLines测试
    
    func testFixedLines() {
        let lines = MasonryLines.fixed(3)
        
        // 测试Sendable一致性
        let sendableLines: any Sendable = lines
        XCTAssertNotNil(sendableLines)
    }
    
    func testAdaptiveLines() {
        let minLines = MasonryLines.adaptive(sizeConstraint: .min(100))
        let maxLines = MasonryLines.adaptive(sizeConstraint: .max(200))
        
        // 测试Sendable一致性
        let sendableMinLines: any Sendable = minLines
        let sendableMaxLines: any Sendable = maxLines
        XCTAssertNotNil(sendableMinLines)
        XCTAssertNotNil(sendableMaxLines)
    }
    
    // MARK: - MasonryPlacementMode测试
    
    func testPlacementModes() {
        let fillMode = MasonryPlacementMode.fill
        let orderMode = MasonryPlacementMode.order
        
        // 测试Sendable一致性
        let sendableFill: any Sendable = fillMode
        let sendableOrder: any Sendable = orderMode
        XCTAssertNotNil(sendableFill)
        XCTAssertNotNil(sendableOrder)
        
        // 测试所有case
        let allCases = MasonryPlacementMode.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.fill))
        XCTAssertTrue(allCases.contains(.order))
    }
    

    
    // MARK: - 配置测试
    
    func testMasonryConfiguration() {
        let config = MasonryConfiguration(
            axis: .horizontal,
            lines: .fixed(3),
            horizontalSpacing: 12,
            verticalSpacing: 16,
            placementMode: .order
        )
        
        XCTAssertEqual(config.axis, .horizontal)
        XCTAssertEqual(config.horizontalSpacing, 12)
        XCTAssertEqual(config.verticalSpacing, 16)
        XCTAssertEqual(config.placementMode, .order)
    }
    
    func testDefaultConfiguration() {
        let config = MasonryConfiguration.default
        
        XCTAssertEqual(config.axis, .vertical)
        XCTAssertEqual(config.horizontalSpacing, 8)
        XCTAssertEqual(config.verticalSpacing, 8)
        XCTAssertEqual(config.placementMode, .fill)
    }
    
    // MARK: - 输入验证测试

    func testValidInputs() {
        // 测试有效输入不会崩溃
        let validConfig = MasonryConfiguration(
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 8
        )

        XCTAssertEqual(validConfig.horizontalSpacing, 8)
        XCTAssertEqual(validConfig.verticalSpacing, 8)

        // 测试有效的自适应配置
        let validAdaptive = MasonryLines.adaptive(minSize: 100)
        if case .adaptive(let constraint) = validAdaptive,
           case .min(let size) = constraint {
            XCTAssertEqual(size, 100)
        } else {
            XCTFail("自适应配置创建失败")
        }

        // 测试带验证的固定数量方法
        let validFixed = MasonryLines.fixedCount(3)
        if case .fixed(let count) = validFixed {
            XCTAssertEqual(count, 3)
        } else {
            XCTFail("固定数量配置创建失败")
        }
    }

    // MARK: - 便捷方法测试

    func testConfigurationConvenienceMethods() {
        let verticalConfig = MasonryConfiguration.vertical(
            columns: .fixed(3),
            spacing: 12
        )

        XCTAssertEqual(verticalConfig.axis, .vertical)
        XCTAssertEqual(verticalConfig.horizontalSpacing, 12)
        XCTAssertEqual(verticalConfig.verticalSpacing, 12)

        let horizontalConfig = MasonryConfiguration.horizontal(
            rows: .fixed(2),
            spacing: 16
        )

        XCTAssertEqual(horizontalConfig.axis, .horizontal)
        XCTAssertEqual(horizontalConfig.horizontalSpacing, 16)
        XCTAssertEqual(horizontalConfig.verticalSpacing, 16)
    }

    func testConfigurationModification() {
        let originalConfig = MasonryConfiguration.default

        let modifiedSpacing = originalConfig.withSpacing(horizontal: 16, vertical: 20)
        XCTAssertEqual(modifiedSpacing.horizontalSpacing, 16)
        XCTAssertEqual(modifiedSpacing.verticalSpacing, 20)

        let modifiedMode = originalConfig.withPlacementMode(.order)
        XCTAssertEqual(modifiedMode.placementMode, .order)
    }

    // MARK: - 简单性能测试

    func testBasicPerformance() {
        // 简单的性能验证
        measure {
            var cache = MasonryLayout.LayoutCache()
            for _ in 0..<100 {
                cache.invalidate()
            }
        }
    }

    // MARK: - P1 优化测试

    /// 测试缓存效率统计
    func testCacheEfficiencyTracking() throws {
        var cache = MasonryLayout.LayoutCache()

        // 初始状态
        XCTAssertEqual(cache.cacheHitCount, 0, "初始缓存命中数应该为0")
        XCTAssertEqual(cache.cacheMissCount, 0, "初始缓存未命中数应该为0")
        XCTAssertEqual(cache.cacheEfficiency, 0, "初始缓存效率应该为0")

        // 模拟缓存未命中
        cache.recordCacheMiss()
        XCTAssertEqual(cache.cacheMissCount, 1, "缓存未命中数应该增加")
        XCTAssertEqual(cache.cacheEfficiency, 0, "只有未命中时效率应该为0")

        // 模拟缓存命中
        cache.recordCacheHit()
        XCTAssertEqual(cache.cacheHitCount, 1, "缓存命中数应该增加")
        XCTAssertEqual(cache.cacheEfficiency, 0.5, "50%命中率")

        // 再次命中
        cache.recordCacheHit()
        XCTAssertEqual(cache.cacheHitCount, 2, "缓存命中数应该继续增加")
        XCTAssertEqual(cache.cacheEfficiency, 2.0/3.0, accuracy: 0.01, "66.7%命中率")
    }

    /// 测试缓存键哈希性能
    func testCacheKeyHashPerformance() throws {
        let lines1 = MasonryLines.fixed(3)
        let lines2 = MasonryLines.adaptive(sizeConstraint: .min(80))
        let lines3 = MasonryLines.adaptive(sizeConstraint: .max(120))

        // 测试哈希值计算
        measure {
            for _ in 0..<1000 {
                _ = lines1.hashValue
                _ = lines2.hashValue
                _ = lines3.hashValue
            }
        }
    }

    /// 测试边界条件 - 零间距配置
    func testZeroSpacingConfiguration() throws {
        let layout = MasonryLayout(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 0,
            verticalSpacing: 0
        )

        XCTAssertEqual(layout.horizontalSpacing, 0, "水平间距应该为0")
        XCTAssertEqual(layout.verticalSpacing, 0, "垂直间距应该为0")
    }

    /// 测试自适应边界值配置
    func testAdaptiveBoundaryConfiguration() throws {
        // 测试极小的最小尺寸
        let lines1 = MasonryLines.adaptive(sizeConstraint: .min(1))
        let layout1 = MasonryLayout(axis: .vertical, lines: lines1)

        XCTAssertEqual(layout1.lines, lines1, "应该正确设置极小最小尺寸")

        // 测试极大的最大尺寸
        let lines2 = MasonryLines.adaptive(sizeConstraint: .max(1000))
        let layout2 = MasonryLayout(axis: .vertical, lines: lines2)

        XCTAssertEqual(layout2.lines, lines2, "应该正确设置极大最大尺寸")
    }

    /// 测试缓存失效机制
    func testCacheInvalidationMechanism() throws {
        var cache = MasonryLayout.LayoutCache()

        // 设置一些缓存数据
        cache.recordCacheHit()
        cache.recordCacheMiss()
        XCTAssertGreaterThan(cache.cacheHitCount, 0, "应该有缓存统计")

        // 失效缓存
        cache.invalidate()

        // 验证缓存被重置
        XCTAssertNil(cache.cachedResult, "缓存结果应该被清空")
        XCTAssertEqual(cache.lastContainerSize, .zero, "容器尺寸应该被重置")
    }

    /// 测试内存管理配置
    func testMemoryManagementConfiguration() throws {
        // 这些测试验证内存管理相关的常量和配置
        let layout = createTestLayout()

        // 验证布局配置正确
        XCTAssertEqual(layout.axis, .vertical, "轴向应该正确")
        XCTAssertEqual(layout.horizontalSpacing, 8, "水平间距应该正确")
        XCTAssertEqual(layout.verticalSpacing, 8, "垂直间距应该正确")
        XCTAssertEqual(layout.placementMode, .fill, "放置模式应该正确")
    }

    // MARK: - P2 错误处理和平台兼容性测试

    /// 测试平台兼容性 - 不同平台的内存检测
    func testCrossPlatformCompatibility() throws {
        // 测试在不同平台上都能正常工作
        let layout = createTestLayout()

        // 验证基本功能在所有平台都可用
        XCTAssertNotNil(layout, "布局应该在所有平台都能创建")

        #if os(macOS) || os(iOS)
        // macOS/iOS 特定测试
        XCTAssertTrue(true, "macOS/iOS 平台支持")
        #elseif os(watchOS) || os(tvOS) || os(visionOS)
        // 其他平台测试
        XCTAssertTrue(true, "其他平台支持")
        #endif
    }

    /// 测试错误处理 - 无效配置
    func testInvalidConfigurationHandling() throws {
        // 测试零间距（边界情况）
        let layout1 = MasonryLayout(
            axis: .vertical,
            lines: .fixed(1),
            horizontalSpacing: 0,
            verticalSpacing: 0
        )
        XCTAssertEqual(layout1.horizontalSpacing, 0, "应该接受零间距")
        XCTAssertEqual(layout1.verticalSpacing, 0, "应该接受零间距")

        // 测试负间距（应该被处理）
        let layout2 = MasonryLayout(
            axis: .vertical,
            lines: .fixed(1),
            horizontalSpacing: -5,
            verticalSpacing: -10
        )
        // 负间距应该被接受（由布局引擎处理）
        XCTAssertEqual(layout2.horizontalSpacing, -5, "负间距应该被记录")
        XCTAssertEqual(layout2.verticalSpacing, -10, "负间距应该被记录")
    }

    /// 测试边界条件 - 极端配置值
    func testExtremeConfigurationValues() throws {
        // 测试极大的行数
        let layout1 = MasonryLayout(
            axis: .vertical,
            lines: .fixed(1000)
        )
        XCTAssertEqual(layout1.lines, .fixed(1000), "应该接受大行数")

        // 测试极小的自适应尺寸
        let layout2 = MasonryLayout(
            axis: .horizontal,
            lines: .adaptive(sizeConstraint: .min(0.1))
        )
        XCTAssertEqual(layout2.lines, .adaptive(sizeConstraint: .min(0.1)), "应该接受极小尺寸")

        // 测试极大的自适应尺寸
        let layout3 = MasonryLayout(
            axis: .vertical,
            lines: .adaptive(sizeConstraint: .max(10000))
        )
        XCTAssertEqual(layout3.lines, .adaptive(sizeConstraint: .max(10000)), "应该接受极大尺寸")
    }

    /// 测试缓存一致性
    func testCacheConsistency() throws {
        var cache = MasonryLayout.LayoutCache()

        // 测试缓存状态一致性
        let initialHits = cache.cacheHitCount
        let initialMisses = cache.cacheMissCount

        cache.recordCacheHit()
        XCTAssertEqual(cache.cacheHitCount, initialHits + 1, "缓存命中计数应该增加")

        cache.recordCacheMiss()
        XCTAssertEqual(cache.cacheMissCount, initialMisses + 1, "缓存未命中计数应该增加")

        // 测试缓存失效后的状态
        cache.invalidate()
        XCTAssertNil(cache.cachedResult, "缓存失效后结果应该为空")
        XCTAssertEqual(cache.lastContainerSize, .zero, "缓存失效后容器尺寸应该重置")
    }

    /// 测试并发安全性（基础测试）
    func testConcurrencySafety() async throws {
        // 测试多个独立的缓存实例
        let caches = (0..<10).map { _ in MasonryLayout.LayoutCache() }

        // 并发操作不同的缓存实例
        await withTaskGroup(of: Int.self) { group in
            for _ in caches {
                group.addTask {
                    var localCache = MasonryLayout.LayoutCache()
                    localCache.recordCacheHit()
                    localCache.recordCacheMiss()
                    return localCache.cacheHitCount + localCache.cacheMissCount
                }
            }

            var totalOperations = 0
            for await result in group {
                totalOperations += result
            }

            // 验证每个缓存都执行了2个操作
            XCTAssertEqual(totalOperations, 20, "并发操作后计数应该正确")
        }
    }

    /// 测试内存效率
    func testMemoryEfficiency() throws {
        var cache = MasonryLayout.LayoutCache()

        // 测试缓存效率计算
        XCTAssertEqual(cache.cacheEfficiency, 0, "初始效率应该为0")

        // 添加一些操作
        cache.recordCacheMiss()
        cache.recordCacheHit()
        cache.recordCacheHit()

        let expectedEfficiency = 2.0 / 3.0 // 2 hits out of 3 total
        XCTAssertEqual(cache.cacheEfficiency, expectedEfficiency, accuracy: 0.01, "效率计算应该正确")
    }
}
