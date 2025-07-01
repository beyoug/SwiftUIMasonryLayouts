//
// Copyright (c) Beyoug
//

import SwiftUI

/// SwiftUIMasonryLayouts 示例画廊
/// 展示库的各种功能和使用场景
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct ExampleGallery: View {
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("基础示例") {
                    NavigationLink("回调机制演示", destination: CallbackDemoExample())
                    NavigationLink("真实刷新场景", destination: RealWorldRefreshExample())
                    NavigationLink("调试示例", destination: DebugMasonryExample())
                }
                
                Section("业务集成示例") {
                    NavigationLink("基础瀑布流", destination: BasicMasonryViewExample())
                    NavigationLink("自定义列数", destination: ColumnsMasonryViewExample())
                    NavigationLink("自适应布局", destination: AdaptiveMasonryViewExample())
                    NavigationLink("懒加载瀑布流", destination: BasicLazyMasonryViewExample())
                    NavigationLink("滚动回调", destination: ScrollCallbackLazyMasonryViewExample())
                }
                
                Section("功能特性") {
                    FeatureHighlightView()
                }
            }
            .navigationTitle("SwiftUIMasonryLayouts")
        }
    }
}

/// 功能特性展示
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct FeatureHighlightView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🚀 核心特性")
                .font(.headline)
                .fontWeight(.semibold)
            
            FeatureRow(icon: "⚡", title: "高性能懒加载", description: "只渲染可见项目，支持大数据集")
            FeatureRow(icon: "🔄", title: "智能回调机制", description: "可视范围变化、到达顶部/底部回调")
            FeatureRow(icon: "🎯", title: "精确布局控制", description: "支持固定列数、自适应列数等多种布局")
            FeatureRow(icon: "📱", title: "跨平台兼容", description: "支持 iOS、macOS、tvOS、watchOS、visionOS")
            FeatureRow(icon: "🛡️", title: "类型安全", description: "完全的 Swift 类型安全和泛型支持")
            FeatureRow(icon: "🎨", title: "SwiftUI 原生", description: "完全基于 SwiftUI，无需额外依赖")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

/// 功能行组件
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - 预览

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("示例画廊") {
    ExampleGallery()
}
