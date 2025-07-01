//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 基础瀑布流视图

/// 基础瀑布流视图组件
/// 适用于静态内容和简单布局场景
@available(iOS 18.0, macOS 15.0, *)
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
                    hSpacing: hSpacing,
                    vSpacing: vSpacing,
                    placement: placement
                ) {
                    content()
                }
            }
        }
    }
}

// MARK: - 响应式布局内部组件

@available(iOS 18.0, macOS 15.0, *)
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
                hSpacing: config.hSpacing,
                vSpacing: config.vSpacing,
                placement: config.placement
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
            // 使用全局配置的防抖时间
            try? await Task.sleep(nanoseconds: MasonryInternalConfig.responsiveDebounceDelay)
            
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
