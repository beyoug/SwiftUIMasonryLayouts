//
// Copyright (c) Beyoug
//

import SwiftUI

/// 测试分页修复的示例
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PaginationFixTestExample: View {
    
    @StateObject private var dataLoader = TestDataLoader(pageSize: 10)
    @State private var loadCount = 0
    @State private var lastLoadTime = Date()
    @State private var forceRefresh = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 状态面板
            statusPanel
            
            Divider()
            
            // 瀑布流内容
            LazyMasonryStack(dataLoader.items, configuration: .columns(2)) { item in
                itemView(item)
            }
            .onReachBottom {
                loadCount += 1
                lastLoadTime = Date()

                let timestamp = DateFormatter.timeFormatter.string(from: Date())
                print("🎯 [\(timestamp)] 底部回调 #\(loadCount)")
                print("   📊 状态: hasNextPage=\(dataLoader.hasNextPage), isLoading=\(dataLoader.isLoading)")
                print("   📄 页面: \(dataLoader.currentPage + 1)/\(dataLoader.totalPages), 项目数: \(dataLoader.items.count)/\(dataLoader.totalItems)")

                if dataLoader.hasNextPage && !dataLoader.isLoading {
                    print("✅ 开始加载第 \(dataLoader.currentPage + 1) 页...")
                    dataLoader.loadNextPage()
                } else {
                    print("❌ 跳过加载")
                    if !dataLoader.hasNextPage {
                        print("   🏁 原因: 已到达最后一页")
                    }
                    if dataLoader.isLoading {
                        print("   ⏳ 原因: 正在加载中")
                    }
                }
            }
        }
        .navigationTitle("分页修复测试")
        .onAppear {
            print("🏗️ 视图出现，开始初始化")
            if dataLoader.items.isEmpty {
                dataLoader.loadInitialData()
            }
        }
    }
    
    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("分页状态")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前页: \(dataLoader.currentPage + 1)/\(dataLoader.totalPages)")
                    Text("项目数: \(dataLoader.items.count)/\(dataLoader.totalItems)")
                    Text("回调次数: \(loadCount)")
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("有下一页: \(dataLoader.hasNextPage ? "是" : "否")")
                    Text("加载中: \(dataLoader.isLoading ? "是" : "否")")
                    Text("最后加载: \(timeAgo(lastLoadTime))")
                }
            }
            .font(.caption)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // 手动控制
            HStack {
                Button("手动加载") {
                    print("🔘 手动触发加载")
                    dataLoader.loadNextPage()
                }
                .disabled(!dataLoader.hasNextPage || dataLoader.isLoading)
                
                Button("重置") {
                    print("🔄 重置数据")
                    dataLoader.loadInitialData()
                    loadCount = 0
                    lastLoadTime = Date()
                }

                Button("调试刷新") {
                    print("🔄 调试：强制刷新UI（会重置滚动位置）")
                    forceRefresh.toggle()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("期望: 自动连续加载")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("刷新ID: \(forceRefresh ? "1" : "0")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func itemView(_ item: TestDataItem) -> some View {
        Rectangle()
            .fill(item.swiftUIColor.gradient)
            .frame(height: item.cgHeight)
            .overlay(
                VStack(spacing: 2) {
                    Text("#\(item.id)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("页面 \((item.id - 1) / 10 + 1)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            )
            .cornerRadius(8)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "\(Int(interval))秒前"
        } else {
            return "\(Int(interval / 60))分钟前"
        }
    }
}

// MARK: - 扩展

private extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("分页修复测试") {
    NavigationView {
        PaginationFixTestExample()
    }
}
