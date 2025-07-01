//
// Copyright (c) Beyoug
//

import SwiftUI

/// 演示回调机制在真实数据驱动场景中的工作情况
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct CallbackDemoExample: View {
    
    // MARK: - 状态管理
    
    @State private var items: [DemoItem] = []
    @State private var visibleRange: String = "无"
    @State private var reachTopCount = 0
    @State private var reachBottomCount = 0
    @State private var isLoading = false
    @State private var callbackHistory: [String] = []
    @State private var totalItemsLoaded = 0
    @State private var nextId = 1 // 用于生成唯一ID
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            // 状态面板
            statusPanel
            
            // 主要内容
            mainContent
        }
        .navigationTitle("回调机制演示")
        .onAppear {
            loadInitialData()
        }
    }
    
    // MARK: - 子视图
    
    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("数据驱动回调演示")
                    .font(.headline)
                Spacer()
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            Group {
                Text("总项目数: \(totalItemsLoaded)")
                Text("可见范围: \(visibleRange)")
                Text("到达顶部: \(reachTopCount)次")
                Text("到达底部: \(reachBottomCount)次")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if !callbackHistory.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(callbackHistory.suffix(5), id: \.self) { event in
                            Text(event)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
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
                    Text("H: \(Int(item.height))")
                        .font(.caption2)
                }
                .foregroundColor(.white)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - 回调处理
    
    private func handleVisibleRangeChanged(_ range: Range<Array<DemoItem>.Index>) {
        let startIdx = range.lowerBound
        let endIdx = range.upperBound
        visibleRange = "\(startIdx)..<\(endIdx)"
        
        let event = "可见: \(startIdx)..<\(endIdx)"
        addCallbackEvent(event)
        
        // 模拟基于可见范围的业务逻辑
        if endIdx > items.count - 5 && !isLoading {
            // 接近底部时预加载更多数据
            loadMoreData()
        }
    }
    
    private func handleReachTop() {
        reachTopCount += 1
        addCallbackEvent("到达顶部")

        // 注意：真实的下拉刷新会在顶部插入数据，但这会破坏懒加载的索引
        // 在生产环境中，建议使用完全重新加载的方式
        if !isLoading {
            showRefreshAlert()
        }
    }

    private func showRefreshAlert() {
        // 在真实应用中，这里可以显示一个提示，询问用户是否要刷新
        // 或者直接重新加载数据
        refreshDataWithReload()
    }

    private func refreshDataWithReload() {
        guard !isLoading else { return }
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 完全重新加载数据，这样不会破坏懒加载的索引关系
            let newItemCount = items.count + 5
            items = (1...newItemCount).map { DemoItem(id: $0) }
            nextId = newItemCount + 1
            totalItemsLoaded = items.count
            isLoading = false
            addCallbackEvent("数据已刷新，新增5个项目")
        }
    }
    
    private func handleReachBottom() {
        reachBottomCount += 1
        addCallbackEvent("到达底部")
        
        // 模拟加载更多
        if !isLoading {
            loadMoreData()
        }
    }
    
    private func addCallbackEvent(_ event: String) {
        let timestamp = DateFormatter.timeFormatter.string(from: Date())
        let eventWithTime = "\(timestamp): \(event)"
        callbackHistory.append(eventWithTime)
        
        // 保持历史记录在合理范围内
        if callbackHistory.count > 20 {
            callbackHistory.removeFirst()
        }
    }
    
    // MARK: - 数据操作
    
    private func loadInitialData() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            items = (1...20).map { DemoItem(id: $0) }
            nextId = 21 // 设置下一个可用ID
            totalItemsLoaded = items.count
            isLoading = false
            addCallbackEvent("初始数据加载完成")
        }
    }
    
    private func loadMoreData() {
        guard !isLoading else { return }
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let newItems = (nextId..<nextId + 10).map { DemoItem(id: $0) }
            items.append(contentsOf: newItems)
            nextId += 10
            totalItemsLoaded = items.count
            isLoading = false
            addCallbackEvent("加载了\(newItems.count)个新项目")
        }
    }
    

}

// MARK: - 辅助扩展

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("回调机制演示") {
    NavigationView {
        CallbackDemoExample()
    }
}
