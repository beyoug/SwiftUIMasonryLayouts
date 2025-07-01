//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 数据模型

/// 演示用的项目数据模型
struct DemoItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let color: Color
    let height: CGFloat
    let width: CGFloat

    init(id: Int, title: String? = nil, color: Color? = nil, height: CGFloat? = nil, width: CGFloat? = nil) {
        self.id = id
        self.title = title ?? "项目 \(id)"
        self.color = color ?? [.red, .blue, .green, .orange, .purple, .pink, .yellow, .cyan].randomElement() ?? .gray
        self.height = height ?? CGFloat.random(in: 80...200)
        self.width = width ?? 100
    }
}

// MARK: - MasonryView 演示示例

/// 1. 基础 MasonryView - 默认配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct BasicMasonryViewExample: View {
    private let items = (1...5).map { DemoItem(id: $0) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("基础瀑布流布局 - 默认双列")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                MasonryView {
                    ForEach(items) { item in
                        Rectangle()
                            .fill(item.color)
                            .frame(maxWidth: .infinity)
                            .frame(height: item.height)
                            .overlay(
                                Text(item.title)
                                    .foregroundColor(.white)
                                    .font(.caption)
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("基础 MasonryView")
    }
}

/// 2. MasonryView - 自定义列数
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct ColumnsMasonryViewExample: View {
    private let items = (1...30).map { DemoItem(id: $0) }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 30, pinnedViews: []) {
                VStack(spacing: 10) {
                    Text("单列布局")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(lines: .fixed(1)) {
                        ForEach(items.prefix(5)) { item in
                            itemView(item)
                        }
                    }
                }

                VStack(spacing: 10) {
                    Text("三列布局")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(lines: .fixed(3)) {
                        ForEach(items.dropFirst(5).prefix(12)) { item in
                            itemView(item)
                        }
                    }
                }

                VStack(spacing: 10) {
                    Text("四列布局")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(lines: .fixed(4)) {
                        ForEach(items.dropFirst(17).prefix(13)) { item in
                            itemView(item)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("不同列数配置")
    }

    private func itemView(_ item: DemoItem) -> some View {
        Rectangle()
            .fill(item.color)
            .frame(maxWidth: .infinity)
            .frame(height: item.height)
            .overlay(
                Text("\(item.id)")
                    .foregroundColor(.white)
                    .font(.caption)
            )
            .cornerRadius(6)
    }
}

/// 3. MasonryView - 自适应配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct AdaptiveMasonryViewExample: View {
    private let items = (1...30).map { DemoItem(id: $0) }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 30, pinnedViews: []) {
                VStack(spacing: 10) {
                    Text("自适应配置 - 最小列宽 100")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(lines: .adaptive(minSize: 100)) {
                        ForEach(items.prefix(12)) { item in
                            itemView(item, minWidth: 100)
                        }
                    }
                }

                VStack(spacing: 10) {
                    Text("自适应配置 - 最小列宽 150")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(lines: .adaptive(minSize: 150)) {
                        ForEach(items.dropFirst(12).prefix(18)) { item in
                            itemView(item, minWidth: 150)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("自适应配置")
    }

    private func itemView(_ item: DemoItem, minWidth: CGFloat) -> some View {
        Rectangle()
            .fill(item.color)
            .frame(minWidth: minWidth, maxWidth: .infinity)
            .frame(height: item.height)
            .overlay(
                VStack {
                    Text("ID: \(item.id)")
                        .foregroundColor(.white)
                        .font(.caption)
                    Text("最小宽度: \(Int(minWidth))")
                        .foregroundColor(.white)
                        .font(.caption2)
                }
            )
            .cornerRadius(8)
    }
}

/// 4. MasonryView - 水平布局
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct HorizontalMasonryViewExample: View {
    private let items = (1...20).map { DemoItem(id: $0, width: CGFloat.random(in: 80...150)) }

    var body: some View {
        ScrollView(.horizontal) {
            MasonryView(axis: .horizontal, lines: .fixed(3)) {
                ForEach(items) { item in
                    Rectangle()
                        .fill(item.color)
                        .frame(width: item.width, height: 80)
                        .overlay(
                            Text("\(item.id)")
                                .foregroundColor(.white)
                                .font(.caption)
                        )
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("水平布局")
    }
}

/// 5. MasonryView - 间距配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct SpacingMasonryViewExample: View {
    private let items = (1...30).map { DemoItem(id: $0) }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 30, pinnedViews: []) {
                VStack(spacing: 10) {
                    Text("无间距")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(hSpacing: 0, vSpacing: 0) {
                        ForEach(items.prefix(6)) { item in
                            itemView(item)
                        }
                    }
                }

                VStack(spacing: 10) {
                    Text("小间距 (4pt)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(hSpacing: 4, vSpacing: 4) {
                        ForEach(items.dropFirst(6).prefix(6)) { item in
                            itemView(item)
                        }
                    }
                }

                VStack(spacing: 10) {
                    Text("大间距 (16pt)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(hSpacing: 16, vSpacing: 16) {
                        ForEach(items.dropFirst(12).prefix(6)) { item in
                            itemView(item)
                        }
                    }
                }

                VStack(spacing: 10) {
                    Text("不对称间距 (水平:8, 垂直:20)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(hSpacing: 8, vSpacing: 20) {
                        ForEach(items.dropFirst(18).prefix(12)) { item in
                            itemView(item)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("间距配置")
    }

    private func itemView(_ item: DemoItem) -> some View {
        Rectangle()
            .fill(item.color)
            .frame(maxWidth: .infinity)
            .frame(height: item.height)
            .overlay(
                Text("\(item.id)")
                    .foregroundColor(.white)
                    .font(.caption)
            )
            .cornerRadius(6)
    }
}

/// 6. MasonryView - 放置模式
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct PlacementModeMasonryViewExample: View {
    private let items = (1...25).map { DemoItem(id: $0) }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 30, pinnedViews: []) {
                VStack(spacing: 10) {
                    Text("智能填充模式 (.fill)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("项目会被放置在最短的列中")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(placement: .fill) {
                        ForEach(items.prefix(10)) { item in
                            itemView(item, mode: "Fill")
                        }
                    }
                }

                VStack(spacing: 10) {
                    Text("顺序放置模式 (.order)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("项目按顺序依次放置在各列中")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MasonryView(placement: .order) {
                        ForEach(items.dropFirst(10).prefix(15)) { item in
                            itemView(item, mode: "Order")
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("放置模式")
    }

    private func itemView(_ item: DemoItem, mode: String) -> some View {
        Rectangle()
            .fill(item.color)
            .frame(maxWidth: .infinity)
            .frame(height: item.height)
            .overlay(
                VStack {
                    Text("\(item.id)")
                        .foregroundColor(.white)
                        .font(.caption)
                    Text(mode)
                        .foregroundColor(.white)
                        .font(.caption2)
                }
            )
            .cornerRadius(8)
    }
}

/// 7. MasonryView - 响应式布局
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct ResponsiveMasonryViewExample: View {
    private let items = (1...30).map { DemoItem(id: $0) }

    private let breakpoints: [CGFloat: MasonryConfiguration] = [
        0: .columns(1),      // 小屏：单列
        400: .columns(2),    // 中屏：双列
        600: .columns(3),    // 大屏：三列
        800: .columns(4)     // 超大屏：四列
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("响应式布局")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("调整窗口大小查看布局变化")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            MasonryView(breakpoints: breakpoints) {
                ForEach(items) { item in
                    Rectangle()
                        .fill(item.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: item.height)
                        .overlay(
                            VStack {
                                Text("ID: \(item.id)")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                Text("响应式")
                                    .foregroundColor(.white)
                                    .font(.caption2)
                            }
                        )
                        .cornerRadius(8)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("响应式布局")
    }
}

// MARK: - LazyMasonryView 演示示例

/// 8. 基础 LazyMasonryView - 默认配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct BasicLazyMasonryViewExample: View {
    private let items = (1...50).map { DemoItem(id: $0) }

    var body: some View {
        LazyMasonryView(
            items,
            configuration: .default,
            sizeCalculator: { item, lineSize in
                // 使用项目的实际高度
                CGSize(width: lineSize, height: item.height)
            }
        ) { item in
            Rectangle()
                .fill(item.color)
                .frame(maxWidth: .infinity)
                .frame(height: item.height)
                .overlay(
                    VStack {
                        Text("ID: \(item.id)")
                            .foregroundColor(.white)
                            .font(.caption)
                        Text("懒加载")
                            .foregroundColor(.white)
                            .font(.caption2)
                    }
                )
                .cornerRadius(8)
        }
        .padding()
        .navigationTitle("基础 LazyMasonryView")
    }
}

/// 9. LazyMasonryView - 便捷初始化
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct ConvenienceLazyMasonryViewExample: View {
    private let items = (1...60).map { DemoItem(id: $0) }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("双列布局 (默认)")
                    .font(.headline)
                LazyMasonryView(items.prefix(20).map { $0 }) { item in
                    itemView(item, subtitle: "2列")
                }

                Text("三列布局")
                    .font(.headline)
                LazyMasonryView(items.dropFirst(20).prefix(20).map { $0 }, columns: 3) { item in
                    itemView(item, subtitle: "3列")
                }

                Text("四列布局，大间距")
                    .font(.headline)
                LazyMasonryView(items.dropFirst(40).prefix(20).map { $0 }, columns: 4, spacing: 16) { item in
                    itemView(item, subtitle: "4列")
                }
            }
            .padding()
        }
        .navigationTitle("便捷初始化")
    }

    private func itemView(_ item: DemoItem, subtitle: String) -> some View {
        Rectangle()
            .fill(item.color)
            .frame(maxWidth: .infinity)
            .frame(height: item.height)
            .overlay(
                VStack {
                    Text("\(item.id)")
                        .foregroundColor(.white)
                        .font(.caption)
                    Text(subtitle)
                        .foregroundColor(.white)
                        .font(.caption2)
                }
            )
            .cornerRadius(6)
    }
}

/// 10. LazyMasonryView - 响应式配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct ResponsiveLazyMasonryViewExample: View {
    private let items = (1...60).map { DemoItem(id: $0) }

    private let breakpoints: [CGFloat: MasonryConfiguration] = [
        0: .columns(1),
        350: .columns(2),
        500: .columns(3),
        700: .columns(4),
        900: .columns(5)
    ]

    var body: some View {
        LazyMasonryView(items, breakpoints: breakpoints) { item in
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(item.color)
                    .frame(height: 60)
                    .cornerRadius(8)

                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)

                Text("响应式懒加载")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .navigationTitle("响应式懒加载")
    }
}

/// 11. LazyMasonryView - 自定义项目尺寸
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct CustomSizeLazyMasonryViewExample: View {
    private let items = (1...50).map { DemoItem(id: $0) }

    var body: some View {
        LazyMasonryView(
            items,
            configuration: .columns(3),
            sizeCalculator: { item, lineSize in
                // 根据项目ID计算不同的高度
                let baseHeight: CGFloat = 80
                let extraHeight = CGFloat(item.id % 5) * 20
                return CGSize(width: lineSize, height: baseHeight + extraHeight)
            }
        ) { item in
            Rectangle()
                .fill(item.color)
                .overlay(
                    VStack {
                        Text("ID: \(item.id)")
                            .foregroundColor(.white)
                            .font(.caption)
                        Text("自定义尺寸")
                            .foregroundColor(.white)
                            .font(.caption2)
                    }
                )
                .cornerRadius(8)
        }
        .padding()
        .navigationTitle("自定义项目尺寸")
    }
}

/// 12. LazyMasonryView - 滚动回调
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct ScrollCallbackLazyMasonryViewExample: View {
    @State private var items = (1...30).map { DemoItem(id: $0) }
    @State private var visibleRange: String = "无"
    @State private var reachTopCount = 0
    @State private var reachBottomCount = 0
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("滚动状态")
                    .font(.headline)
                Text("可见范围: \(visibleRange)")
                    .font(.caption)
                Text("到达顶部次数: \(reachTopCount)")
                    .font(.caption)
                Text("到达底部次数: \(reachBottomCount)")
                    .font(.caption)
                if isLoading {
                    Text("正在加载更多...")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            LazyMasonryView(items, configuration: .columns(2)) { item in
                Rectangle()
                    .fill(item.color)
                    .frame(maxWidth: .infinity)
                    .frame(height: item.height)
                    .overlay(
                        Text("\(item.id)")
                            .foregroundColor(.white)
                            .font(.caption)
                    )
                    .cornerRadius(8)
            }
            .onVisibleRangeChanged { range in
                visibleRange = "\(range.lowerBound)..<\(range.upperBound)"
            }
            .onReachTop {
                reachTopCount += 1
            }
            .onReachBottom {
                reachBottomCount += 1
                loadMoreItems()
            }
        }
        .padding()
        .navigationTitle("滚动回调")
    }

    private func loadMoreItems() {
        guard !isLoading else { return }
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newItems = (items.count + 1...items.count + 10).map { DemoItem(id: $0) }
            items.append(contentsOf: newItems)
            isLoading = false
        }
    }
}



// MARK: - 预览

/// MasonryView 预览
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("1. 基础 MasonryView") {
    NavigationView {
        BasicMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("2. 不同列数配置") {
    NavigationView {
        ColumnsMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("3. 自适应配置") {
    NavigationView {
        AdaptiveMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("4. 水平布局") {
    NavigationView {
        HorizontalMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("5. 间距配置") {
    NavigationView {
        SpacingMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("6. 放置模式") {
    NavigationView {
        PlacementModeMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("7. 响应式 MasonryView") {
    NavigationView {
        ResponsiveMasonryViewExample()
    }
}

/// LazyMasonryView 预览
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("8. 基础 LazyMasonryView") {
    NavigationView {
        BasicLazyMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("9. 便捷初始化") {
    NavigationView {
        ConvenienceLazyMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("10. 响应式 LazyMasonryView") {
    NavigationView {
        ResponsiveLazyMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("11. 自定义项目尺寸") {
    NavigationView {
        CustomSizeLazyMasonryViewExample()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("12. 滚动回调") {
    NavigationView {
        ScrollCallbackLazyMasonryViewExample()
    }
}


