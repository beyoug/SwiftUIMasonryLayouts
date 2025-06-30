//
// Copyright (c) Beyoug
//

import XCTest
import SwiftUI
@testable import SwiftUIMasonryLayouts

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
final class LazyMasonryLayoutTests: XCTestCase {
    
    // MARK: - 测试数据
    
    struct TestItem: Identifiable, Hashable {
        let id: Int
        let height: CGFloat
        
        init(id: Int, height: CGFloat = 100) {
            self.id = id
            self.height = height
        }
    }
    
    // MARK: - 基础功能测试
    
    func testLazyMasonryLayoutCreation() {
        let layout = LazyMasonryLayout(
            configuration: .default,
            itemCount: 10
        )
        
        XCTAssertNotNil(layout)
    }
    
    func testLazyMasonryLayoutWithCustomConfiguration() {
        let configuration = MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(3),
            hSpacing: 12,
            vSpacing: 16,
            placement: .fill
        )
        
        let layout = LazyMasonryLayout(
            configuration: configuration,
            itemCount: 20
        )
        
        XCTAssertNotNil(layout)
    }
    
    func testLazyMasonryLayoutWithItemSizeCalculator() {
        let layout = LazyMasonryLayout(
            configuration: .default,
            itemCount: 15,
            itemSizeCalculator: { index, lineSize in
                CGSize(width: lineSize, height: CGFloat(100 + index * 10))
            }
        )
        
        XCTAssertNotNil(layout)
    }
    
    // MARK: - 缓存系统测试
    
    func testLazyLayoutCache() {
        var cache = LazyLayoutCache()
        
        // 测试项目尺寸缓存
        let testSize = CGSize(width: 100, height: 150)
        cache.cacheItemSize(for: 1, size: testSize)
        
        let cachedSize = cache.getCachedItemSize(for: 1)
        XCTAssertEqual(cachedSize, testSize)
        
        // 测试不存在的缓存
        let nonExistentSize = cache.getCachedItemSize(for: 999)
        XCTAssertNil(nonExistentSize)
    }
    
    func testLazyLayoutCacheInvalidation() {
        var cache = LazyLayoutCache()
        
        // 添加一些缓存数据
        cache.cacheItemSize(for: 1, size: CGSize(width: 100, height: 150))
        cache.cacheItemSize(for: 2, size: CGSize(width: 120, height: 180))
        
        // 验证缓存存在
        XCTAssertNotNil(cache.getCachedItemSize(for: 1))
        XCTAssertNotNil(cache.getCachedItemSize(for: 2))
        
        // 清除缓存
        cache.invalidate()
        
        // 验证缓存已清除
        XCTAssertNil(cache.getCachedItemSize(for: 1))
        XCTAssertNil(cache.getCachedItemSize(for: 2))
    }
    
    // MARK: - 可见性检测测试
    
    func testVisibleRangeCalculation() {
        let itemFrames = [
            CGRect(x: 0, y: 0, width: 100, height: 100),
            CGRect(x: 110, y: 0, width: 100, height: 150),
            CGRect(x: 0, y: 110, width: 100, height: 120),
            CGRect(x: 110, y: 160, width: 100, height: 80),
            CGRect(x: 0, y: 240, width: 100, height: 200)
        ]
        
        let layoutResult = LazyLayoutResult(
            itemFrames: itemFrames,
            totalSize: CGSize(width: 220, height: 450),
            lineCount: 2,
            itemPositions: [:]
        )
        
        let viewportRect = CGRect(x: 0, y: 50, width: 220, height: 200)
        
        let visibleRange = LazyMasonryLayout.calculateVisibleRange(
            viewportRect: viewportRect,
            layoutResult: layoutResult,
            bufferSize: 50
        )
        
        XCTAssertFalse(visibleRange.isEmpty)
        XCTAssertTrue(visibleRange.contains(0))
        XCTAssertTrue(visibleRange.contains(1))
        XCTAssertTrue(visibleRange.contains(2))
    }
    
    func testOptimizedVisibleRangeCalculation() {
        let itemFrames = [
            CGRect(x: 0, y: 0, width: 100, height: 100),
            CGRect(x: 110, y: 0, width: 100, height: 150),
            CGRect(x: 0, y: 110, width: 100, height: 120),
            CGRect(x: 110, y: 160, width: 100, height: 80),
            CGRect(x: 0, y: 240, width: 100, height: 200),
            CGRect(x: 110, y: 250, width: 100, height: 100)
        ]
        
        let layoutResult = LazyLayoutResult(
            itemFrames: itemFrames,
            totalSize: CGSize(width: 220, height: 450),
            lineCount: 2,
            itemPositions: [:]
        )
        
        let viewportRect = CGRect(x: 0, y: 100, width: 220, height: 200)
        
        let visibleRange = LazyMasonryLayout.calculateVisibleRangeOptimized(
            viewportRect: viewportRect,
            layoutResult: layoutResult,
            axis: .vertical,
            bufferSize: 50
        )
        
        XCTAssertFalse(visibleRange.isEmpty)
        // 应该包含在视口范围内的项目
        XCTAssertTrue(visibleRange.contains(2))
        XCTAssertTrue(visibleRange.contains(3))
    }
    
    // MARK: - 布局优化测试
    
    func testOptimizedLayoutCreation() {
        let layout = LazyMasonryLayout.optimized(
            configuration: .columns(3),
            itemCount: 50,
            visibleRange: 10..<20
        )
        
        XCTAssertNotNil(layout)
    }
    
    func testLayoutWithViewportInfo() {
        let viewportInfo = LazyViewportInfo(
            visibleRect: CGRect(x: 0, y: 100, width: 300, height: 400),
            bufferRect: CGRect(x: 0, y: 0, width: 300, height: 600),
            scrollDirection: .down
        )
        
        let layout = LazyMasonryLayout.withViewport(
            configuration: .default,
            itemCount: 30,
            viewportInfo: viewportInfo
        )
        
        XCTAssertNotNil(layout)
    }
    
    // MARK: - 性能测试
    
    func testLargeDataSetPerformance() {
        let itemCount = 1000
        let configuration = MasonryConfiguration.columns(3)
        
        measure {
            let _ = LazyMasonryLayout(
                configuration: configuration,
                itemCount: itemCount,
                itemSizeCalculator: { index, lineSize in
                    CGSize(width: lineSize, height: CGFloat(80 + index % 100))
                }
            )
            
            // 直接测试布局引擎性能
            var cache = LazyLayoutCache()
            let containerSize = CGSize(width: 300, height: 600)

            _ = MasonryLayoutEngine.calculateIndexBasedLazyLayout(
                containerSize: containerSize,
                itemCount: itemCount,
                configuration: configuration,
                itemSizeCalculator: { index, lineSize in
                    CGSize(width: lineSize, height: CGFloat(80 + index % 100))
                },
                cache: &cache
            )
        }
    }
    
    func testCachePerformance() {
        var cache = LazyLayoutCache()
        let itemCount = 1000
        
        measure {
            // 缓存大量项目尺寸
            for i in 0..<itemCount {
                let size = CGSize(width: 100, height: CGFloat(80 + i % 100))
                cache.cacheItemSize(for: i, size: size)
            }
            
            // 读取缓存
            for i in 0..<itemCount {
                _ = cache.getCachedItemSize(for: i)
            }
        }
    }
}

// MARK: - 辅助扩展

// 注意：LayoutSubviews 是 SwiftUI 内部类型，在测试中我们只能使用空的实例
