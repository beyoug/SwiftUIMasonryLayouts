//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - DataMasonryView 数据驱动预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动") {
    ScrollView {
        DataMasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 6,
            data: PreviewData.sampleItems,
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "数据驱动")
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("懒加载模拟") {
    let largeDataSet = PreviewData.generateItems(count: 100)

    ScrollView {
        DataMasonryView(
            axis: .vertical,
            lines: .fixed(3),
            data: largeDataSet,
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "懒加载")
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动 - 三列") {
    ScrollView {
        DataMasonryView(
            axis: .vertical,
            lines: .fixed(3),
            horizontalSpacing: 10,
            verticalSpacing: 8,
            data: PreviewData.generateItems(count: 20),
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "三列数据")
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动 - 水平布局") {
    ScrollView(.horizontal) {
        DataMasonryView(
            axis: .horizontal,
            lines: .fixed(2),
            horizontalSpacing: 12,
            verticalSpacing: 10,
            data: PreviewData.generateItems(count: 15),
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "水平数据")
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动 - 自适应列") {
    ScrollView {
        DataMasonryView(
            axis: .vertical,
            lines: .adaptive(minSize: 140),
            horizontalSpacing: 8,
            verticalSpacing: 6,
            data: PreviewData.generateItems(count: 25),
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "自适应数据")
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动 - 填充模式") {
    ScrollView {
        DataMasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 6,
            placementMode: .fill,
            data: PreviewData.generateItems(count: 18),
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "填充数据")
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动 - 顺序模式") {
    ScrollView {
        DataMasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 8,
            verticalSpacing: 6,
            placementMode: .order,
            data: PreviewData.generateItems(count: 18),
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "顺序数据")
        }
        .padding()
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动 - 大数据集") {
    NavigationView {
        ScrollView {
            DataMasonryView(
                axis: .vertical,
                lines: .fixed(4),
                horizontalSpacing: 6,
                verticalSpacing: 4,
                data: PreviewData.generateItems(count: 200),
                id: \.id
            ) { item in
                PreviewItemCard(item: item, badge: "大数据")
            }
            .padding()
        }
        .navigationTitle("大数据集测试")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动 - 空数据集") {
    ScrollView {
        DataMasonryView(
            axis: .vertical,
            lines: .fixed(2),
            data: [] as [PreviewItem],
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "空数据")
        }
        .padding()
        .overlay(
            Text("空数据集")
                .foregroundColor(.secondary)
        )
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("数据驱动 - 单项数据") {
    ScrollView {
        DataMasonryView(
            axis: .vertical,
            lines: .fixed(3),
            data: [PreviewData.sampleItems.first!],
            id: \.id
        ) { item in
            PreviewItemCard(item: item, badge: "单项数据")
        }
        .padding()
    }
}
