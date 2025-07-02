//
// Copyright (c) Beyoug
//

import SwiftUI

/// 内容自适应高度演示
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct ContentAdaptiveExample: View {
    
    // MARK: - 测试数据
    
    private let adaptiveItems = [
        AdaptiveTestItem(
            id: 1,
            title: "短标题",
            description: "简短描述",
            tags: ["标签1"],
            color: .blue
        ),
        AdaptiveTestItem(
            id: 2,
            title: "这是一个比较长的标题，用来测试多行文本的自适应效果",
            description: "这是一个相对较长的描述文本，用来演示当内容较多时，卡片高度如何自动调整以适应内容。这样可以更好地展示瀑布流布局的自适应特性。",
            tags: ["长文本", "自适应", "测试"],
            color: .green
        ),
        AdaptiveTestItem(
            id: 3,
            title: "中等长度标题示例",
            description: "中等长度的描述内容，不长不短。",
            tags: ["中等", "示例"],
            color: .orange
        ),
        AdaptiveTestItem(
            id: 4,
            title: "超级长标题：这是一个非常非常长的标题，用来测试当标题文本过长时的换行和布局效果",
            description: "超长描述：这是一个非常详细和冗长的描述文本，包含了大量的信息和细节。它的目的是测试当描述内容非常多时，卡片的高度是否能够正确地自适应内容，而不是使用固定的高度值。这样的测试对于确保瀑布流布局的灵活性和实用性非常重要。",
            tags: ["超长文本", "详细描述", "自适应测试", "布局验证", "用户体验"],
            color: .purple
        ),
        AdaptiveTestItem(
            id: 5,
            title: "极简",
            description: "简",
            tags: ["极简"],
            color: .red
        ),
        AdaptiveTestItem(
            id: 6,
            title: "标准长度的标题文本",
            description: "这是一个标准长度的描述文本，既不太短也不太长，用来展示正常情况下的卡片布局效果。",
            tags: ["标准", "正常", "布局"],
            color: .cyan
        ),
        AdaptiveTestItem(
            id: 7,
            title: "多标签测试项目",
            description: "这个项目有很多标签，用来测试标签区域的自适应布局。",
            tags: ["标签1", "标签2", "标签3", "标签4", "标签5", "标签6", "标签7", "标签8"],
            color: .yellow
        ),
        AdaptiveTestItem(
            id: 8,
            title: "无标签项目",
            description: "这个项目没有标签，用来测试当标签为空时的布局效果。",
            tags: [],
            color: .pink
        )
    ]
    
    // MARK: - 视图主体
    
    var body: some View {
        NavigationView {
            ScrollView {
                // 🎯 使用标准 MasonryLayout 实现真正的内容自适应
                MasonryLayout(configuration: .columns(2)) {
                    ForEach(adaptiveItems) { item in
                        adaptiveItemView(item)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("内容自适应高度")
        }
    }
    
    // MARK: - 自适应卡片视图
    
    private func adaptiveItemView(_ item: AdaptiveTestItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头部：ID 和颜色指示器
            HStack {
                Text("#\(item.id)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(6)
                
                Spacer()
                
                Circle()
                    .fill(item.color)
                    .frame(width: 12, height: 12)
            }
            
            // 标题 - 自适应行数
            Text(item.title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true) // 🎯 关键：允许垂直扩展
            
            // 描述 - 自适应行数
            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true) // 🎯 关键：允许垂直扩展
                .opacity(0.8)
            
            // 标签区域 - 自适应布局
            if !item.tags.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 60), spacing: 4)
                ], spacing: 4) {
                    ForEach(item.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(16)
        // 🎯 关键：不设置固定高度，让内容决定高度
        .background(item.color.gradient)
        .foregroundColor(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 自适应测试数据模型

struct AdaptiveTestItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let tags: [String]
    let color: Color
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("内容自适应高度") {
    ContentAdaptiveExample()
}
