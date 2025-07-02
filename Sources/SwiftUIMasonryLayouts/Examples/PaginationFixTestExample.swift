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
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 🎯 关键：强制占用所有可用空间
        }
        .navigationTitle("垂直轴向分页")
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
                Button("重置") {
                    print("🔄 重置数据")
                    dataLoader.loadInitialData()
                    loadCount = 0
                    lastLoadTime = Date()
                }

                Spacer()

                Text("期望: 自动连续加载")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func itemView(_ item: TestDataItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 头部信息
            HStack {
                Text("#\(item.id)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(4)

                Spacer()

                Text(item.category)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(3)
            }

            // 标题
            Text(item.title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // 描述
            Text(item.description)
                .font(.caption)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .opacity(0.9)

            // 标签
            if !item.tags.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 50), spacing: 4)
                ], spacing: 4) {
                    ForEach(item.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(3)
                            .lineLimit(1)
                    }
                }
            }

            // 底部信息
            HStack {
                Text("页面 \((item.id - 1) / 10 + 1)")
                    .font(.caption2)
                    .opacity(0.7)

                Spacer()

                Text("高度: \(item.height)")
                    .font(.caption2)
                    .opacity(0.7)
            }
        }
        .padding(12)
        .frame(height: item.cgHeight)
        .background(item.swiftUIColor.gradient)
        .foregroundColor(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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
#Preview("垂直轴向分页测试") {
    NavigationView {
        PaginationFixTestExample()
    }
}
