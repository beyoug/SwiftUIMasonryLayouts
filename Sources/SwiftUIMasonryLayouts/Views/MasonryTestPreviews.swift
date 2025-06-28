//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 测试覆盖预览

/// 专门用于测试覆盖的预览集合
/// 确保所有功能都有对应的可视化测试

// MARK: - 边界条件测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：空数据集") {
    VStack {
        Text("空数据集测试")
            .font(.title2)
            .padding()
        
        ScrollView {
            MasonryView(
                axis: .vertical,
                lines: .fixed(2)
            ) {
                // 空内容 - 应该显示空白区域
            }
        }
        .frame(height: 200)
        .background(Color.gray.opacity(0.1))
        .overlay(
            Text("应该显示空白区域")
                .foregroundColor(.secondary)
        )
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：单个项目") {
    VStack {
        Text("单个项目测试")
            .font(.title2)
            .padding()
        
        ScrollView {
            MasonryView(
                axis: .vertical,
                lines: .fixed(3)
            ) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                    .frame(height: 100)
                    .overlay(
                        Text("唯一项目")
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(height: 200)
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
                        lines: .fixed(2),
                        horizontalSpacing: 30,
                        verticalSpacing: 20
                    ) {
                        ForEach(0..<6) { index in
                            Rectangle()
                                .fill(Color.green)
                                .frame(height: 40)
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

// MARK: - 配置验证测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：负值自动修正") {
    VStack {
        Text("负值自动修正测试")
            .font(.title2)
            .padding()
        
        Text("负间距应该被自动修正为0")
            .font(.caption)
            .foregroundColor(.secondary)
        
        ScrollView {
            MasonryView(
                axis: .vertical,
                lines: .fixed(2),
                horizontalSpacing: -10, // 应该被修正为0
                verticalSpacing: -5     // 应该被修正为0
            ) {
                ForEach(0..<8) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.orange)
                        .frame(height: 60)
                        .overlay(
                            Text("修正\(index)")
                                .font(.caption)
                        )
                }
            }
        }
        .frame(height: 200)
    }
    .padding()
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：自适应边界值") {
    VStack {
        Text("自适应边界值测试")
            .font(.title2)
            .padding()
        
        VStack(spacing: 20) {
            VStack {
                Text("最小尺寸: 1px (边界值)")
                    .font(.caption)
                
                ScrollView {
                    MasonryView(
                        axis: .vertical,
                        lines: .adaptive(minSize: 1) // 极小值
                    ) {
                        ForEach(0..<20) { index in
                            Rectangle()
                                .fill(Color.purple)
                                .frame(height: 30)
                                .overlay(Text("\(index)").font(.caption2))
                        }
                    }
                }
                .frame(height: 100)
            }
            
            VStack {
                Text("最大尺寸: 1000px (大值)")
                    .font(.caption)
                
                ScrollView {
                    MasonryView(
                        axis: .vertical,
                        lines: .adaptive(maxSize: 1000) // 大值
                    ) {
                        ForEach(0..<6) { index in
                            Rectangle()
                                .fill(Color.cyan)
                                .frame(height: 40)
                                .overlay(Text("\(index)"))
                        }
                    }
                }
                .frame(height: 100)
            }
        }
    }
    .padding()
}

// MARK: - 性能测试

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
                    lines: .adaptive(minSize: 80)
                ) {
                    ForEach(0..<1000) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.random)
                            .frame(height: CGFloat.random(in: 60...180))
                            .overlay(
                                VStack {
                                    Text("项目")
                                        .font(.caption2)
                                    Text("\(index)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                            )
                    }
                }
            }
        }
        .navigationTitle("性能测试")
    }
}

// MARK: - 虚拟化测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：虚拟化边界") {
    NavigationView {
        VStack {
            Text("虚拟化边界测试")
                .font(.title2)
                .padding()

            Text("测试虚拟化在极端情况下的表现")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(4),
                data: Array(0..<100000), // 10万个项目
                id: \.self
            ) { index in
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.blue.opacity(0.7))
                    .frame(height: CGFloat.random(in: 80...150))
                    .overlay(
                        VStack {
                            Text("虚拟")
                                .font(.caption2)
                            Text("\(index)")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                    )
            }
        }
        .navigationTitle("虚拟化边界")
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
                data: Array(0..<5000),
                id: \.self
            ) { index in
                Rectangle()
                    .fill(Color.green)
                    .frame(height: 120)
                    .overlay(Text("缓存1-\(index)").font(.caption))
            }
            .tabItem {
                Label("配置A", systemImage: "1.circle")
            }

            // 相同配置 - 应该命中缓存
            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(3),
                data: Array(0..<5000),
                id: \.self
            ) { index in
                Rectangle()
                    .fill(Color.green)
                    .frame(height: 120)
                    .overlay(Text("缓存2-\(index)").font(.caption))
            }
            .tabItem {
                Label("配置A", systemImage: "2.circle")
            }

            // 不同配置 - 应该重新计算
            LazyMasonryView(
                axis: .vertical,
                lines: .fixed(4),
                data: Array(0..<5000),
                id: \.self
            ) { index in
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 120)
                    .overlay(Text("新配置-\(index)").font(.caption))
            }
            .tabItem {
                Label("配置B", systemImage: "3.circle")
            }
        }
        .navigationTitle("缓存测试")
    }
}

// MARK: - 响应式测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：响应式断点") {
    NavigationView {
        VStack {
            Text("响应式断点测试")
                .font(.title2)
                .padding()

            Text("调整窗口大小观察布局变化")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)

            ResponsiveMasonryView(breakpoints: [
                0: MasonryConfiguration(lines: .fixed(1)),
                200: MasonryConfiguration(lines: .fixed(2)),
                400: MasonryConfiguration(lines: .fixed(3)),
                600: MasonryConfiguration(lines: .fixed(4)),
                800: MasonryConfiguration(lines: .fixed(5))
            ]) {
                ForEach(0..<25) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple.opacity(0.7))
                        .frame(height: CGFloat.random(in: 60...120))
                        .overlay(
                            Text("响应\(index)")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .navigationTitle("响应式测试")
    }
}

// MARK: - 错误处理测试

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("测试：错误恢复") {
    VStack {
        Text("错误恢复测试")
            .font(.title2)
            .padding()

        Text("测试各种错误情况的处理")
            .font(.caption)
            .foregroundColor(.secondary)

        ScrollView {
            VStack(spacing: 20) {
                // 测试零行数（应该自动修正为1）
                VStack {
                    Text("零行数测试（自动修正为1行）")
                        .font(.caption)

                    MasonryView(
                        axis: .vertical,
                        lines: .fixedCount(0) // 应该被修正为1
                    ) {
                        ForEach(0..<4) { index in
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 50)
                                .overlay(Text("修正\(index)"))
                        }
                    }
                    .frame(height: 100)
                }

                // 测试负数最小尺寸（应该自动修正）
                VStack {
                    Text("负数最小尺寸测试（自动修正）")
                        .font(.caption)

                    MasonryView(
                        axis: .vertical,
                        lines: .adaptive(minSize: -50) // 应该被修正为1
                    ) {
                        ForEach(0..<6) { index in
                            Rectangle()
                                .fill(Color.orange)
                                .frame(height: 40)
                                .overlay(Text("修正\(index)"))
                        }
                    }
                    .frame(height: 100)
                }
            }
        }
    }
    .padding()
}

// MARK: - 工具扩展

private extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0.3...0.9),
            green: .random(in: 0.3...0.9),
            blue: .random(in: 0.3...0.9)
        )
    }
}
