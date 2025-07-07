//
// Copyright (c) Beyoug
//

import SwiftUI
@testable import SwiftUIMasonryLayouts

/// 编译时测试：验证所有初始化方法的语法正确性
@available(iOS 18.0, *)
struct CompilationTests {
    
    // MARK: - 测试数据

    private let testData = Array(0..<20).map { IdentifiableInt(id: $0, value: $0) }
    private let testItems = [
        TestDataItem(id: 1, title: "Item 1", height: 100),
        TestDataItem(id: 2, title: "Item 2", height: 150),
        TestDataItem(id: 3, title: "Item 3", height: 120)
    ]
    
    // MARK: - MasonryStack 编译测试

    @MainActor
    func testMasonryStackCompilation() {
        // 1. 基础初始化 - 默认参数
        let _ = MasonryStack {
            Text("Default")
        }
        
        // 2. 基础初始化 - 完整参数
        let _ = MasonryStack(
            axis: .vertical,
            lines: .fixed(3),
            hSpacing: 12,
            vSpacing: 16,
            placement: .fill
        ) {
            ForEach(testData) { item in
                Text("\(item.value)")
            }
        }
        
        // 3. 配置对象初始化
        let config = MasonryConfiguration(
            axis: .horizontal,
            lines: .adaptive(minSize: 150),
            hSpacing: 10,
            vSpacing: 10,
            placement: .order
        )
        let _ = MasonryStack(configuration: config) {
            ForEach(testItems) { item in
                VStack {
                    Text(item.title)
                    Rectangle()
                        .frame(height: CGFloat(item.height))
                }
            }
        }
        
        // 4. 响应式初始化
        let breakpoints: [CGFloat: MasonryConfiguration] = [
            0: .columns(1),
            480: .columns(2),
            768: .columns(3),
            1024: .columns(4)
        ]
        let _ = MasonryStack(breakpoints: breakpoints) {
            ForEach(testData) { item in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                    .frame(height: CGFloat.random(in: 80...200))
                    .overlay(Text("\(item.value)"))
            }
        }
        
        // 5. 便捷初始化 - 列数
        let _ = MasonryStack(columns: 2) {
            Text("Columns")
        }
        
        let _ = MasonryStack(columns: 3, spacing: 16) {
            ForEach(testData) { item in
                Text("Item \(item.value)")
            }
        }
        
        // 6. 便捷初始化 - 行数
        let _ = MasonryStack(rows: 2) {
            Text("Rows")
        }
        
        let _ = MasonryStack(rows: 3, spacing: 12) {
            ForEach(testItems) { item in
                Text(item.title)
            }
        }
        
        // 7. 便捷初始化 - 自适应列
        let _ = MasonryStack(adaptiveColumns: 120) {
            Text("Adaptive Columns")
        }
        
        let _ = MasonryStack(adaptiveColumns: 150, spacing: 8) {
            ForEach(testData) { item in
                Circle()
                    .fill(Color.green)
                    .frame(width: 60, height: 60)
                    .overlay(Text("\(item.value)"))
            }
        }
        
        // 8. 便捷初始化 - 自适应行
        let _ = MasonryStack(adaptiveRows: 80) {
            Text("Adaptive Rows")
        }
        
        let _ = MasonryStack(adaptiveRows: 100, spacing: 10) {
            ForEach(testItems) { item in
                HStack {
                    Text(item.title)
                    Spacer()
                }
            }
        }
        
        // 9. 便捷初始化 - 响应式
        let _ = MasonryStack(phoneColumns: 1, tabletColumns: 3) {
            Text("Responsive")
        }
        
        let _ = MasonryStack(phoneColumns: 2, tabletColumns: 4, spacing: 12) {
            ForEach(testData) { item in
                VStack {
                    Image(systemName: "star.fill")
                    Text("\(item.value)")
                }
            }
        }
    }
    
    // MARK: - LazyMasonryStack 编译测试

    @MainActor
    func testLazyMasonryStackCompilation() {
        // 1. 基础初始化 - 默认参数
        let _ = LazyMasonryStack(testData) { item in
            Text("\(item.value)")
        }
        
        // 2. 基础初始化 - 完整参数
        let _ = LazyMasonryStack(
            testItems,
            axis: .horizontal,
            lines: .fixed(2),
            hSpacing: 15,
            vSpacing: 20,
            placement: .order,
            bottomTriggerThreshold: 0.8,
            debounceInterval: 1.5
        ) { item in
            VStack {
                Text(item.title)
                Rectangle()
                    .frame(height: CGFloat(item.height))
            }
        }
        
        // 3. 配置对象初始化
        let lazyConfig = MasonryConfiguration(
            axis: .vertical,
            lines: .adaptive(minSize: 120),
            bottomTriggerThreshold: 0.7,
            debounceInterval: 0.8
        )
        let _ = LazyMasonryStack(testData, configuration: lazyConfig) { item in
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange)
                .frame(height: CGFloat.random(in: 100...250))
                .overlay(Text("\(item.value)"))
        }
        
        // 4. 便捷初始化 - 列数（默认参数）
        let _ = LazyMasonryStack(testData, columns: 2) { item in
            Text("Column \(item.value)")
        }
        
        // 5. 便捷初始化 - 列数（完整参数）
        let _ = LazyMasonryStack(
            testItems,
            columns: 3,
            spacing: 14,
            bottomTriggerThreshold: 0.9,
            debounceInterval: 2.0
        ) { item in
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Rectangle()
                    .fill(Color.purple)
                    .frame(height: CGFloat(item.height))
            }
        }
        
        // 6. 便捷初始化 - 行数（默认参数）
        let _ = LazyMasonryStack(testData, rows: 2) { item in
            Text("Row \(item.value)")
        }
        
        // 7. 便捷初始化 - 行数（完整参数）
        let _ = LazyMasonryStack(
            testItems,
            rows: 3,
            spacing: 18,
            bottomTriggerThreshold: 0.6,
            debounceInterval: 0.5
        ) { item in
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 30, height: 30)
                Text(item.title)
                Spacer()
            }
        }
        
        // 8. 便捷初始化 - 自适应列（默认参数）
        let _ = LazyMasonryStack(testData, adaptiveColumns: 140) { item in
            Text("Adaptive \(item.value)")
        }
        
        // 9. 便捷初始化 - 自适应列（完整参数）
        let _ = LazyMasonryStack(
            testItems,
            adaptiveColumns: 160,
            spacing: 12,
            bottomTriggerThreshold: 0.75,
            debounceInterval: 1.2
        ) { item in
            VStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                Text(item.title)
                    .font(.caption)
            }
        }
        
        // 10. 便捷初始化 - 自适应行（默认参数）
        let _ = LazyMasonryStack(testData, adaptiveRows: 90) { item in
            Text("Adaptive Row \(item.value)")
        }
        
        // 11. 便捷初始化 - 自适应行（完整参数）
        let _ = LazyMasonryStack(
            testItems,
            adaptiveRows: 110,
            spacing: 16,
            bottomTriggerThreshold: 0.85,
            debounceInterval: 1.8
        ) { item in
            HStack {
                Text(item.title)
                    .font(.subheadline)
                Spacer()
                Text("\(item.height)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - 链式方法编译测试

    @MainActor
    func testChainMethodsCompilation() {
        // Footer 方法测试
        let _ = LazyMasonryStack(testData, columns: 2) { item in
            Text("\(item.value)")
        }
        .footer {
            HStack {
                ProgressView()
                Text("Loading...")
            }
            .padding()
        }
        
        // onReachBottom 方法测试
        let _ = LazyMasonryStack(testItems, rows: 2) { item in
            Text(item.title)
        }
        .onReachBottom {
            print("Reached bottom!")
        }
        
        // 链式方法组合测试
        let _ = LazyMasonryStack(testData, columns: 3) { item in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.3))
                .frame(height: CGFloat.random(in: 80...180))
                .overlay(Text("\(item.value)"))
        }
        .footer {
            VStack {
                if Bool.random() {
                    ProgressView("Loading more...")
                } else {
                    Text("No more content")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .onReachBottom {
            // 模拟加载更多数据
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("Load more data")
            }
        }
    }
}

// MARK: - 测试数据模型

private struct TestDataItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let height: Int
}

private struct IdentifiableInt: Identifiable, Hashable {
    let id: Int
    let value: Int
}
