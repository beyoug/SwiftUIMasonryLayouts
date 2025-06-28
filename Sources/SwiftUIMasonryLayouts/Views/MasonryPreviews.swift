//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 预览数据模型

/// 预览项目数据模型
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PreviewItem: Identifiable, Sendable {
    /// 唯一标识符
    let id: Int
    /// 标题
    let title: String
    /// 颜色
    let color: Color
    /// 高度
    let height: CGFloat

    /// 初始化预览项目
    /// - Parameters:
    ///   - id: 唯一标识符
    ///   - title: 标题，默认为"Item {id}"
    init(id: Int, title: String? = nil) {
        self.id = id
        self.title = title ?? "Item \(id)"
        self.color = Color.random
        self.height = CGFloat.random(in: 100...250)
    }
}

/// 预览数据生成器
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PreviewData {
    /// 生成指定数量的预览项目
    /// - Parameters:
    ///   - count: 项目数量
    ///   - startId: 起始ID，默认为0
    /// - Returns: 预览项目数组
    static func generateItems(count: Int, startId: Int = 0) -> [PreviewItem] {
        (0..<count).map { index in
            PreviewItem(id: startId + index)
        }
    }

    /// 示例数据（20个项目）
    static let sampleItems = generateItems(count: 20)
}

// MARK: - 预览组件

/// 预览项目卡片视图
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PreviewItemCard: View {
    /// 预览项目数据
    let item: PreviewItem
    /// 徽章文本
    let badge: String?

    /// 初始化预览卡片
    /// - Parameters:
    ///   - item: 预览项目数据
    ///   - badge: 徽章文本，可选
    init(item: PreviewItem, badge: String? = nil) {
        self.item = item
        self.badge = badge
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(item.color.gradient)
            .frame(height: item.height)
            .overlay(
                VStack {
                    if let badge = badge {
                        HStack {
                            Text(badge)
                                .font(.caption2)
                                .padding(4)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 8)
                    }
                    
                    Spacer()
                    
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                    
                    Spacer()
                }
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 基础瀑布流预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("基础瀑布流") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 12,
            verticalSpacing: 12
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "基础")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("三列布局") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(3),
            horizontalSpacing: 8,
            verticalSpacing: 8
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "三列")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("水平瀑布流") {
    ScrollView(.horizontal) {
        MasonryView(
            axis: .horizontal,
            lines: .fixed(2),
            horizontalSpacing: 10,
            verticalSpacing: 10
        ) {
            ForEach(PreviewData.sampleItems.prefix(12)) { item in
                PreviewItemCard(item: item, badge: "水平")
                    .frame(width: CGFloat.random(in: 120...200))
            }
        }
        .padding()
    }
}

// MARK: - 数据驱动预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动") {
    ScrollView {
        DataMasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 8,
            data: PreviewData.sampleItems,
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "数据驱动")
        }
        .padding()
    }
}

// MARK: - 自适应列数预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("自适应最小尺寸") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .adaptive(minSize: 120),
            horizontalSpacing: 8,
            verticalSpacing: 8
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "自适应最小")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("自适应最大尺寸") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .adaptive(maxSize: 180),
            horizontalSpacing: 8,
            verticalSpacing: 8
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "自适应最大")
            }
        }
        .padding()
    }
}

// MARK: - 懒加载预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("懒加载") {
    let largeDataSet = PreviewData.generateItems(count: 100)

    LazyMasonryView(
        axis: .vertical,
        lines: .fixed(2),
        horizontalSpacing: 8,
        verticalSpacing: 8,
        data: largeDataSet,
        id: \.id,
        estimatedItemSize: CGSize(width: 150, height: 200)
    ) { item in
        PreviewItemCard(item: item, badge: "懒加载")
    }
    .padding()
}

#Preview("虚拟化大数据集") {
    let largeDataSet = PreviewData.generateItems(count: 5000)

    NavigationView {
        LazyMasonryView(
            axis: .vertical,
            lines: .fixed(3),
            data: largeDataSet,
            id: \.id,
            estimatedItemSize: CGSize(width: 100, height: 150)
        ) { item in
            PreviewItemCard(item: item, badge: "Virtual")
        }
        .navigationTitle("虚拟化瀑布流 (5K项目)")
    }
}

// MARK: - 响应式设计预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("响应式设计") {
    ResponsiveMasonryView(breakpoints: MasonryConfiguration.commonBreakpoints) {
        ForEach(PreviewData.sampleItems) { item in
            PreviewItemCard(item: item, badge: "响应式")
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("自定义响应式") {
    ResponsiveMasonryView(breakpoints: [
        0: MasonryConfiguration(lines: .fixed(1)),
        400: MasonryConfiguration(lines: .fixed(2)),
        600: MasonryConfiguration(lines: .fixed(3)),
        800: MasonryConfiguration(lines: .fixed(4))
    ]) {
        ForEach(PreviewData.sampleItems) { item in
            PreviewItemCard(item: item, badge: "自定义响应")
        }
    }
    .padding()
}

// MARK: - 放置模式预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("填充模式") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 8,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleItems.prefix(10)) { item in
                PreviewItemCard(item: item, badge: "填充模式")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("顺序模式") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 8,
            placementMode: .order
        ) {
            ForEach(PreviewData.sampleItems.prefix(10)) { item in
                PreviewItemCard(item: item, badge: "顺序模式")
            }
        }
        .padding()
    }
}

// MARK: - 配置预设预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("单列布局") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(1),
            horizontalSpacing: 0,
            verticalSpacing: 12
        ) {
            ForEach(PreviewData.sampleItems.prefix(8)) { item in
                PreviewItemCard(item: item, badge: "单列")
            }
        }
        .padding()
    }
}

// MARK: - 边界情况预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("空数据集") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2)
        ) {
            // 空内容
        }
        .frame(height: 200)
        .background(Color.gray.opacity(0.1))
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("单个项目") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(3)
        ) {
            PreviewItemCard(
                item: PreviewItem(id: 1, title: "唯一项目"),
                badge: "单项"
            )
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("极小间距") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(4),
            horizontalSpacing: 1,
            verticalSpacing: 1
        ) {
            ForEach(PreviewData.generateItems(count: 12)) { item in
                PreviewItemCard(item: item, badge: "紧密")
                    .frame(height: 80)
            }
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("极大间距") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 50,
            verticalSpacing: 30
        ) {
            ForEach(PreviewData.generateItems(count: 6)) { item in
                PreviewItemCard(item: item, badge: "宽松")
                    .frame(height: 100)
            }
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("混合尺寸项目") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(3)
        ) {
            ForEach(0..<15) { index in
                let heights: [CGFloat] = [60, 120, 180, 240, 300]
                PreviewItemCard(
                    item: PreviewItem(id: index, title: "项目 \(index)"),
                    badge: "混合"
                )
                .frame(height: heights[index % heights.count])
            }
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("性能测试 - 中等数据集") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .adaptive(minSize: 100)
        ) {
            ForEach(PreviewData.generateItems(count: 500)) { item in
                PreviewItemCard(item: item, badge: "500项")
                    .frame(height: CGFloat.random(in: 80...200))
            }
        }
    }
    .navigationTitle("性能测试")
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("错误处理 - 负间距") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: -10, // 负值会被自动修正
            verticalSpacing: -5     // 负值会被自动修正
        ) {
            ForEach(PreviewData.generateItems(count: 8)) { item in
                PreviewItemCard(item: item, badge: "修正")
            }
        }
    }
    .padding()
}

// MARK: - 高级功能预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("便捷方法测试") {
    ScrollView {
        VStack(spacing: 20) {
            Text("垂直便捷方法")
                .font(.headline)

            MasonryView(
                axis: .vertical,
                lines: .fixed(3),
                horizontalSpacing: 12,
                verticalSpacing: 12
            ) {
                ForEach(PreviewData.generateItems(count: 9)) { item in
                    PreviewItemCard(item: item, badge: "垂直")
                        .frame(height: 100)
                }
            }

            Text("水平便捷方法")
                .font(.headline)

            MasonryView(
                axis: .horizontal,
                lines: .fixed(2),
                horizontalSpacing: 8,
                verticalSpacing: 8
            ) {
                ForEach(PreviewData.generateItems(count: 8, startId: 100)) { item in
                    PreviewItemCard(item: item, badge: "水平")
                        .frame(width: 120)
                }
            }
            .frame(height: 200)
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("配置预设测试") {
    NavigationView {
        ScrollView {
            VStack(spacing: 30) {
                    Text("单列预设")
                        .font(.headline)
                    MasonryView(
                        axis: MasonryConfiguration.singleColumn.axis,
                        lines: MasonryConfiguration.singleColumn.lines,
                        horizontalSpacing: MasonryConfiguration.singleColumn.horizontalSpacing,
                        verticalSpacing: MasonryConfiguration.singleColumn.verticalSpacing,
                        placementMode: MasonryConfiguration.singleColumn.placementMode
                    ) {
                        ForEach(PreviewData.generateItems(count: 3)) { item in
                            PreviewItemCard(item: item, badge: "单列")
                        }
                    }

                    Text("四列预设")
                        .font(.headline)
                    MasonryView(
                        axis: MasonryConfiguration.fourColumns.axis,
                        lines: MasonryConfiguration.fourColumns.lines,
                        horizontalSpacing: MasonryConfiguration.fourColumns.horizontalSpacing,
                        verticalSpacing: MasonryConfiguration.fourColumns.verticalSpacing,
                        placementMode: MasonryConfiguration.fourColumns.placementMode
                    ) {
                        ForEach(PreviewData.generateItems(count: 12, startId: 200)) { item in
                            PreviewItemCard(item: item, badge: "四列")
                                .frame(height: 80)
                        }
                    }

                    Text("自适应预设")
                        .font(.headline)
                    MasonryView(
                        axis: MasonryConfiguration.adaptiveColumns.axis,
                        lines: MasonryConfiguration.adaptiveColumns.lines,
                        horizontalSpacing: MasonryConfiguration.adaptiveColumns.horizontalSpacing,
                        verticalSpacing: MasonryConfiguration.adaptiveColumns.verticalSpacing,
                        placementMode: MasonryConfiguration.adaptiveColumns.placementMode
                    ) {
                        ForEach(PreviewData.generateItems(count: 15, startId: 300)) { item in
                            PreviewItemCard(item: item, badge: "自适应")
                                .frame(height: CGFloat.random(in: 60...140))
                        }
                    }
            }
        }
        .navigationTitle("配置预设")
    }
}

// MARK: - 虚拟化和异步功能预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("虚拟化性能对比") {
    NavigationView {
        VStack {
            Text("虚拟化 vs 普通渲染")
                .font(.title2)
                .padding()

            HStack(spacing: 20) {
                VStack {
                    Text("虚拟化 (10000项)")
                        .font(.caption)

                    LazyMasonryView(
                        axis: .vertical,
                        lines: .fixed(3),
                        data: PreviewData.generateItems(count: 10000),
                        id: \.id
                    ) { item in
                        PreviewItemCard(item: item, badge: "虚拟")
                    }
                    .frame(height: 300)
                    .border(Color.green, width: 2)
                }

                VStack {
                    Text("普通渲染 (100项)")
                        .font(.caption)

                    ScrollView {
                        MasonryView(
                            axis: .vertical,
                            lines: .fixed(3)
                        ) {
                            ForEach(PreviewData.generateItems(count: 100)) { item in
                                PreviewItemCard(item: item, badge: "普通")
                            }
                        }
                    }
                    .frame(height: 300)
                    .border(Color.blue, width: 2)
                }
            }
        }
        .navigationTitle("性能对比")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("异步布局计算") {
    NavigationView {
        VStack {
            Text("异步布局计算演示")
                .font(.title2)
                .padding()

            Text("大数据集异步处理，保持UI响应性")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)

            LazyMasonryView(
                axis: .vertical,
                lines: .adaptive(minSize: 80),
                horizontalSpacing: 8,
                verticalSpacing: 8,
                data: PreviewData.generateItems(count: 50000),
                id: \.id
            ) { item in
                VStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.color.gradient)
                        .overlay(
                            VStack {
                                Text("\(item.id)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Text("异步")
                                    .font(.caption2)
                            }
                            .foregroundColor(.white)
                        )
                }
                .frame(height: item.height * 0.8)
            }
        }
        .navigationTitle("异步计算")
    }
}

// MARK: - 工具扩展

/// Color扩展，提供随机颜色生成
private extension Color {
    /// 生成随机颜色
    /// - Returns: 随机的Color实例
    static var random: Color {
        Color(
            red: .random(in: 0.3...0.9),
            green: .random(in: 0.3...0.9),
            blue: .random(in: 0.3...0.9)
        )
    }
}
