//
// Copyright (c) Beyoug
//

import SwiftUI

// MARK: - 简化的智能尺寸计算

/// 简单的尺寸计算策略
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum SimpleSizingMode: Sendable, Equatable, Hashable {
    /// 黄金比例 (1:1.618)
    case golden
    /// 正方形 (1:1)
    case square
    /// 经典比例 (4:3)
    case classic
    /// 宽屏比例 (16:9)
    case widescreen
    /// 自定义比例
    case custom(ratio: CGFloat)
    /// 自适应（基于内容）
    case adaptive
    
    var ratio: CGFloat {
        switch self {
        case .golden: return 0.618 // 使用逆黄金比例，更适合布局
        case .square: return 1.0
        case .classic: return 0.75 // 3:4
        case .widescreen: return 0.5625 // 9:16
        case .custom(let ratio): return ratio
        case .adaptive: return 0.618 // 默认黄金比例
        }
    }
}

/// 简化的智能尺寸计算器
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct SimpleSizeCalculator {
    
    /// 计算智能尺寸
    /// - Parameters:
    ///   - index: 项目索引
    ///   - lineSize: 行/列尺寸
    ///   - axis: 布局轴向
    ///   - mode: 尺寸模式
    /// - Returns: 计算出的尺寸
    static func calculateSize(
        index: Int,
        lineSize: CGFloat,
        axis: Axis,
        mode: SimpleSizingMode = .golden
    ) -> CGSize {
        
        guard lineSize > 0 else {
            return createFallbackSize(lineSize: max(100, lineSize), axis: axis)
        }
        
        let ratio = mode.ratio
        
        // 为adaptive模式添加一些变化
        let finalRatio: CGFloat
        if case .adaptive = mode {
            // 基于索引创建一些变化，但保持简单
            let variations: [CGFloat] = [0.5, 0.618, 0.75, 1.0, 1.2]
            finalRatio = variations[index % variations.count]
        } else {
            finalRatio = ratio
        }
        
        if axis == .vertical {
            let height = lineSize * finalRatio
            return CGSize(width: lineSize, height: max(30, height))
        } else {
            let width = lineSize * finalRatio
            return CGSize(width: max(30, width), height: lineSize)
        }
    }
    
    /// 计算子视图的智能尺寸
    /// - Parameters:
    ///   - subview: 子视图
    ///   - lineSize: 行/列尺寸
    ///   - axis: 布局轴向
    ///   - mode: 尺寸模式
    /// - Returns: 计算出的尺寸
    static func calculateSizeForSubview(
        subview: LayoutSubview,
        lineSize: CGFloat,
        axis: Axis,
        mode: SimpleSizingMode = .adaptive
    ) -> CGSize {
        
        guard lineSize > 0 else {
            return createFallbackSize(lineSize: max(100, lineSize), axis: axis)
        }
        
        // 对于adaptive模式，尝试获取子视图的内在尺寸
        if case .adaptive = mode {
            let proposedSize = ProposedViewSize(
                width: axis == .vertical ? lineSize : nil,
                height: axis == .horizontal ? lineSize : nil
            )
            
            let intrinsicSize = subview.sizeThatFits(proposedSize)
            
            // 验证并调整
            if intrinsicSize.width.isFinite && intrinsicSize.height.isFinite &&
               intrinsicSize.width > 0 && intrinsicSize.height > 0 {
                
                var adjustedSize = intrinsicSize
                
                if axis == .vertical {
                    adjustedSize.width = lineSize
                    // 保持宽高比，但限制高度范围
                    let aspectRatio = intrinsicSize.height / intrinsicSize.width
                    adjustedSize.height = lineSize * aspectRatio
                    adjustedSize.height = max(lineSize * 0.3, min(lineSize * 2.0, adjustedSize.height))
                } else {
                    adjustedSize.height = lineSize
                    // 保持宽高比，但限制宽度范围
                    let aspectRatio = intrinsicSize.width / intrinsicSize.height
                    adjustedSize.width = lineSize * aspectRatio
                    adjustedSize.width = max(lineSize * 0.3, min(lineSize * 2.0, adjustedSize.width))
                }
                
                return adjustedSize
            }
        }
        
        // 回退到基于模式的计算
        return calculateSize(index: 0, lineSize: lineSize, axis: axis, mode: mode)
    }
    
    /// 创建回退尺寸
    internal static func createFallbackSize(lineSize: CGFloat, axis: Axis) -> CGSize {
        let fallbackRatio: CGFloat = 0.618 // 黄金比例

        if axis == .vertical {
            return CGSize(width: lineSize, height: lineSize * fallbackRatio)
        } else {
            return CGSize(width: lineSize * fallbackRatio, height: lineSize)
        }
    }
}

// MARK: - 简化的配置

/// 简化的智能尺寸配置
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct SimpleSizingConfiguration: Sendable, Equatable, Hashable {
    /// 尺寸模式
    public let mode: SimpleSizingMode
    /// 是否启用（如果禁用，使用传统计算）
    public let enabled: Bool
    
    public init(mode: SimpleSizingMode = .golden, enabled: Bool = true) {
        self.mode = mode
        self.enabled = enabled
    }
}

// MARK: - 预设配置

public extension SimpleSizingConfiguration {
    /// 默认配置（黄金比例）
    static let `default` = SimpleSizingConfiguration(mode: .golden)
    
    /// 正方形配置
    static let square = SimpleSizingConfiguration(mode: .square)
    
    /// 经典比例配置
    static let classic = SimpleSizingConfiguration(mode: .classic)
    
    /// 自适应配置
    static let adaptive = SimpleSizingConfiguration(mode: .adaptive)
    
    /// 禁用智能计算
    static let disabled = SimpleSizingConfiguration(enabled: false)
}

// MARK: - MasonryConfiguration 扩展

public extension MasonryConfiguration {
    /// 添加简化的智能尺寸配置
    /// - Parameter simpleSizing: 简化的智能尺寸配置
    /// - Returns: 新的配置实例
    func withSimpleSizing(_ simpleSizing: SimpleSizingConfiguration?) -> MasonryConfiguration {
        return MasonryConfiguration(
            axis: axis,
            lines: lines,
            hSpacing: hSpacing,
            vSpacing: vSpacing,
            placement: placement,
            simpleSizing: simpleSizing
        )
    }

    /// 便捷方法：黄金比例
    func withGoldenRatio() -> MasonryConfiguration {
        withSimpleSizing(.default)
    }

    /// 便捷方法：正方形
    func withSquareRatio() -> MasonryConfiguration {
        withSimpleSizing(.square)
    }

    /// 便捷方法：自适应
    func withAdaptiveSizing() -> MasonryConfiguration {
        withSimpleSizing(.adaptive)
    }
}
