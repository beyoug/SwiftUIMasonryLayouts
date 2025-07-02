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

    // MARK: - 滚动配置

    /// 底部触发阈值 (0.0-1.0，表示滚动进度百分比)
    public let bottomTriggerThreshold: CGFloat
    /// 顶部触发阈值 (像素值，表示距离顶部的像素距离)
    public let topTriggerThreshold: CGFloat
    /// 防抖间隔 (秒，避免重复触发)
    public let debounceInterval: TimeInterval

    // MARK: - 初始化
    
    /// 创建瀑布流配置
    /// - Parameters:
    ///   - axis: 布局轴向，默认为垂直
    ///   - lines: 行/列配置，默认为2列
    ///   - hSpacing: 水平间距，默认为8
    ///   - vSpacing: 垂直间距，默认为8
    ///   - placement: 放置模式，默认为智能填充
    ///   - bottomTriggerThreshold: 底部触发阈值，默认为0.6 (60%)
    ///   - topTriggerThreshold: 顶部触发阈值，默认为0 (顶部)
    ///   - debounceInterval: 防抖间隔，默认为1.0秒
    public init(
        axis: Axis = .vertical,
        lines: MasonryLines = .fixed(2),
        hSpacing: CGFloat = 8,
        vSpacing: CGFloat = 8,
        placement: MasonryPlacementMode = .fill,
        bottomTriggerThreshold: CGFloat = 0.6,
        topTriggerThreshold: CGFloat = 0,
        debounceInterval: TimeInterval = 1.0
    ) {
        self.axis = axis
        self.lines = lines
        self.hSpacing = max(0, hSpacing)
        self.vSpacing = max(0, vSpacing)
        self.placement = placement
        self.bottomTriggerThreshold = max(0, min(1, bottomTriggerThreshold))
        self.topTriggerThreshold = max(0, topTriggerThreshold)
        self.debounceInterval = max(0.1, debounceInterval)

        #if DEBUG
        if hSpacing < 0 {
            MasonryLogger.warning("Validation: 水平间距不能为负数，已自动修正为0")
        }
        if vSpacing < 0 {
            MasonryLogger.warning("Validation: 垂直间距不能为负数，已自动修正为0")
        }
        if bottomTriggerThreshold < 0 || bottomTriggerThreshold > 1 {
            MasonryLogger.warning("Validation: 底部触发阈值应在0-1之间，已自动修正")
        }
        if topTriggerThreshold < 0 {
            MasonryLogger.warning("Validation: 顶部触发阈值不能为负数，已自动修正为0")
        }
        if debounceInterval < 0.1 {
            MasonryLogger.warning("Validation: 防抖间隔不能小于0.1秒，已自动修正")
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

    /// 早期触发配置（滚动到50%时触发，适合快速加载）
    static let earlyTrigger = MasonryConfiguration(bottomTriggerThreshold: 0.5)

    /// 延迟触发配置（滚动到90%时触发，适合节省资源）
    static let lateTrigger = MasonryConfiguration(bottomTriggerThreshold: 0.9)

    /// 快速响应配置（0.5秒防抖，适合实时场景）
    static let fastResponse = MasonryConfiguration(debounceInterval: 0.5)

    /// 慢速响应配置（2秒防抖，适合避免频繁请求）
    static let slowResponse = MasonryConfiguration(debounceInterval: 2.0)
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

// 移除了 ScrollOffsetPreferenceKey，完全使用 iOS 18 onScrollGeometryChange API

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
                // 修正计算公式：先估算列数，然后验证是否能容纳
                let estimatedCount = Int(floor(availableSize / minSize))
                let actualCount = max(1, estimatedCount)

                // 验证计算的列数是否合理
                let totalSpacing = CGFloat(max(0, actualCount - 1)) * spacing
                let actualMinSize = (availableSize - totalSpacing) / CGFloat(actualCount)

                if actualMinSize < minSize && actualCount > 1 {
                    // 如果实际尺寸小于最小尺寸，减少一列
                    let adjustedCount = actualCount - 1
                    let adjustedTotalSpacing = CGFloat(max(0, adjustedCount - 1)) * spacing
                    let adjustedMinSize = (availableSize - adjustedTotalSpacing) / CGFloat(adjustedCount)

                    if adjustedMinSize >= minSize {
                        return adjustedCount
                    }
                }

                return actualCount

            case .max(let maxSize):
                guard maxSize > 0 else {
                    MasonryLogger.warning("Validation: 最大尺寸无效 (\(maxSize))，使用默认单列布局")
                    return 1
                }
                // 修正计算公式：计算能容纳的最小列数，使每列不超过最大尺寸
                let minCount = Int(ceil(availableSize / maxSize))
                let actualCount = max(1, minCount)

                // 验证计算的列数是否合理
                let totalSpacing = CGFloat(max(0, actualCount - 1)) * spacing
                let actualMaxSize = (availableSize - totalSpacing) / CGFloat(actualCount)

                if actualMaxSize > maxSize {
                    // 如果实际尺寸大于最大尺寸，增加一列
                    let adjustedCount = actualCount + 1
                    let adjustedTotalSpacing = CGFloat(max(0, adjustedCount - 1)) * spacing
                    let adjustedMaxSize = (availableSize - adjustedTotalSpacing) / CGFloat(adjustedCount)

                    if adjustedMaxSize <= maxSize {
                        return adjustedCount
                    }
                }

                return actualCount
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
        // 确保参数有效性
        guard lineCount > 0, lineSize >= 0 else {
            return .zero
        }

        let maxOffset = lineOffsets.max() ?? 0
        let safeLineCount = max(1, lineCount)
        let safeLineSize = max(0, lineSize)

        if axis == .vertical {
            // 垂直布局：宽度由列数决定，高度由内容决定
            let totalWidth = CGFloat(safeLineCount) * safeLineSize + CGFloat(max(0, safeLineCount - 1)) * hSpacing
            let totalHeight = maxOffset > 0 ? max(0, maxOffset - vSpacing) : 0
            return CGSize(width: totalWidth, height: totalHeight)
        } else {
            // 水平布局：高度由行数决定，宽度由内容决定
            let totalHeight = CGFloat(safeLineCount) * safeLineSize + CGFloat(max(0, safeLineCount - 1)) * vSpacing
            let totalWidth = maxOffset > 0 ? max(0, maxOffset - hSpacing) : 0
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
