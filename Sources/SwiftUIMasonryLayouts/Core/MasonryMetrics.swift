import CoreGraphics
import SwiftUI

@available(iOS 26.0, *)
internal struct MasonryMetrics: Equatable {
    let containerSize: CGSize
    let axis: Axis
    let spacing: CGFloat
    let trackCount: Int
    let trackSize: CGFloat

    init(containerSize: CGSize, axis: Axis, tracks: MasonryTracks, spacing: CGFloat) {
        let safeWidth = MasonryValidation.normalizedLength(containerSize.width)
        let safeHeight = MasonryValidation.normalizedLength(containerSize.height)

        self.containerSize = CGSize(width: safeWidth, height: safeHeight)
        self.axis = axis
        self.spacing = MasonryValidation.normalizedSpacing(spacing)

        let availableCrossAxis = axis == .vertical ? safeWidth : safeHeight

        switch tracks {
        case .fixed(let count):
            self.trackCount = MasonryValidation.normalizedFixedTrackCount(count)
        case .adaptive(min: let minimum):
            let normalizedMinimum = MasonryValidation.normalizedAdaptiveMinimum(minimum)
            let rawTrackCount = Self.stableAdaptiveTrackCountRatio(
                availableCrossAxis: availableCrossAxis,
                minimum: normalizedMinimum,
                spacing: self.spacing
            )

            if !rawTrackCount.isFinite || Double(rawTrackCount) >= Double(Int.max) {
                self.trackCount = Int.max
            } else {
                self.trackCount = max(1, Int(rawTrackCount))
            }
        }

        let totalSpacing = CGFloat(max(0, trackCount - 1)) * self.spacing
        self.trackSize = max(0, (availableCrossAxis - totalSpacing) / CGFloat(trackCount))
    }

    private static func stableAdaptiveTrackCountRatio(
        availableCrossAxis: CGFloat,
        minimum: CGFloat,
        spacing: CGFloat
    ) -> CGFloat {
        let numeratorScale = max(availableCrossAxis, spacing)
        let denominatorScale = max(minimum, spacing)

        guard numeratorScale.isFinite, numeratorScale > 0 else {
            return 1
        }

        guard denominatorScale.isFinite, denominatorScale > 0 else {
            return 1
        }

        let numeratorNormalized = availableCrossAxis / numeratorScale + spacing / numeratorScale
        let denominatorNormalized = minimum / denominatorScale + spacing / denominatorScale

        guard denominatorNormalized > 0 else { return 1 }

        let scaleRatio = numeratorScale / denominatorScale
        let normalizedRatio = numeratorNormalized / denominatorNormalized

        return scaleRatio * normalizedRatio
    }
}
