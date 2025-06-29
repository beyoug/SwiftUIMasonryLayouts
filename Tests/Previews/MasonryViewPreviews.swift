//
// Copyright (c) Beyoug
//

import SwiftUI


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
                VerticalMasonryCard(item: item, badge: "基础")
            }
        }
        .padding()
    }
}

// MARK: - MasonryView 水平布局预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("水平瀑布流") {
    ScrollView(.horizontal) {
        MasonryView(
            axis: .horizontal,
            lines: .fixed(3),
            horizontalSpacing: 12,
            verticalSpacing: 12,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleHorizontalItems) { item in
                HorizontalMasonryCard(item: item, badge: "水平")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("水平自适应行数") {
    ScrollView(.horizontal) {
        MasonryView(
            axis: .horizontal,
            lines: .adaptive(sizeConstraint: .min(60)),
            horizontalSpacing: 8,
            verticalSpacing: 8,
            placementMode: .order
        ) {
            ForEach(PreviewData.sampleHorizontalItems) { item in
                HorizontalMasonryCard(item: item, badge: "自适应")
            }
        }
        .padding()
    }
}

// MARK: - 简单水平布局测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("简单水平测试") {
    VStack(spacing: 20) {
        Text("水平布局测试 - 期望：2行，从左到右")
            .font(.headline)

        ScrollView(.horizontal) {
            MasonryView(
                axis: .horizontal,
                lines: .fixed(2),
                horizontalSpacing: 10,
                verticalSpacing: 10,
                placementMode: .order
            ) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 50)
                    .overlay(Text("1").foregroundColor(.white).font(.title2))

                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 150, height: 50)
                    .overlay(Text("2").foregroundColor(.white).font(.title2))

                Rectangle()
                    .fill(Color.green)
                    .frame(width: 120, height: 50)
                    .overlay(Text("3").foregroundColor(.white).font(.title2))

                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 80, height: 50)
                    .overlay(Text("4").foregroundColor(.white).font(.title2))

                Rectangle()
                    .fill(Color.purple)
                    .frame(width: 90, height: 50)
                    .overlay(Text("5").foregroundColor(.white).font(.title2))

                Rectangle()
                    .fill(Color.pink)
                    .frame(width: 110, height: 50)
                    .overlay(Text("6").foregroundColor(.white).font(.title2))
            }
            .background(Color.gray.opacity(0.2))
            .padding()
        }
        .frame(height: 140)
        .border(Color.black, width: 1)

        Text("期望布局：\n行1: [1][3][5] \n行2: [2][4][6]")
            .font(.caption)
            .multilineTextAlignment(.center)
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("水平紧凑布局") {
    ScrollView(.horizontal) {
        MasonryView(
            axis: .horizontal,
            lines: .fixed(4),
            horizontalSpacing: 6,
            verticalSpacing: 6,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleHorizontalItems) { item in
                HorizontalMasonryCard(item: item, badge: "紧凑")
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("水平顺序放置") {
    ScrollView(.horizontal) {
        MasonryView(
            axis: .horizontal,
            lines: .fixed(2),
            horizontalSpacing: 16,
            verticalSpacing: 12,
            placementMode: .order
        ) {
            ForEach(PreviewData.sampleHorizontalItems) { item in
                HorizontalMasonryCard(item: item, badge: "顺序")
            }
        }
        .padding()
    }
}

// MARK: - 垂直布局扩展测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("垂直自适应列数") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .adaptive(sizeConstraint: .min(120)),
            horizontalSpacing: 12,
            verticalSpacing: 8,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleItems) { item in
                VerticalMasonryCard(item: item, badge: "自适应")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("垂直三列布局") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(3),
            horizontalSpacing: 8,
            verticalSpacing: 12,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleItems) { item in
                VerticalMasonryCard(item: item, badge: "三列")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("垂直顺序模式") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 12,
            verticalSpacing: 8,
            placementMode: .order
        ) {
            ForEach(PreviewData.sampleItems) { item in
                VerticalMasonryCard(item: item, badge: "顺序")
            }
        }
        .padding()
    }
}

// MARK: - 边界情况测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("单列垂直布局") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(1),
            horizontalSpacing: 0,
            verticalSpacing: 8,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleItems.prefix(8)) { item in
                VerticalMasonryCard(item: item, badge: "单列")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("单行水平布局") {
    ScrollView(.horizontal) {
        MasonryView(
            axis: .horizontal,
            lines: .fixed(1),
            horizontalSpacing: 8,
            verticalSpacing: 0,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleHorizontalItems.prefix(8)) { item in
                HorizontalMasonryCard(item: item, badge: "单行")
            }
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("零间距测试") {
    VStack(spacing: 20) {
        Text("零间距测试")
            .font(.headline)

        ScrollView {
            MasonryView(
                axis: .vertical,
                lines: .fixed(3),
                horizontalSpacing: 0,
                verticalSpacing: 0,
                placementMode: .fill
            ) {
                ForEach(PreviewData.sampleItems.prefix(9)) { item in
                    VerticalMasonryCard(item: item, badge: "零间距")
                }
            }
            .padding()
        }
        .frame(height: 300)
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("大间距测试") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 24,
            verticalSpacing: 20,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleItems.prefix(6)) { item in
                VerticalMasonryCard(item: item, badge: "大间距")
            }
        }
        .padding()
    }
}

// MARK: - 水平布局自适应测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("水平自适应最大行高") {
    ScrollView(.horizontal) {
        MasonryView(
            axis: .horizontal,
            lines: .adaptive(sizeConstraint: .max(80)),
            horizontalSpacing: 8,
            verticalSpacing: 8,
            placementMode: .fill
        ) {
            ForEach(PreviewData.sampleHorizontalItems) { item in
                HorizontalMasonryCard(item: item, badge: "最大行高")
            }
        }
        .padding()
    }
}

// MARK: - 性能测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("多项目性能测试") {
    let manyItems = PreviewData.generateItems(count: 50)

    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(3),
            horizontalSpacing: 8,
            verticalSpacing: 8,
            placementMode: .fill
        ) {
            ForEach(manyItems) { item in
                VerticalMasonryCard(item: item, badge: "性能")
            }
        }
        .padding()
    }
}

// MARK: - 混合内容测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("混合内容测试") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 12,
            verticalSpacing: 8,
            placementMode: .fill
        ) {
            // 文本卡片
            Text("短文本")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)

            // 长文本卡片
            Text("这是一个很长的文本内容，用来测试不同高度的项目在瀑布流中的表现效果")
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)

            // 图片占位符
            Rectangle()
                .fill(Color.orange.opacity(0.3))
                .frame(height: 120)
                .overlay(Text("图片占位符"))
                .cornerRadius(8)

            // 按钮
            Button("点击按钮") { }
                .padding()
                .background(Color.purple.opacity(0.2))
                .cornerRadius(8)

            // 更多混合内容
            ForEach(PreviewData.sampleItems.prefix(6)) { item in
                VerticalMasonryCard(item: item, badge: "混合")
            }
        }
        .padding()
    }
}






