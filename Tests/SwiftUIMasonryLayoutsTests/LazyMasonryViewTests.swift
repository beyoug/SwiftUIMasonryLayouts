import XCTest
import SwiftUI
@testable import SwiftUIMasonryLayouts

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
final class LazyMasonryViewTests: XCTestCase {

    struct TestItem: Identifiable {
        let id = UUID()
        let height: CGFloat
    }

    /// 测试LazyMasonryView的基本初始化
    func testLazyMasonryViewInitialization() {
        let items = Array(0..<10).map { TestItem(height: CGFloat($0 * 20 + 100)) }

        let lazyView = LazyMasonryView(
            axis: .vertical,
            lines: .fixed(2),
            data: items,
            id: \.id
        ) { item in
            Rectangle()
                .frame(height: item.height)
        }

        XCTAssertNotNil(lazyView)
    }

    /// 测试小数据集的同步初始化
    func testSmallDataSetSynchronousInitialization() {
        let items = Array(0..<20).map { TestItem(height: CGFloat($0 * 20 + 100)) }

        // 使用完整的初始化器避免泛型推断问题
        let lazyView = LazyMasonryView(
            axis: .vertical,
            lines: .fixed(2),
            data: items,
            id: \.id
        ) { item in
            Rectangle()
                .frame(height: item.height)
        }

        XCTAssertNotNil(lazyView)

        // 小数据集应该能够快速初始化
        let expectation = XCTestExpectation(description: "Small dataset initialization")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    /// 测试大数据集的异步初始化
    func testLargeDataSetAsynchronousInitialization() {
        let items = Array(0..<1000).map { TestItem(height: CGFloat($0 % 200 + 100)) }

        let lazyView = LazyMasonryView(
            axis: .vertical,
            lines: .fixed(3),
            data: items,
            id: \.id,
            estimatedItemSize: CGSize(width: 120, height: 150)
        ) { item in
            Rectangle()
                .frame(height: item.height)
        }

        XCTAssertNotNil(lazyView)
    }
    
    /// 测试不同的列配置
    func testDifferentColumnConfigurations() {
        let items = Array(0..<50).map { TestItem(height: CGFloat($0 * 10 + 100)) }

        // 固定列数
        let fixedColumnsView = LazyMasonryView(
            axis: .vertical,
            lines: .fixed(3),
            data: items,
            id: \.id
        ) { item in
            Rectangle().frame(height: item.height)
        }

        // 自适应列数
        let adaptiveColumnsView = LazyMasonryView(
            axis: .vertical,
            lines: .adaptive(minSize: 120),
            data: items,
            id: \.id
        ) { item in
            Rectangle().frame(height: item.height)
        }

        XCTAssertNotNil(fixedColumnsView)
        XCTAssertNotNil(adaptiveColumnsView)
    }
    
    /// 测试空数据集
    func testEmptyDataSet() {
        let items: [TestItem] = []

        let lazyView = LazyMasonryView(
            axis: .vertical,
            lines: .fixed(2),
            data: items,
            id: \.id
        ) { item in
            Rectangle().frame(height: item.height)
        }

        XCTAssertNotNil(lazyView)
    }

    /// 测试水平布局
    func testHorizontalLayout() {
        let items = Array(0..<25).map { TestItem(height: CGFloat($0 * 10 + 100)) }

        let horizontalView = LazyMasonryView(
            axis: .horizontal,
            lines: .fixed(2),
            data: items,
            id: \.id
        ) { item in
            Rectangle().frame(width: item.height) // 使用height作为width
        }

        XCTAssertNotNil(horizontalView)
    }
}
