//
// Copyright (c) Beyoug
//

import SwiftUI



// MARK: - 预览专用组件
// 注意：这些组件仅用于预览演示，不是库的公共API

/// 预览项目尺寸协议（仅用于预览演示）
internal protocol PreviewItemSizing {
    /// 内容高度
    var contentHeight: CGFloat { get }
    /// 内容宽度
    var contentWidth: CGFloat { get }
}

/// 预览项目数据模型
internal struct PreviewItem: Identifiable, PreviewItemSizing {
    let id = UUID()
    let title: String
    let height: CGFloat
    let width: CGFloat
    let color: Color

    // MARK: - PreviewItemSizing

    /// 内容高度
    var contentHeight: CGFloat {
        return height
    }

    /// 内容宽度
    var contentWidth: CGFloat {
        return width
    }
}

/// 预览数据生成器
internal struct PreviewData {
    /// 生成指定数量的预览项目（垂直布局用）
    /// - Parameter count: 项目数量
    /// - Returns: 预览项目数组，高度随机，宽度固定
    static func generateItems(count: Int) -> [PreviewItem] {
        Array(0..<count).map { index in
            PreviewItem(
                title: "项目 \(index + 1)",
                height: CGFloat.random(in: 100...300), // 缩小高度范围，减少差异
                width: 150, // 固定宽度
                color: Color.random
            )
        }
    }

    /// 生成稳定的预览项目（用于一致的预览效果）
    /// - Parameter count: 项目数量
    /// - Returns: 预览项目数组，使用预定义的高度分布
    static func generateStableItems(count: Int) -> [PreviewItem] {
        // 预定义的高度，确保合理的分布
        let heights: [CGFloat] = [120, 160, 100, 180, 140, 110, 170, 130, 150, 190, 125, 165]
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .cyan, .yellow, .indigo, .mint, .teal, .brown]

        return Array(0..<count).map { index in
            PreviewItem(
                title: "项目 \(index + 1)",
                height: heights[index % heights.count],
                width: 150,
                color: colors[index % colors.count]
            )
        }
    }
    
    /// 生成指定数量的预览项目（水平布局用）
    /// - Parameter count: 项目数量
    /// - Returns: 预览项目数组，高度固定，宽度随机
    static func generateHorizontalItems(count: Int) -> [PreviewItem] {
        let widths: [CGFloat] = [160, 100, 80, 210, 30, 220, 90, 60, 120, 80, 175, 230]
        return Array(0..<count).map { index in
            PreviewItem(
                title: "项目 \(index + 1)",
                height: 80, // 固定高度
                width: widths[index % widths.count], // 使用预定义宽度
                color: Color.random
            )
        }
    }

    /// 示例数据集（垂直布局）- 使用稳定数据确保一致的预览效果
    static let sampleItems = generateStableItems(count: 12)

    /// 随机数据集（用于性能测试等需要大量数据的场景）
    static func randomItems(count: Int) -> [PreviewItem] {
        return generateItems(count: count)
    }
    
    /// 示例数据集（水平布局）
    static let sampleHorizontalItems = generateHorizontalItems(count: 12)
}

/// 垂直布局卡片组件（通用于MasonryView和LazyMasonryView预览）
/// 设计理念：可变高度，固定宽度，适合垂直瀑布流
internal struct VerticalMasonryCard: View {
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

// MARK: - 水平布局专用卡片

/// 水平布局卡片组件（通用于MasonryView和LazyMasonryView预览）
/// 设计理念：固定高度，可变宽度，适合水平瀑布流
internal struct HorizontalMasonryCard: View {
    let item: PreviewItem
    let badge: String?
    
    init(item: PreviewItem, badge: String? = nil) {
        self.item = item
        self.badge = badge
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // 左侧颜色条
            Rectangle()
                .fill(item.color.gradient)
                .frame(width: item.contentWidth * 0.3) // 宽度的30%作为颜色区域
                .cornerRadius(8)
            
            // 右侧内容区域
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
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
            .padding(.vertical, 8)
            
            Spacer(minLength: 0)
        }
        .frame(width: item.contentWidth) // 只设置宽度，让MasonryLayout控制高度
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 工具扩展

/// Color扩展，提供随机颜色生成（仅用于预览）
internal extension Color {
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


/// 快速瀑布流预览 - 用于日常开发测试
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct QuickMasonryPreview: View {
    
    // MARK: - 数据源
    
    private let items = PreviewData.sampleItems
    private let horizontalItems = PreviewData.sampleHorizontalItems
    
    var body: some View {
        TabView {
            // 垂直布局标签页
            verticalLayoutsTab
                .tabItem {
                    Image(systemName: "rectangle.grid.2x2")
                    Text("垂直布局")
                }
            
            // 水平布局标签页
            horizontalLayoutsTab
                .tabItem {
                    Image(systemName: "rectangle.grid.2x2.fill")
                    Text("水平布局")
                }
            
            // 模式对比标签页
            modeComparisonTab
                .tabItem {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("模式对比")
                }
            
            // 预设配置标签页
            presetsTab
                .tabItem {
                    Image(systemName: "gear")
                    Text("预设配置")
                }
        }
    }
}

// MARK: - 垂直布局标签页

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension QuickMasonryPreview {
    
    private var verticalLayoutsTab: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // 双列 Fill
                    quickSection(
                        title: "双列 Fill 模式",
                        subtitle: "最常用的配置"
                    ) {
                        MasonryView(
                            axis: .vertical,
                            lines: .fixed(2),
                            horizontalSpacing: 8,
                            verticalSpacing: 8,
                            placementMode: .fill
                        ) {
                            ForEach(items.prefix(8)) { item in
                                VerticalMasonryCard(item: item, badge: "Fill")
                            }
                        }
                        .frame(height: 300)
                    }
                    
                    // 三列 Fill
                    quickSection(
                        title: "三列 Fill 模式",
                        subtitle: "适合平板和大屏"
                    ) {
                        MasonryView(
                            axis: .vertical,
                            lines: .fixed(3),
                            horizontalSpacing: 8,
                            verticalSpacing: 8,
                            placementMode: .fill
                        ) {
                            ForEach(items.prefix(9)) { item in
                                VerticalMasonryCard(item: item, badge: "Fill")
                            }
                        }
                        .frame(height: 300)
                    }
                    
                    // 自适应列数
                    quickSection(
                        title: "自适应列数",
                        subtitle: "根据屏幕宽度自动调整"
                    ) {
                        MasonryView(
                            axis: .vertical,
                            lines: .adaptive(minSize: 120),
                            horizontalSpacing: 8,
                            verticalSpacing: 8,
                            placementMode: .fill
                        ) {
                            ForEach(items) { item in
                                VerticalMasonryCard(item: item, badge: "Adaptive")
                            }
                        }
                        .frame(height: 350)
                    }
                    
                    // 大间距示例
                    quickSection(
                        title: "大间距布局",
                        subtitle: "16pt 间距的视觉效果"
                    ) {
                        MasonryView(
                            axis: .vertical,
                            lines: .fixed(2),
                            horizontalSpacing: 16,
                            verticalSpacing: 16,
                            placementMode: .fill
                        ) {
                            ForEach(items.prefix(6)) { item in
                                VerticalMasonryCard(item: item, badge: "大间距")
                            }
                        }
                        .frame(height: 300)
                    }
                }
                .padding()
            }
            .navigationTitle("垂直布局")
        }
    }
}

// MARK: - 水平布局标签页

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension QuickMasonryPreview {
    
    private var horizontalLayoutsTab: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // 双行水平
                    quickSection(
                        title: "双行水平布局",
                        subtitle: "水平滚动的瀑布流"
                    ) {
                        ScrollView(.horizontal) {
                            MasonryView(
                                axis: .horizontal,
                                lines: .fixed(2),
                                horizontalSpacing: 8,
                                verticalSpacing: 8,
                                placementMode: .fill
                            ) {
                                ForEach(horizontalItems) { item in
                                    HorizontalMasonryCard(item: item, badge: "Fill")
                                }
                            }
                            .frame(height: 180)
                            .padding(.horizontal)
                        }
                    }
                    
                    // 三行水平
                    quickSection(
                        title: "三行水平布局",
                        subtitle: "更紧凑的水平排列"
                    ) {
                        ScrollView(.horizontal) {
                            MasonryView(
                                axis: .horizontal,
                                lines: .fixed(3),
                                horizontalSpacing: 8,
                                verticalSpacing: 8,
                                placementMode: .fill
                            ) {
                                ForEach(horizontalItems) { item in
                                    HorizontalMasonryCard(item: item, badge: "Fill")
                                }
                            }
                            .frame(height: 240)
                            .padding(.horizontal)
                        }
                    }
                    
                    // 自适应行数
                    quickSection(
                        title: "自适应行数",
                        subtitle: "根据容器高度自动调整"
                    ) {
                        ScrollView(.horizontal) {
                            MasonryView(
                                axis: .horizontal,
                                lines: .adaptive(minSize: 60),
                                horizontalSpacing: 8,
                                verticalSpacing: 8,
                                placementMode: .fill
                            ) {
                                ForEach(horizontalItems) { item in
                                    HorizontalMasonryCard(item: item, badge: "Adaptive")
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("水平布局")
        }
    }
}

// MARK: - 模式对比标签页

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension QuickMasonryPreview {
    
    private var modeComparisonTab: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Fill vs Order 对比
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fill vs Order 模式对比")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("观察两种模式的排列差异")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            // Fill 模式
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fill 模式")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                MasonryView(
                                    axis: .vertical,
                                    lines: .fixed(2),
                                    horizontalSpacing: 8,
                                    verticalSpacing: 8,
                                    placementMode: .fill
                                ) {
                                    ForEach(items.prefix(8)) { item in
                                        VerticalMasonryCard(item: item, badge: "Fill")
                                    }
                                }
                                .frame(height: 300)
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(8)
                            }
                            
                            // Order 模式
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Order 模式")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                MasonryView(
                                    axis: .vertical,
                                    lines: .fixed(2),
                                    horizontalSpacing: 8,
                                    verticalSpacing: 8,
                                    placementMode: .order
                                ) {
                                    ForEach(items.prefix(8)) { item in
                                        VerticalMasonryCard(item: item, badge: "Order")
                                    }
                                }
                                .frame(height: 300)
                                .background(Color.green.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                        
                        // 说明
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Fill 模式：智能填充到最短列，视觉效果更平衡")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("• Order 模式：按顺序循环放置，保持逻辑顺序")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("模式对比")
        }
    }
}

// MARK: - 预设配置标签页

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension QuickMasonryPreview {
    
    private var presetsTab: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // 预设配置展示
                    presetSection(title: "双列预设", config: .twoColumns)
                    presetSection(title: "自适应预设", config: .adaptiveColumns)
                }
                .padding()
            }
            .navigationTitle("预设配置")
        }
    }
    
    // 预设配置展示组件
    private func presetSection(title: String, config: MasonryConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            MasonryView(
                axis: config.axis,
                lines: config.lines,
                horizontalSpacing: config.horizontalSpacing,
                verticalSpacing: config.verticalSpacing,
                placementMode: config.placementMode
            ) {
                ForEach(items.prefix(8)) { item in
                    VerticalMasonryCard(item: item, badge: title)
                }
            }
            .frame(height: 250)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
    }
}

// MARK: - 辅助组件

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension QuickMasonryPreview {
    
    // 快速区块组件
    private func quickSection<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            content()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
        }
    }
}

#Preview("快速预览") {
    QuickMasonryPreview()
}
