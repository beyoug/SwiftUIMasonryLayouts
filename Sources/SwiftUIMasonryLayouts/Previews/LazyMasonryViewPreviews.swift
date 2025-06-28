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
