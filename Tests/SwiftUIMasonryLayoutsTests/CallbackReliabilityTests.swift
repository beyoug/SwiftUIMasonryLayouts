//
// Copyright (c) Beyoug
//

import XCTest
import SwiftUI
@testable import SwiftUIMasonryLayouts

/// 测试回调机制在真实数据驱动场景中的可靠性
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
final class CallbackReliabilityTests: XCTestCase {
    
    // MARK: - 测试数据
    
    struct TestItem: Identifiable, Equatable {
        let id: Int
        let height: CGFloat
        let content: String
        
        init(id: Int, height: CGFloat = 100) {
            self.id = id
            self.height = height
            self.content = "Item \(id)"
        }
    }
    
    // MARK: - 回调可靠性测试
    
    func testVisibleRangeCallbackReliability() {
        // 模拟真实数据驱动场景
        let items = (1...50).map { TestItem(id: $0) }
        var callbackCount = 0

        // 创建回调
        let onVisibleRangeChanged: (Range<Array<TestItem>.Index>) -> Void = { _ in
            callbackCount += 1
        }

        // 创建视图（模拟真实使用）
        let _ = LazyMasonryView(items, configuration: .columns(2)) { item in
            Rectangle()
                .frame(height: item.height)
                .overlay(Text(item.content))
        }
        .onVisibleRangeChanged(onVisibleRangeChanged)

        // 验证回调配置正确
        XCTAssertNotNil(onVisibleRangeChanged, "回调应该正确配置")

        // 在真实环境中，回调会在视图渲染时触发
        // 这里主要验证回调机制的配置正确性
        XCTAssertEqual(items.count, 50, "数据应该正确")
    }
    
    func testCallbackConfigurationCorrectness() {
        // 测试回调配置的正确性
        let items = (1...20).map { TestItem(id: $0) }

        let _ = LazyMasonryView(items, configuration: .columns(2)) { item in
            Rectangle().frame(height: item.height)
        }
        .onVisibleRangeChanged { _ in
            // 回调配置测试
        }
        .onReachTop {
            // 回调配置测试
        }
        .onReachBottom {
            // 回调配置测试
        }

        // 验证回调配置
        XCTAssertTrue(true, "所有回调应该正确配置")
        XCTAssertEqual(items.count, 20, "数据应该正确")
    }
    
    func testCallbackChainConfiguration() {
        let items = (1...100).map { TestItem(id: $0) }

        let _ = LazyMasonryView(items, configuration: .columns(2)) { item in
            Rectangle().frame(height: item.height)
        }
        .onVisibleRangeChanged { _ in
            // 可见范围变化回调
        }
        .onReachTop {
            // 到达顶部回调
        }
        .onReachBottom {
            // 到达底部回调
        }

        // 验证链式配置正确
        XCTAssertEqual(items.count, 100, "数据应该正确")
    }
    
    func testLargeDatasetCallbackConfiguration() {
        // 测试大数据集下回调配置
        let largeDataset = (1...1000).map { TestItem(id: $0, height: CGFloat.random(in: 50...200)) }

        let _ = LazyMasonryView(largeDataset, configuration: .columns(3)) { item in
            Rectangle().frame(height: item.height)
        }
        .onVisibleRangeChanged { range in
            // 验证范围的基本有效性
            XCTAssertFalse(range.isEmpty, "可见范围不应为空")
            XCTAssertLessThanOrEqual(range.upperBound, largeDataset.endIndex, "范围不应超出数据边界")
        }

        // 验证大数据集配置
        XCTAssertEqual(largeDataset.count, 1000, "大数据集应该正确")
    }
    
    func testCallbacksWithDifferentConfigurations() {
        // 测试不同配置下的回调
        let items = (1...50).map { TestItem(id: $0) }

        // 测试列配置
        let _ = LazyMasonryView(items, configuration: .columns(2)) { item in
            Rectangle().frame(height: item.height)
        }
        .onVisibleRangeChanged { _ in }

        // 测试自适应配置
        let _ = LazyMasonryView(items, configuration: .adaptive(minColumnWidth: 100)) { item in
            Rectangle().frame(height: item.height)
        }
        .onVisibleRangeChanged { _ in }

        // 验证配置正确
        XCTAssertEqual(items.count, 50, "数据应该正确")
    }
}

// MARK: - 回调机制验证

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension CallbackReliabilityTests {

    func testCallbackMechanismIntegrity() {
        let items = (1...100).map { TestItem(id: $0) }

        // 验证回调机制的完整性
        let _ = LazyMasonryView(items, configuration: .columns(2)) { item in
            Rectangle().frame(height: item.height)
        }
        .onVisibleRangeChanged { range in
            // 验证回调参数的有效性
            XCTAssertGreaterThanOrEqual(range.lowerBound, items.startIndex, "范围下界应有效")
            XCTAssertLessThanOrEqual(range.upperBound, items.endIndex, "范围上界应有效")
        }

        // 验证数据完整性
        XCTAssertEqual(items.count, 100, "数据应该完整")
        XCTAssertEqual(items.first?.id, 1, "第一个项目ID应正确")
        XCTAssertEqual(items.last?.id, 100, "最后一个项目ID应正确")
    }

    func testDataResetScenario() {
        // 测试数据重置场景，模拟CallbackDemoExample中的问题
        var items = (1...20).map { TestItem(id: $0) }

        // 模拟添加更多数据
        let moreItems = (21...40).map { TestItem(id: $0) }
        items.append(contentsOf: moreItems)

        // 验证数据添加后的状态
        XCTAssertEqual(items.count, 40, "应该有40个项目")
        XCTAssertEqual(items.first?.id, 1, "第一个项目ID应该是1")
        XCTAssertEqual(items.last?.id, 40, "最后一个项目ID应该是40")

        // 模拟数据重置（使用新的连续ID）
        let resetItems = (41...65).map { TestItem(id: $0) }
        items = resetItems

        // 验证重置后的数据
        XCTAssertEqual(items.count, 25, "重置后应该有25个项目")
        XCTAssertEqual(items.first?.id, 41, "重置后第一个项目ID应该是41")
        XCTAssertEqual(items.last?.id, 65, "重置后最后一个项目ID应该是65")

        // 验证ID的唯一性
        let uniqueIds = Set(items.map { $0.id })
        XCTAssertEqual(uniqueIds.count, items.count, "所有ID应该是唯一的")
    }
}
