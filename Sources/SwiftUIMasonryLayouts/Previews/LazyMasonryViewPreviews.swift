//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - LazyMasonryView 虚拟化预览


@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 小数据集") {
    let items = PreviewData.generateItems(count: 30)
    
    NavigationView {
        LazyMasonryView(
            axis: .vertical,
            lines: .fixed(2),
            data: items,
            id: \.id,
            estimatedItemSize: CGSize(width: 150, height: 180)
        ) { item in
            PreviewItemCard(item: item, badge: "小数据集")
        }
        .padding()
        .navigationTitle("LazyMasonry 小数据集")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("虚拟化大数据集") {
    let largeDataSet = PreviewData.generateItems(count: 100)

    NavigationView {
        LazyMasonryView(
            axis: .vertical,
            lines: .fixed(3),
            data: largeDataSet,
            id: \.id,
            estimatedItemSize: CGSize(width: 100, height: 180)
        ) { item in
            PreviewItemCard(item: item, badge: "Virtual")
        }
        .navigationTitle("虚拟化瀑布流")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 自适应列") {
    let items = PreviewData.generateItems(count: 30)
    
    NavigationView {
        LazyMasonryView(
            axis: .vertical,
            lines: .adaptive(minSize: 140),
            data: items,
            id: \.id,
            estimatedItemSize: CGSize(width: 140, height: 200)
        ) { item in
            PreviewItemCard(item: item, badge: "自适应")
        }
        .padding()
        .navigationTitle("LazyMasonry 自适应列")
    }
}

// MARK: - 水平布局专用卡片

/// 水平布局专用卡片组件
/// 设计理念：固定高度，可变宽度，适合水平瀑布流
struct HorizontalLazyMasonryCard: View {
    let index: Int
    let title: String
    let subtitle: String
    let category: String
    let width: CGFloat
    let color: Color

    init(index: Int, title: String = "", subtitle: String = "", category: String = "", width: CGFloat = 160, color: Color = .blue) {
        self.index = index
        self.title = title.isEmpty ? "任务 \(index + 1)" : title
        self.subtitle = subtitle.isEmpty ? "这是一个示例任务描述" : subtitle
        self.category = category.isEmpty ? ["设计", "开发", "测试", "部署", "维护"][index % 5] : category
        self.width = width
        self.color = color
    }

    var body: some View {
        HStack(spacing: 12) {
            // 左侧图标区域
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.gradient)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text("\(index)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )

                Text(category)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .lineLimit(1)
            }

            // 中间内容区域
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("2小时前")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    // 优先级指示器
                    HStack(spacing: 2) {
                        ForEach(0..<(index % 3 + 1), id: \.self) { _ in
                            Circle()
                                .fill(color)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            // 右侧操作区域
            VStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // 进度指示
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: CGFloat(index % 10) / 10.0)
                            .stroke(color, lineWidth: 2)
                            .rotationEffect(.degrees(-90))
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: width, height: 88) // 增加到88高度，更舒适的视觉效果
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 水平布局专用卡片") {
    NavigationView {
        VStack(spacing: 16) {
            Text("水平瀑布流布局")
                .font(.title2)
                .fontWeight(.bold)
                .padding()

            Text("使用专门设计的水平布局卡片")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyMasonryView(
                axis: .horizontal,
                lines: .fixed(3),
                placementMode: .order,
                data: Array(0..<15),
                id: \.self,
                estimatedItemSize: CGSize(width: 180, height: 88)
            ) { index in
                HorizontalLazyMasonryCard(
                    index: index,
                    title: "任务 \(index + 1)",
                    subtitle: ["UI设计优化", "后端API开发", "单元测试编写", "生产环境部署", "系统维护升级"][index % 5],
                    category: ["设计", "开发", "测试", "部署", "维护"][index % 5],
                    width: CGFloat(160 + index * 12), // 渐增宽度
                    color: [.blue, .green, .orange, .purple, .red][index % 5]
                )
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("水平布局测试")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("虚拟化性能对比") {
    NavigationView {
        VStack {
            Text("虚拟化 vs 普通渲染")
                .font(.title2)
                .padding()
            
            TabView {
                // 虚拟化渲染
                LazyMasonryView(
                    axis: .vertical,
                    lines: .fixed(3),
                    data: PreviewData.generateItems(count: 500),
                    id: \.id,
                    estimatedItemSize: CGSize(width: 100, height: 160)
                ) { item in
                    PreviewItemCard(item: item, badge: "虚拟化")
                }
                .tabItem {
                    Label("虚拟化", systemImage: "rectangle.grid.2x2")
                }
                
                // 普通渲染
                ScrollView {
                    DataMasonryView(
                        axis: .vertical,
                        lines: .fixed(3),
                        data: PreviewData.generateItems(count: 100), // 较少数据避免性能问题
                        id: \.id
                    ) { item in
                        PreviewItemCard(item: item, badge: "普通")
                    }
                    .padding()
                }
                .tabItem {
                    Label("普通", systemImage: "rectangle.grid.1x2")
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
            
            Text("大数据集使用异步计算")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(4),
                data: PreviewData.generateItems(count: 1000),
                id: \.id,
                estimatedItemSize: CGSize(width: 80, height: 140)
            ) { item in
                PreviewItemCard(item: item, badge: "异步")
            }
        }
        .navigationTitle("异步布局")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 空数据集") {
    NavigationView {
        VStack {
            if [PreviewItem]().isEmpty {
                Text("没有数据")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyMasonryView(
                    axis: .vertical,
                    lines: .fixed(2),
                    data: [PreviewItem](),
                    id: \.id
                ) { item in
                    PreviewItemCard(item: item, badge: "空数据")
                }
                .padding()
            }
        }
        .navigationTitle("LazyMasonry 空数据集")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 极大数据集") {
    NavigationView {
        VStack {
            Text("极大数据集 (5000项)")
                .font(.title2)
                .padding()
            
            Text("测试虚拟化性能")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(4),
                data: PreviewData.generateItems(count: 5000),
                id: \.id,
                estimatedItemSize: CGSize(width: 80, height: 160)
            ) { item in
                PreviewItemCard(item: item, badge: "极大")
            }
        }
        .navigationTitle("极大数据集")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 初始显示测试") {
    NavigationView {
        VStack {
            Text("初始显示测试")
                .font(.title2)
                .padding()

            Text("应该立即显示内容，无需拖动")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)

            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(2),
                data: PreviewData.generateItems(count: 20),
                id: \.id,
                estimatedItemSize: CGSize(width: 150, height: 180)
            ) { item in
                PreviewItemCard(item: item, badge: "初始显示")
            }
        }
        .navigationTitle("初始显示测试")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 顺序模式对齐测试") {
    NavigationView {
        VStack {
            Text("顺序模式对齐测试")
                .font(.title2)
                .padding()

            Text("使用.order模式，第一行应该对齐")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)

            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(2),
                placementMode: .order, // 使用顺序模式
                data: PreviewData.generateItems(count: 10),
                id: \.id,
                estimatedItemSize: CGSize(width: 150, height: 180)
            ) { item in
                PreviewItemCard(item: item, badge: "顺序")
            }
        }
        .navigationTitle("顺序模式测试")
    }
}


@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 水平布局对比测试") {
    VStack(spacing: 20) {
        Text("水平布局：Order vs Fill 模式对比")
            .font(.title2)
            .fontWeight(.bold)

        // Order模式
        VStack(alignment: .leading, spacing: 8) {
            Text("Order模式：按顺序分配")
                .font(.headline)
                .foregroundColor(.blue)

            LazyMasonryView(
                axis: .horizontal,
                lines: .fixed(3),
                placementMode: .order,
                data: Array(0..<9),
                id: \.self,
                estimatedItemSize: CGSize(width: 180, height: 88)
            ) { index in
                HorizontalLazyMasonryCard(
                    index: index,
                    width: CGFloat(160 + index * 15),
                    color: .blue
                )
            }
            .frame(height: 280)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
        }

        // Fill模式
        VStack(alignment: .leading, spacing: 8) {
            Text("Fill模式：智能填充")
                .font(.headline)
                .foregroundColor(.green)

            LazyMasonryView(
                axis: .horizontal,
                lines: .fixed(3),
                placementMode: .fill,
                data: Array(0..<9),
                id: \.self,
                estimatedItemSize: CGSize(width: 180, height: 88)
            ) { index in
                HorizontalMasonryCard(
                    index: index,
                    width: CGFloat(160 + index * 15),
                    color: .green
                )
            }
            .frame(height: 280)
            .background(Color.green.opacity(0.05))
            .cornerRadius(8)
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("观察要点：")
                .font(.caption)
                .fontWeight(.bold)
            Text("• Order：0,1,2分别在第0,1,2行，然后3,4,5...")
                .font(.caption2)
            Text("• Fill：动态分配到当前最短的行")
                .font(.caption2)
            Text("• 两种模式都应该第一列完美左对齐")
                .font(.caption2)
        }
        .foregroundColor(.orange)
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 坐标系统诊断") {
    VStack(spacing: 16) {
        Text("水平布局坐标系统深度诊断")
            .font(.title2)
            .fontWeight(.bold)

        Text("使用最简单的内容测试坐标计算")
            .font(.caption)
            .foregroundColor(.blue)

        // 简化测试：只用纯色Rectangle
        LazyMasonryView(
            axis: .horizontal,
            lines: .fixed(3),
            placementMode: .order,
            data: Array(0..<6),
            id: \.self,
            estimatedItemSize: CGSize(width: 100, height: 60)
        ) { index in
            Rectangle()
                .fill([Color.red, Color.green, Color.blue][index % 3])
                .frame(width: 80, height: 50)
                .overlay(
                    Text("\(index)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
        }
        .frame(width: 400, height: 180)
        .background(Color.gray.opacity(0.2))
        .overlay(
            // 网格参考线
            VStack(spacing: 0) {
                ForEach(0..<4) { row in
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 1, height: 60)
                        Spacer()
                    }
                    if row < 3 {
                        Spacer().frame(height: 0)
                    }
                }
            }
        )

        Text("期望：红0绿1蓝2应该在左侧垂直对齐")
            .font(.caption)
            .foregroundColor(.red)

        // 对比：使用MasonryView
        VStack(alignment: .leading, spacing: 8) {
            Text("对比：MasonryView（非虚拟化）")
                .font(.headline)

            ScrollView(.horizontal) {
                MasonryView(
                    axis: .horizontal,
                    lines: .fixed(3),
                    horizontalSpacing: 8,
                    verticalSpacing: 8,
                    placementMode: .order
                ) {
                    ForEach(0..<6, id: \.self) { index in
                        Rectangle()
                            .fill([Color.red, Color.green, Color.blue][index % 3])
                            .frame(width: 80, height: 50)
                            .overlay(
                                Text("\(index)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .frame(height: 180)
            .background(Color.gray.opacity(0.2))
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("LazyMasonry - 不同预估尺寸") {
    NavigationView {
        TabView {
            // 准确预估
            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(3),
                data: PreviewData.generateItems(count: 100),
                id: \.id,
                estimatedItemSize: CGSize(width: 120, height: 180) // 接近实际
            ) { item in
                PreviewItemCard(item: item, badge: "准确预估")
            }
            .tabItem { Text("准确预估") }
            
            // 不准确预估
            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(3),
                data: PreviewData.generateItems(count: 100),
                id: \.id,
                estimatedItemSize: CGSize(width: 50, height: 50) // 远离实际
            ) { item in
                PreviewItemCard(item: item, badge: "不准确预估")
            }
            .tabItem { Text("不准确预估") }
        }
        .navigationTitle("预估尺寸对比")
    }
}


