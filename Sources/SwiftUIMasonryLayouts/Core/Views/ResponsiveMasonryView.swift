//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 响应式瀑布流视图

/// 根据屏幕宽度自动调整布局的响应式瀑布流视图
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct ResponsiveMasonryView<Content: View>: View {

    /// 响应式断点配置
    private let breakpoints: [CGFloat: MasonryConfiguration]
    /// 内容构建器
    private let content: () -> Content

    /// 当前使用的配置
    @State private var currentConfiguration: MasonryConfiguration

    /// 初始化响应式瀑布流视图
    /// - Parameters:
    ///   - breakpoints: 响应式断点配置字典，键为屏幕宽度，值为对应的瀑布流配置
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
        self._currentConfiguration = State(initialValue: initialConfig)
    }

    public var body: some View {
        GeometryReader { geometry in
            MasonryView(
                axis: currentConfiguration.axis,
                lines: currentConfiguration.lines,
                horizontalSpacing: currentConfiguration.horizontalSpacing,
                verticalSpacing: currentConfiguration.verticalSpacing,
                placementMode: currentConfiguration.placementMode,
                content: content
            )
            .onChange(of: geometry.size.width) { _, newWidth in
                updateConfiguration(for: newWidth)
            }
            .onAppear {
                updateConfiguration(for: geometry.size.width)
            }
        }
    }

    /// 根据屏幕宽度更新配置
    /// - Parameter width: 当前屏幕宽度
    private func updateConfiguration(for width: CGFloat) {
        // 确保宽度为正数
        guard width > 0 else { return }

        // 找到适合当前宽度的最大断点
        let newConfig = breakpoints
            .filter { width >= $0.key }
            .max(by: { $0.key < $1.key })?.value ?? .default

        // 检查配置是否真的发生了变化
        let configChanged = currentConfiguration.lines != newConfig.lines ||
                           currentConfiguration.axis != newConfig.axis ||
                           currentConfiguration.placementMode != newConfig.placementMode

        if configChanged {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentConfiguration = newConfig
            }
        } else if currentConfiguration.horizontalSpacing != newConfig.horizontalSpacing ||
                  currentConfiguration.verticalSpacing != newConfig.verticalSpacing {
            // 只有间距变化时，不需要动画
            currentConfiguration = newConfig
        }
    }
}

// MARK: - 响应式瀑布流便捷方法

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension ResponsiveMasonryView {

    /// 使用通用响应式断点创建响应式瀑布流
    /// - Parameter content: 视图内容构建器
    /// - Returns: 使用通用断点的响应式瀑布流视图
    static func withCommonBreakpoints<C: View>(
        @ViewBuilder content: @escaping () -> C
    ) -> ResponsiveMasonryView<C> {
        ResponsiveMasonryView<C>(
            breakpoints: MasonryConfiguration.commonBreakpoints,
            content: content
        )
    }

    /// 使用设备特定断点创建响应式瀑布流
    /// - Parameter content: 视图内容构建器
    /// - Returns: 使用设备特定断点的响应式瀑布流视图
    static func deviceAdaptive<C: View>(
        @ViewBuilder content: @escaping () -> C
    ) -> ResponsiveMasonryView<C> {
        ResponsiveMasonryView<C>(
            breakpoints: MasonryConfiguration.deviceBreakpoints,
            content: content
        )
    }
}
