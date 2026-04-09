import CoreGraphics
import SwiftUI

@available(iOS 26.0, *)
internal enum MasonryLayoutEngine {
    static func layout(
        itemSizes: [CGSize],
        metrics: MasonryMetrics,
        placement: MasonryPlacement
    ) -> MasonryLayoutResult {
        guard metrics.trackCount > 0, !itemSizes.isEmpty else {
            return .empty
        }

        var offsets = Array(repeating: CGFloat.zero, count: metrics.trackCount)
        var frames: [CGRect] = []
        frames.reserveCapacity(itemSizes.count)

        for (index, itemSize) in itemSizes.enumerated() {
            let trackIndex = nextTrackIndex(offsets: offsets, placement: placement, itemIndex: index)

            switch metrics.axis {
            case .vertical:
                let x = CGFloat(trackIndex) * (metrics.trackSize + metrics.spacing)
                let frame = CGRect(
                    x: x,
                    y: offsets[trackIndex],
                    width: metrics.trackSize,
                    height: max(0, itemSize.height)
                )
                frames.append(frame)
                offsets[trackIndex] += frame.height + metrics.spacing

            case .horizontal:
                let y = CGFloat(trackIndex) * (metrics.trackSize + metrics.spacing)
                let frame = CGRect(
                    x: offsets[trackIndex],
                    y: y,
                    width: max(0, itemSize.width),
                    height: metrics.trackSize
                )
                frames.append(frame)
                offsets[trackIndex] += frame.width + metrics.spacing
            }
        }

        let maxOffset = offsets.max() ?? 0
        let trailingSpacing = itemSizes.isEmpty ? 0 : metrics.spacing

        switch metrics.axis {
        case .vertical:
            return MasonryLayoutResult(
                frames: frames,
                contentSize: CGSize(
                    width: CGFloat(metrics.trackCount) * metrics.trackSize + CGFloat(max(0, metrics.trackCount - 1)) * metrics.spacing,
                    height: max(0, maxOffset - trailingSpacing)
                )
            )

        case .horizontal:
            return MasonryLayoutResult(
                frames: frames,
                contentSize: CGSize(
                    width: max(0, maxOffset - trailingSpacing),
                    height: CGFloat(metrics.trackCount) * metrics.trackSize + CGFloat(max(0, metrics.trackCount - 1)) * metrics.spacing
                )
            )
        }
    }

    private static func nextTrackIndex(
        offsets: [CGFloat],
        placement: MasonryPlacement,
        itemIndex: Int
    ) -> Int {
        switch placement {
        case .shortestFirst:
            return offsets.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
        case .sequential:
            return itemIndex % max(1, offsets.count)
        }
    }
}
