//
// Copyright (c) Beyoug
//

import SwiftUI

/// 瀑布流布局示例
/// 🎯 展示懒加载瀑布流的分页加载功能（垂直和水平轴向）
@available(iOS 18.0, *)
public struct LazyMasonryExample: View {

    @StateObject private var verticalDataLoader = SampleDataLoader(pageSize: 10)
    @StateObject private var horizontalDataLoader = SampleDataLoader(pageSize: 8)
    @State private var verticalLoadCount = 0
    @State private var horizontalLoadCount = 0
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
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
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Masonry Layout Demo")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 标签选择器

    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                VStack(spacing: 4) {
                    Image(systemName: "rectangle.grid.2x2")
                    Text("Vertical")
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
                    Text("Horizontal")
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

            // 🚀 Vertical lazy masonry layout - triggers loading at 60% scroll
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
                MasonryLogger.info("[\(timestamp)] Vertical layout reached bottom trigger #\(verticalLoadCount)")
                MasonryLogger.debug("State: hasNextPage=\(verticalDataLoader.hasNextPage), isLoading=\(verticalDataLoader.isLoading)")
                MasonryLogger.debug("Page: \(verticalDataLoader.currentPage + 1)/\(verticalDataLoader.totalPages), Items: \(verticalDataLoader.items.count)/\(verticalDataLoader.totalItems)")

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
    
    /// 精美的数据卡片视图 - 支持图片、主题色和丰富内容
    private func smartItemView(_ item: SampleDataItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片区域 - 动态高度瀑布流效果
            let imageHeight = CGFloat(120 + (item.id * 13) % 80) // 120-200px 动态高度范围
            AsyncImage(url: URL(string: item.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: imageHeight)
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

    /// 水平布局精美卡片视图 - 紧凑型设计
    private func horizontalItemView(_ item: SampleDataItem) -> some View {
        HStack(spacing: 12) {
            // 左侧图片
            AsyncImage(url: URL(string: item.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(12)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.themeColor.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: item.typeIcon)
                                .font(.title2)
                                .foregroundColor(item.themeColor)
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(item.themeColor)
                        }
                    )
            }
            .overlay(
                // ID标签
                VStack {
                    HStack {
                        Text("\(item.id)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(item.themeColor)
                            .cornerRadius(6)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(4)
            )

            // 右侧内容
            VStack(alignment: .leading, spacing: 6) {
                // 类型和标题
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: item.typeIcon)
                            .font(.caption)
                            .foregroundColor(item.themeColor)
                        Text(item.type)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(item.themeColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(item.themeColor.opacity(0.1))
                    .cornerRadius(8)

                    Spacer()
                }

                Text(item.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                // 底部标签和互动
                HStack {
                    if !item.metadata.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(item.metadata.prefix(2), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(item.themeColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(item.themeColor.opacity(0.15))
                                    .cornerRadius(6)
                            }
                        }
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundColor(.red)
                            Text("\(item.id * 2 + 8)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 2) {
                            Image(systemName: "eye.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text("\(item.id * 5 + 20)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(height: 120)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.themeColor.opacity(0.2), lineWidth: 1)
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

@available(iOS 18.0, *)
#Preview("Masonry Layout Demo") {
    NavigationView {
        LazyMasonryExample()
    }
}
