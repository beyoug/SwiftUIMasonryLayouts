//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 边界条件和测试预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("空数据集") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2)
        ) {
            // 空内容
        }
        .frame(height: 200)
        .overlay(
            Text("空数据集测试")
                .foregroundColor(.secondary)
        )
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("单个项目") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(3)
        ) {
            PreviewItemCard(item: PreviewData.sampleItems.first!, badge: "单项")
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("极小间距") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(4),
            horizontalSpacing: 1,
            verticalSpacing: 1
        ) {
            ForEach(PreviewData.sampleItems.prefix(8), id: \.id) { item in
                PreviewItemCard(item: item, badge: "极小间距")
            }
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("极大间距") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: 50,
            verticalSpacing: 30
        ) {
            ForEach(PreviewData.sampleItems.prefix(6), id: \.id) { item in
                PreviewItemCard(item: item, badge: "极大间距")
            }
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("混合尺寸项目") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(3)
        ) {
            Rectangle().fill(Color.red).frame(height: 50)
            Rectangle().fill(Color.blue).frame(height: 150)
            Rectangle().fill(Color.green).frame(height: 80)
            Rectangle().fill(Color.orange).frame(height: 200)
            Rectangle().fill(Color.purple).frame(height: 30)
            Rectangle().fill(Color.pink).frame(height: 120)
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("性能测试 - 中等数据集") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .adaptive(minSize: 100)
        ) {
            ForEach(0..<500, id: \.self) { index in
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: CGFloat.random(in: 50...150))
                    .overlay(Text("\(index)"))
            }
        }
    }
    .navigationTitle("性能测试")
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("错误处理 - 负间距") {
    ScrollView {
        MasonryView(
            axis: .vertical,
            lines: .fixed(2),
            horizontalSpacing: -10, // 负值会被自动修正
            verticalSpacing: -5    // 负值会被自动修正
        ) {
            ForEach(PreviewData.sampleItems.prefix(6), id: \.id) { item in
                PreviewItemCard(item: item, badge: "负间距修正")
            }
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：极端间距") {
    VStack {
        Text("极端间距测试")
            .font(.title2)
            .padding()
        
        HStack {
            VStack {
                Text("零间距")
                    .font(.caption)
                
                ScrollView {
                    MasonryView(
                        axis: .vertical,
                        lines: .fixed(3),
                        horizontalSpacing: 0,
                        verticalSpacing: 0
                    ) {
                        ForEach(0..<9) { index in
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 50)
                                .overlay(Text("\(index)"))
                        }
                    }
                }
                .frame(height: 150)
            }
            
            VStack {
                Text("大间距")
                    .font(.caption)
                
                ScrollView {
                    MasonryView(
                        axis: .vertical,
                        lines: .fixed(3),
                        horizontalSpacing: 50,
                        verticalSpacing: 30
                    ) {
                        ForEach(0..<9) { index in
                            Rectangle()
                                .fill(Color.blue)
                                .frame(height: 50)
                                .overlay(Text("\(index)"))
                        }
                    }
                }
                .frame(height: 150)
            }
        }
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：负值自动修正") {
    VStack {
        Text("负值自动修正测试")
            .font(.title2)
            .padding()
        
        ScrollView {
            MasonryView(
                axis: .vertical,
                lines: .fixed(2),
                horizontalSpacing: -10, // 负值应该被修正为0
                verticalSpacing: -5    // 负值应该被修正为0
            ) {
                ForEach(0..<6) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange)
                        .frame(height: CGFloat.random(in: 60...120))
                        .overlay(
                            Text("项目 \(index)")
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .frame(height: 200)
        
        Text("负值间距应该被自动修正为0")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：自适应边界值") {
    VStack {
        Text("自适应边界值测试")
            .font(.title2)
            .padding()
        
        HStack {
            VStack {
                Text("最小尺寸: 1")
                    .font(.caption)
                
                ScrollView {
                    MasonryView(
                        axis: .vertical,
                        lines: .adaptive(minSize: 1) // 极小值
                    ) {
                        ForEach(0..<12) { index in
                            Rectangle()
                                .fill(Color.green)
                                .frame(height: 40)
                                .overlay(Text("\(index)"))
                        }
                    }
                }
                .frame(height: 120)
            }
            
            VStack {
                Text("最小尺寸: 200")
                    .font(.caption)
                
                ScrollView {
                    MasonryView(
                        axis: .vertical,
                        lines: .adaptive(minSize: 200) // 大值
                    ) {
                        ForEach(0..<6) { index in
                            Rectangle()
                                .fill(Color.purple)
                                .frame(height: 40)
                                .overlay(Text("\(index)"))
                        }
                    }
                }
                .frame(height: 120)
            }
        }
    }
    .padding()
}
