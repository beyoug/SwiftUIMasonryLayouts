//
// Copyright (c) Beyoug
//

import SwiftUI

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
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let placementMode: MasonryPlacementMode
    
    /// 计算行/列数
    func calculateLineCount() -> Int {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height
        let spacing = axis == .vertical ? horizontalSpacing : verticalSpacing

        guard availableSize > 0 else {
            if MasonryInternalConfig.enableInternalLogging {
                print("⚠️ SwiftUIMasonryLayouts: 容器尺寸无效 (availableSize: \(availableSize))，使用默认单列布局")
            }
            return 1
        }

        switch lines {
        case .fixed(let count):
            let validCount = max(1, count)
            if MasonryInternalConfig.enableInternalLogging && count <= 0 {
                print("⚠️ SwiftUIMasonryLayouts: 固定列数无效 (\(count))，已修正为 \(validCount)")
            }
            return validCount

        case .adaptive(let constraint):
            switch constraint {
            case .min(let minSize):
                guard minSize > 0 else {
                    if MasonryInternalConfig.enableInternalLogging {
                        print("⚠️ SwiftUIMasonryLayouts: 最小尺寸无效 (\(minSize))，使用默认单列布局")
                    }
                    return 1
                }
                let count = Int(floor((availableSize + spacing) / (minSize + spacing)))
                let validCount = max(1, count)
                if MasonryInternalConfig.enableInternalLogging && count <= 0 {
                    print("⚠️ SwiftUIMasonryLayouts: 计算的自适应列数无效 (\(count))，已修正为 \(validCount)")
                }
                return validCount

            case .max(let maxSize):
                guard maxSize > 0 else {
                    if MasonryInternalConfig.enableInternalLogging {
                        print("⚠️ SwiftUIMasonryLayouts: 最大尺寸无效 (\(maxSize))，使用默认单列布局")
                    }
                    return 1
                }
                let count = Int(ceil((availableSize + spacing) / (maxSize + spacing)))
                let validCount = max(1, count)
                if MasonryInternalConfig.enableInternalLogging && count <= 0 {
                    print("⚠️ SwiftUIMasonryLayouts: 计算的自适应列数无效 (\(count))，已修正为 \(validCount)")
                }
                return validCount
            }
        }
    }
    
    /// 计算行/列尺寸
    func calculateLineSize(lineCount: Int) -> CGFloat {
        let availableSize = axis == .vertical ? containerSize.width : containerSize.height
        guard lineCount > 0 && availableSize > 0 else { return 0 }
        
        let totalSpacing = CGFloat(max(0, lineCount - 1)) * (axis == .vertical ? horizontalSpacing : verticalSpacing)
        let lineSize = (availableSize - totalSpacing) / CGFloat(lineCount)
        
        return max(0, lineSize)
    }
    
    /// 选择放置的行/列索引
    func selectLineIndex(lineOffsets: [CGFloat], index: Int) -> Int {
        guard !lineOffsets.isEmpty else { return 0 }
        
        switch placementMode {
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
            let totalHeight = max(0, maxOffset - verticalSpacing)
            let totalWidth = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * horizontalSpacing
            return CGSize(width: totalWidth, height: totalHeight)
        } else {
            let totalWidth = max(0, maxOffset - horizontalSpacing)
            let totalHeight = CGFloat(lineCount) * lineSize + CGFloat(max(0, lineCount - 1)) * verticalSpacing
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
