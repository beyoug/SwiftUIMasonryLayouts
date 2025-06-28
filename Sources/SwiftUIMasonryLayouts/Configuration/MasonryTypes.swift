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

// MARK: - 验证扩展

public extension MasonryLines {


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
