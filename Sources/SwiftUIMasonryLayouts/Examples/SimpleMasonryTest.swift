//
// Copyright (c) Beyoug
//

import SwiftUI

/// 最简单的LazyMasonryView测试，用于调试遮挡问题
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct SimpleMasonryTest: View {
    
    // 简单的测试数据
    private let testItems = Array(1...10).map { TestItem(id: $0, height: CGFloat.random(in: 100...300)) }
    
    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
                // 顶部标题栏
//                Text("简单测试")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue.opacity(0.1))
                
                // LazyMasonryView - 最简单的使用方式
                LazyMasonryView(testItems, configuration: .columns(2, spacing: 8)) { item in
                    Rectangle()
                        .fill(Color.blue.gradient)
                        .frame(height: item.height)
                        .overlay(
                            Text("项目 \(item.id)")
                                .foregroundColor(.white)
                                .font(.caption)
                        )
                        .cornerRadius(8)
                }.navigationTitle("简单测试")
//            }.navigationTitle("简单测试")
//        }.navigationTitle("简单测试")
    }
}

// 简单的测试数据模型
private struct TestItem: Identifiable {
    let id: Int
    let height: CGFloat
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview("简单瀑布流测试") {
    NavigationView {
        SimpleMasonryTest()
    }
}
