//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 预览数据模型

/// 预览项目数据模型
struct PreviewItem: Identifiable, PreviewItemProtocol {
    let id = UUID()
    let title: String
    let height: CGFloat
    let color: Color

    // MARK: - PreviewItemProtocol

    /// 内容高度（Rectangle的高度）
    var contentHeight: CGFloat {
        return height
    }

    /// 内容宽度（使用默认值）
    var contentWidth: CGFloat {
        return 150 // 默认宽度
    }
}

/// 预览数据生成器
struct PreviewData {
    /// 生成指定数量的预览项目
    /// - Parameter count: 项目数量
    /// - Returns: 预览项目数组
    static func generateItems(count: Int) -> [PreviewItem] {
        Array(0..<count).map { index in
            PreviewItem(
                title: "项目 \(index + 1)",
                height: CGFloat.random(in: 80...200),
                color: Color.random
            )
        }
    }
    
    /// 示例数据集
    static let sampleItems = generateItems(count: 12)
}

/// 预览项目卡片视图
struct PreviewItemCard: View {
    let item: PreviewItem
    let badge: String?
    
    init(item: PreviewItem, badge: String? = nil) {
        self.item = item
        self.badge = badge
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(item.color.gradient)
                .frame(height: item.height)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if let badge = badge {
                    Text(badge)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

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
                PreviewItemCard(item: item, badge: "基础")
            }
        }
        .padding()
    }
}


// MARK: - 工具扩展

/// Color扩展，提供随机颜色生成
extension Color {
    /// 生成随机颜色
    /// - Returns: 随机的Color实例
    static var random: Color {
        Color(
            red: .random(in: 0.3...0.9),
            green: .random(in: 0.3...0.9),
            blue: .random(in: 0.3...0.9)
        )
    }
}
