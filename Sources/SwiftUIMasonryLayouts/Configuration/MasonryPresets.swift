//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 瀑布流配置预设

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension MasonryConfiguration {

    /// 单列垂直布局
    static let singleColumn = MasonryConfiguration(
        axis: .vertical,
        lines: .fixed(1)
    )

    /// 双列垂直布局
    static let twoColumns = MasonryConfiguration(
        axis: .vertical,
        lines: .fixed(2)
    )

    /// 三列垂直布局
    static let threeColumns = MasonryConfiguration(
        axis: .vertical,
        lines: .fixed(3)
    )

    /// 四列垂直布局
    static let fourColumns = MasonryConfiguration(
        axis: .vertical,
        lines: .fixed(4)
    )

    /// 自适应布局（最小120pt列宽）
    static let adaptiveColumns = MasonryConfiguration(
        axis: .vertical,
        lines: .adaptive(minSize: 120)
    )

    /// 单行水平布局
    static let singleRow = MasonryConfiguration(
        axis: .horizontal,
        lines: .fixed(1)
    )

    /// 双行水平布局
    static let twoRows = MasonryConfiguration(
        axis: .horizontal,
        lines: .fixed(2)
    )

    /// 三行水平布局
    static let threeRows = MasonryConfiguration(
        axis: .horizontal,
        lines: .fixed(3)
    )
}

// MARK: - 响应式断点

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension MasonryConfiguration {

    /// 不同屏幕尺寸的通用响应式断点
    static let commonBreakpoints: [CGFloat: MasonryConfiguration] = [
        0: .singleColumn,      // 手机竖屏
        480: .twoColumns,      // 手机横屏 / 小平板
        768: .threeColumns,    // 平板
        1024: .fourColumns     // 桌面
    ]

    /// 设备特定的响应式断点
    static var deviceBreakpoints: [CGFloat: MasonryConfiguration] {
        #if os(iOS)
        return [
            0: .singleColumn,      // iPhone竖屏
            375: .twoColumns,      // iPhone横屏
            768: .threeColumns     // iPad
        ]
        #elseif os(macOS)
        return [
            0: .twoColumns,        // 小窗口
            800: .threeColumns,    // 中等窗口
            1200: .fourColumns     // 大窗口
        ]
        #else
        return [
            0: .twoColumns         // 其他平台默认
        ]
        #endif
    }

    /// 小屏幕的紧凑断点
    static let compactBreakpoints: [CGFloat: MasonryConfiguration] = [
        0: .singleColumn,      // 最小屏幕
        320: .twoColumns       // 小屏幕
    ]

    /// 大屏幕的扩展断点
    static let extendedBreakpoints: [CGFloat: MasonryConfiguration] = [
        0: .singleColumn,                              // 最小
        480: .twoColumns,                              // 小
        768: .threeColumns,                            // 中
        1024: .fourColumns,                            // 大
        1440: MasonryConfiguration(lines: .fixed(5)),  // 超大
        1920: MasonryConfiguration(lines: .fixed(6))   // 极大
    ]
}
