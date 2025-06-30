/**
*  SwiftUIMasonryLayouts Lazy Masonry View Tests
*  Copyright (c) Beyoug 2025
*  MIT license, see LICENSE file for details
*/

import XCTest
import SwiftUI
@testable import SwiftUIMasonryLayouts

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
final class LazyMasonryViewTests: XCTestCase {

    // MARK: - 测试数据模型
    
    struct TestItem: Identifiable {
        let id = UUID()
        let title: String
        let height: CGFloat
        
        static func generateItems(count: Int) -> [TestItem] {
            (0..<count).map { index in
                TestItem(
                    title: "Item \(index)",
                    height: CGFloat.random(in: 100...200)
                )
            }
        }
    }

    // MARK: - 基础功能测试

    func testDataGeneration() {
        let items = TestItem.generateItems(count: 10)
        XCTAssertEqual(items.count, 10, "应该生成正确数量的测试项目")
        XCTAssertTrue(items.allSatisfy { !$0.title.isEmpty }, "所有项目都应该有标题")
        XCTAssertTrue(items.allSatisfy { $0.height >= 100 && $0.height <= 200 }, "项目高度应该在合理范围内")
    }

    // MARK: - 缓存机制测试

    func testLazyLayoutCacheBasicOperations() {
        var cache = LazyLayoutCache()
        let testId = UUID()
        let testSize = CGSize(width: 100, height: 150)
        
        // 测试缓存项目尺寸
        cache.cacheItemSize(for: testId, size: testSize)
        let cachedSize = cache.getCachedItemSize(for: testId)
        
        XCTAssertEqual(cachedSize, testSize, "应该能够正确缓存和获取项目尺寸")
    }
    
    func testLazyLayoutCacheLayoutResult() {
        var cache = LazyLayoutCache()
        let testKey = "test_layout_key"
        let testResult = LazyLayoutResult(
            itemFrames: [CGRect(x: 0, y: 0, width: 100, height: 100)],
            totalSize: CGSize(width: 200, height: 300),
            lineCount: 2,
            itemPositions: [:]
        )
        
        // 测试缓存布局结果
        cache.cacheLayoutResult(for: testKey, result: testResult)
        let cachedResult = cache.getCachedLayoutResult(for: testKey)
        
        XCTAssertNotNil(cachedResult, "应该能够缓存布局结果")
        XCTAssertEqual(cachedResult?.totalSize, testResult.totalSize, "缓存的布局结果应该正确")
        XCTAssertEqual(cachedResult?.lineCount, testResult.lineCount, "缓存的行数应该正确")
    }
    
    func testLazyLayoutCacheInvalidation() {
        var cache = LazyLayoutCache()
        let testId = UUID()
        let testSize = CGSize(width: 100, height: 150)
        let testKey = "test_key"
        let testResult = LazyLayoutResult(
            itemFrames: [],
            totalSize: CGSize(width: 200, height: 300),
            lineCount: 1,
            itemPositions: [:]
        )
        
        // 添加缓存数据
        cache.cacheItemSize(for: testId, size: testSize)
        cache.cacheLayoutResult(for: testKey, result: testResult)
        
        // 清除缓存
        cache.invalidate()
        
        // 验证缓存已清除
        XCTAssertNil(cache.getCachedItemSize(for: testId), "清除后应该无法获取项目尺寸")
        XCTAssertNil(cache.getCachedLayoutResult(for: testKey), "清除后应该无法获取布局结果")
    }

    // MARK: - 边界条件测试

    func testEmptyDataSource() {
        let emptyItems: [TestItem] = []
        XCTAssertEqual(emptyItems.count, 0, "空数据源应该包含0个项目")
    }

    func testSingleItemDataSource() {
        let singleItem = [TestItem(title: "Single", height: 100)]
        XCTAssertEqual(singleItem.count, 1, "单项数据源应该包含1个项目")
        XCTAssertEqual(singleItem.first?.title, "Single", "单项数据源的标题应该正确")
    }

    func testLargeDataSource() {
        let largeItems = TestItem.generateItems(count: 1000)
        XCTAssertEqual(largeItems.count, 1000, "大数据源应该包含正确数量的项目")
        XCTAssertTrue(largeItems.allSatisfy { !$0.title.isEmpty }, "所有项目都应该有标题")
    }

    // MARK: - 性能测试

    func testLazyLayoutCachePerformance() {
        var cache = LazyLayoutCache()
        
        measure {
            // 测试大量缓存操作的性能
            for i in 0..<1000 {
                let id = UUID()
                let size = CGSize(width: 100, height: CGFloat(i % 200 + 100))
                cache.cacheItemSize(for: id, size: size)
            }
        }
    }

    // MARK: - 类型别名测试

    func testTypeAliasesExist() {
        // 测试类型别名是否存在（编译时检查）
        let _: LazyMasonry<[TestItem], UUID, Text>.Type = LazyMasonryView<[TestItem], UUID, Text>.self

        XCTAssertTrue(true, "类型别名应该正确定义")
    }
}
