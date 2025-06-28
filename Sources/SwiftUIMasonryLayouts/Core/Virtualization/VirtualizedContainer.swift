//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 虚拟化瀑布流容器

/// 虚拟化瀑布流容器，实现真正的懒加载
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct VirtualizedMasonryContainer<Data, ID, Content>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      Content: View
{
    let axis: Axis
    let lines: MasonryLines
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let placementMode: MasonryPlacementMode
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let estimatedItemSize: CGSize
    let content: (Data.Element) -> Content

    @State private var virtualizer = MasonryVirtualizer()
    @State private var containerSize: CGSize = .zero
    @State private var scrollOffset: CGPoint = .zero
    @State private var containerOffset: CGPoint = .zero
    @State private var isInitialized: Bool = false

    // 防抖机制
    @State private var scrollUpdateTask: Task<Void, Never>?
    @State private var lastScrollUpdate: Date = Date()

    var body: some View {
        GeometryReader { geometry in
            ScrollView(axis == .vertical ? .vertical : .horizontal) {
                // 使用不同的方式设置内容尺寸，避免虚拟容器影响对齐
                Group {
                    // 只在初始化完成后渲染项目，避免闪烁
                    if isInitialized {
                        ZStack(alignment: .topLeading) {
                            ForEach(virtualizer.visibleItems, id: \.stableViewID) { item in
                                // 安全访问数据，防止索引越界
                                if item.dataIndex >= 0 && item.dataIndex < data.count {
                                    Group {
                                        // 水平布局时使用严格的高度控制
                                        if axis == .horizontal {
                                            // 创建固定高度的容器
                                            Rectangle()
                                                .fill(Color.clear)
                                                .frame(
                                                    width: item.frame.width,
                                                    height: item.frame.height
                                                )
                                                .overlay(
                                                    content(data[data.index(data.startIndex, offsetBy: item.dataIndex)])
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        .clipped()
                                                )
                                        } else {
                                            content(data[data.index(data.startIndex, offsetBy: item.dataIndex)])
                                                .frame(
                                                    width: item.frame.width,
                                                    height: item.frame.height
                                                )
                                                .clipped()
                                        }
                                    }
                                    .position(
                                        x: item.frame.midX,
                                        y: item.frame.midY
                                    )
                                    .id(item.stableViewID) // 双重ID保护
                                }
                            }
                        }
                    }
                }
                .frame(
                    width: virtualizer.totalSize.width,
                    height: virtualizer.totalSize.height,
                    alignment: .topLeading
                )
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear
                            .onAppear {
                                // 初始化时立即更新可见项目
                                let initialVisibleRect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
                                virtualizer.updateVisibleItems(visibleRect: initialVisibleRect)
                            }
                            .onChange(of: scrollGeometry.frame(in: .named("scrollView"))) { _, frame in
                                // 计算滚动偏移
                                let scrollOffset = CGPoint(x: -frame.minX, y: -frame.minY)
                                let visibleRect = CGRect(
                                    x: max(0, scrollOffset.x),
                                    y: max(0, scrollOffset.y),
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )

                                #if DEBUG
                                print("🔍 滚动更新 - scrollOffset: \(scrollOffset), visibleRect: \(visibleRect)")
                                #endif

                                virtualizer.updateVisibleItems(visibleRect: visibleRect)
                            }
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .coordinateSpace(name: "scrollView")
                .onAppear {
                    #if DEBUG
                    print("🔄 LazyMasonryView onAppear - 容器尺寸: \(geometry.size), 数据项目: \(data.count)")
                    #endif

                    // 使用实际的几何尺寸而不是硬编码值
                    let currentSize = geometry.size
                    // 更严格的初始化条件，避免导航动画期间的重复初始化
                    if !isInitialized && currentSize.width > 0 && currentSize.height > 0 {
                        containerSize = currentSize

                        #if DEBUG
                        print("🚀 LazyMasonryView 开始初始化虚拟化器...")
                        #endif

                        virtualizer.initialize(
                            data: data,
                            axis: axis,
                            lines: lines,
                            horizontalSpacing: horizontalSpacing,
                            verticalSpacing: verticalSpacing,
                            placementMode: placementMode,
                            estimatedItemSize: estimatedItemSize,
                            containerSize: currentSize,
                            id: id
                        )

                        // 修复：同步初始化后立即更新可见项目，避免闪烁
                        let initialVisibleRect = CGRect(x: 0, y: 0, width: currentSize.width, height: currentSize.height)
                        virtualizer.updateVisibleItems(visibleRect: initialVisibleRect)

                        // 标记为已初始化，开始渲染
                        isInitialized = true

                        #if DEBUG
                        print("✅ LazyMasonryView 初始化完成")
                        print("   - 总项目数: \(virtualizer.allItemsCount)")
                        print("   - 可见项目数: \(virtualizer.visibleItems.count)")
                        print("   - 总尺寸: \(virtualizer.totalSize)")
                        print("   - 容器尺寸: \(currentSize)")
                        if virtualizer.allItemsCount > 0 {
                            let frames = virtualizer.allItemsFrames
                            print("   - 前6个项目frame: \(frames.prefix(6))")
                            if axis == .horizontal {
                                print("🔍 水平布局详细分析:")
                                for (index, frame) in frames.prefix(6).enumerated() {
                                    let lineIndex = index % 3
                                    print("     项目\(index): lineIndex=\(lineIndex), frame=(\(frame.minX), \(frame.minY), \(frame.width), \(frame.height))")
                                }
                            }
                        }
                        #endif
                    }
                }
                .onChange(of: geometry.size) { _, newSize in
                    // 智能尺寸变化处理，避免导航动画期间的闪烁
                    handleSizeChange(newSize: newSize)
                }
                .onDisappear {
                    virtualizer.cleanup()
                }
        }
    }

    /// 智能处理尺寸变化，避免导航动画期间的闪烁
    private func handleSizeChange(newSize: CGSize) {
        // 计算尺寸变化的幅度
        let widthChange = abs(newSize.width - containerSize.width)
        let heightChange = abs(newSize.height - containerSize.height)

        // 定义显著变化的阈值（避免导航动画期间的微小变化）
        let significantChangeThreshold: CGFloat = 20.0

        // 只有在显著变化时才更新
        if widthChange > significantChangeThreshold || heightChange > significantChangeThreshold {
            #if DEBUG
            print("📐 显著尺寸变化 - 从 \(containerSize) 到 \(newSize)")
            #endif

            containerSize = newSize
            virtualizer.updateContainerSizeGracefully(newSize)
        } else {
            #if DEBUG
            print("📐 微小尺寸变化忽略 - 从 \(containerSize) 到 \(newSize), 变化: (\(widthChange), \(heightChange))")
            #endif

            // 只更新容器尺寸，不清空可见项目
            containerSize = newSize
        }
    }
}
