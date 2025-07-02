//
// Copyright (c) Beyoug
//

import SwiftUI

/// 分页加载演示示例
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PaginationDemoExample2: View {
    
    // MARK: - 状态管理
    
    @StateObject private var dataLoader = TestDataLoader(pageSize: 20)
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var showingFilters = false
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部控制栏
            topControlBar

            // 筛选栏（可选显示）
            if showingFilters {
                filterBar
            }

            // 主要内容 - 让LazyMasonryView自己管理空间
            mainContent
        }
        .navigationTitle("分页加载演示")
        .onAppear {
            if dataLoader.items.isEmpty {
                dataLoader.loadInitialData()
            }
        }
    }
    
    // MARK: - 子视图
    
    private var topControlBar: some View {
        VStack(spacing: 12) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索标题、描述或标签...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        dataLoader.search(query: searchText)
                    }
                
                if !searchText.isEmpty {
                    Button("清除") {
                        searchText = ""
                        dataLoader.loadInitialData()
                    }
                    .font(.caption)
                }
            }
            
            // 控制按钮
            HStack(spacing: 16) {
                Button(action: {
                    dataLoader.refresh()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("刷新")
                    }
                }
                .disabled(dataLoader.isLoading)
                
                Button(action: {
                    showingFilters.toggle()
                }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("筛选")
                    }
                }
                
                Spacer()
                
                // 状态信息
                VStack(alignment: .trailing, spacing: 2) {
                    Text("第 \(dataLoader.currentPage + 1)/\(max(dataLoader.totalPages, 1)) 页")
                        .font(.caption)
                    Text("共 \(dataLoader.totalItems) 项")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.bordered)
            .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 全部分类按钮
                Button("全部") {
                    selectedCategory = nil
                    dataLoader.filterByCategory(nil)
                }
                .buttonStyle(.bordered)
                .background(selectedCategory == nil ? Color.blue.opacity(0.2) : Color.clear)
                
                // 分类按钮
                ForEach(dataLoader.getAllCategories(), id: \.self) { category in
                    Button(category) {
                        selectedCategory = category
                        dataLoader.filterByCategory(category)
                    }
                    .buttonStyle(.bordered)
                    .background(selectedCategory == category ? Color.blue.opacity(0.2) : Color.clear)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
        .background(Color.gray.opacity(0.05))
    }
    
    private var mainContent: some View {
        ZStack {
            if dataLoader.items.isEmpty && !dataLoader.isLoading {
                emptyStateView
            } else {
                // 使用标准的SwiftUI LazyVGrid布局进行对比测试
                masonryView
            }

            // 错误提示
            if let error = dataLoader.error {
                VStack {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding()
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("暂无数据")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if !searchText.isEmpty || selectedCategory != nil {
                Button("清除筛选") {
                    searchText = ""
                    selectedCategory = nil
                    dataLoader.loadInitialData()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var masonryView: some View {
        // 使用标准的SwiftUI ScrollView + LazyVGrid替换LazyMasonryView
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(dataLoader.items, id: \.id) { item in
                    itemView(item)
                }

                // 分页加载触发器
                if dataLoader.hasNextPage && !dataLoader.isLoading {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            dataLoader.loadNextPage()
                        }
                }
            }
            .padding(.horizontal, 8)
        }
        .overlay(
            // 加载指示器覆盖层
            Group {
                if dataLoader.isLoading {
                    VStack {
                        Spacer()
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("加载中...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.9))
                        .cornerRadius(8)
                        .padding()
                    }
                }
            }
        )
    }
    
    private func itemView(_ item: TestDataItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 主要内容区域
            Rectangle()
                .fill(item.swiftUIColor.gradient)
                .frame(maxWidth: .infinity)
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
            
            // 文本信息
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(item.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // 标签
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("分页加载演示 - LazyVGrid对比") {
    NavigationView {
        PaginationDemoExample2()
    }
}
