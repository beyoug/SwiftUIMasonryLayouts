//
// Copyright (c) Beyoug
//

import XCTest
import SwiftUI
@testable import SwiftUIMasonryLayouts

/// 测试泛型推断问题
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
final class GenericInferenceTests: XCTestCase {

    // MARK: - 测试数据

    struct TestItem: Identifiable {
        let id = UUID()
        let title: String
        let height: CGFloat
    }

    let testItems = [
        TestItem(title: "Item 1", height: 100),
        TestItem(title: "Item 2", height: 150),
        TestItem(title: "Item 3", height: 120),
        TestItem(title: "Item 4", height: 180),
        TestItem(title: "Item 5", height: 90)
    ]
    
    // MARK: - MasonryView 泛型推断测试

    func testMasonryViewZeroParameterInference() {
        // 测试最简单的初始化方法
        let view = MasonryView {
            ForEach(self.testItems) { item in
                Text(item.title)
                    .frame(height: item.height)
            }
        }

        XCTAssertNotNil(view)
        // 验证视图可以正常创建，不强制类型检查
    }
    
    func testMasonryViewColumnsParameterInference() {
        // 测试指定列数的初始化方法
        let view = MasonryView(columns: 3) {
            ForEach(self.testItems) { item in
                Text(item.title)
                    .frame(height: item.height)
            }
        }

        XCTAssertNotNil(view)
        // 验证视图可以正常创建
    }

    func testMasonryViewSpacingParameterInference() {
        // 测试指定间距的初始化方法
        let view = MasonryView(columns: 2, spacing: 12) {
            ForEach(self.testItems) { item in
                Text(item.title)
                    .frame(height: item.height)
            }
        }

        XCTAssertNotNil(view)
        // 验证视图可以正常创建
    }
    
    // MARK: - LazyMasonryView 泛型推断测试

    func testLazyMasonryViewSimplestInference() {
        // 测试最简单的初始化方法
        let view = LazyMasonryView(testItems) { item in
            Text(item.title)
                .frame(height: item.height)
        }

        XCTAssertNotNil(view)
        // 验证视图可以正常创建
    }
    
    func testLazyMasonryViewColumnsInference() {
        // 测试指定列数的初始化方法
        let view = LazyMasonryView(testItems, columns: 3) { item in
            Text(item.title)
        }

        XCTAssertNotNil(view)
        // 验证视图可以正常创建
    }

    func testLazyMasonryViewSpacingInference() {
        // 测试指定间距的初始化方法
        let view = LazyMasonryView(testItems, columns: 2, spacing: 12) { item in
            Text(item.title)
        }

        XCTAssertNotNil(view)
        // 验证视图可以正常创建
    }

    func testLazyMasonryViewMasonryLinesInference() {
        // 测试基于 MasonryLines 的初始化方法
        let view = LazyMasonryView(testItems, columns: .fixed(3)) { item in
            Text(item.title)
        }

        XCTAssertNotNil(view)
        // 验证视图可以正常创建
    }

    func testLazyMasonryViewAdaptiveColumnsInference() {
        // 测试自适应列数的初始化方法
        let view = LazyMasonryView(testItems, columns: .adaptive(minSize: 120), spacing: 8) { item in
            Text(item.title)
        }

        XCTAssertNotNil(view)
        // 验证视图可以正常创建
    }

    // MARK: - 链式调用泛型推断测试

    func testChainedSpacingInference() {
        // 测试链式调用的泛型推断
        let view = LazyMasonryView(testItems) { item in
            Text(item.title)
        }
        .spacing(12)

        XCTAssertNotNil(view)
        // 验证链式调用可以正常工作
    }

    func testChainedDifferentSpacingInference() {
        // 测试链式调用不同间距的泛型推断
        let view = LazyMasonryView(testItems) { item in
            Text(item.title)
        }
        .spacing(horizontal: 16, vertical: 12)

        XCTAssertNotNil(view)
        // 验证链式调用可以正常工作
    }

    // MARK: - 类型推断验证测试

    func testTypeInferenceWithExplicitTypes() {
        // 测试显式类型声明是否正常工作
        let view: LazyMasonryView<[TestItem], UUID, Text> = LazyMasonryView(testItems) { item in
            Text(item.title)
        }

        XCTAssertNotNil(view)
        // 验证显式类型声明可以正常工作
    }

    func testTypeInferenceWithComplexContent() {
        // 测试复杂内容的类型推断
        let view = LazyMasonryView(testItems) { item in
            VStack {
                Text(item.title)
                    .font(.headline)
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: item.height)
            }
        }

        XCTAssertNotNil(view)
        // 验证复杂视图内容可以正常创建
    }
}
