//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 可视化演示主页面

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct VisualPreviewExample: View {
    var body: some View {
        NavigationView {
            List {
                Section("基础演示") {
                    NavigationLink("MasonryView 演示", destination: BasicMasonryDemo())
                    NavigationLink("LazyMasonryView 演示", destination: BasicLazyMasonryDemo())
                }
                
                Section("高级功能") {
                    NavigationLink("响应式布局", destination: ResponsiveLayoutDemo())
                    NavigationLink("性能测试", destination: PerformanceTestDemo())
                    NavigationLink("自定义配置", destination: CustomConfigDemo())
                    NavigationLink("用户自定义视图", destination: CustomViewDemo())
                }
                
                Section("实际应用") {
                    NavigationLink("图片画廊", destination: PhotoGalleryDemo())
                    NavigationLink("卡片列表", destination: CardListDemo())
                    NavigationLink("混合内容", destination: MixedContentDemo())
                }
            }
            .navigationTitle("瀑布流布局演示")
        }
    }
}

// MARK: - 演示数据模型

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension VisualPreviewExample {
    struct DemoItem: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let height: CGFloat
        let color: Color
        
        static let sampleData: [DemoItem] = [
            DemoItem(title: "短文本", height: 80, color: .red),
            DemoItem(title: "中等长度的文本内容", height: 120, color: .blue),
            DemoItem(title: "这是一个比较长的文本内容，用来测试不同高度的卡片", height: 160, color: .green),
            DemoItem(title: "中号", height: 100, color: .purple),
            DemoItem(title: "简短", height: 90, color: .orange),
            DemoItem(title: "超长文本内容，用来展示瀑布流布局如何处理各种不同高度的内容项目", height: 200, color: .pink),
            DemoItem(title: "标准", height: 140, color: .yellow),
            DemoItem(title: "短", height: 70, color: .cyan),
            DemoItem(title: "这是另一个中等长度的文本", height: 110, color: .indigo),
            DemoItem(title: "高", height: 180, color: .mint)
        ]
    }
}

// MARK: - 基础 MasonryView 演示

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct BasicMasonryDemo: View {
    let items = Array(repeating: VisualPreviewExample.DemoItem.sampleData, count: 3).flatMap { $0 }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 基础用法
                DemoSection(
                    title: "基础用法 (2列)",
                    code: "MasonryView(columns: 2) { ... }"
                ) {
                    MasonryView(columns: 2) {
                        ForEach(items.prefix(8)) { item in
                            DemoCard(item: item)
                        }
                    }
                    .frame(height: 250)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // 3列布局
                DemoSection(
                    title: "3列布局",
                    code: "MasonryView(columns: 3) { ... }"
                ) {
                    MasonryView(columns: 3) {
                        ForEach(items.prefix(12)) { item in
                            DemoCard(item: item, compact: true)
                        }
                    }
                    .frame(height: 250)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // 自适应列数
                DemoSection(
                    title: "自适应列数",
                    code: "MasonryView(lines: MasonryLines.adaptive(minSize: 120)) { ... }"
                ) {
                    MasonryView(lines: MasonryLines.adaptive(minSize: 120)) {
                        ForEach(items.prefix(10)) { item in
                            DemoCard(item: item, compact: true)
                        }
                    }
                    .frame(height: 250)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // 自定义间距
                DemoSection(
                    title: "自定义间距",
                    code: "MasonryView(columns: 2, spacing: 20) { ... }"
                ) {
                    MasonryView(columns: 2, spacing: 20) {
                        ForEach(items.prefix(8)) { item in
                            DemoCard(item: item)
                        }
                    }
                    .frame(height: 250)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("MasonryView 演示")
    }
}

// MARK: - 基础 LazyMasonryView 演示

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct BasicLazyMasonryDemo: View {
    let items = Array(repeating: VisualPreviewExample.DemoItem.sampleData, count: 5).flatMap { $0 }
    @State private var selectedDemo = 0

    var body: some View {
        VStack(spacing: 0) {
            // 选择器
            Picker("演示类型", selection: $selectedDemo) {
                Text("最简单").tag(0)
                Text("3列").tag(1)
                Text("自适应").tag(2)
                Text("链式配置").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // 演示内容
            Group {
                switch selectedDemo {
                case 0:
                    // 最简单用法
                    LazyMasonryView(
                        items.prefix(30),
                        configuration: MasonryConfiguration(),
                        sizeCalculator: { item, lineSize in
                            let cardHeight = DemoCard.calculateHeight(for: item, compact: false)
                            return CGSize(width: lineSize, height: cardHeight)
                        }
                    ) { item in
                        DemoCard(item: item)
                    }
                case 1:
                    // 指定列数
                    LazyMasonryView(
                        items.prefix(30),
                        configuration: MasonryConfiguration(lines: .fixed(3)),
                        sizeCalculator: { item, lineSize in
                            let cardHeight = DemoCard.calculateHeight(for: item, compact: false)
                            return CGSize(width: lineSize, height: cardHeight)
                        }
                    ) { item in
                        DemoCard(item: item)
                    }
                case 2:
                    // 自适应列数
                    LazyMasonryView(
                        items.prefix(30),
                        configuration: MasonryConfiguration(lines: .adaptive(minSize: 120)),
                        sizeCalculator: { item, lineSize in
                            let cardHeight = DemoCard.calculateHeight(for: item, compact: false)
                            return CGSize(width: lineSize, height: cardHeight)
                        }
                    ) { item in
                        DemoCard(item: item)
                    }
                case 3:
                    // 链式配置
                    LazyMasonryView(
                        items.prefix(30),
                        configuration: MasonryConfiguration(hSpacing: 16, vSpacing: 16),
                        sizeCalculator: { item, lineSize in
                            let cardHeight = DemoCard.calculateHeight(for: item, compact: false)
                            return CGSize(width: lineSize, height: cardHeight)
                        }
                    ) { item in
                        DemoCard(item: item)
                    }
                default:
                    EmptyView()
                }
            }
        }
        .navigationTitle("LazyMasonryView 演示")
    }
}

// MARK: - 响应式布局演示

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct ResponsiveLayoutDemo: View {
    let items = Array(repeating: VisualPreviewExample.DemoItem.sampleData, count: 5).flatMap { $0 }
    
    let breakpoints: [CGFloat: MasonryConfiguration] = [
        0: .columns(1, spacing: 8),
        400: .columns(2, spacing: 12),
        600: .columns(3, spacing: 16),
        800: .columns(4, spacing: 20)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("调整窗口大小查看响应式效果")
                    .font(.headline)
                
                Text("断点: 400px(2列) → 600px(3列) → 800px(4列)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            MasonryView(breakpoints: breakpoints) {
                ForEach(items) { item in
                    DemoCard(item: item)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("响应式布局")
    }
}

// MARK: - 演示组件

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct DemoSection<Content: View>: View {
    let title: String
    let code: String
    let content: Content
    
    init(title: String, code: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.code = code
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(code)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }

            content
        }
    }
}

/// 演示卡片组件
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct DemoCard: View {
    let item: VisualPreviewExample.DemoItem
    var showIndex: Bool = false
    var index: Int = 0
    var compact: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(item.color.gradient)
                .frame(height: item.height)
                .overlay(
                    VStack(spacing: 2) {
                        if showIndex {
                            Text("#\(index)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(4)
                        }
                        if !compact {
                            Text("\(Int(item.height))pt")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                )

            if !compact {
                Text(item.title)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.gray.opacity(0.1))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    /// 计算卡片的总高度
    /// - Parameters:
    ///   - item: 数据项
    ///   - compact: 是否为紧凑模式
    /// - Returns: 卡片的总高度
    static func calculateHeight(for item: VisualPreviewExample.DemoItem, compact: Bool) -> CGFloat {
        let imageHeight = item.height
        let titleHeight: CGFloat = compact ? 0 : 30 // 标题区域高度
        return imageHeight + titleHeight
    }
}

// MARK: - 性能测试演示

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PerformanceTestDemo: View {
    @State private var itemCount = 100
    @State private var columns = 2

    private var items: [VisualPreviewExample.DemoItem] {
        Array(repeating: VisualPreviewExample.DemoItem.sampleData, count: itemCount / 10 + 1)
            .flatMap { $0 }
            .prefix(itemCount)
            .map { $0 }
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                HStack {
                    Text("项目数量: \(itemCount)")
                    Spacer()
                    Stepper("", value: $itemCount, in: 10...1000, step: 10)
                }

                HStack {
                    Text("列数: \(columns)")
                    Spacer()
                    Stepper("", value: $columns, in: 1...5)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)

            LazyMasonryView(
                items,
                configuration: MasonryConfiguration(lines: .fixed(columns), hSpacing: 8, vSpacing: 8),
                sizeCalculator: { item, lineSize in
                    let cardHeight = DemoCard.calculateHeight(for: item, compact: true)
                    return CGSize(width: lineSize, height: cardHeight)
                }
            ) { item in
                DemoCard(item: item, compact: true)
            }
        }
        .navigationTitle("性能测试")
    }
}

// MARK: - 自定义配置演示

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct CustomConfigDemo: View {
    let items = Array(repeating: VisualPreviewExample.DemoItem.sampleData, count: 3).flatMap { $0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                horizontalLayoutSection
                spacingSection
                centerAlignmentSection
            }
            .padding()
        }
        .navigationTitle("自定义配置")
    }

    private var horizontalLayoutSection: some View {
        DemoSection(
            title: "水平布局",
            code: "MasonryView(.horizontal, lines: 3) { ... }"
        ) {
            ScrollView(.horizontal) {
                MasonryView(axis: .horizontal, lines: MasonryLines.fixed(3)) {
                    ForEach(items.prefix(15)) { item in
                        DemoCard(item: item, compact: true)
                            .frame(width: item.height) // 水平布局时使用高度作为宽度
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }

    private var spacingSection: some View {
        DemoSection(
            title: "不同水平和垂直间距",
            code: "MasonryView(columns: 2, hSpacing: 20, vSpacing: 8) { ... }"
        ) {
            MasonryView(axis: .vertical, lines: MasonryLines.fixed(2), hSpacing: 20, vSpacing: 8) {
                ForEach(items.prefix(8)) { item in
                    DemoCard(item: item)
                }
            }
            .frame(height: 250)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }

    private var centerAlignmentSection: some View {
        DemoSection(
            title: "居中对齐",
            code: "MasonryView(columns: 3, placement: .center) { ... }"
        ) {
            MasonryView(axis: .vertical, lines: MasonryLines.fixed(3), placement: MasonryPlacementMode.fill) {
                ForEach(items.prefix(6)) { item in
                    DemoCard(item: item, compact: true)
                }
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - 图片画廊演示

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PhotoGalleryDemo: View {
    let photos = (1...50).map { PhotoItem(id: $0) }

    var body: some View {
        LazyMasonryView(
            photos,
            configuration: MasonryConfiguration(lines: .adaptive(minSize: 150), hSpacing: 8, vSpacing: 8),
            sizeCalculator: { photo, lineSize in
                let aspectRatio = photo.aspectRatio
                let height = lineSize / aspectRatio
                return CGSize(width: lineSize, height: height)
            }
        ) { photo in
            PhotoCard(photo: photo)
        }
        .navigationTitle("图片画廊")
    }

    struct PhotoItem: Identifiable {
        let id: Int
        var aspectRatio: Double { Double.random(in: 0.6...1.8) }
        var color: Color { Color.random }
    }

    struct PhotoCard: View {
        let photo: PhotoItem

        var body: some View {
            Rectangle()
                .fill(photo.color.gradient)
                .aspectRatio(photo.aspectRatio, contentMode: .fit)
                .overlay(
                    Text("Photo \(photo.id)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(6),
                    alignment: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - 卡片列表演示

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct CardListDemo: View {
    let cards = (1...30).map { CardItem(id: $0) }

    var body: some View {
        LazyMasonryView(
            cards,
            configuration: MasonryConfiguration(lines: .fixed(2), hSpacing: 12, vSpacing: 12),
            sizeCalculator: { card, lineSize in
                // 计算卡片高度
                let baseHeight: CGFloat = 80 // 标题和描述的基础高度
                let imageHeight: CGFloat = card.hasImage ? 100 + 8 : 0 // 图片高度 + 间距
                let totalHeight = baseHeight + imageHeight
                return CGSize(width: lineSize, height: totalHeight)
            }
        ) { card in
            CardView(card: card)
        }
        .navigationTitle("卡片列表")
    }

    struct CardItem: Identifiable {
        let id: Int
        var title: String { "卡片 \(id)" }
        var subtitle: String { "这是卡片 \(id) 的描述内容" }
        var hasImage: Bool { id % 3 == 0 }
        var color: Color { Color.random }
    }

    struct CardView: View {
        let card: CardItem

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                if card.hasImage {
                    Rectangle()
                        .fill(card.color.gradient)
                        .frame(height: 100)
                        .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title)
                        .font(.headline)

                    Text(card.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - 混合内容演示

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct MixedContentDemo: View {
    let items = MixedItem.sampleData

    var body: some View {
        LazyMasonryView(
            items,
            configuration: MasonryConfiguration(lines: .adaptive(minSize: 160), hSpacing: 10, vSpacing: 10),
            sizeCalculator: { item, lineSize in
                let baseHeight: CGFloat = 120
                let extraHeight: CGFloat = item.type == .video ? 40 : 0
                return CGSize(width: lineSize, height: baseHeight + extraHeight)
            }
        ) { item in
            MixedContentCard(item: item)
        }
        .navigationTitle("混合内容")
    }

    struct MixedItem: Identifiable {
        let id = UUID()
        let type: ContentType
        let title: String
        let color: Color

        enum ContentType {
            case text, image, video, quote
        }

        static let sampleData: [MixedItem] = [
            MixedItem(type: .text, title: "文本内容", color: .blue),
            MixedItem(type: .image, title: "图片内容", color: .green),
            MixedItem(type: .video, title: "视频内容", color: .red),
            MixedItem(type: .quote, title: "引用内容", color: .purple),
            MixedItem(type: .text, title: "另一个文本", color: .orange),
            MixedItem(type: .image, title: "另一张图片", color: .pink),
        ] + Array(repeating: [
            MixedItem(type: .text, title: "更多文本", color: .cyan),
            MixedItem(type: .image, title: "更多图片", color: .mint),
            MixedItem(type: .video, title: "更多视频", color: .indigo),
            MixedItem(type: .quote, title: "更多引用", color: .yellow),
        ], count: 5).flatMap { $0 }
    }

    struct MixedContentCard: View {
        let item: MixedItem

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                // 图标和标题
                HStack {
                    Image(systemName: iconName)
                        .foregroundColor(item.color)
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                }

                // 内容区域
                Rectangle()
                    .fill(item.color.opacity(0.3))
                    .frame(height: contentHeight)
                    .overlay(
                        Text(contentText)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
                    .cornerRadius(8)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }

        private var iconName: String {
            switch item.type {
            case .text: return "text.alignleft"
            case .image: return "photo"
            case .video: return "video"
            case .quote: return "quote.bubble"
            }
        }

        private var contentHeight: CGFloat {
            switch item.type {
            case .text: return CGFloat.random(in: 60...120)
            case .image: return CGFloat.random(in: 100...180)
            case .video: return CGFloat.random(in: 80...140)
            case .quote: return CGFloat.random(in: 70...110)
            }
        }

        private var contentText: String {
            switch item.type {
            case .text: return "这是一段文本内容"
            case .image: return "📷"
            case .video: return "🎥"
            case .quote: return "💬"
            }
        }
    }
}

// MARK: - 扩展工具

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

// MARK: - 用户自定义视图演示

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct CustomViewDemo: View {

    // 自定义数据模型
    struct CustomItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
        let priority: Int

        static let sampleData = [
            CustomItem(title: "重要任务", subtitle: "需要立即处理的紧急事项", icon: "exclamationmark.triangle.fill", color: .red, priority: 1),
            CustomItem(title: "会议安排", subtitle: "下午3点团队会议", icon: "calendar", color: .blue, priority: 2),
            CustomItem(title: "代码审查", subtitle: "检查新功能的代码质量", icon: "doc.text.magnifyingglass", color: .green, priority: 2),
            CustomItem(title: "文档更新", subtitle: "更新API文档和使用指南", icon: "doc.text", color: .orange, priority: 3),
            CustomItem(title: "测试用例", subtitle: "编写单元测试和集成测试", icon: "checkmark.circle", color: .purple, priority: 2),
            CustomItem(title: "性能优化", subtitle: "分析和优化应用性能瓶颈", icon: "speedometer", color: .cyan, priority: 3),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 演示1：完全自定义的卡片视图
                DemoSection(
                    title: "自定义任务卡片",
                    code: "LazyMasonryView(tasks) { task in CustomTaskCard(task: task) }"
                ) {
                    LazyMasonryView(
                        CustomItem.sampleData,
                        configuration: MasonryConfiguration(lines: .fixed(2)),
                        sizeCalculator: { item, lineSize in
                            let baseHeight: CGFloat = 120
                            let extraHeight = CGFloat(item.priority * 20)
                            return CGSize(width: lineSize, height: baseHeight + extraHeight)
                        }
                    ) { item in
                        CustomTaskCard(item: item)
                    }
                    .frame(height: 400)
                }

                // 演示2：使用系统组件组合
                DemoSection(
                    title: "系统组件组合",
                    code: "LazyMasonryView(items) { item in VStack { ... } }"
                ) {
                    LazyMasonryView(
                        CustomItem.sampleData.prefix(6),
                        configuration: MasonryConfiguration(lines: .fixed(3)),
                        sizeCalculator: { item, lineSize in
                            let baseHeight: CGFloat = 100
                            return CGSize(width: lineSize, height: baseHeight)
                        }
                    ) { item in
                        VStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.title2)
                                .foregroundColor(item.color)

                            Text(item.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(item.color.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .frame(height: 200)
                }
            }
            .padding()
        }
        .navigationTitle("用户自定义视图")
    }
}

// MARK: - 自定义视图组件

/// 自定义任务卡片
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct CustomTaskCard: View {
    let item: CustomViewDemo.CustomItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头部
            HStack {
                Image(systemName: item.icon)
                    .foregroundColor(item.color)
                    .font(.title3)

                Spacer()

                // 优先级指示器
                Text("P\(item.priority)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(priorityColor)
                    .cornerRadius(4)
            }

            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            Spacer()
        }
        .padding(16)
        .frame(height: CGFloat(120 + item.priority * 20)) // 动态高度
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: item.color.opacity(0.2), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.color.opacity(0.3), lineWidth: 1)
        )
    }

    private var priorityColor: Color {
        switch item.priority {
        case 1: return .red
        case 2: return .orange
        default: return .gray
        }
    }
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview {
    VisualPreviewExample()
}
