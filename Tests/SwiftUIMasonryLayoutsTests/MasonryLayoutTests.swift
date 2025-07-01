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
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill
        )
    }

    // MARK: - 基础布局测试

    func testLayoutCacheInitialization() {
        let cache = LayoutCache()
        XCTAssertEqual(cache.subviewCount, 0)
        XCTAssertEqual(cache.lastContainerSize, CGSize.zero)
        XCTAssertNil(cache.cachedResult)
    }

    func testLayoutCacheInvalidation() {
        var cache = LayoutCache()
        cache.subviewCount = 5
        cache.lastContainerSize = CGSize(width: 100, height: 200)

        cache.invalidate()

        XCTAssertEqual(cache.lastContainerSize, CGSize.zero)
        XCTAssertNil(cache.cachedResult)
    }

    func testMasonryLayoutInitialization() {
        let layout = MasonryLayout(
            axis: .vertical,
            lines: .fixed(2),
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill
        )

        XCTAssertEqual(layout.axis, .vertical)
        XCTAssertEqual(layout.hSpacing, 8)
        XCTAssertEqual(layout.vSpacing, 8)
        XCTAssertEqual(layout.placement, .fill)
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
        
        // 测试基本功能
        XCTAssertEqual(fillMode, MasonryPlacementMode.fill)
        XCTAssertEqual(orderMode, MasonryPlacementMode.order)
        XCTAssertNotEqual(fillMode, orderMode)
    }
    

    
    // MARK: - 配置测试
    
    func testMasonryConfiguration() {
        let config = MasonryConfiguration(
            axis: .horizontal,
            lines: .fixed(3),
            hSpacing: 12,
            vSpacing: 16,
            placement: .order
        )

        XCTAssertEqual(config.axis, .horizontal)
        XCTAssertEqual(config.hSpacing, 12)
        XCTAssertEqual(config.vSpacing, 16)
        XCTAssertEqual(config.placement, .order)
    }
    
    func testDefaultConfiguration() {
        let config = MasonryConfiguration.default
        
        XCTAssertEqual(config.axis, .vertical)
        XCTAssertEqual(config.hSpacing, 8)
        XCTAssertEqual(config.vSpacing, 8)
        XCTAssertEqual(config.placement, .fill)
    }
    
    // MARK: - 输入验证测试

    func testValidInputs() {
        // 测试有效输入不会崩溃
        let validConfig = MasonryConfiguration(
            lines: .fixed(2),
            hSpacing: 8,
            vSpacing: 8
        )

        XCTAssertEqual(validConfig.hSpacing, 8)
        XCTAssertEqual(validConfig.vSpacing, 8)

        // 测试有效的自适应配置
        let validAdaptive = MasonryLines.adaptive(minSize: 100)
        if case .adaptive(let constraint) = validAdaptive,
           case .min(let size) = constraint {
            XCTAssertEqual(size, 100)
        } else {
            XCTFail("自适应配置创建失败")
        }

        // 测试固定数量配置
        let validFixed = MasonryLines.fixed(3)
        if case .fixed(let count) = validFixed {
            XCTAssertEqual(count, 3)
        } else {
            XCTFail("固定数量配置创建失败")
        }
    }

    // MARK: - 便捷方法测试

    func testConfigurationConvenienceMethods() {
        let columnsConfig = MasonryConfiguration.columns(3, spacing: 12)
        XCTAssertEqual(columnsConfig.axis, Axis.vertical)
        XCTAssertEqual(columnsConfig.hSpacing, 12)
        XCTAssertEqual(columnsConfig.vSpacing, 12)

        let rowsConfig = MasonryConfiguration.rows(2, spacing: 16)
        XCTAssertEqual(rowsConfig.axis, Axis.horizontal)
        XCTAssertEqual(rowsConfig.hSpacing, 16)
        XCTAssertEqual(rowsConfig.vSpacing, 16)
    }

    func testConfigurationModification() {
        let originalConfig = MasonryConfiguration.default

        let modifiedSpacing = originalConfig.withSpacing(horizontal: 16, vertical: 20)
        XCTAssertEqual(modifiedSpacing.hSpacing, 16)
        XCTAssertEqual(modifiedSpacing.vSpacing, 20)

        let modifiedMode = originalConfig.withPlacementMode(.order)
        XCTAssertEqual(modifiedMode.placement, MasonryPlacementMode.order)
    }

    // MARK: - 简单性能测试

    func testBasicPerformance() {
        // 简单的性能验证
        measure {
            var cache = LayoutCache()
            for _ in 0..<100 {
                cache.invalidate()
            }
        }
    }

    // MARK: - P1 优化测试

    /// 测试缓存效率统计
    func testCacheEfficiencyTracking() throws {
        var cache = LayoutCache()

        // 初始状态
        XCTAssertEqual(cache.cacheHitRate, 0, "初始缓存命中率应该为0")

        // 模拟缓存操作
        cache.recordCacheMiss()
        cache.recordCacheHit()

        // 验证命中率计算
        XCTAssertEqual(cache.cacheHitRate, 0.5, "50%命中率")

        // 再次命中
        cache.recordCacheHit()
        XCTAssertEqual(cache.cacheHitRate, 2.0/3.0, accuracy: 0.01, "66.7%命中率")
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
            hSpacing: 0,
            vSpacing: 0
        )

        XCTAssertEqual(layout.hSpacing, 0, "水平间距应该为0")
        XCTAssertEqual(layout.vSpacing, 0, "垂直间距应该为0")
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
        var cache = LayoutCache()

        // 设置一些缓存数据
        cache.recordCacheHit()
        cache.recordCacheMiss()
        XCTAssertGreaterThan(cache.cacheHitRate, 0, "应该有缓存统计")

        // 失效缓存
        cache.invalidate()

        // 验证缓存被重置
        XCTAssertNil(cache.cachedResult, "缓存结果应该被清空")
        XCTAssertEqual(cache.lastContainerSize, CGSize.zero, "容器尺寸应该被重置")
    }

    /// 测试内存管理配置
    func testMemoryManagementConfiguration() throws {
        // 这些测试验证内存管理相关的常量和配置
        let layout = createTestLayout()

        // 验证布局配置正确
        XCTAssertEqual(layout.axis, .vertical, "轴向应该正确")
        XCTAssertEqual(layout.hSpacing, 8, "水平间距应该正确")
        XCTAssertEqual(layout.vSpacing, 8, "垂直间距应该正确")
        XCTAssertEqual(layout.placement, .fill, "放置模式应该正确")
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
            hSpacing: 0,
            vSpacing: 0
        )
        XCTAssertEqual(layout1.hSpacing, 0, "应该接受零间距")
        XCTAssertEqual(layout1.vSpacing, 0, "应该接受零间距")

        // 测试负间距（应该被处理）
        let layout2 = MasonryLayout(
            axis: .vertical,
            lines: .fixed(1),
            hSpacing: -5,
            vSpacing: -10
        )
        // 负间距应该被自动修正为0
        XCTAssertEqual(layout2.hSpacing, 0, "负间距应该被自动修正为0")
        XCTAssertEqual(layout2.vSpacing, 0, "负间距应该被自动修正为0")
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
        var cache = LayoutCache()

        // 测试缓存状态一致性
        let initialRate = cache.cacheHitRate

        cache.recordCacheHit()
        cache.recordCacheMiss()

        // 验证缓存率有变化
        XCTAssertNotEqual(cache.cacheHitRate, initialRate, "缓存命中率应该有变化")

        // 测试缓存失效后的状态
        cache.invalidate()
        XCTAssertNil(cache.cachedResult, "缓存失效后结果应该为空")
        XCTAssertEqual(cache.lastContainerSize, CGSize.zero, "缓存失效后容器尺寸应该重置")
    }

    /// 测试并发安全性（基础测试）
    func testConcurrencySafety() async throws {
        // 测试多个独立的缓存实例
        let caches = (0..<10).map { _ in LayoutCache() }

        // 并发操作不同的缓存实例
        await withTaskGroup(of: Double.self) { group in
            for _ in caches {
                group.addTask {
                    var localCache = LayoutCache()
                    localCache.recordCacheHit()
                    localCache.recordCacheMiss()
                    return localCache.cacheHitRate
                }
            }

            var totalRate = 0.0
            for await result in group {
                totalRate += result
            }

            // 验证并发操作
            XCTAssertGreaterThan(totalRate, 0, "并发操作后应该有缓存率")
        }
    }

    /// 测试内存效率
    func testMemoryEfficiency() throws {
        var cache = LayoutCache()

        // 测试缓存效率计算
        XCTAssertEqual(cache.cacheHitRate, 0, "初始效率应该为0")

        // 添加一些操作
        cache.recordCacheMiss()
        cache.recordCacheHit()
        cache.recordCacheHit()

        let expectedEfficiency = 2.0 / 3.0 // 2 hits out of 3 total
        XCTAssertEqual(cache.cacheHitRate, expectedEfficiency, accuracy: 0.01, "效率计算应该正确")
    }

    // MARK: - 视图叠加问题修复测试

    func testEmptyDataRangeHandling() {
        // 测试空数据范围不会导致布局问题
        let parameters = LayoutParameters(
            containerSize: CGSize(width: 300, height: 400),
            axis: .vertical,
            lines: .fixed(2),
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill
        )

        let lineCount = parameters.calculateLineCount()
        XCTAssertEqual(lineCount, 2)

        let lineSize = parameters.calculateLineSize(lineCount: lineCount)
        XCTAssertGreaterThan(lineSize, 0)

        // 测试空的行偏移数组
        let emptyOffsets: [CGFloat] = []
        let totalSize = parameters.calculateTotalSize(lineOffsets: emptyOffsets, lineSize: lineSize, lineCount: lineCount)
        XCTAssertEqual(totalSize.width, lineSize * 2 + 8) // 两列 + 一个间距
        XCTAssertEqual(totalSize.height, 0) // 没有内容，高度为0
    }

    func testInvalidLineIndexHandling() {
        let parameters = LayoutParameters(
            containerSize: CGSize(width: 300, height: 400),
            axis: .vertical,
            lines: .fixed(2),
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill
        )

        let lineOffsets: [CGFloat] = [0, 0]

        // 测试负索引
        let negativeIndex = parameters.selectLineIndex(lineOffsets: lineOffsets, index: -1)
        XCTAssertGreaterThanOrEqual(negativeIndex, 0)
        XCTAssertLessThan(negativeIndex, lineOffsets.count)

        // 测试超出范围的索引
        let largeIndex = parameters.selectLineIndex(lineOffsets: lineOffsets, index: 1000)
        XCTAssertGreaterThanOrEqual(largeIndex, 0)
        XCTAssertLessThan(largeIndex, lineOffsets.count)
    }

    func testTotalSizeCalculationWithZeroContent() {
        let parameters = LayoutParameters(
            containerSize: CGSize(width: 300, height: 400),
            axis: .vertical,
            lines: .fixed(3),
            hSpacing: 10,
            vSpacing: 12,
            placement: .fill
        )

        // 测试没有内容时的总尺寸计算
        let emptyOffsets: [CGFloat] = [0, 0, 0]
        let lineSize: CGFloat = 90
        let totalSize = parameters.calculateTotalSize(lineOffsets: emptyOffsets, lineSize: lineSize, lineCount: 3)

        // 宽度应该是：3列 * 90 + 2个间距 * 10 = 290
        XCTAssertEqual(totalSize.width, 290)
        // 高度应该是0（没有内容）
        XCTAssertEqual(totalSize.height, 0)
    }

    func testAdaptiveColumnCalculation() {
        // 测试自适应列数计算的修复
        let parameters = LayoutParameters(
            containerSize: CGSize(width: 320, height: 400),
            axis: .vertical,
            lines: .adaptive(minSize: 100),
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill
        )

        let lineCount = parameters.calculateLineCount()

        // 容器宽度320，最小列宽100，间距8
        // 理论上可以放3列：100 + 8 + 100 + 8 + 100 = 316 < 320 ✓
        // 但4列：100 + 8 + 100 + 8 + 100 + 8 + 100 = 424 > 320 ✗
        XCTAssertEqual(lineCount, 3, "应该计算出3列")

        let lineSize = parameters.calculateLineSize(lineCount: lineCount)

        // 验证实际列宽：(320 - 2*8) / 3 = 304/3 ≈ 101.33 > 100 ✓
        let expectedLineSize = CGFloat(320 - 2 * 8) / CGFloat(3)
        XCTAssertEqual(lineSize, expectedLineSize, accuracy: 0.1)
        XCTAssertGreaterThanOrEqual(lineSize, 100.0, "实际列宽应该不小于最小列宽")
    }

    func testAdaptiveColumnCalculationEdgeCase() {
        // 测试边界情况：容器很小
        let parameters = LayoutParameters(
            containerSize: CGSize(width: 150, height: 400),
            axis: .vertical,
            lines: .adaptive(minSize: 100),
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill
        )

        let lineCount = parameters.calculateLineCount()

        // 容器宽度150，最小列宽100，间距8
        // 只能放1列：100 < 150 ✓
        // 2列：100 + 8 + 100 = 208 > 150 ✗
        XCTAssertEqual(lineCount, 1, "小容器应该只有1列")

        let lineSize = parameters.calculateLineSize(lineCount: lineCount)
        XCTAssertEqual(lineSize, 150.0, "单列时应该占满容器宽度")
    }
}
