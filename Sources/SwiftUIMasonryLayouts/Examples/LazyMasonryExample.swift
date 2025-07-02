//
// Copyright (c) Beyoug
//

import SwiftUI

/// 智能瀑布流示例
/// 🎯 展示懒加载瀑布流的分页加载功能
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct LazyMasonryExample: View {
    
    @StateObject private var dataLoader = TestDataLoader(pageSize: 10)
    @State private var loadCount = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // 状态面板
            statusPanel
            
            Divider()
            
            // 🚀 懒加载瀑布流 - 滚动60%触发加载
            LazyMasonryStack(
                dataLoader.items,
                columns: 2,
                spacing: 8
            ) { item in
                smartItemView(item)
            }

            .onReachBottom {
                // 🎯 滚动到底部回调 - 标准的分页加载
                loadCount += 1

                let timestamp = DateFormatter.timeFormatter.string(from: Date())
                MasonryLogger.info("[\(timestamp)] 滚动到底部触发 #\(loadCount)")
                MasonryLogger.debug("状态: hasNextPage=\(dataLoader.hasNextPage), isLoading=\(dataLoader.isLoading)")
                MasonryLogger.debug("页面: \(dataLoader.currentPage + 1)/\(dataLoader.totalPages), 项目数: \(dataLoader.items.count)/\(dataLoader.totalItems)")

                if dataLoader.hasNextPage && !dataLoader.isLoading {
                    MasonryLogger.info("开始加载第 \(dataLoader.currentPage + 1) 页...")
                    dataLoader.loadNextPage()
                } else {
                    MasonryLogger.debug("跳过加载")
                    if !dataLoader.hasNextPage {
                        MasonryLogger.debug("原因: 已到达最后一页")
                    }
                    if dataLoader.isLoading {
                        MasonryLogger.debug("原因: 正在加载中")
                    }
                }
            }

        }
        .navigationTitle("懒加载瀑布流")
        .padding(.horizontal)
        .onAppear {
            MasonryLogger.info("智能瀑布流视图出现，开始初始化")
            MasonryLogger.debug("当前数据状态: items=\(dataLoader.items.count), isLoading=\(dataLoader.isLoading)")
            if dataLoader.items.isEmpty {
                MasonryLogger.info("开始加载初始数据...")
                dataLoader.loadInitialData()
            } else {
                MasonryLogger.debug("数据已存在，跳过初始化")
            }
        }
        .onChange(of: dataLoader.items.count) { oldCount, newCount in
            MasonryLogger.debug("数据加载完成: \(oldCount) → \(newCount) 项")
        }
    }
    
    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("懒加载瀑布流状态")
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
                    Text("显示: 全部已加载数据")
                }
            }
            .font(.caption)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // 手动控制
            HStack {
                Button("重置") {
                    MasonryLogger.info("重置懒加载瀑布流数据")
                    dataLoader.loadInitialData()
                    loadCount = 0
                }

                Spacer()

                Text("特性: 滚动60%触发加载")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
    }
    
    /// 智能项目视图 - 真正的内容自适应
    private func smartItemView(_ item: TestDataItem) -> some View {
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

            // 标题 - 完全自适应，无行数限制
            Text(item.title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                // 🎯 关键：让文本完全自适应
                .fixedSize(horizontal: false, vertical: true)

            // 描述 - 完全自适应，无行数限制
            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.leading)
                .opacity(0.9)
                // 🎯 关键：让文本完全自适应
                .fixedSize(horizontal: false, vertical: true)

            // 标签 - 自适应布局
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
                Text("页面 \((item.id - 1) / 15 + 1)")
                    .font(.caption2)
                    .opacity(0.7)

                Spacer()

                Text("智能自适应")
                    .font(.caption2)
                    .opacity(0.7)
            }
        }
        .padding(12)
        .background(item.swiftUIColor.gradient)
        .foregroundColor(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        // 🎯 关键：让整个视图完全自适应
        .fixedSize(horizontal: false, vertical: true)
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
#Preview("懒加载瀑布流") {
    NavigationView {
        LazyMasonryExample()
    }
}
