//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 基础瀑布流视图

/// 基础瀑布流视图组件
/// 适用于静态内容和简单布局场景
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct MasonryView<Content: View>: View {
    
    // MARK: - 属性
    
    /// 布局轴向
    private let axis: Axis
    /// 行/列配置
    private let lines: MasonryLines
    /// 水平间距
    private let hSpacing: CGFloat
    /// 垂直间距
    private let vSpacing: CGFloat
    /// 放置模式
    private let placement: MasonryPlacementMode
    /// 响应式断点配置（可选）
    private let breakpoints: [CGFloat: MasonryConfiguration]?
    /// 内容构建器
    private let content: () -> Content
    
    // MARK: - 状态管理
    
    /// 当前使用的配置（仅用于响应式模式）
    @State private var currentConfiguration: MasonryConfiguration?
    /// 防抖任务，避免频繁更新
    @State private var debounceTask: Task<Void, Never>?
    
    // MARK: - 初始化方法
    
    /// 创建基础瀑布流视图
    /// - Parameters:
    ///   - axis: 布局轴向
    ///   - lines: 行/列配置
    ///   - hSpacing: 水平间距
    ///   - vSpacing: 垂直间距
    ///   - placement: 放置模式
    ///   - content: 内容构建器
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        hSpacing: CGFloat = 8,
        vSpacing: CGFloat = 8,
        placement: MasonryPlacementMode = .fill,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.lines = lines
        self.hSpacing = hSpacing
        self.vSpacing = vSpacing
        self.placement = placement
        self.breakpoints = nil
        self.content = content
    }

    /// 创建简单瀑布流视图（便捷方法）
    /// - Parameters:
    ///   - columns: 列数
    ///   - spacing: 间距
    ///   - content: 内容构建器
    public init(
        columns: Int = 2,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = .vertical
        self.lines = .fixed(columns)
        self.hSpacing = spacing
        self.vSpacing = spacing
        self.placement = .fill
        self.breakpoints = nil
        self.content = content
    }

    /// 创建最简单的瀑布流视图（类似 LazyVGrid 的设计）
    /// - Parameter content: 内容构建器
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.axis = .vertical
        self.lines = .fixed(2)
        self.hSpacing = 8
        self.vSpacing = 8
        self.placement = .fill
        self.breakpoints = nil
        self.content = content
    }

    /// 创建响应式瀑布流视图
    /// - Parameters:
    ///   - breakpoints: 响应式断点配置
    ///   - content: 内容构建器
    public init(
        breakpoints: [CGFloat: MasonryConfiguration],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = .vertical
        self.lines = .fixed(2)
        self.hSpacing = 8
        self.vSpacing = 8
        self.placement = .fill
        self.breakpoints = breakpoints
        self.content = content
    }
    
    // MARK: - 视图主体
    
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
                    horizontalSpacing: hSpacing,
                    verticalSpacing: vSpacing,
                    placementMode: placement
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
                horizontalSpacing: config.hSpacing,
                verticalSpacing: config.vSpacing,
                placementMode: config.placement
            ) {
                content()
            }
            .onChange(of: geometry.size.width) { _, newWidth in
                updateConfigurationWithDebounce(for: newWidth)
            }
            .onAppear {
                updateConfiguration(for: geometry.size.width)
            }
            .onDisappear {
                debounceTask?.cancel()
                debounceTask = nil
            }
        }
    }
    
    /// 根据屏幕宽度更新配置（带防抖）
    private func updateConfigurationWithDebounce(for width: CGFloat) {
        debounceTask?.cancel()

        debounceTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: MasonryInternalConfig.responsiveDebounceDelay)

                // 检查任务是否被取消
                guard !Task.isCancelled else { return }

                // 更新配置
                updateConfiguration(for: width)
            } catch {
                // 处理取消或其他错误
                if !(error is CancellationError) {
                    MasonryInternalConfig.Logger.warning("防抖任务错误: \(error)")
                }
            }
        }
    }
    
    /// 根据屏幕宽度更新配置
    private func updateConfiguration(for width: CGFloat) {
        guard width > 0 else { return }

        let newConfig = breakpoints
            .filter { width >= $0.key }
            .max(by: { $0.key < $1.key })?.value ?? MasonryConfiguration.default

        let configChanged = currentConfiguration?.lines != newConfig.lines ||
                           currentConfiguration?.axis != newConfig.axis ||
                           currentConfiguration?.placement != newConfig.placement

        if configChanged {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentConfiguration = newConfig
            }
        } else if currentConfiguration?.hSpacing != newConfig.hSpacing ||
                  currentConfiguration?.vSpacing != newConfig.vSpacing {
            currentConfiguration = newConfig
        }
    }
}



// MARK: - 调试辅助

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension MasonryView {

    /// 启用调试模式（显示布局边界）
    /// - Parameter enabled: 是否启用
    /// - Returns: 带调试信息的视图
    func debugLayout(_ enabled: Bool = true) -> some View {
        self.overlay(
            enabled ? Rectangle()
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                .allowsHitTesting(false) : nil
        )
    }
}
