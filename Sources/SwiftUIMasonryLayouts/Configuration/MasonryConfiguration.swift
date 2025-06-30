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
            MasonryLogger.warning("Validation: 最小尺寸必须大于0，已自动修正为1")
        }
        return .adaptive(sizeConstraint: .min(correctedSize))
    }

    /// 创建具有最大尺寸约束的自适应配置
    /// - Parameter maxSize: 每行或列的最大尺寸
    static func adaptive(maxSize: CGFloat) -> MasonryLines {
        let correctedSize = max(1, maxSize)
        if maxSize <= 0 {
            MasonryLogger.warning("Validation: 最大尺寸必须大于0，已自动修正为1")
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
    
    // MARK: - 初始化
    
    /// 创建瀑布流配置
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置，默认为2列
    ///   - hSpacing: 水平间距，默认为8
    ///   - vSpacing: 垂直间距，默认为8
    ///   - placement: 放置模式，默认为智能填充
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        hSpacing: CGFloat = 8,
        vSpacing: CGFloat = 8,
        placement: MasonryPlacementMode = .fill
    ) {
        self.axis = axis
        self.lines = lines
        self.hSpacing = max(0, hSpacing)
        self.vSpacing = max(0, vSpacing)
        self.placement = placement
        
        #if DEBUG
        if hSpacing < 0 {
            MasonryLogger.warning("Validation: 水平间距不能为负数，已自动修正为0")
        }
        if vSpacing < 0 {
            MasonryLogger.warning("Validation: 垂直间距不能为负数，已自动修正为0")
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
            placement: placement
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

// MARK: - 布局相关类型定义

/// 瀑布流布局结果
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct LayoutResult {
    /// 每个项目的框架
    let itemFrames: [CGRect]
    /// 总尺寸
    let totalSize: CGSize
    /// 行/列数
    let lineCount: Int
}

/// 懒加载布局结果
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct LazyLayoutResult {
    let itemFrames: [CGRect]
    let totalSize: CGSize
    let lineCount: Int
    let itemPositions: [AnyHashable: CGRect]
}

/// 滚动偏移检测
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

/// 布局计算参数
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct LayoutParameters {
    let containerSize: CGSize
    let axis: Axis
    let lines: MasonryLines
    let hSpacing: CGFloat
    let vSpacing: CGFloat
    let placement: MasonryPlacementMode

    /// 计算行/列数
    func calculateLineCount() -> Int {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height
        let spacing = axis == .vertical ? hSpacing : vSpacing

        guard availableSize > 0 else {
            MasonryLogger.warning("Container: 容器尺寸无效 (availableSize: \(availableSize))，使用默认单列布局")
            return 1
        }

        switch lines {
        case .fixed(let count):
            let validCount = max(1, count)
            if count <= 0 {
                MasonryLogger.warning("Validation: 固定列数无效 (\(count))，已修正为 \(validCount)")
            }
            return validCount

        case .adaptive(let constraint):
            switch constraint {
            case .min(let minSize):
                guard minSize > 0 else {
                    MasonryLogger.warning("Validation: 最小尺寸无效 (\(minSize))，使用默认单列布局")
                    return 1
                }
                let count = Int(floor((availableSize + spacing) / (minSize + spacing)))
                let validCount = max(1, count)
                if count <= 0 {
                    MasonryLogger.warning("Validation: 计算的自适应列数无效 (\(count))，已修正为 \(validCount)")
                }
                return validCount

            case .max(let maxSize):
                guard maxSize > 0 else {
                    MasonryLogger.warning("Validation: 最大尺寸无效 (\(maxSize))，使用默认单列布局")
                    return 1
                }
                let count = Int(ceil((availableSize + spacing) / (maxSize + spacing)))
                let validCount = max(1, count)
                if count <= 0 {
                    MasonryLogger.warning("Validation: 计算的自适应列数无效 (\(count))，已修正为 \(validCount)")
                }
                return validCount
            }
        }
    }

    /// 计算行/列尺寸
    func calculateLineSize(lineCount: Int) -> CGFloat {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height
        guard lineCount > 0 && availableSize > 0 else { return 0 }

        let totalSpacing = CGFloat(max(0, lineCount - 1)) * (axis == .vertical ? hSpacing : vSpacing)
        let lineSize = (availableSize - totalSpacing) / CGFloat(lineCount)

        return max(0, lineSize)
    }

    /// 选择放置的行/列索引
    func selectLineIndex(lineOffsets: [CGFloat], index: Int) -> Int {
        guard !lineOffsets.isEmpty else { return 0 }

        switch placement {
        case .fill:
            let selectedIndex = lineOffsets.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            return max(0, min(selectedIndex, lineOffsets.count - 1))
        case .order:
            return index % lineOffsets.count
        }
    }

    /// 计算总尺寸
    func calculateTotalSize(lineOffsets: [CGFloat], lineSize: CGFloat, lineCount: Int) -> CGSize {
        let maxOffset = lineOffsets.max() ?? 0

        if axis == .vertical {
            let totalHeight = max(0, maxOffset - vSpacing)
            let totalWidth = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * hSpacing
            return CGSize(width: totalWidth, height: totalHeight)
        } else {
            let totalWidth = max(0, maxOffset - hSpacing)
            let totalHeight = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * vSpacing
            return CGSize(width: totalWidth, height: totalHeight)
        }
    }
}

/// 项目布局信息
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal struct ItemLayoutInfo {
    let frame: CGRect
    let lineIndex: Int
    let itemIndex: Int
}

// MARK: - 内部配置常量

/// SwiftUIMasonryLayouts 内部配置常量
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal enum MasonryInternalConfig {
    /// 响应式布局防抖延迟（纳秒）
    static let responsiveDebounceDelay: UInt64 = 50_000_000 // 50ms

    /// 推断容器尺寸时的最小宽度
    static let minimumInferredWidth: CGFloat = 320

    /// 推断容器尺寸时的最小高度
    static let minimumInferredHeight: CGFloat = 200
}

// MARK: - 内部工具和扩展

/// SwiftUIMasonryLayouts 内部工具集合
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal enum MasonryInternal {
    /// 安全的尺寸验证
    static func validateSize(_ size: CGSize, context: String = "") -> CGSize {
        let validWidth = max(0, size.width.isFinite ? size.width : 0)
        let validHeight = max(0, size.height.isFinite ? size.height : 0)

        #if DEBUG
        if size.width != validWidth || size.height != validHeight {
            MasonryLogger.warning("Validation: 尺寸验证修正 \(context): \(size) -> \(CGSize(width: validWidth, height: validHeight))")
        }
        #endif

        return CGSize(width: validWidth, height: validHeight)
    }
}

// MARK: - 简化日志系统

/// 简化的日志工具
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal enum MasonryLogger {
    /// 调试信息
    static func debug(_ message: String) {
        #if DEBUG
        print("🔵 SwiftUIMasonryLayouts: \(message)")
        #endif
    }

    /// 一般信息
    static func info(_ message: String) {
        #if DEBUG
        print("🟢 SwiftUIMasonryLayouts: \(message)")
        #endif
    }

    /// 警告信息
    static func warning(_ message: String) {
        #if DEBUG
        print("🟡 SwiftUIMasonryLayouts: \(message)")
        #endif
    }

    /// 错误信息
    static func error(_ message: String) {
        #if DEBUG
        print("🔴 SwiftUIMasonryLayouts: \(message)")
        #endif
    }
}
