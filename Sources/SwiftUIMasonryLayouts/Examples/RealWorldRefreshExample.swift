//
// Copyright (c) Beyoug
//

import SwiftUI

/// 演示真实世界中的下拉刷新和懒加载场景
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct RealWorldRefreshExample: View {
    
    // MARK: - 状态管理
    
    @State private var items: [DemoItem] = []
    @State private var visibleRange: String = "无"
    @State private var isRefreshing = false
    @State private var isLoadingMore = false
    @State private var refreshCount = 0
    @State private var loadMoreCount = 0
    @State private var currentPage = 0
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            // 状态面板
            statusPanel
            
            // 主要内容
            mainContent
        }
        .navigationTitle("真实刷新场景")
        .onAppear {
            loadInitialData()
        }
    }
    
    // MARK: - 子视图
    
    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("真实下拉刷新演示")
                    .font(.headline)
                Spacer()
                if isRefreshing || isLoadingMore {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            Group {
                Text("总项目数: \(items.count)")
                Text("可见范围: \(visibleRange)")
                Text("当前页: \(currentPage)")
                Text("刷新次数: \(refreshCount)")
                Text("加载更多次数: \(loadMoreCount)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Text("💡 提示：下拉刷新会完全重新加载数据，这是推荐的做法")
                .font(.caption2)
                .foregroundColor(.orange)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    private var mainContent: some View {
        LazyMasonryView(items, configuration: .columns(2)) { item in
            itemView(item)
        }
        .onVisibleRangeChanged { range in
            handleVisibleRangeChanged(range)
        }
        .onReachTop {
            handleReachTop()
        }
        .onReachBottom {
            handleReachBottom()
        }
    }
    
    private func itemView(_ item: DemoItem) -> some View {
        Rectangle()
            .fill(item.color.gradient)
            .frame(maxWidth: .infinity)
            .frame(height: item.height)
            .overlay(
                VStack(spacing: 4) {
                    Text("ID: \(item.id)")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("P\(getPageForItem(item.id))")
                        .font(.caption2)
                        .opacity(0.8)
                }
                .foregroundColor(.white)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - 数据操作
    
    private func loadInitialData() {
        currentPage = 1
        items = generateItemsForPage(1)
    }
    
    private func handleVisibleRangeChanged(_ range: Range<Array<DemoItem>.Index>) {
        let startIdx = range.lowerBound
        let endIdx = range.upperBound
        visibleRange = "\(startIdx)..<\(endIdx)"
        
        // 预加载逻辑：当接近底部时自动加载更多
        if endIdx > items.count - 3 && !isLoadingMore && !isRefreshing {
            loadMoreData()
        }
    }
    
    private func handleReachTop() {
        // 下拉刷新：完全重新加载数据
        refreshData()
    }
    
    private func handleReachBottom() {
        // 到达底部：加载更多数据
        if !isLoadingMore && !isRefreshing {
            loadMoreData()
        }
    }
    
    private func refreshData() {
        guard !isRefreshing && !isLoadingMore else { return }
        isRefreshing = true
        refreshCount += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 完全重新加载数据 - 这是推荐的做法
            currentPage = 1
            loadMoreCount = 0
            items = generateItemsForPage(1)
            isRefreshing = false
        }
    }
    
    private func loadMoreData() {
        guard !isLoadingMore && !isRefreshing else { return }
        isLoadingMore = true
        loadMoreCount += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 在底部添加新数据 - 这不会破坏懒加载的索引
            currentPage += 1
            let newItems = generateItemsForPage(currentPage)
            items.append(contentsOf: newItems)
            isLoadingMore = false
        }
    }
    
    // MARK: - 辅助方法
    
    private func generateItemsForPage(_ page: Int) -> [DemoItem] {
        let startId = (page - 1) * 10 + 1
        let endId = page * 10
        return (startId...endId).map { DemoItem(id: $0) }
    }
    
    private func getPageForItem(_ itemId: Int) -> Int {
        return (itemId - 1) / 10 + 1
    }
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("真实刷新场景") {
    NavigationView {
        RealWorldRefreshExample()
    }
}
