//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 简化的智能尺寸演示

/// 简化的智能尺寸演示视图
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct SimpleSizingExample: View {
    @State private var selectedMode: SimpleSizingMode = .golden
    @State private var itemCount: Int = 20
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 控制面板
                controlPanel
                
                // 演示区域
                demoArea
            }
            .navigationTitle("简化智能尺寸")
        }
    }
    
    private var controlPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("尺寸模式")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Button("黄金比例") { selectedMode = .golden }
                        .buttonStyle(modeButtonStyle(isSelected: selectedMode == .golden))
                    Button("正方形") { selectedMode = .square }
                        .buttonStyle(modeButtonStyle(isSelected: selectedMode == .square))
                    Button("经典") { selectedMode = .classic }
                        .buttonStyle(modeButtonStyle(isSelected: selectedMode == .classic))
                }
                
                HStack {
                    Button("宽屏") { selectedMode = .widescreen }
                        .buttonStyle(modeButtonStyle(isSelected: selectedMode == .widescreen))
                    Button("自适应") { selectedMode = .adaptive }
                        .buttonStyle(modeButtonStyle(isSelected: selectedMode == .adaptive))
                    Spacer()
                }
            }
            
            HStack {
                Text("项目数量: \(itemCount)")
                Spacer()
                Stepper("", value: $itemCount, in: 10...30, step: 5)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func modeButtonStyle(isSelected: Bool) -> some ButtonStyle {
        return SimpleButtonStyle(isSelected: isSelected)
    }
    
    private var demoArea: some View {
        let configuration = MasonryConfiguration(
            lines: MasonryLines.fixed(2),
            hSpacing: 12,
            vSpacing: 12
        ).withSimpleSizing(SimpleSizingConfiguration(mode: selectedMode))
        
        return LazyMasonryView(
            Array(0..<itemCount).map { SimpleDemoItem(id: $0) },
            configuration: configuration
        ) { item in
            SimpleDemoCard(item: item, mode: selectedMode)
        }
    }
}

// MARK: - 简单按钮样式

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct SimpleButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - 简单演示数据

/// 简单演示项目
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct SimpleDemoItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let content: String
    let color: Color
    
    init(id: Int) {
        self.id = id
        self.title = "项目 \(id + 1)"
        self.content = Self.generateContent(for: id)
        self.color = Self.generateColor(for: id)
    }
    
    private static func generateContent(for id: Int) -> String {
        let contents = [
            "简短内容",
            "这是中等长度的内容描述",
            "这是一个较长的内容描述，包含更多的信息和详细说明",
            "图片",
            "文本内容"
        ]
        return contents[id % contents.count]
    }
    
    private static func generateColor(for id: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink]
        return colors[id % colors.count]
    }
}

// MARK: - 简单演示卡片

/// 简单演示卡片
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct SimpleDemoCard: View {
    let item: SimpleDemoItem
    let mode: SimpleSizingMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Circle()
                    .fill(item.color)
                    .frame(width: 12, height: 12)
            }
            
            Text(item.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
            
            HStack {
                Spacer()
                Text(modeDescription)
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var modeDescription: String {
        switch mode {
        case .golden: return "黄金比例"
        case .square: return "正方形"
        case .classic: return "经典比例"
        case .widescreen: return "宽屏比例"
        case .custom: return "自定义"
        case .adaptive: return "自适应"
        }
    }
}

// MARK: - 对比演示

/// 简化的对比演示
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct SimpleSizingComparisonExample: View {
    private let sampleItems = Array(0..<12).map { SimpleDemoItem(id: $0) }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    comparisonSection(title: "黄金比例", mode: .golden)
                    comparisonSection(title: "正方形", mode: .square)
                    comparisonSection(title: "自适应", mode: .adaptive)
                }
                .padding()
            }
            .navigationTitle("尺寸对比")
        }
    }
    
    private func comparisonSection(title: String, mode: SimpleSizingMode) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("比例: \(String(format: "%.3f", mode.ratio))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyMasonryView(
                Array(sampleItems.prefix(6)),
                configuration: MasonryConfiguration(
                    lines: MasonryLines.fixed(2),
                    hSpacing: 8,
                    vSpacing: 8
                ).withSimpleSizing(SimpleSizingConfiguration(mode: mode))
            ) { item in
                CompactCard(item: item)
            }
            .frame(height: 250)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - 紧凑卡片

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct CompactCard: View {
    let item: SimpleDemoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(item.content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Spacer()
                Circle()
                    .fill(item.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 1)
    }
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct SimpleSizingExample_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimpleSizingExample()
                .previewDisplayName("简化智能尺寸")
            
            SimpleSizingComparisonExample()
                .previewDisplayName("尺寸对比")
        }
    }
}
