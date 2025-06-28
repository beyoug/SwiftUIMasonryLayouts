//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 预览数据模型

/// 预览项目数据模型
struct PreviewItem: Identifiable, PreviewItemProtocol {
    let id = UUID()
    let title: String
    let height: CGFloat
    let color: Color

    // MARK: - PreviewItemProtocol

    /// 内容高度（Rectangle的高度）
    var contentHeight: CGFloat {
        return height
    }

    /// 内容宽度（使用默认值）
    var contentWidth: CGFloat {
        return 150 // 默认宽度
    }
}

/// 预览数据生成器
struct PreviewData {
    /// 生成指定数量的预览项目
    /// - Parameter count: 项目数量
    /// - Returns: 预览项目数组
    static func generateItems(count: Int) -> [PreviewItem] {
        Array(0..<count).map { index in
            PreviewItem(
                title: "项目 \(index + 1)",
                height: CGFloat.random(in: 80...200),
                color: Color.random
            )
        }
    }
    
    /// 示例数据集
    static let sampleItems = generateItems(count: 12)
}

/// 预览项目卡片视图
struct PreviewItemCard: View {
    let item: PreviewItem
    let badge: String?
    
    init(item: PreviewItem, badge: String? = nil) {
        self.item = item
        self.badge = badge
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(item.color.gradient)
                .frame(height: item.height)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if let badge = badge {
                    Text(badge)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - MasonryView 基础预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("基础瀑布流") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 12,
            verticalSpacing: 8
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
            verticalSpacing: 6
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
            verticalSpacing: 8
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "水平")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("MasonryView - 水平布局问题诊断") {
    VStack(spacing: 20) {
        Text("MasonryView 水平布局问题诊断")
            .font(.title2)
            .fontWeight(.bold)

        Text("验证MasonryView是否也存在左侧不对齐问题")
            .font(.caption)
            .foregroundColor(.blue)

        // MasonryView Order模式测试
        VStack(alignment: .leading, spacing: 8) {
            Text("MasonryView - Order模式")
                .font(.headline)
                .foregroundColor(.green)

            ScrollView(.horizontal) {
                MasonryView(
                    axis: .horizontal,
                    lines: .fixed(3),
                    horizontalSpacing: 8,
                    verticalSpacing: 8,
                    placementMode: .order
                ) {
                    ForEach(0..<6, id: \.self) { index in
                        HorizontalMasonryCard(
                            index: index,
                            title: "任务 \(index + 1)",
                            subtitle: ["短描述", "这是一个稍微长一点的任务描述", "中等长度的描述文本", "非常详细的任务描述，包含更多信息", "简短", "超长的任务描述，用来测试不同宽度的卡片在水平布局中的对齐效果"][index % 6],
                            category: ["设计", "开发", "测试", "部署", "维护", "优化"][index % 6],
                            width: [160, 200, 180, 240, 170, 220][index % 6], // 使用不同的固定宽度
                            color: [.blue, .green, .orange, .purple, .red, .cyan][index % 6]
                        )
                    }
                }
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .overlay(
                // 添加垂直参考线
                VStack {
                    HStack {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 1)
                        Spacer()
                    }
                    Spacer()
                }
            )
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("验证要点：")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.red)
            Text("• 使用不同宽度的卡片测试对齐问题")
                .font(.caption2)
            Text("• 第一列卡片应该完美左对齐")
                .font(.caption2)
            Text("• 如果MasonryView也不对齐，说明问题在核心算法")
                .font(.caption2)
            Text("• 如果MasonryView对齐，说明问题在虚拟化渲染")
                .font(.caption2)
        }
        .foregroundColor(.red)
    }
    .padding()
}

// MARK: - MasonryView专用水平卡片

/// MasonryView专用水平布局卡片组件
/// 设计理念：固定高度，可变宽度，适合水平瀑布流
struct HorizontalMasonryCard: View {
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
#Preview("MasonryView - 水平卡片测试") {
    VStack(spacing: 20) {
        Text("MasonryView 水平卡片测试")
            .font(.title2)
            .fontWeight(.bold)

        Text("使用专门设计的水平布局卡片测试MasonryView")
            .font(.caption)
            .foregroundColor(.blue)

        ScrollView(.horizontal) {
            MasonryView(
                axis: .horizontal,
                lines: .fixed(3),
                horizontalSpacing: 12,
                verticalSpacing: 12,
                placementMode: .order
            ) {
                ForEach(0..<9, id: \.self) { index in
                    HorizontalMasonryCard(
                        index: index,
                        title: "任务 \(index + 1)",
                        subtitle: [
                            "短描述",
                            "这是一个稍微长一点的任务描述",
                            "中等长度的描述文本",
                            "非常详细的任务描述，包含更多信息和细节",
                            "简短",
                            "超长的任务描述，用来测试不同宽度",
                            "普通描述",
                            "详细的功能说明和实现要求",
                            "基础任务"
                        ][index],
                        category: ["设计", "开发", "测试", "部署", "维护", "优化", "分析", "重构", "文档"][index],
                        width: [160, 220, 180, 260, 170, 240, 190, 280, 200][index], // 使用多样化的宽度
                        color: [.blue, .green, .orange, .purple, .red, .cyan, .pink, .indigo, .mint][index]
                    )
                }
            }
        }
        .frame(height: 300)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)

        VStack(alignment: .leading, spacing: 4) {
            Text("观察要点：")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
            Text("• 使用多样化宽度(160-280px)测试布局")
                .font(.caption2)
            Text("• 第一列（0,1,2）应该完美左对齐")
                .font(.caption2)
            Text("• 每行内的卡片从左到右依次排列")
                .font(.caption2)
            Text("• 不同宽度的卡片应该正确放置")
                .font(.caption2)
            Text("• 卡片内容应该完整显示，无裁剪")
                .font(.caption2)
        }
        .foregroundColor(.green)
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("MasonryView vs LazyMasonryView - 水平卡片对比") {
    VStack(spacing: 20) {
        Text("MasonryView vs LazyMasonryView 水平卡片对比")
            .font(.title2)
            .fontWeight(.bold)

        Text("使用相同的水平卡片对比两种布局的表现")
            .font(.caption)
            .foregroundColor(.blue)

        // MasonryView测试
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("MasonryView")
                    .font(.headline)
                    .foregroundColor(.green)

                Spacer()

                Text("Layout协议实现")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }

            ScrollView(.horizontal) {
                MasonryView(
                    axis: .horizontal,
                    lines: .fixed(3),
                    horizontalSpacing: 12,
                    verticalSpacing: 12,
                    placementMode: .order
                ) {
                    ForEach(0..<6, id: \.self) { index in
                        HorizontalMasonryCard(
                            index: index,
                            title: "MasonryView任务\(index + 1)",
                            subtitle: ["短", "这是一个较长的描述文本", "中等", "非常详细的任务描述内容", "简短", "超长描述用于测试"][index],
                            width: [160, 240, 180, 280, 170, 260][index], // 使用差异较大的宽度
                            color: [.blue, .green, .orange, .purple, .red, .cyan][index]
                        )
                    }
                }
            }
            .frame(height: 300)
            .background(Color.green.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                // 添加垂直参考线
                VStack {
                    HStack {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 2)
                        Spacer()
                    }
                    Spacer()
                }
            )
        }

        // LazyMasonryView测试
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("LazyMasonryView")
                    .font(.headline)
                    .foregroundColor(.orange)

                Spacer()

                Text("虚拟化实现")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }

            LazyMasonryView(
                axis: .horizontal,
                lines: .fixed(3),
                placementMode: .order,
                data: Array(0..<6),
                id: \.self,
                estimatedItemSize: CGSize(width: 200, height: 88)
            ) { index in
                HorizontalLazyMasonryCard(
                    index: index,
                    title: "LazyMasonryView任务\(index + 1)",
                    subtitle: ["短", "这是一个较长的描述文本", "中等", "非常详细的任务描述内容", "简短", "超长描述用于测试"][index],
                    width: [160, 240, 180, 280, 170, 260][index], // 与MasonryView使用相同的宽度进行对比
                    color: [.blue, .green, .orange, .purple, .red, .cyan][index]
                )
            }
            .frame(height: 300)
            .background(Color.orange.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                // 添加垂直参考线
                VStack {
                    HStack {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 2)
                        Spacer()
                    }
                    Spacer()
                }
            )
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("对比要点：")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.red)
            Text("• 使用相同的动态宽度卡片进行对比")
                .font(.caption2)
            Text("• 绿色参考线：MasonryView的左对齐基准")
                .font(.caption2)
            Text("• 橙色参考线：LazyMasonryView的左对齐基准")
                .font(.caption2)
            Text("• 观察第一列卡片是否都与各自参考线对齐")
                .font(.caption2)
            Text("• 动态宽度能更好地暴露对齐问题")
                .font(.caption2)
            Text("• 如果MasonryView对齐而LazyMasonryView不对齐，确认问题在虚拟化")
                .font(.caption2)
        }
        .foregroundColor(.red)
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("自适应最小尺寸") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .adaptive(minSize: 120),
            horizontalSpacing: 8,
            verticalSpacing: 6
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "自适应")
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
            verticalSpacing: 6
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "最大尺寸")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("填充模式") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 6,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "填充")
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
            verticalSpacing: 6,
            placementMode: .order
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "顺序")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("单列布局") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(1),
            horizontalSpacing: 0,
            verticalSpacing: 12
        ) {
            ForEach(PreviewData.sampleItems) { item in
                PreviewItemCard(item: item, badge: "单列")
            }
        }
        .padding()
    }
}

// MARK: - 工具扩展

/// Color扩展，提供随机颜色生成
extension Color {
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
