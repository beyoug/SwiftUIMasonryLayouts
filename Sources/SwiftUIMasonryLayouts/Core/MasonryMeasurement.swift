import CoreGraphics
import SwiftUI

@available(iOS 26.0, *)
internal struct MasonryMeasurement: Equatable {
    let axis: Axis
    let trackSize: CGFloat
    let measuredSize: CGSize

    var normalizedSize: CGSize {
        switch axis {
        case .vertical:
            return CGSize(width: trackSize, height: MasonryValidation.normalizedLength(measuredSize.height))
        case .horizontal:
            return CGSize(width: MasonryValidation.normalizedLength(measuredSize.width), height: trackSize)
        }
    }

    static func == (lhs: MasonryMeasurement, rhs: MasonryMeasurement) -> Bool {
        lhs.normalizedSize == rhs.normalizedSize
    }
}
