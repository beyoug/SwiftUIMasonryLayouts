//
// Copyright (c) Beyoug
//

import SwiftUI

/// 分页加载演示示例的包装器
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PaginationDemoExample: View {

    // MARK: - 状态管理 - 🎯 使用单例模式，确保数据持久性
    @ObservedObject private var dataLoader = TestDataLoader.getInstance(pageSize: 10)

    var body: some View {
        PaginationDemoContent(dataLoader: dataLoader)
            .onAppear {
                print("🏗️ PaginationDemoExample 出现 - dataLoader实例: \(ObjectIdentifier(dataLoader))")
            }
    }
}

/// 分页加载演示的实际内容
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PaginationDemoContent: View {

    // MARK: - 属性
    @ObservedObject var dataLoader: TestDataLoader
    @State private var hasInitialized = false  // 🎯 防止重复初始化
    
    // MARK: - 视图主体
    
    var body: some View {
        // 最简洁版本：只保留LazyMasonryView核心功能
        LazyMasonryView(dataLoader.items, configuration: .columns(2)) { item in
            itemView(item)
        }
        .onReachBottom {
            // 保留分页加载功能
            let timestamp = Date().timeIntervalSince1970
            print("🎯 [\(String(format: "%.2f", timestamp))] 底部回调触发 - hasNextPage: \(dataLoader.hasNextPage), isLoading: \(dataLoader.isLoading), currentPage: \(dataLoader.currentPage), totalPages: \(dataLoader.totalPages), items: \(dataLoader.items.count)")
            if dataLoader.hasNextPage && !dataLoader.isLoading {
                print("✅ [\(String(format: "%.2f", timestamp))] 开始加载第 \(dataLoader.currentPage + 1) 页...")
                dataLoader.loadNextPage()
            } else {
                print("❌ [\(String(format: "%.2f", timestamp))] 跳过加载 - hasNextPage: \(dataLoader.hasNextPage), isLoading: \(dataLoader.isLoading)")
            }
        }
        .navigationTitle("分页加载演示")
        .onAppear {
            print("🏗️ PaginationDemoContent 出现 - dataLoader实例: \(ObjectIdentifier(dataLoader)), hasInitialized: \(hasInitialized), items: \(dataLoader.items.count)")
            // 🎯 使用单例后，只在数据为空时初始化（不依赖 hasInitialized）
            if dataLoader.items.isEmpty {
                print("🚀 数据为空，开始初始化数据加载")
                dataLoader.loadInitialData()
            } else {
                print("🔄 视图重新出现 - 数据已存在，跳过初始化，items: \(dataLoader.items.count)")
            }
            hasInitialized = true
        }
    }
    
    // MARK: - 最简洁版本：只保留LazyMasonryView核心功能
    
    private func itemView(_ item: TestDataItem) -> some View {
        // 简化版本：与SimpleMasonryTest类似的简洁样式
        Rectangle()
            .fill(item.swiftUIColor.gradient)
            .frame(height: item.cgHeight)
            .overlay(
                VStack(spacing: 4) {
                    Text("#\(item.id)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(item.category)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            )
            .cornerRadius(8)
    }
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("分页加载演示") {
    NavigationView {
        PaginationDemoExample()
    }
}
