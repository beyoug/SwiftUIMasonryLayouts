import CoreGraphics
import SwiftUI

@available(iOS 26.0, *)
internal enum MasonryValidation {
    static func normalizedSpacing(_ value: CGFloat) -> CGFloat {
        guard value.isFinite else { return 0 }
        return max(0, value)
    }

    static func normalizedFixedTrackCount(_ value: Int) -> Int {
        max(1, value)
    }

    static func normalizedAdaptiveMinimum(_ value: CGFloat) -> CGFloat {
        guard value.isFinite, value > 0 else { return 1 }
        return value
    }

    static func normalizedLength(_ value: CGFloat) -> CGFloat {
        guard value.isFinite else { return 0 }
        return max(0, value)
    }

    static func normalizedMeasuredSize(_ size: CGSize, axis: Axis, trackSize: CGFloat) -> CGSize {
        switch axis {
        case .vertical:
            return CGSize(width: trackSize, height: normalizedLength(size.height))
        case .horizontal:
            return CGSize(width: normalizedLength(size.width), height: trackSize)
        }
    }
}
