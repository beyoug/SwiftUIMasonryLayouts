import CoreGraphics
import SwiftUI

@available(iOS 26.0, *)
internal struct MasonryLayoutCacheKey: Equatable {
    let axis: Axis
    let crossAxisLength: CGFloat
    let tracks: MasonryTracks
    let spacing: CGFloat
    let placement: MasonryPlacement
    let subviewCount: Int
    let measurementSignature: [CGSize]

    init(
        axis: Axis,
        crossAxisLength: CGFloat,
        tracks: MasonryTracks,
        spacing: CGFloat,
        placement: MasonryPlacement,
        subviewCount: Int,
        measurementSignature: [CGSize] = []
    ) {
        self.axis = axis
        self.crossAxisLength = MasonryValidation.normalizedLength(crossAxisLength)
        self.tracks = tracks
        self.spacing = spacing
        self.placement = placement
        self.subviewCount = subviewCount
        self.measurementSignature = measurementSignature
    }
}

@available(iOS 26.0, *)
internal struct MasonryLayoutCache {
    private var key: MasonryLayoutCacheKey?
    private var cachedResult: MasonryLayoutResult?

    mutating func store(_ result: MasonryLayoutResult, for key: MasonryLayoutCacheKey) {
        self.key = key
        self.cachedResult = result
    }

    func result(for key: MasonryLayoutCacheKey) -> MasonryLayoutResult? {
        guard self.key == key else { return nil }
        return cachedResult
    }
}
