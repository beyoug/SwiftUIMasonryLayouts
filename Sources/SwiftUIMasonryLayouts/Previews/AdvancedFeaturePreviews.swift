//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 高级功能和测试预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("便捷方法测试") {
    ScrollView {
        VStack(spacing: 20) {
            Text("垂直便捷方法")
                .font(.headline)

            MasonryView(
                axis: .vertical,
                lines: .fixed(2)
            ) {
                ForEach(PreviewData.sampleItems.prefix(6), id: \.id) { item in
                    PreviewItemCard(item: item, badge: "垂直便捷")
                }
            }

            Text("水平便捷方法")
                .font(.headline)

            MasonryView(
                axis: .horizontal,
                lines: .fixed(2)
            ) {
                ForEach(PreviewData.sampleItems.prefix(6), id: \.id) { item in
                    PreviewItemCard(item: item, badge: "水平便捷")
                }
            }
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
                        axis: .vertical,
                        lines: .fixed(1)
                    ) {
                        ForEach(PreviewData.sampleItems.prefix(4), id: \.id) { item in
                            PreviewItemCard(item: item, badge: "单列预设")
                        }
                    }

                    Text("双列预设")
                        .font(.headline)

                    MasonryView(
                        axis: .vertical,
                        lines: .fixed(2)
                    ) {
                        ForEach(PreviewData.sampleItems.prefix(6), id: \.id) { item in
                            PreviewItemCard(item: item, badge: "双列预设")
                        }
                    }

                    Text("三列预设")
                        .font(.headline)

                    MasonryView(
                        axis: .vertical,
                        lines: .fixed(3)
                    ) {
                        ForEach(PreviewData.sampleItems.prefix(9), id: \.id) { item in
                            PreviewItemCard(item: item, badge: "三列预设")
                        }
                    }
            }
            .padding()
        }
        .navigationTitle("配置预设")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：大数据集性能") {
    NavigationView {
        VStack {
            Text("大数据集性能测试")
                .font(.title2)
                .padding()
            
            Text("1000个项目的渲染性能")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView {
                MasonryView(
                    axis: .vertical,
                    lines: .fixed(4)
                ) {
                    ForEach(0..<1000, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue)
                            .frame(height: CGFloat.random(in: 40...100))
                            .overlay(
                                Text("\(index)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
        .navigationTitle("性能测试")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：虚拟化边界") {
    NavigationView {
        VStack(spacing: 16) {
            Text("虚拟化边界测试")
                .font(.title2)
                .padding(.horizontal)
            
            Text("测试不同数据集大小的虚拟化行为")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            TabView {
                // 小数据集 - 应该同步渲染
                LazyMasonryView(
                    axis: .vertical,
                    lines: .fixed(2),
                    data: Array(0..<10),
                    id: \.self
                ) { index in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: CGFloat(60 + index * 10))
                        .overlay(Text("小:\(index)"))
                }
                .tabItem { Text("小数据集") }
                
                // 大数据集 - 应该虚拟化
                LazyMasonryView(
                    axis: .vertical,
                    lines: .fixed(3),
                    data: Array(0..<500),
                    id: \.self,
                    estimatedItemSize: CGSize(width: 100, height: 80)
                ) { index in
                    Rectangle()
                        .fill(Color.green)
                        .frame(height: CGFloat(50 + index % 100))
                        .overlay(Text("大:\(index)"))
                }
                .tabItem { Text("大数据集") }
            }
        }
        .navigationTitle("虚拟化边界测试")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：缓存效率") {
    NavigationView {
        TabView {
            // 相同配置 - 应该命中缓存
            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(3),
                data: Array(0..<50),
                id: \.self
            ) { index in
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 80)
                    .overlay(Text("缓存1:\(index)"))
            }
            .tabItem { Text("配置A") }
            
            // 相同配置 - 应该命中缓存
            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(3),
                data: Array(0..<50),
                id: \.self
            ) { index in
                Rectangle()
                    .fill(Color.green)
                    .frame(height: 80)
                    .overlay(Text("缓存2:\(index)"))
            }
            .tabItem { Text("配置A (重复)") }
            
            // 不同配置 - 应该重新计算
            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(4), // 不同的列数
                data: Array(0..<50),
                id: \.self
            ) { index in
                Rectangle()
                    .fill(Color.orange)
                    .frame(height: 80)
                    .overlay(Text("新:\(index)"))
            }
            .tabItem { Text("配置B") }
        }
        .navigationTitle("缓存效率测试")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：错误恢复") {
    VStack {
        Text("错误恢复测试")
            .font(.title2)
            .padding()
        
        Text("测试各种边界条件和错误情况")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom)
        
        ScrollView {
            VStack(spacing: 20) {
                // 测试零列数（应该自动修正为1）
                VStack {
                    Text("零列数测试")
                        .font(.headline)
                    
                    MasonryView(
                        axis: .vertical,
                        lines: .fixed(0) // 应该被修正为1
                    ) {
                        ForEach(0..<3) { index in
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 60)
                                .overlay(Text("修正:\(index)"))
                        }
                    }
                    .frame(height: 100)
                }
                
                // 测试极大列数
                VStack {
                    Text("极大列数测试")
                        .font(.headline)
                    
                    MasonryView(
                        axis: .vertical,
                        lines: .fixed(100) // 极大值
                    ) {
                        ForEach(0..<5) { index in
                            Rectangle()
                                .fill(Color.blue)
                                .frame(height: 40)
                                .overlay(Text("极大:\(index)"))
                        }
                    }
                    .frame(height: 80)
                }
            }
        }
    }
    .padding()
}

// MARK: - 工具扩展

// Color.random扩展已在MasonryViewPreviews.swift中定义
