import SwiftUI

@available(iOS 26.0, *)
public struct MasonryLayout: Layout {
    public struct Cache {
        var layout = MasonryLayoutCache()
    }

    private struct MasonryContainerContext {
        let crossAxisLength: CGFloat
        let proposedMainAxisLength: CGFloat?

        func containerSize(for axis: Axis) -> CGSize {
            let crossAxisLength = MasonryValidation.normalizedLength(crossAxisLength)
            let mainAxisLength = proposedMainAxisLength.map(MasonryValidation.normalizedLength)

            switch axis {
            case .vertical:
                return CGSize(width: crossAxisLength, height: mainAxisLength ?? 0)
            case .horizontal:
                return CGSize(width: mainAxisLength ?? 0, height: crossAxisLength)
            }
        }
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
        let containerContext = resolvedContainerContext(from: proposal, subviews: subviews)
        return resolvedResult(containerContext: containerContext, subviews: subviews, cache: &cache).contentSize
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let containerContext = resolvedContainerContext(from: bounds.size)
        let result = resolvedResult(containerContext: containerContext, subviews: subviews, cache: &cache)

        for (subview, frame) in zip(subviews, result.frames) {
            let point = CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY)
            subview.place(at: point, proposal: ProposedViewSize(frame.size))
        }
    }

    private func resolvedResult(
        containerContext: MasonryContainerContext,
        subviews: Subviews,
        cache: inout Cache
    ) -> MasonryLayoutResult {
        let metrics = MasonryMetrics(
            containerSize: containerContext.containerSize(for: axis),
            axis: axis,
            tracks: tracks,
            spacing: spacing
        )
        let measurementProposal = axis == .vertical
            ? ProposedViewSize(width: metrics.trackSize, height: nil)
            : ProposedViewSize(width: nil, height: metrics.trackSize)

        let itemSizes = subviews.map { subview in
            MasonryMeasurement(
                axis: axis,
                trackSize: metrics.trackSize,
                measuredSize: subview.sizeThatFits(measurementProposal)
            ).normalizedSize
        }

        let key = MasonryLayoutCacheKey(
            axis: axis,
            crossAxisLength: containerContext.crossAxisLength,
            tracks: tracks,
            spacing: metrics.spacing,
            placement: placement,
            subviewCount: subviews.count,
            measurementSignature: itemSizes
        )

        if let cached = cache.layout.result(for: key) {
            return cached
        }

        let result = MasonryLayoutEngine.layout(itemSizes: itemSizes, metrics: metrics, placement: placement)
        cache.layout.store(result, for: key)
        return result
    }

    internal func containerContext(
        for proposal: ProposedViewSize,
        fallbackSize: CGSize
    ) -> (crossAxisLength: CGFloat, proposedMainAxisLength: CGFloat?) {
        let context = resolvedContainerContext(from: proposal, fallbackSize: fallbackSize)
        return (context.crossAxisLength, context.proposedMainAxisLength)
    }

    private func resolvedContainerContext(from proposal: ProposedViewSize, subviews: Subviews) -> MasonryContainerContext {
        let fallbackSize = subviews.reduce(CGSize(width: 1, height: 1)) { partialResult, subview in
            let size = subview.sizeThatFits(.unspecified)
            return CGSize(
                width: max(partialResult.width, MasonryValidation.normalizedLength(size.width)),
                height: max(partialResult.height, MasonryValidation.normalizedLength(size.height))
            )
        }

        return resolvedContainerContext(from: proposal, fallbackSize: fallbackSize)
    }

    private func resolvedContainerContext(from proposal: ProposedViewSize, fallbackSize: CGSize) -> MasonryContainerContext {
        switch axis {
        case .vertical:
            return MasonryContainerContext(
                crossAxisLength: proposal.width ?? fallbackSize.width,
                proposedMainAxisLength: proposal.height
            )
        case .horizontal:
            return MasonryContainerContext(
                crossAxisLength: proposal.height ?? fallbackSize.height,
                proposedMainAxisLength: proposal.width
            )
        }
    }

    private func resolvedContainerContext(from containerSize: CGSize) -> MasonryContainerContext {
        switch axis {
        case .vertical:
            return MasonryContainerContext(
                crossAxisLength: containerSize.width,
                proposedMainAxisLength: containerSize.height
            )
        case .horizontal:
            return MasonryContainerContext(
                crossAxisLength: containerSize.height,
                proposedMainAxisLength: containerSize.width
            )
        }
    }
}
