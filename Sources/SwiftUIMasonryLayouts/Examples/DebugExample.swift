//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 调试示例

/// 用于调试视图叠加问题的示例
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct DebugMasonryExample: View {
    private let items = (1...30).map { DemoItem(id: $0) }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("调试瀑布流布局")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // 测试1：单列布局
                VStack(alignment: .leading, spacing: 8) {
                    Text("单列布局 (5个项目)")
                        .font(.headline)
                    
                    MasonryView(lines: .fixed(1)) {
                        ForEach(items.prefix(5)) { item in
                            debugItemView(item, section: "单列")
                        }
                    }
                    .border(Color.red, width: 1)
                }
                
                // 测试2：三列布局
                VStack(alignment: .leading, spacing: 8) {
                    Text("三列布局 (12个项目)")
                        .font(.headline)
                    
                    MasonryView(lines: .fixed(3)) {
                        ForEach(items.dropFirst(5).prefix(12)) { item in
                            debugItemView(item, section: "三列")
                        }
                    }
                    .border(Color.blue, width: 1)
                }
                
                // 测试3：四列布局
                VStack(alignment: .leading, spacing: 8) {
                    Text("四列布局 (13个项目)")
                        .font(.headline)
                    
                    MasonryView(lines: .fixed(4)) {
                        ForEach(items.dropFirst(17).prefix(13)) { item in
                            debugItemView(item, section: "四列")
                        }
                    }
                    .border(Color.green, width: 1)
                }
                
                // 测试4：自适应配置测试
                VStack(alignment: .leading, spacing: 8) {
                    Text("自适应配置 - 最小列宽 100")
                        .font(.headline)

                    MasonryView(lines: .adaptive(minSize: 100)) {
                        ForEach(items.dropFirst(20).prefix(10)) { item in
                            debugItemView(item, section: "自适应")
                        }
                    }
                    .border(Color.purple, width: 1)
                }

                // 测试5：空数据测试
                VStack(alignment: .leading, spacing: 8) {
                    Text("空数据测试")
                        .font(.headline)

                    MasonryView(lines: .fixed(2)) {
                        ForEach(items.dropFirst(30)) { item in
                            debugItemView(item, section: "空数据")
                        }
                    }
                    .border(Color.orange, width: 1)
                }
            }
            .padding()
        }
        .navigationTitle("调试示例")
    }
    
    private func debugItemView(_ item: DemoItem, section: String) -> some View {
        Rectangle()
            .fill(item.color)
            .frame(maxWidth: .infinity)
            .frame(height: item.height)
            .overlay(
                VStack(spacing: 2) {
                    Text("\(item.id)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .fontWeight(.bold)
                    Text(section)
                        .foregroundColor(.white)
                        .font(.caption2)
                }
            )
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("调试示例") {
    NavigationView {
        DebugMasonryExample()
    }
}
