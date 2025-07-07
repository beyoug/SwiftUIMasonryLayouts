//
// Copyright (c) Beyoug
//

import XCTest
import SwiftUI
@testable import SwiftUIMasonryLayouts

/// 测试所有初始化方法的正确性
@available(iOS 18.0, *)
final class InitializationTests: XCTestCase {
    
    // MARK: - 测试数据

    private let testData = Array(0..<10).map { TestDataItem(id: $0, name: "Item \($0)") }
    private let testConfiguration = MasonryConfiguration(
        axis: .vertical,
        lines: .fixed(3),
        hSpacing: 12,
        vSpacing: 16,
        placement: .order,
        bottomTriggerThreshold: 0.8,
        debounceInterval: 1.5
    )
    
    // MARK: - MasonryStack 初始化测试

    @MainActor
    func testMasonryStackBasicInitialization() {
        // 测试基础初始化
        let stack1 = MasonryStack {
            Text("Test")
        }
        XCTAssertNotNil(stack1)
        
        // 测试带参数的基础初始化
        let stack2 = MasonryStack(
            axis: .horizontal,
            lines: .fixed(3),
            hSpacing: 12,
            vSpacing: 16,
            placement: .order
        ) {
            Text("Test")
        }
        XCTAssertNotNil(stack2)
    }
    
    @MainActor
    func testMasonryStackConfigurationInitialization() {
        // 测试配置对象初始化
        let stack = MasonryStack(configuration: testConfiguration) {
            Text("Test")
        }
        XCTAssertNotNil(stack)
    }
    
    @MainActor
    func testMasonryStackResponsiveInitialization() {
        // 测试响应式初始化
        let breakpoints: [CGFloat: MasonryConfiguration] = [
            0: .columns(2),
            768: .columns(3),
            1024: .columns(4)
        ]
        
        let stack = MasonryStack(breakpoints: breakpoints) {
            Text("Test")
        }
        XCTAssertNotNil(stack)
    }
    
    @MainActor
    func testMasonryStackConvenienceInitializations() {
        // 测试列数便捷初始化
        let columnsStack = MasonryStack(columns: 3) {
            Text("Test")
        }
        XCTAssertNotNil(columnsStack)
        
        // 测试行数便捷初始化
        let rowsStack = MasonryStack(rows: 2, spacing: 12) {
            Text("Test")
        }
        XCTAssertNotNil(rowsStack)
        
        // 测试自适应列便捷初始化
        let adaptiveColumnsStack = MasonryStack(adaptiveColumns: 150, spacing: 10) {
            Text("Test")
        }
        XCTAssertNotNil(adaptiveColumnsStack)
        
        // 测试自适应行便捷初始化
        let adaptiveRowsStack = MasonryStack(adaptiveRows: 100, spacing: 8) {
            Text("Test")
        }
        XCTAssertNotNil(adaptiveRowsStack)
        
        // 测试响应式便捷初始化
        let responsiveStack = MasonryStack(phoneColumns: 2, tabletColumns: 4) {
            Text("Test")
        }
        XCTAssertNotNil(responsiveStack)
    }
    
    // MARK: - LazyMasonryStack 初始化测试

    @MainActor
    func testLazyMasonryStackBasicInitialization() {
        // 测试基础初始化（默认参数）
        let stack1 = LazyMasonryStack(testData) { item in
            Text(item.name)
        }
        XCTAssertNotNil(stack1)
        
        // 测试基础初始化（完整参数）
        let stack2 = LazyMasonryStack(
            testData,
            axis: .horizontal,
            lines: .fixed(3),
            hSpacing: 12,
            vSpacing: 16,
            placement: .order,
            bottomTriggerThreshold: 0.8,
            debounceInterval: 1.5
        ) { item in
            Text(item.name)
        }
        XCTAssertNotNil(stack2)
    }
    
    @MainActor
    func testLazyMasonryStackConfigurationInitialization() {
        // 测试配置对象初始化
        let stack = LazyMasonryStack(testData, configuration: testConfiguration) { item in
            Text(item.name)
        }
        XCTAssertNotNil(stack)
    }
    
    @MainActor
    func testLazyMasonryStackConvenienceInitializations() {
        // 测试列数便捷初始化（默认参数）
        let columnsStack1 = LazyMasonryStack(testData, columns: 3) { item in
            Text(item.name)
        }
        XCTAssertNotNil(columnsStack1)

        // 测试列数便捷初始化（完整参数）
        let columnsStack2 = LazyMasonryStack(
            testData,
            columns: 3,
            spacing: 12,
            bottomTriggerThreshold: 0.7,
            debounceInterval: 0.8
        ) { item in
            Text(item.name)
        }
        XCTAssertNotNil(columnsStack2)

        // 测试行数便捷初始化（默认参数）
        let rowsStack1 = LazyMasonryStack(testData, rows: 2) { item in
            Text(item.name)
        }
        XCTAssertNotNil(rowsStack1)

        // 测试行数便捷初始化（完整参数）
        let rowsStack2 = LazyMasonryStack(
            testData,
            rows: 2,
            spacing: 16,
            bottomTriggerThreshold: 0.9,
            debounceInterval: 2.0
        ) { item in
            Text(item.name)
        }
        XCTAssertNotNil(rowsStack2)
    }
    
    @MainActor
    func testLazyMasonryStackAdaptiveInitializations() {
        // 测试自适应列初始化（默认参数）
        let adaptiveColumnsStack1 = LazyMasonryStack(testData, adaptiveColumns: 150) { item in
            Text(item.name)
        }
        XCTAssertNotNil(adaptiveColumnsStack1)

        // 测试自适应列初始化（完整参数）
        let adaptiveColumnsStack2 = LazyMasonryStack(
            testData,
            adaptiveColumns: 150,
            spacing: 10,
            bottomTriggerThreshold: 0.6,
            debounceInterval: 1.2
        ) { item in
            Text(item.name)
        }
        XCTAssertNotNil(adaptiveColumnsStack2)

        // 测试自适应行初始化（默认参数）
        let adaptiveRowsStack1 = LazyMasonryStack(testData, adaptiveRows: 100) { item in
            Text(item.name)
        }
        XCTAssertNotNil(adaptiveRowsStack1)

        // 测试自适应行初始化（完整参数）
        let adaptiveRowsStack2 = LazyMasonryStack(
            testData,
            adaptiveRows: 100,
            spacing: 8,
            bottomTriggerThreshold: 0.5,
            debounceInterval: 0.5
        ) { item in
            Text(item.name)
        }
        XCTAssertNotNil(adaptiveRowsStack2)
    }
    
    // MARK: - 链式方法测试

    @MainActor
    func testLazyMasonryStackChainMethods() {
        // 测试Footer链式方法
        let stackWithFooter = LazyMasonryStack(testData, columns: 2) { item in
            Text(item.name)
        }
        .footer {
            Text("Footer")
        }
        XCTAssertNotNil(stackWithFooter)

        // 测试onReachBottom链式方法
        let stackWithCallback = LazyMasonryStack(testData, columns: 2) { item in
            Text(item.name)
        }
        .onReachBottom {
            // 回调逻辑
        }
        XCTAssertNotNil(stackWithCallback)

        // 测试链式方法组合
        let stackWithBoth = LazyMasonryStack(testData, columns: 2) { item in
            Text(item.name)
        }
        .footer {
            Text("Footer")
        }
        .onReachBottom {
            // 回调逻辑
        }
        XCTAssertNotNil(stackWithBoth)
    }

    // MARK: - 配置验证测试

    func testMasonryConfigurationInitialization() {
        // 测试默认配置
        let defaultConfig = MasonryConfiguration()
        XCTAssertEqual(defaultConfig.axis, .vertical)
        XCTAssertEqual(defaultConfig.lines, .fixed(2))
        XCTAssertEqual(defaultConfig.hSpacing, 8)
        XCTAssertEqual(defaultConfig.vSpacing, 8)
        XCTAssertEqual(defaultConfig.placement, .fill)
        XCTAssertEqual(defaultConfig.bottomTriggerThreshold, 0.6)
        XCTAssertEqual(defaultConfig.debounceInterval, 1.0)

        // 测试自定义配置
        let customConfig = MasonryConfiguration(
            axis: .horizontal,
            lines: .adaptive(minSize: 120),
            hSpacing: 16,
            vSpacing: 20,
            placement: .order,
            bottomTriggerThreshold: 0.8,
            debounceInterval: 2.0
        )
        XCTAssertEqual(customConfig.axis, .horizontal)
        XCTAssertEqual(customConfig.lines, .adaptive(minSize: 120))
        XCTAssertEqual(customConfig.hSpacing, 16)
        XCTAssertEqual(customConfig.vSpacing, 20)
        XCTAssertEqual(customConfig.placement, .order)
        XCTAssertEqual(customConfig.bottomTriggerThreshold, 0.8)
        XCTAssertEqual(customConfig.debounceInterval, 2.0)
    }

    func testMasonryConfigurationPresets() {
        // 测试预设配置
        XCTAssertNotNil(MasonryConfiguration.default)
        XCTAssertNotNil(MasonryConfiguration.adaptiveColumns)
        XCTAssertNotNil(MasonryConfiguration.twoRows)
        XCTAssertNotNil(MasonryConfiguration.earlyTrigger)
        XCTAssertNotNil(MasonryConfiguration.lateTrigger)
        XCTAssertNotNil(MasonryConfiguration.fastResponse)
        XCTAssertNotNil(MasonryConfiguration.slowResponse)

        // 验证预设配置的值
        XCTAssertEqual(MasonryConfiguration.earlyTrigger.bottomTriggerThreshold, 0.5)
        XCTAssertEqual(MasonryConfiguration.lateTrigger.bottomTriggerThreshold, 0.9)
        XCTAssertEqual(MasonryConfiguration.fastResponse.debounceInterval, 0.5)
        XCTAssertEqual(MasonryConfiguration.slowResponse.debounceInterval, 2.0)
    }

    func testMasonryConfigurationConvenienceMethods() {
        // 测试便捷方法
        let columnsConfig = MasonryConfiguration.columns(3)
        XCTAssertEqual(columnsConfig.axis, .vertical)
        XCTAssertEqual(columnsConfig.lines, .fixed(3))

        let rowsConfig = MasonryConfiguration.rows(2)
        XCTAssertEqual(rowsConfig.axis, .horizontal)
        XCTAssertEqual(rowsConfig.lines, .fixed(2))

        let adaptiveConfig = MasonryConfiguration.adaptive(minColumnWidth: 150)
        XCTAssertEqual(adaptiveConfig.axis, .vertical)
        XCTAssertEqual(adaptiveConfig.lines, .adaptive(minSize: 150))

        let spacingConfig = MasonryConfiguration.columns(2, spacing: 16)
        XCTAssertEqual(spacingConfig.hSpacing, 16)
        XCTAssertEqual(spacingConfig.vSpacing, 16)
    }

    // MARK: - 边界值测试

    func testBoundaryValues() {
        // 测试边界值配置
        let boundaryConfig = MasonryConfiguration(
            hSpacing: -5,  // 负值应该被修正为0
            vSpacing: -10, // 负值应该被修正为0
            bottomTriggerThreshold: 1.5, // 超过1.0应该被修正为1.0
            debounceInterval: 0.05 // 小于0.1应该被修正为0.1
        )

        XCTAssertEqual(boundaryConfig.hSpacing, 0)
        XCTAssertEqual(boundaryConfig.vSpacing, 0)
        XCTAssertEqual(boundaryConfig.bottomTriggerThreshold, 1.0)
        XCTAssertEqual(boundaryConfig.debounceInterval, 0.1)
    }

    // MARK: - 类型约束测试

    @MainActor
    func testTypeConstraints() {
        // 测试不同数据类型（都需要遵循Identifiable）
        let identifiableIntArray = [1, 2, 3, 4, 5].map { IdentifiableInt(id: $0, value: $0) }
        let identifiableStringArray = ["A", "B", "C", "D"].map { IdentifiableString(id: $0, value: $0) }
        let customStructArray = [TestItem(id: 1, name: "Test")]

        // Identifiable Int数组
        let intStack = LazyMasonryStack(identifiableIntArray, columns: 2) { item in
            Text("\(item.value)")
        }
        XCTAssertNotNil(intStack)

        // Identifiable String数组
        let stringStack = LazyMasonryStack(identifiableStringArray, columns: 2) { item in
            Text(item.value)
        }
        XCTAssertNotNil(stringStack)

        // 自定义结构体数组
        let customStack = LazyMasonryStack(customStructArray, columns: 2) { item in
            Text(item.name)
        }
        XCTAssertNotNil(customStack)
    }
}

// MARK: - 测试辅助类型

private struct TestDataItem: Identifiable, Hashable {
    let id: Int
    let name: String
}

private struct TestItem: Identifiable, Hashable {
    let id: Int
    let name: String
}

private struct IdentifiableInt: Identifiable, Hashable {
    let id: Int
    let value: Int
}

private struct IdentifiableString: Identifiable, Hashable {
    let id: String
    let value: String
}
