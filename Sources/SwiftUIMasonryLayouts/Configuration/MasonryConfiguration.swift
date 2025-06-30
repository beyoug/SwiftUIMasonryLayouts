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
            MasonryInternalConfig.Logger.warning("最小尺寸必须大于0，已自动修正为1")
        }
        return .adaptive(sizeConstraint: .min(correctedSize))
    }

    /// 创建具有最大尺寸约束的自适应配置
    /// - Parameter maxSize: 每行或列的最大尺寸
    static func adaptive(maxSize: CGFloat) -> MasonryLines {
        let correctedSize = max(1, maxSize)
        if maxSize <= 0 {
            MasonryInternalConfig.Logger.warning("最大尺寸必须大于0，已自动修正为1")
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
    public let hSpacing: CGFloat
    /// 垂直间距
    public let vSpacing: CGFloat
    /// 放置模式
    public let placement: MasonryPlacementMode
    /// 简化的智能尺寸配置
    public let simpleSizing: SimpleSizingConfiguration?

    // MARK: - 初始化
    
    /// 创建瀑布流配置
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置，默认为2列
    ///   - hSpacing: 水平间距，默认为8
    ///   - vSpacing: 垂直间距，默认为8
    ///   - placement: 放置模式，默认为智能填充
    ///   - simpleSizing: 简化的智能尺寸配置，默认为nil（使用传统计算）
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        hSpacing: CGFloat = 8,
        vSpacing: CGFloat = 8,
        placement: MasonryPlacementMode = .fill,
        simpleSizing: SimpleSizingConfiguration? = nil
    ) {
        self.axis = axis
        self.lines = lines
        self.hSpacing = max(0, hSpacing)
        self.vSpacing = max(0, vSpacing)
        self.placement = placement
        self.simpleSizing = simpleSizing

        if hSpacing < 0 {
            MasonryInternalConfig.Logger.warning("水平间距不能为负数，已自动修正为0")
        }
        if vSpacing < 0 {
            MasonryInternalConfig.Logger.warning("垂直间距不能为负数，已自动修正为0")
        }
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

    /// 黄金比例配置
    static let golden = MasonryConfiguration(simpleSizing: .default)

    /// 正方形配置
    static let square = MasonryConfiguration(simpleSizing: .square)

    /// 自适应配置
    static let adaptive = MasonryConfiguration(simpleSizing: .adaptive)
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
            hSpacing: spacing,
            vSpacing: spacing
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
            hSpacing: spacing,
            vSpacing: spacing
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
            hSpacing: spacing,
            vSpacing: spacing
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
            hSpacing: max(0, horizontal),
            vSpacing: max(0, vertical),
            placement: placement,
            simpleSizing: simpleSizing
        )
    }

    /// 修改放置模式
    /// - Parameter mode: 新的放置模式
    /// - Returns: 新的配置实例
    func withPlacementMode(_ mode: MasonryPlacementMode) -> MasonryConfiguration {
        MasonryConfiguration(
            axis: axis,
            lines: lines,
            hSpacing: hSpacing,
            vSpacing: vSpacing,
            placement: mode
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

    /// 最大缓存项目数量（优化后）
    static let maxCacheSize: Int = 2000

    /// 布局缓存最大数量（优化后）
    static let maxLayoutCacheSize: Int = 100

    /// 缓存有效期（秒）
    static let cacheValidityPeriod: TimeInterval = 300 // 5分钟

    /// 内存压力清理阈值
    static let memoryPressureThreshold: Int = 3

    // MARK: - 默认值常量

    /// 默认列数
    static let defaultColumnCount: Int = 2

    /// 推断容器尺寸时的最小宽度
    static let minimumInferredWidth: CGFloat = 320

    /// 推断容器尺寸时的最小高度
    static let minimumInferredHeight: CGFloat = 200

    // MARK: - 日志系统

    /// 内部日志记录器
    internal enum Logger {
        /// 记录错误信息（仅在DEBUG模式下显示）
        static func error(_ message: String) {
            #if DEBUG
            print("🔴 SwiftUIMasonryLayouts: \(message)")
            #endif
        }

        /// 记录警告信息（仅在DEBUG模式下显示）
        static func warning(_ message: String) {
            #if DEBUG
            print("🟡 SwiftUIMasonryLayouts: \(message)")
            #endif
        }

        /// 记录信息日志（仅在DEBUG模式下显示）
        static func info(_ message: String) {
            #if DEBUG
            print("🔵 SwiftUIMasonryLayouts: \(message)")
            #endif
        }

        /// 记录调试日志（仅在DEBUG模式下显示）
        static func debug(_ message: String) {
            #if DEBUG
            print("🟢 SwiftUIMasonryLayouts: \(message)")
            #endif
        }
    }
}
