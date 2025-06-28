//
// Copyright (c) Beyoug
//
import SwiftUI

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
