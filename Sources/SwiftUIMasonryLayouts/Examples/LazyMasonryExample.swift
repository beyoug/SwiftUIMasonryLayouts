//
// Copyright (c) Beyoug
//

import SwiftUI

/// 智能瀑布流示例
/// 🎯 展示懒加载瀑布流的分页加载功能（垂直和水平轴向）
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct LazyMasonryExample: View {

    @StateObject private var verticalDataLoader = TestDataLoader(pageSize: 10)
    @StateObject private var horizontalDataLoader = TestDataLoader(pageSize: 8)
    @State private var verticalLoadCount = 0
    @State private var horizontalLoadCount = 0
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // 标签选择器
            tabSelector

            // 内容区域
            TabView(selection: $selectedTab) {
                // 垂直布局测试
                verticalLayoutView
                    .tag(0)

                // 水平布局测试
                horizontalLayoutView
                    .tag(1)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
        }
        .navigationTitle("懒加载瀑布流")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - 标签选择器

    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                VStack(spacing: 4) {
                    Image(systemName: "rectangle.grid.2x2")
                    Text("垂直布局")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            Button(action: { selectedTab = 1 }) {
                VStack(spacing: 4) {
                    Image(systemName: "rectangle.grid.2x2")
                        .rotationEffect(.degrees(90))
                    Text("水平布局")
                        .font(.caption)
                }
                .foregroundColor(selectedTab == 1 ? .blue : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - 垂直布局视图

    private var verticalLayoutView: some View {
        VStack(spacing: 16) {
            // 垂直布局状态面板
            verticalStatusPanel

            Divider()

            // 🚀 垂直懒加载瀑布流 - 滚动60%触发加载
            LazyMasonryStack(
                verticalDataLoader.items,
                columns: 2,
                spacing: 8
            ) { item in
                smartItemView(item)
            }
            .onReachBottom {
                verticalLoadCount += 1
                let timestamp = DateFormatter.timeFormatter.string(from: Date())
                MasonryLogger.info("[\(timestamp)] 垂直布局滚动到底部触发 #\(verticalLoadCount)")
                MasonryLogger.debug("状态: hasNextPage=\(verticalDataLoader.hasNextPage), isLoading=\(verticalDataLoader.isLoading)")
                MasonryLogger.debug("页面: \(verticalDataLoader.currentPage + 1)/\(verticalDataLoader.totalPages), 项目数: \(verticalDataLoader.items.count)/\(verticalDataLoader.totalItems)")

                if verticalDataLoader.hasNextPage && !verticalDataLoader.isLoading {
                    MasonryLogger.info("开始加载垂直布局第 \(verticalDataLoader.currentPage + 1) 页...")
                    verticalDataLoader.loadNextPage()
                } else {
                    MasonryLogger.debug("跳过垂直布局加载")
                    if !verticalDataLoader.hasNextPage {
                        MasonryLogger.debug("原因: 已到达最后一页")
                    }
                    if verticalDataLoader.isLoading {
                        MasonryLogger.debug("原因: 正在加载中")
                    }
                }
            }
        }
        .onAppear {
            MasonryLogger.info("垂直布局瀑布流视图出现，开始初始化")
            MasonryLogger.debug("当前数据状态: items=\(verticalDataLoader.items.count), isLoading=\(verticalDataLoader.isLoading)")
            if verticalDataLoader.items.isEmpty {
                MasonryLogger.info("开始加载垂直布局初始数据...")
                verticalDataLoader.loadInitialData()
            } else {
                MasonryLogger.debug("垂直布局数据已存在，跳过初始化")
            }
        }
        .onChange(of: verticalDataLoader.items.count) { oldCount, newCount in
            MasonryLogger.debug("垂直布局数据加载完成: \(oldCount) → \(newCount) 项")
        }
        .padding()
    }

    // MARK: - 水平布局视图

    private var horizontalLayoutView: some View {
        VStack(spacing: 16) {
            // 水平布局状态面板
            horizontalStatusPanel

            Divider()

            // 🚀 水平懒加载瀑布流 - 滚动60%触发加载
            LazyMasonryStack(
                horizontalDataLoader.items,
                rows: 3,
                spacing: 12
            ) { item in
                horizontalItemView(item)
            }
            .onReachBottom {
                horizontalLoadCount += 1
                let timestamp = DateFormatter.timeFormatter.string(from: Date())
                MasonryLogger.info("[\(timestamp)] 水平布局滚动到底部触发 #\(horizontalLoadCount)")
                MasonryLogger.debug("状态: hasNextPage=\(horizontalDataLoader.hasNextPage), isLoading=\(horizontalDataLoader.isLoading)")
                MasonryLogger.debug("页面: \(horizontalDataLoader.currentPage + 1)/\(horizontalDataLoader.totalPages), 项目数: \(horizontalDataLoader.items.count)/\(horizontalDataLoader.totalItems)")

                if horizontalDataLoader.hasNextPage && !horizontalDataLoader.isLoading {
                    MasonryLogger.info("开始加载水平布局第 \(horizontalDataLoader.currentPage + 1) 页...")
                    horizontalDataLoader.loadNextPage()
                } else {
                    MasonryLogger.debug("跳过水平布局加载")
                    if !horizontalDataLoader.hasNextPage {
                        MasonryLogger.debug("原因: 已到达最后一页")
                    }
                    if horizontalDataLoader.isLoading {
                        MasonryLogger.debug("原因: 正在加载中")
                    }
                }
            }
        }
        .onAppear {
            MasonryLogger.info("水平布局瀑布流视图出现，开始初始化")
            MasonryLogger.debug("当前数据状态: items=\(horizontalDataLoader.items.count), isLoading=\(horizontalDataLoader.isLoading)")
            if horizontalDataLoader.items.isEmpty {
                MasonryLogger.info("开始加载水平布局初始数据...")
                horizontalDataLoader.loadInitialData()
            } else {
                MasonryLogger.debug("水平布局数据已存在，跳过初始化")
            }
        }
        .onChange(of: horizontalDataLoader.items.count) { oldCount, newCount in
            MasonryLogger.debug("水平布局数据加载完成: \(oldCount) → \(newCount) 项")
        }
        .padding()
    }

    // MARK: - 状态面板

    private var verticalStatusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("垂直布局状态")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前页: \(verticalDataLoader.currentPage + 1)/\(verticalDataLoader.totalPages)")
                    Text("项目数: \(verticalDataLoader.items.count)/\(verticalDataLoader.totalItems)")
                    Text("回调次数: \(verticalLoadCount)")
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("有下一页: \(verticalDataLoader.hasNextPage ? "是" : "否")")
                    Text("加载中: \(verticalDataLoader.isLoading ? "是" : "否")")
                    Text("轴向: 垂直 (列布局)")
                }
            }
            .font(.caption)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // 手动控制
            HStack {
                Button("重置") {
                    MasonryLogger.info("重置垂直布局瀑布流数据")
                    verticalDataLoader.loadInitialData()
                    verticalLoadCount = 0
                }

                Spacer()

                Text("特性: 滚动60%触发加载")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }

    private var horizontalStatusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("水平布局状态")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前页: \(horizontalDataLoader.currentPage + 1)/\(horizontalDataLoader.totalPages)")
                    Text("项目数: \(horizontalDataLoader.items.count)/\(horizontalDataLoader.totalItems)")
                    Text("回调次数: \(horizontalLoadCount)")
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("有下一页: \(horizontalDataLoader.hasNextPage ? "是" : "否")")
                    Text("加载中: \(horizontalDataLoader.isLoading ? "是" : "否")")
                    Text("轴向: 水平 (3行布局)")
                }
            }
            .font(.caption)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // 手动控制
            HStack {
                Button("重置") {
                    MasonryLogger.info("重置水平布局瀑布流数据")
                    horizontalDataLoader.loadInitialData()
                    horizontalLoadCount = 0
                }

                Spacer()

                Text("特性: 滚动60%触发加载")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
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

            Text(item.title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.leading)
                .opacity(0.9)
                .fixedSize(horizontal: false, vertical: true)

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
        .fixedSize(horizontal: false, vertical: true)
    }

    /// 水平布局专用项目视图
    private func horizontalItemView(_ item: TestDataItem) -> some View {
        HStack(spacing: 12) {
            // 左侧图标
            RoundedRectangle(cornerRadius: 8)
                .fill(item.swiftUIColor.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    VStack(spacing: 2) {
                        Text("\(item.id)")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text(item.category)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundColor(.primary)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                HStack {
                    if !item.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(item.tags.prefix(2), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(item.swiftUIColor.opacity(0.2))
                                    .cornerRadius(6)
                            }
                        }
                    }

                    Spacer()

                    Text("H: \(item.height)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(minHeight: 80) // 设置合适的高度范围
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(item.swiftUIColor.opacity(0.2))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
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
