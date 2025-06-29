//
// Copyright (c) Beyoug
//

import SwiftUI
import SwiftUIMasonryLayouts

// MARK: - 预览专用组件
// 注意：这些组件仅用于预览演示，不是库的公共API

/// 预览项目尺寸协议（仅用于预览演示）
internal protocol PreviewItemSizing {
    /// 内容高度
    var contentHeight: CGFloat { get }
    /// 内容宽度
    var contentWidth: CGFloat { get }
}

/// 预览项目数据模型
internal struct PreviewItem: Identifiable, PreviewItemSizing {
    let id = UUID()
    let title: String
    let height: CGFloat
    let width: CGFloat
    let color: Color

    // MARK: - PreviewItemSizing

    /// 内容高度
    var contentHeight: CGFloat {
        return height
    }

    /// 内容宽度
    var contentWidth: CGFloat {
        return width
    }
}

/// 预览数据生成器
internal struct PreviewData {
    /// 生成指定数量的预览项目（垂直布局用）
    /// - Parameter count: 项目数量
    /// - Returns: 预览项目数组，高度随机，宽度固定
    static func generateItems(count: Int) -> [PreviewItem] {
        Array(0..<count).map { index in
            PreviewItem(
                title: "项目 \(index + 1)",
                height: CGFloat.random(in: 80...300), // 随机高度
                width: 150, // 固定宽度
                color: Color.random
            )
        }
    }
    
    /// 生成指定数量的预览项目（水平布局用）
    /// - Parameter count: 项目数量
    /// - Returns: 预览项目数组，高度固定，宽度随机
    static func generateHorizontalItems(count: Int) -> [PreviewItem] {
        let widths: [CGFloat] = [160, 200, 180, 240, 170, 220, 190, 260, 150, 210, 175, 230]
        return Array(0..<count).map { index in
            PreviewItem(
                title: "项目 \(index + 1)",
                height: 80, // 固定高度
                width: widths[index % widths.count], // 使用预定义宽度
                color: Color.random
            )
        }
    }

    /// 示例数据集（垂直布局）
    static let sampleItems = generateItems(count: 12)
    
    /// 示例数据集（水平布局）
    static let sampleHorizontalItems = generateHorizontalItems(count: 12)
}

/// 垂直布局卡片组件（通用于MasonryView和LazyMasonryView预览）
/// 设计理念：可变高度，固定宽度，适合垂直瀑布流
internal struct VerticalMasonryCard: View {
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

// MARK: - 水平布局专用卡片

/// 水平布局卡片组件（通用于MasonryView和LazyMasonryView预览）
/// 设计理念：固定高度，可变宽度，适合水平瀑布流
internal struct HorizontalMasonryCard: View {
    let item: PreviewItem
    let badge: String?
    
    init(item: PreviewItem, badge: String? = nil) {
        self.item = item
        self.badge = badge
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // 左侧颜色条
            Rectangle()
                .fill(item.color.gradient)
                .frame(width: item.contentWidth * 0.3) // 宽度的30%作为颜色区域
                .cornerRadius(8)
            
            // 右侧内容区域
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
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
            .padding(.vertical, 8)
            
            Spacer(minLength: 0)
        }
        .frame(width: item.contentWidth) // 只设置宽度，让MasonryLayout控制高度
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 工具扩展

/// Color扩展，提供随机颜色生成（仅用于预览）
internal extension Color {
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
