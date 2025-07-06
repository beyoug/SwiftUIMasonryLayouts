//
// Copyright (c) Beyoug
//

import SwiftUI

/// 示例预览
/// 🎯 展示完整的滚动体验：下拉刷新 + 底部加载
@available(iOS 18.0, *)
struct ExamplePreview: View {
    
    @StateObject private var dataLoader = SampleDataLoader(pageSize: 6)
    @State private var loadCount = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 状态信息
                statusPanel
                
                Divider()
                
                // 瀑布流布局
                LazyMasonryStack(
                    dataLoader.items,
                    columns: 2,
                    spacing: 12
                ) { item in
                    itemView(item)
                }
                .onReachBottom {
                    loadCount += 1
                    if dataLoader.hasNextPage && !dataLoader.isLoading {
                        dataLoader.loadNextPage()
                    }
                }
                .refreshable {
                    await withCheckedContinuation { continuation in
                        dataLoader.refresh()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            continuation.resume()
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("SwiftUI Masonry")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if dataLoader.items.isEmpty {
                dataLoader.loadInitialData()
            }
        }
    }
    
    // MARK: - 状态面板
    
    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("瀑布流演示")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("页面: \(dataLoader.currentPage + 1)/\(dataLoader.totalPages)")
                    Text("项目: \(dataLoader.items.count)/\(dataLoader.totalItems)")
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("加载: \(dataLoader.isLoading ? "是" : "否")")
                    Text("回调: \(loadCount)次")
                }
            }
            .font(.caption)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Text("✨ 下拉刷新 + 底部加载")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - 项目视图

    private func itemView(_ item: SampleDataItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图片
            AsyncImage(url: URL(string: item.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(item.themeColor.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
            .frame(height: CGFloat.random(in: 120...200))
            .clipped()
            .cornerRadius(8)

            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                HStack {
                    Text(item.type)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.themeColor.opacity(0.2))
                        .cornerRadius(4)

                    Spacer()

                    Text("#\(item.id)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 预览

@available(iOS 18.0, *)
#Preview {
    ExamplePreview()
}
