//
// Copyright (c) Beyoug
//
import SwiftUI

// MARK: - 瀑布流基础类型定义

// MARK: - 瀑布流行列配置

/// 定义瀑布流视图中行或列数量的常量
public enum MasonryLines: Sendable, Equatable, Hashable {

    /// 可变数量的行或列
    ///
    /// 此选项使用提供的 `sizeConstraint` 来决定确切的行或列数量
    case adaptive(sizeConstraint: AdaptiveSizeConstraint)

    /// 固定数量的行或列
    case fixed(Int)

    /// 约束瀑布流视图中自适应行或列边界的常量
    public enum AdaptiveSizeConstraint: Equatable, Sendable, Hashable {

        /// 给定轴上行或列的最小尺寸
        case min(CGFloat)

        /// 给定轴上行或列的最大尺寸
        case max(CGFloat)
    }
}

// MARK: - 便捷方法

public extension MasonryLines {

    /// 创建具有最小尺寸约束的自适应配置
    /// - Parameter minSize: 每行或列的最小尺寸（自动修正为大于0的值）
    /// - Returns: 自适应瀑布流行列配置
    static func adaptive(minSize: CGFloat) -> MasonryLines {
        let correctedSize = max(1, minSize)
        #if DEBUG
        if minSize <= 0 {
            print("⚠️ SwiftUIMasonryLayouts: 最小尺寸必须大于0，已自动修正为1")
        }
        #endif
        return .adaptive(sizeConstraint: .min(correctedSize))
    }

    /// 创建具有最大尺寸约束的自适应配置
    /// - Parameter maxSize: 每行或列的最大尺寸（自动修正为大于0的值）
    /// - Returns: 自适应瀑布流行列配置
    static func adaptive(maxSize: CGFloat) -> MasonryLines {
        let correctedSize = max(1, maxSize)
        #if DEBUG
        if maxSize <= 0 {
            print("⚠️ SwiftUIMasonryLayouts: 最大尺寸必须大于0，已自动修正为1")
        }
        #endif
        return .adaptive(sizeConstraint: .max(correctedSize))
    }

    /// 创建固定数量的行或列配置（带验证）
    /// - Parameter count: 行或列的数量（自动修正为大于0的值）
    /// - Returns: 固定数量的瀑布流行列配置
    static func fixedCount(_ count: Int) -> MasonryLines {
        let correctedCount = max(1, count)
        #if DEBUG
        if count <= 0 {
            print("⚠️ SwiftUIMasonryLayouts: 行或列数量必须大于0，已自动修正为1")
        }
        #endif
        return .fixed(correctedCount)
    }
}

// MARK: - 瀑布流放置模式

/// 定义瀑布流子视图在可用空间中如何放置的常量
public enum MasonryPlacementMode: Hashable, CaseIterable, Sendable {

    /// 将每个子视图放置在可用空间最多的行或列中
    case fill

    /// 按视图树顺序放置每个子视图
    case order
}

// MARK: - 瀑布流配置

/// 瀑布流布局的完整配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct MasonryConfiguration: Sendable {
    /// 布局轴向（垂直或水平）
    public let axis: Axis
    /// 行或列的配置
    public let lines: MasonryLines
    /// 水平间距
    public let horizontalSpacing: CGFloat
    /// 垂直间距
    public let verticalSpacing: CGFloat
    /// 放置模式
    public let placementMode: MasonryPlacementMode

    /// 初始化瀑布流配置
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行或列的配置
    ///   - horizontalSpacing: 水平间距，默认为8（必须大于等于0）
    ///   - verticalSpacing: 垂直间距，默认为8（必须大于等于0）
    ///   - placementMode: 放置模式，默认为填充模式
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill
    ) {
        // 使用更温和的错误处理，自动修正无效值
        self.axis = axis
        self.lines = lines
        self.horizontalSpacing = max(0, horizontalSpacing)
        self.verticalSpacing = max(0, verticalSpacing)
        self.placementMode = placementMode

        // 在调试模式下发出警告
        #if DEBUG
        if horizontalSpacing < 0 {
            print("⚠️ SwiftUIMasonryLayouts: 水平间距不能为负数，已自动修正为0")
        }
        if verticalSpacing < 0 {
            print("⚠️ SwiftUIMasonryLayouts: 垂直间距不能为负数，已自动修正为0")
        }
        #endif
    }

    /// 默认配置（2列垂直布局）
    public static let `default` = MasonryConfiguration(lines: .fixed(2))
}

// MARK: - 便捷配置方法

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension MasonryConfiguration {

    /// 创建垂直瀑布流配置
    /// - Parameters:
    ///   - columns: 列数配置
    ///   - spacing: 统一间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    /// - Returns: 垂直瀑布流配置
    static func vertical(
        columns: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill
    ) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: .vertical,
            lines: columns,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode
        )
    }

    /// 创建水平瀑布流配置
    /// - Parameters:
    ///   - rows: 行数配置
    ///   - spacing: 统一间距，默认为8
    ///   - placementMode: 放置模式，默认为填充
    /// - Returns: 水平瀑布流配置
    static func horizontal(
        rows: MasonryLines,
        spacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill
    ) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: .horizontal,
            lines: rows,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            placementMode: placementMode
        )
    }

    /// 修改间距
    /// - Parameters:
    ///   - horizontal: 新的水平间距
    ///   - vertical: 新的垂直间距
    /// - Returns: 修改间距后的新配置
    func withSpacing(horizontal: CGFloat? = nil, vertical: CGFloat? = nil) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: self.axis,
            lines: self.lines,
            horizontalSpacing: horizontal ?? self.horizontalSpacing,
            verticalSpacing: vertical ?? self.verticalSpacing,
            placementMode: self.placementMode
        )
    }

    /// 修改放置模式
    /// - Parameter mode: 新的放置模式
    /// - Returns: 修改放置模式后的新配置
    func withPlacementMode(_ mode: MasonryPlacementMode) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: self.axis,
            lines: self.lines,
            horizontalSpacing: self.horizontalSpacing,
            verticalSpacing: self.verticalSpacing,
            placementMode: mode
        )
    }
}

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

    /// 小屏幕的紧凑断点（适用于手机等小屏设备）
    static let compactBreakpoints: [CGFloat: MasonryConfiguration] = [
        0: .singleColumn,      // 最小屏幕
        320: .twoColumns       // 小屏幕
    ]

    /// 大屏幕的扩展断点（适用于大屏显示器）
    static let extendedBreakpoints: [CGFloat: MasonryConfiguration] = [
        0: .singleColumn,                              // 最小
        480: .twoColumns,                              // 小
        768: .threeColumns,                            // 中
        1024: .fourColumns,                            // 大
        1440: MasonryConfiguration(lines: .fixed(5)),  // 超大
        1920: MasonryConfiguration(lines: .fixed(6))   // 极大
    ]
}
