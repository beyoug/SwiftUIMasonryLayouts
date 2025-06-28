//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - ResponsiveMasonryView 响应式预览

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
            PreviewItemCard(item: item, badge: "自定义")
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("响应式断点测试") {
    NavigationView {
        VStack {
            Text("响应式断点测试")
                .font(.title2)
                .padding()
            
            Text("调整窗口大小观察列数变化")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView {
                ResponsiveMasonryView(
                    breakpoints: [
                        320: MasonryConfiguration(axis: .vertical, lines: .fixed(1)),
                        480: MasonryConfiguration(axis: .vertical, lines: .fixed(2)),
                        768: MasonryConfiguration(axis: .vertical, lines: .fixed(3)),
                        1024: MasonryConfiguration(axis: .vertical, lines: .fixed(4))
                    ]
                ) {
                    ForEach(0..<20, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple)
                            .frame(height: CGFloat.random(in: 60...120))
                            .overlay(
                                Text("响应式 \(index)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
        .navigationTitle("响应式断点")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("响应式 - 移动优先") {
    ResponsiveMasonryView(breakpoints: [
        0: MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(1),
            horizontalSpacing: 8,
            verticalSpacing: 8
        ),
        375: MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 12,
            verticalSpacing: 10
        ),
        768: MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(3),
            horizontalSpacing: 16,
            verticalSpacing: 12
        ),
        1024: MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(4),
            horizontalSpacing: 20,
            verticalSpacing: 16
        )
    ]) {
        ForEach(PreviewData.generateItems(count: 24)) { item in
            PreviewItemCard(item: item, badge: "移动优先")
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("响应式 - 自适应列") {
    ResponsiveMasonryView(breakpoints: [
        0: MasonryConfiguration(
            axis: .vertical,
            lines: .adaptive(minSize: 150),
            horizontalSpacing: 8,
            verticalSpacing: 8
        ),
        600: MasonryConfiguration(
            axis: .vertical,
            lines: .adaptive(minSize: 180),
            horizontalSpacing: 12,
            verticalSpacing: 10
        ),
        900: MasonryConfiguration(
            axis: .vertical,
            lines: .adaptive(minSize: 200),
            horizontalSpacing: 16,
            verticalSpacing: 12
        )
    ]) {
        ForEach(PreviewData.generateItems(count: 20)) { item in
            PreviewItemCard(item: item, badge: "自适应响应")
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("响应式 - 不同放置模式") {
    ResponsiveMasonryView(breakpoints: [
        0: MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(2),
            placementMode: .order
        ),
        600: MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(3),
            placementMode: .fill
        ),
        900: MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(4),
            placementMode: .fill
        )
    ]) {
        ForEach(PreviewData.generateItems(count: 18)) { item in
            PreviewItemCard(item: item, badge: "放置模式")
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("响应式 - 水平切换") {
    ResponsiveMasonryView(breakpoints: [
        0: MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(1),
            horizontalSpacing: 8,
            verticalSpacing: 8
        ),
        480: MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 12,
            verticalSpacing: 10
        ),
        768: MasonryConfiguration(
            axis: .horizontal,
            lines: .fixed(2),
            horizontalSpacing: 16,
            verticalSpacing: 12
        ),
        1024: MasonryConfiguration(
            axis: .horizontal,
            lines: .fixed(3),
            horizontalSpacing: 20,
            verticalSpacing: 16
        )
    ]) {
        ForEach(PreviewData.generateItems(count: 16)) { item in
            PreviewItemCard(item: item, badge: "轴切换")
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("响应式 - 复杂断点") {
    NavigationView {
        ResponsiveMasonryView(breakpoints: [
            0: MasonryConfiguration(
                axis: .vertical,
                lines: .fixed(1),
                horizontalSpacing: 4,
                verticalSpacing: 4,
                placementMode: .order
            ),
            320: MasonryConfiguration(
                axis: .vertical,
                lines: .fixed(2),
                horizontalSpacing: 6,
                verticalSpacing: 6,
                placementMode: .order
            ),
            480: MasonryConfiguration(
                axis: .vertical,
                lines: .adaptive(minSize: 140),
                horizontalSpacing: 8,
                verticalSpacing: 8,
                placementMode: .fill
            ),
            768: MasonryConfiguration(
                axis: .vertical,
                lines: .adaptive(minSize: 160),
                horizontalSpacing: 12,
                verticalSpacing: 10,
                placementMode: .fill
            ),
            1024: MasonryConfiguration(
                axis: .vertical,
                lines: .adaptive(minSize: 180),
                horizontalSpacing: 16,
                verticalSpacing: 12,
                placementMode: .fill
            )
        ]) {
            ForEach(PreviewData.generateItems(count: 30)) { item in
                PreviewItemCard(item: item, badge: "复杂")
            }
        }
        .navigationTitle("复杂响应式")
    }
}
