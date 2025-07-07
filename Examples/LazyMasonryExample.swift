//
// Copyright (c) Beyoug
//

import SwiftUI

/// 瀑布流布局示例
/// 展示懒加载瀑布流的完整滚动体验：
/// - 垂直布局：下拉刷新 + 底部加载（使用系统refreshable + onReachBottom）
/// - 水平布局：右滑加载更多（使用onReachBottom）
/// - 双轴向布局演示
@available(iOS 18.0, *)
public struct LazyMasonryExample: View {

    @StateObject private var verticalDataLoader = SampleDataLoader(pageSize: 10)
    @StateObject private var horizontalDataLoader = SampleDataLoader(pageSize: 8)
    @State private var verticalLoadTriggerCount = 0
    @State private var horizontalLoadTriggerCount = 0
    @State private var selectedTabIndex = 0

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // 标签选择器
            tabSelectorView

            // 内容区域
            TabView(selection: $selectedTabIndex) {
                // 垂直布局测试
                verticalLayoutView
                    .tag(0)

                // 水平布局测试
                horizontalLayoutView
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Masonry Layout Demo")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Tab Selector

    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTabIndex = 0 }) {
                VStack(spacing: 4) {
                    Image(systemName: "rectangle.grid.2x2")
                    Text("Vertical")
                        .font(.caption)
                }
                .foregroundColor(selectedTabIndex == 0 ? .blue : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            Button(action: { selectedTabIndex = 1 }) {
                VStack(spacing: 4) {
                    Image(systemName: "rectangle.grid.2x2")
                        .rotationEffect(.degrees(90))
                    Text("Horizontal")
                        .font(.caption)
                }
                .foregroundColor(selectedTabIndex == 1 ? .blue : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Vertical Layout

    private var verticalLayoutView: some View {
        VStack(spacing: 16) {
            // 垂直布局状态面板
            verticalStatusPanelView

            Divider()

            // 垂直懒加载瀑布流 - 支持下拉刷新、底部加载和Footer
            LazyMasonryStack(
                verticalDataLoader.items,
                columns: 2,
                spacing: 8
            ) { item in
                verticalItemView(item)
            }
            .footer {
                // Footer示例：显示加载状态
                verticalLoadingFooterView
            }
            .onReachBottom {
                verticalLoadTriggerCount += 1
                MasonryLogger.info("垂直布局触发底部加载 #\(verticalLoadTriggerCount)")

                if verticalDataLoader.hasNextPage && !verticalDataLoader.isLoading {
                    MasonryLogger.info("加载垂直布局第 \(verticalDataLoader.currentPage + 1) 页")
                    verticalDataLoader.loadNextPage()
                }
            }
            .refreshable {
                MasonryLogger.info("垂直布局触发下拉刷新")
                await withCheckedContinuation { continuation in
                    verticalDataLoader.refresh()
                    // 模拟网络延迟
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        continuation.resume()
                    }
                }
            }
        }
        .onAppear {
            if verticalDataLoader.items.isEmpty {
                MasonryLogger.info("初始化垂直布局数据")
                verticalDataLoader.loadInitialData()
            }
        }
        .onChange(of: verticalDataLoader.items.count) { oldCount, newCount in
            MasonryLogger.debug("垂直布局数据加载完成: \(oldCount) → \(newCount) 项")
        }
        .padding()
    }

    // MARK: - Horizontal Layout

    private var horizontalLayoutView: some View {
        VStack(spacing: 16) {
            // 水平布局状态面板
            horizontalStatusPanelView

            Divider()

            // 水平懒加载瀑布流 - 支持右滑加载更多和Footer
            LazyMasonryStack(
                horizontalDataLoader.items,
                rows: 2,
                spacing: 16
            ) { item in
                horizontalItemView(item)
            }
            .footer {
                // Footer示例：水平布局的右侧状态显示
                horizontalLoadingFooterView
            }
            .onReachBottom {
                horizontalLoadTriggerCount += 1
                MasonryLogger.info("水平布局触发右侧加载 #\(horizontalLoadTriggerCount)")

                if horizontalDataLoader.hasNextPage && !horizontalDataLoader.isLoading {
                    MasonryLogger.info("加载水平布局第 \(horizontalDataLoader.currentPage + 1) 页")
                    horizontalDataLoader.loadNextPage()
                }
            }
        }
        .onAppear {
            if horizontalDataLoader.items.isEmpty {
                MasonryLogger.info("初始化水平布局数据")
                horizontalDataLoader.loadInitialData()
            }
        }
        .padding()
    }

    // MARK: - Status Panels

    private var verticalStatusPanelView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("垂直布局状态")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前页: \(verticalDataLoader.currentPage + 1)/\(verticalDataLoader.totalPages)")
                    Text("项目数: \(verticalDataLoader.items.count)/\(verticalDataLoader.totalItems)")
                    Text("回调次数: \(verticalLoadTriggerCount)")
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
                    verticalLoadTriggerCount = 0
                }

                Spacer()

                Text("特性: 下拉刷新 + 底部加载")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }

    private var horizontalStatusPanelView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("水平布局状态")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前页: \(horizontalDataLoader.currentPage + 1)/\(horizontalDataLoader.totalPages)")
                    Text("项目数: \(horizontalDataLoader.items.count)/\(horizontalDataLoader.totalItems)")
                    Text("回调次数: \(horizontalLoadTriggerCount)")
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("有下一页: \(horizontalDataLoader.hasNextPage ? "是" : "否")")
                    Text("加载中: \(horizontalDataLoader.isLoading ? "是" : "否")")
                    Text("轴向: 水平 (2行紧凑布局)")
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
                    horizontalLoadTriggerCount = 0
                }

                Button("刷新") {
                    MasonryLogger.info("手动刷新水平布局数据")
                    horizontalDataLoader.refresh()
                }

                Spacer()

                Text("特性: 右滑加载 + 图片浮动 + 紧凑布局")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Item Views

    /// 垂直布局数据卡片视图 - 支持图片、主题色和丰富内容
    private func verticalItemView(_ item: SampleDataItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片区域 - 动态高度瀑布流效果
            let imageHeight = CGFloat(120 + (item.id * 13) % 80) // 120-200px 动态高度范围
            AsyncImage(url: URL(string: item.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 280)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(item.themeColor.opacity(0.3))
                    .frame(height: imageHeight)
                    .overlay(
                        ProgressView()
                            .tint(item.themeColor)
                    )
            }
            .overlay(
                // 类型标签
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: item.typeIcon)
                                .font(.caption2)
                            Text(item.type)
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.themeColor.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                    }
                    Spacer()
                }
                .padding(8)
            )

            // 内容区域
            VStack(alignment: .leading, spacing: 8) {
                // 标题 - 限制一行
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                // 副标题 - 限制两行
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)

                // 标签区域 - 水平滚动确保单行显示
                if !item.metadata.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(item.metadata, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(item.themeColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(item.themeColor.opacity(0.1))
                                    .cornerRadius(8)
                                    .fixedSize()
                            }
                        }
                        .padding(.horizontal, 2) // 防止边缘裁切
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // 限制滚动视图宽度
                }

                // 底部信息
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "number")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(item.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.caption2)
                            .foregroundColor(.red)
                        Text("\(item.id * 3 + 12)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
            }
            .padding(12)
        }
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.themeColor.opacity(0.2), lineWidth: 1)
        )
    }

    /// 水平布局图片卡片视图 - 纯图片展示，内容描述浮动在图片上
    private func horizontalItemView(_ item: SampleDataItem) -> some View {
        // 图片区域 - 内容描述浮动在图片上
        AsyncImage(url: URL(string: item.imageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 200)
                .clipped()
                .cornerRadius(12)
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(item.themeColor.opacity(0.2))
                .frame(maxWidth: 200)
                .aspectRatio(1.2, contentMode: .fit)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: item.typeIcon)
                            .font(.title)
                            .foregroundColor(item.themeColor)
                        ProgressView()
                            .scaleEffect(0.9)
                            .tint(item.themeColor)
                        Text("加载中...")
                            .font(.caption)
                            .foregroundColor(item.themeColor)
                    }
                )
        }
        .overlay(
            // 浮动在图片上的内容描述
            VStack {
                // 顶部：ID标签
                HStack {
                    Text("\(item.id)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(item.themeColor.opacity(0.9))
                        .cornerRadius(6)

                    Spacer()

                    // 类型标签
                    HStack(spacing: 3) {
                        Image(systemName: item.typeIcon)
                            .font(.caption2)
                        Text(item.type)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(6)
                }

                Spacer()

                // 底部：内容描述浮动显示
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.8), radius: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .padding(6)
        )

        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    // MARK: - Footer Views

    /// 垂直布局Footer视图 - 显示加载状态
    private var verticalLoadingFooterView: some View {
        HStack(spacing: 8) {
            if verticalDataLoader.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                Text("正在加载更多内容...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if !verticalDataLoader.hasNextPage {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("已加载全部内容，共 \(verticalDataLoader.items.count) 项")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "arrow.up.circle")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text("继续滚动加载更多")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }

    /// 水平布局Footer视图 - 显示加载状态
    private var horizontalLoadingFooterView: some View {
        VStack(spacing: 4) {
            if horizontalDataLoader.isLoading {
                ProgressView()
                    .scaleEffect(0.7)
                Text("加载中")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else if !horizontalDataLoader.hasNextPage {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
                Text("完成")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "arrow.right.circle")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text("右滑")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
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

@available(iOS 18.0, *)
#Preview("Masonry Layout Demo") {
    NavigationView {
        LazyMasonryExample()
    }
}
