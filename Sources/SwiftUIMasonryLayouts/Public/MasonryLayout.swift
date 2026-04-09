import SwiftUI

@available(iOS 26.0, *)
public struct MasonryLayout: Layout {
    public struct Cache {
        var storage = MasonryCache()
    }

    public let axis: Axis
    public let tracks: MasonryTracks
    public let spacing: CGFloat
    public let placement: MasonryPlacement

    public init(
        axis: Axis = .vertical,
        tracks: MasonryTracks = .fixed(2),
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst
    ) {
        self.axis = axis
        self.tracks = tracks
        self.spacing = spacing
        self.placement = placement
    }

    public func makeCache(subviews: Subviews) -> Cache {
        Cache()
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let containerSize = resolvedContainerSize(from: proposal, subviews: subviews)
        return resolvedResult(containerSize: containerSize, subviews: subviews, cache: &cache).contentSize
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let result = resolvedResult(containerSize: bounds.size, subviews: subviews, cache: &cache)

        for (subview, frame) in zip(subviews, result.frames) {
            let point = CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY)
            subview.place(at: point, proposal: ProposedViewSize(frame.size))
        }
    }

    private func resolvedResult(
        containerSize: CGSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> MasonryLayoutResult {
        let metrics = MasonryMetrics(containerSize: containerSize, axis: axis, tracks: tracks, spacing: spacing)
        let measurementProposal = axis == .vertical
            ? ProposedViewSize(width: metrics.trackSize, height: nil)
            : ProposedViewSize(width: nil, height: metrics.trackSize)

        let itemSizes = subviews.map { subview in
            MasonryValidation.normalizedMeasuredSize(
                subview.sizeThatFits(measurementProposal),
                axis: axis,
                trackSize: metrics.trackSize
            )
        }

        let key = MasonryCacheKey(
            containerSize: metrics.containerSize,
            axis: axis,
            tracks: tracks,
            spacing: metrics.spacing,
            placement: placement,
            subviewCount: subviews.count,
            measurementSignature: itemSizes
        )

        if let cached = cache.storage.result(for: key) {
            return cached
        }

        let result = MasonryLayoutEngine.layout(itemSizes: itemSizes, metrics: metrics, placement: placement)
        cache.storage.store(result, for: key)
        return result
    }

    private func resolvedContainerSize(from proposal: ProposedViewSize, subviews: Subviews) -> CGSize {
        let fallbackSize = subviews.reduce(CGSize(width: 1, height: 1)) { partialResult, subview in
            let size = subview.sizeThatFits(.unspecified)
            return CGSize(
                width: max(partialResult.width, MasonryValidation.normalizedLength(size.width)),
                height: max(partialResult.height, MasonryValidation.normalizedLength(size.height))
            )
        }

        switch axis {
        case .vertical:
            return CGSize(width: proposal.width ?? fallbackSize.width, height: proposal.height ?? 10_000)
        case .horizontal:
            return CGSize(width: proposal.width ?? 10_000, height: proposal.height ?? fallbackSize.height)
        }
    }
}
