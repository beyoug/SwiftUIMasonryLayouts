//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

// MARK: - 预览项目协议

/// 预览项目协议，用于动态尺寸估算
protocol PreviewItemProtocol {
    /// 内容高度（不包括文本和padding）
    var contentHeight: CGFloat { get }
    /// 内容宽度（不包括padding）
    var contentWidth: CGFloat { get }
}

// MARK: - 滚动偏移监听

/// 滚动偏移偏好键
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

/// 容器偏移偏好键
struct ContainerOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// MARK: - 虚拟化错误类型

/// 虚拟化计算错误
enum VirtualizationError: Error, LocalizedError {
    case invalidContainerSize
    case invalidEstimatedSize
    case invalidLineCount
    case cancelled
    case memoryAllocationFailed
    case invalidConfiguration
    case dataCorruption

    var errorDescription: String? {
        switch self {
        case .invalidContainerSize:
            return "容器尺寸无效"
        case .invalidEstimatedSize:
            return "估计项目尺寸无效"
        case .invalidLineCount:
            return "无效的行数配置"
        case .cancelled:
            return "布局计算被取消"
        case .memoryAllocationFailed:
            return "内存分配失败"
        case .invalidConfiguration:
            return "无效的配置参数"
        case .dataCorruption:
            return "数据损坏或不一致"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidContainerSize:
            return "请确保容器宽度和高度都大于0"
        case .invalidEstimatedSize:
            return "请提供有效的估计项目尺寸"
        case .invalidLineCount:
            return "请检查行数配置是否合理"
        case .cancelled:
            return "操作已被取消，可以重新尝试"
        case .memoryAllocationFailed:
            return "请减少数据量或释放内存后重试"
        case .invalidConfiguration:
            return "请检查配置参数是否正确"
        case .dataCorruption:
            return "请检查数据源的完整性"
        }
    }
}
