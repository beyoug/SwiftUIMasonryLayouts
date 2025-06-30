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
    /// - Parameter minSize: 每行或列的最小尺寸
    static func adaptive(minSize: CGFloat) -> MasonryLines {
        let correctedSize = max(1, minSize)
        if minSize <= 0 {
            print("⚠️ SwiftUIMasonryLayouts: 最小尺寸必须大于0，已自动修正为1")
        }
        return .adaptive(sizeConstraint: .min(correctedSize))
    }

    /// 创建具有最大尺寸约束的自适应配置
    /// - Parameter maxSize: 每行或列的最大尺寸
    static func adaptive(maxSize: CGFloat) -> MasonryLines {
        let correctedSize = max(1, maxSize)
        if maxSize <= 0 {
            print("⚠️ SwiftUIMasonryLayouts: 最大尺寸必须大于0，已自动修正为1")
        }
        return .adaptive(sizeConstraint: .max(correctedSize))
    }

    /// 获取固定数量（如果是固定模式）
    var fixedCount: Int? {
        switch self {
        case .fixed(let count):
            return count
        case .adaptive:
            return nil
        }
    }
}

// MARK: - 瀑布流放置模式

/// 定义瀑布流视图中项目的放置策略
public enum MasonryPlacementMode: Sendable, Equatable, Hashable {
    
    /// 智能填充模式
    ///
    /// 每个项目都会被放置在当前最短的行或列中，以保持整体布局的平衡
    case fill
    
    /// 顺序放置模式
    ///
    /// 项目按照数据源的顺序依次放置在各行或列中，循环进行
    case order
}

// MARK: - 瀑布流配置

/// 瀑布流布局的完整配置
public struct MasonryConfiguration: Sendable, Equatable, Hashable {
    
    // MARK: - 属性
    
    /// 布局轴向
    public let axis: Axis
    /// 行/列配置
    public let lines: MasonryLines
    /// 水平间距
    public let horizontalSpacing: CGFloat
    /// 垂直间距
    public let verticalSpacing: CGFloat
    /// 放置模式
    public let placementMode: MasonryPlacementMode
    
    // MARK: - 初始化
    
    /// 创建瀑布流配置
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置，默认为2列
    ///   - horizontalSpacing: 水平间距，默认为8
    ///   - verticalSpacing: 垂直间距，默认为8
    ///   - placementMode: 放置模式，默认为智能填充
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        placementMode: MasonryPlacementMode = .fill
    ) {
        self.axis = axis
        self.lines = lines
        self.horizontalSpacing = max(0, horizontalSpacing)
        self.verticalSpacing = max(0, verticalSpacing)
        self.placementMode = placementMode
        
        #if DEBUG
        if horizontalSpacing < 0 {
            print("⚠️ SwiftUIMasonryLayouts: 水平间距不能为负数，已自动修正为0")
        }
        if verticalSpacing < 0 {
            print("⚠️ SwiftUIMasonryLayouts: 垂直间距不能为负数，已自动修正为0")
        }
        #endif
    }
}

// MARK: - 预设配置

public extension MasonryConfiguration {
    
    /// 默认配置：垂直2列，间距8
    static let `default` = MasonryConfiguration()

    /// 自适应列配置（最小列宽120）
    static let adaptiveColumns = adaptive(minColumnWidth: 120)

    /// 水平双行配置
    static let twoRows = rows(2)
}

// MARK: - 便捷方法

public extension MasonryConfiguration {
    
    /// 创建固定列数的垂直配置
    /// - Parameters:
    ///   - columns: 列数
    ///   - spacing: 间距
    /// - Returns: 瀑布流配置
    static func columns(_ count: Int, spacing: CGFloat = 8) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(max(1, count)),
            horizontalSpacing: spacing,
            verticalSpacing: spacing
        )
    }
    
    /// 创建固定行数的水平配置
    /// - Parameters:
    ///   - rows: 行数
    ///   - spacing: 间距
    /// - Returns: 瀑布流配置
    static func rows(_ count: Int, spacing: CGFloat = 8) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: .horizontal,
            lines: .fixed(max(1, count)),
            horizontalSpacing: spacing,
            verticalSpacing: spacing
        )
    }
    
    /// 创建自适应列数的垂直配置
    /// - Parameters:
    ///   - minColumnWidth: 最小列宽
    ///   - spacing: 间距
    /// - Returns: 瀑布流配置
    static func adaptive(minColumnWidth: CGFloat, spacing: CGFloat = 8) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: .vertical,
            lines: .adaptive(minSize: minColumnWidth),
            horizontalSpacing: spacing,
            verticalSpacing: spacing
        )
    }
    
    /// 修改间距
    /// - Parameters:
    ///   - horizontal: 水平间距
    ///   - vertical: 垂直间距
    /// - Returns: 新的配置实例
    func withSpacing(horizontal: CGFloat, vertical: CGFloat) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: axis,
            lines: lines,
            horizontalSpacing: max(0, horizontal),
            verticalSpacing: max(0, vertical),
            placementMode: placementMode
        )
    }

    /// 修改放置模式
    /// - Parameter mode: 新的放置模式
    /// - Returns: 新的配置实例
    func withPlacementMode(_ mode: MasonryPlacementMode) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: axis,
            lines: lines,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            placementMode: mode
        )
    }
}

// MARK: - 内部配置常量

/// SwiftUIMasonryLayouts 内部配置常量
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal enum MasonryInternalConfig {

    // MARK: - 性能常量

    /// 响应式布局防抖延迟（纳秒）
    static let responsiveDebounceDelay: UInt64 = 50_000_000 // 50ms

    /// 最大缓存项目数量
    static let maxCacheSize: Int = 1000

    /// 布局缓存最大数量
    static let maxLayoutCacheSize: Int = 50

    // MARK: - 默认值常量

    /// 默认水平间距
    static let defaultHorizontalSpacing: CGFloat = 8

    /// 默认垂直间距
    static let defaultVerticalSpacing: CGFloat = 8

    /// 默认列数
    static let defaultColumnCount: Int = 2

    /// 推断容器尺寸时的最小宽度
    static let minimumInferredWidth: CGFloat = 320

    /// 推断容器尺寸时的最小高度
    static let minimumInferredHeight: CGFloat = 200

    // MARK: - 调试开关（基于编译模式）

    /// 是否启用内部调试日志
    static var enableInternalLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
