//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 基础瀑布流视图

/// 基于iOS 18.0+ Layout协议的现代瀑布流视图
/// 提供简洁的API和高性能布局
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct MasonryView<Content: View>: View {

    /// 布局轴向
    private let axis: Axis
    /// 行/列配置
    private let lines: MasonryLines
    /// 水平间距
    private let horizontalSpacing: CGFloat
    /// 垂直间距
    private let verticalSpacing: CGFloat
    /// 放置模式
    private let placementMode: MasonryPlacementMode
    /// 响应式断点配置（可选）
    private let breakpoints: [CGFloat: MasonryConfiguration]?
    /// 内容构建器
    private let content: () -> Content

    /// 当前使用的配置（仅用于响应式模式）
    @State private var currentConfiguration: MasonryConfiguration?
    /// 防抖任务，避免频繁更新
    @State private var debounceTask: Task<Void, Never>?

    /// 初始化瀑布流视图
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    ///   - content: 视图内容构建器
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.lines = lines
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.placementMode = placementMode
        self.breakpoints = nil
        self.content = content
    }

    /// 响应式初始化方法
    /// - Parameters:
    ///   - breakpoints: 响应式断点配置字典
    ///   - content: 视图内容构建器
    public init(
        breakpoints: [CGFloat: MasonryConfiguration],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.breakpoints = breakpoints
        self.content = content

        // 选择最小断点作为初始配置
        let initialConfig = breakpoints
            .sorted { $0.key < $1.key }
            .first?.value ?? .default

        self.axis = initialConfig.axis
        self.lines = initialConfig.lines
        self.horizontalSpacing = initialConfig.horizontalSpacing
        self.verticalSpacing = initialConfig.verticalSpacing
        self.placementMode = initialConfig.placementMode
        self._currentConfiguration = State(initialValue: initialConfig)
    }

    public var body: some View {
        Group {
            if let breakpoints = breakpoints {
                // 响应式模式
                ResponsiveMasonryLayout(
                    breakpoints: breakpoints,
                    currentConfiguration: $currentConfiguration,
                    debounceTask: $debounceTask,
                    content: content
                )
            } else {
                // 静态模式
                MasonryLayout(
                    axis: axis,
                    lines: lines,
                    horizontalSpacing: horizontalSpacing,
                    verticalSpacing: verticalSpacing,
                    placementMode: placementMode
                ) {
                    content()
                }
            }
        }
    }
}

// MARK: - 响应式布局内部组件

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct ResponsiveMasonryLayout<Content: View>: View {
    let breakpoints: [CGFloat: MasonryConfiguration]
    @Binding var currentConfiguration: MasonryConfiguration?
    @Binding var debounceTask: Task<Void, Never>?
    let content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            let config = currentConfiguration ?? .default
            MasonryLayout(
                axis: config.axis,
                lines: config.lines,
                horizontalSpacing: config.horizontalSpacing,
                verticalSpacing: config.verticalSpacing,
                placementMode: config.placementMode
            ) {
                content()
            }
            .onChange(of: geometry.size.width) { _, newWidth in
                updateConfigurationWithDebounce(for: newWidth)
            }
            .onAppear {
                updateConfiguration(for: geometry.size.width)
            }
        }
    }

    /// 根据屏幕宽度更新配置（带防抖）
    private func updateConfigurationWithDebounce(for width: CGFloat) {
        // 取消之前的防抖任务
        debounceTask?.cancel()

        // 创建新的防抖任务
        debounceTask = Task {
            // 防抖延迟
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒

            // 检查任务是否被取消
            guard !Task.isCancelled else { return }

            // 在主线程更新配置
            await MainActor.run {
                updateConfiguration(for: width)
            }
        }
    }

    /// 根据屏幕宽度更新配置
    private func updateConfiguration(for width: CGFloat) {
        guard width > 0 else { return }

        let newConfig = breakpoints
            .filter { width >= $0.key }
            .max(by: { $0.key < $1.key })?.value ?? .default

        let configChanged = currentConfiguration?.lines != newConfig.lines ||
                           currentConfiguration?.axis != newConfig.axis ||
                           currentConfiguration?.placementMode != newConfig.placementMode

        if configChanged {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentConfiguration = newConfig
            }
        } else if currentConfiguration?.horizontalSpacing != newConfig.horizontalSpacing ||
                  currentConfiguration?.verticalSpacing != newConfig.verticalSpacing {
            currentConfiguration = newConfig
        }
    }


}