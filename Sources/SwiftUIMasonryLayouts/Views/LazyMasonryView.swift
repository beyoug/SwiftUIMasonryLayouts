//
// Copyright (c) Beyoug
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - 懒加载瀑布流视图

/// 专注于布局性能的懒加载瀑布流视图
/// 只关注数据绑定、布局计算和渲染优化，不涉及业务逻辑
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyMasonryView<Data: RandomAccessCollection, ID: Hashable, Content: View>: View where Data.Element: Identifiable, Data.Element.ID == ID {
    
    // MARK: - 核心属性
    
    /// 数据源
    private let data: Data
    /// 布局配置
    private let configuration: MasonryConfiguration
    /// 响应式断点配置（可选）
    private let breakpoints: [CGFloat: MasonryConfiguration]?
    /// 内容构建器
    private let content: (Data.Element) -> Content
    /// 项目尺寸计算器（性能优化）
    private let itemSizeCalculator: ((Data.Element, CGFloat) -> CGSize)?
    
    // MARK: - 可扩展回调
    
    /// 可见范围变化回调
    private let onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?
    /// 滚动到底部回调（垂直布局）或右边回调（水平布局）
    private let onReachBottom: (() -> Void)?
    /// 滚动到顶部回调（垂直布局）或左边回调（水平布局）
    private let onReachTop: (() -> Void)?
    
    // MARK: - 状态管理
    
    @State private var currentConfiguration: MasonryConfiguration?
    @State private var visibleRange: Range<Data.Index>?
    @State private var layoutCache: LazyLayoutCache = LazyLayoutCache()
    @State private var debounceTask: Task<Void, Never>?
    
    // MARK: - 初始化方法
    
    /// 创建懒加载瀑布流视图
    public init(
        _ data: Data,
        configuration: MasonryConfiguration,
        itemSizeCalculator: ((Data.Element, CGFloat) -> CGSize)? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = configuration
        self.breakpoints = nil
        self.itemSizeCalculator = itemSizeCalculator
        self.content = content
        self.onVisibleRangeChanged = nil
        self.onReachBottom = nil
        self.onReachTop = nil
    }
    
    /// 创建懒加载瀑布流视图（便捷版本）
    /// - Parameters:
    ///   - data: 数据源
    ///   - columns: 列数，默认为2
    ///   - spacing: 间距，默认为8
    ///   - content: 内容构建器
    public init(
        _ data: Data,
        columns: Int = 2,
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(columns),
            horizontalSpacing: spacing,
            verticalSpacing: spacing
        )
        self.breakpoints = nil
        self.itemSizeCalculator = nil
        self.content = content
        self.onVisibleRangeChanged = nil
        self.onReachBottom = nil
        self.onReachTop = nil
    }
    
    /// 创建响应式懒加载瀑布流视图
    /// - Parameters:
    ///   - data: 数据源
    ///   - breakpoints: 响应式断点配置
    ///   - itemSizeCalculator: 可选的项目尺寸计算器
    ///   - content: 内容构建器
    public init(
        _ data: Data,
        breakpoints: [CGFloat: MasonryConfiguration],
        itemSizeCalculator: ((Data.Element, CGFloat) -> CGSize)? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.configuration = .default
        self.breakpoints = breakpoints
        self.itemSizeCalculator = itemSizeCalculator
        self.content = content
        self.onVisibleRangeChanged = nil
        self.onReachBottom = nil
        self.onReachTop = nil
    }
    
    // MARK: - 视图主体
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyMasonryContainer(
                        data: data,
                        configuration: effectiveConfiguration(for: geometry.size.width),
                        geometry: geometry,
                        visibleRange: $visibleRange,
                        layoutCache: $layoutCache,
                        itemSizeCalculator: itemSizeCalculator,
                        content: content,
                        onVisibleRangeChanged: onVisibleRangeChanged,
                        onReachBottom: onReachBottom,
                        onReachTop: onReachTop
                    )
                }
                .coordinateSpace(name: "scroll")
                .onChange(of: geometry.size.width) { _, newWidth in
                    updateConfigurationWithDebounce(for: newWidth)
                }
                .onAppear {
                    if let breakpoints = breakpoints {
                        updateConfiguration(for: geometry.size.width, breakpoints: breakpoints)
                    }
                }
#if canImport(UIKit)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                    // 内存警告时的智能清理策略
                    handleMemoryPressure()
                }
#endif
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 获取有效配置
    private func effectiveConfiguration(for width: CGFloat) -> MasonryConfiguration {
        if let breakpoints = breakpoints {
            return currentConfiguration ?? 
                   breakpoints.filter { width >= $0.key }
                             .max(by: { $0.key < $1.key })?.value ?? 
                   .default
        } else {
            return configuration
        }
    }
    
    /// 防抖更新配置
    private func updateConfigurationWithDebounce(for width: CGFloat) {
        guard let breakpoints = breakpoints else { return }

        debounceTask?.cancel()
        debounceTask = Task {
            // 使用全局配置的防抖时间
            try? await Task.sleep(nanoseconds: MasonryInternalConfig.responsiveDebounceDelay)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                // 由于 struct 不需要 weak self，直接调用
                updateConfiguration(for: width, breakpoints: breakpoints)
            }
        }
    }
    
    /// 更新配置
    private func updateConfiguration(for width: CGFloat, breakpoints: [CGFloat: MasonryConfiguration]) {
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
                layoutCache.invalidate()
            }
        } else if currentConfiguration?.horizontalSpacing != newConfig.horizontalSpacing ||
                  currentConfiguration?.verticalSpacing != newConfig.verticalSpacing {
            currentConfiguration = newConfig
        }
    }

    /// 处理内存压力
    private func handleMemoryPressure() {
        // 1. 清理布局缓存
        layoutCache.invalidate()

        // 2. 如果数据量很大，考虑减少预加载缓冲区
        if data.count > 1000 {
            // 通过重新计算可见范围来减少内存使用
            // 这会触发 LazyMasonryContainer 重新计算可见项目
        }

        // 3. 强制垃圾回收（在内存紧张时）
        #if DEBUG
        if MasonryInternalConfig.enableInternalLogging {
            print("🧹 SwiftUIMasonryLayouts: 内存警告 - 已清理缓存，数据量: \(data.count)")
        }
        #endif
    }
}

// MARK: - 可扩展接口

/// 懒加载瀑布流的回调配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LazyMasonryCallbacks<Data: RandomAccessCollection> {
    /// 可见范围变化回调
    public let onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?
    /// 滚动到底部回调（垂直布局）或右边回调（水平布局）
    public let onReachBottom: (() -> Void)?
    /// 滚动到顶部回调（垂直布局）或左边回调（水平布局）
    public let onReachTop: (() -> Void)?

    /// 创建回调配置
    public init(
        onVisibleRangeChanged: ((Range<Data.Index>) -> Void)? = nil,
        onReachBottom: (() -> Void)? = nil,
        onReachTop: (() -> Void)? = nil
    ) {
        self.onVisibleRangeChanged = onVisibleRangeChanged
        self.onReachBottom = onReachBottom
        self.onReachTop = onReachTop
    }

    /// 创建回调配置（使用通用命名）
    public init(
        onVisibleRangeChanged: ((Range<Data.Index>) -> Void)? = nil,
        onReachEnd: (() -> Void)? = nil,
        onReachStart: (() -> Void)? = nil
    ) {
        self.onVisibleRangeChanged = onVisibleRangeChanged
        self.onReachBottom = onReachEnd
        self.onReachTop = onReachStart
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension LazyMasonryView {

    /// 配置回调（推荐方式，避免多次实例创建）
    /// - Parameter callbacks: 回调配置
    /// - Returns: 配置了回调的视图
    func callbacks(_ callbacks: LazyMasonryCallbacks<Data>) -> LazyMasonryView {
        LazyMasonryView(
            data: data,
            configuration: configuration,
            breakpoints: breakpoints,
            itemSizeCalculator: itemSizeCalculator,
            content: content,
            onVisibleRangeChanged: callbacks.onVisibleRangeChanged,
            onReachBottom: callbacks.onReachBottom,
            onReachTop: callbacks.onReachTop
        )
    }

    /// 添加可见范围变化监听（用于业务层实现分页等逻辑）
    func onVisibleRangeChanged(_ action: @escaping (Range<Data.Index>) -> Void) -> LazyMasonryView {
        LazyMasonryView(
            data: data,
            configuration: configuration,
            breakpoints: breakpoints,
            itemSizeCalculator: itemSizeCalculator,
            content: content,
            onVisibleRangeChanged: action,
            onReachBottom: onReachBottom,
            onReachTop: onReachTop
        )
    }

    /// 添加滚动到底部监听
    func onReachBottom(_ action: @escaping () -> Void) -> LazyMasonryView {
        LazyMasonryView(
            data: data,
            configuration: configuration,
            breakpoints: breakpoints,
            itemSizeCalculator: itemSizeCalculator,
            content: content,
            onVisibleRangeChanged: onVisibleRangeChanged,
            onReachBottom: action,
            onReachTop: onReachTop
        )
    }

    /// 添加滚动到顶部监听
    func onReachTop(_ action: @escaping () -> Void) -> LazyMasonryView {
        LazyMasonryView(
            data: data,
            configuration: configuration,
            breakpoints: breakpoints,
            itemSizeCalculator: itemSizeCalculator,
            content: content,
            onVisibleRangeChanged: onVisibleRangeChanged,
            onReachBottom: onReachBottom,
            onReachTop: action
        )
    }

    /// 添加滚动到起始位置监听（垂直布局的顶部，水平布局的左边）
    func onReachStart(_ action: @escaping () -> Void) -> LazyMasonryView {
        onReachTop(action)
    }

    /// 添加滚动到结束位置监听（垂直布局的底部，水平布局的右边）
    func onReachEnd(_ action: @escaping () -> Void) -> LazyMasonryView {
        onReachBottom(action)
    }
}

// MARK: - 内部初始化器

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private extension LazyMasonryView {
    
    init(
        data: Data,
        configuration: MasonryConfiguration,
        breakpoints: [CGFloat: MasonryConfiguration]?,
        itemSizeCalculator: ((Data.Element, CGFloat) -> CGSize)?,
        content: @escaping (Data.Element) -> Content,
        onVisibleRangeChanged: ((Range<Data.Index>) -> Void)?,
        onReachBottom: (() -> Void)?,
        onReachTop: (() -> Void)?
    ) {
        self.data = data
        self.configuration = configuration
        self.breakpoints = breakpoints
        self.itemSizeCalculator = itemSizeCalculator
        self.content = content
        self.onVisibleRangeChanged = onVisibleRangeChanged
        self.onReachBottom = onReachBottom
        self.onReachTop = onReachTop
    }
}
