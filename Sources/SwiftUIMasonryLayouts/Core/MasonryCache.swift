import CoreGraphics
import SwiftUI

@available(iOS 26.0, *)
internal struct MasonryCacheKey: Equatable {
    let containerSize: CGSize
    let axis: Axis
    let tracks: MasonryTracks
    let spacing: CGFloat
    let placement: MasonryPlacement
    let subviewCount: Int
    let measurementSignature: [CGSize]

    init(
        containerSize: CGSize,
        axis: Axis,
        tracks: MasonryTracks,
        spacing: CGFloat,
        placement: MasonryPlacement,
        subviewCount: Int,
        measurementSignature: [CGSize] = []
    ) {
        self.containerSize = containerSize
        self.axis = axis
        self.tracks = tracks
        self.spacing = spacing
        self.placement = placement
        self.subviewCount = subviewCount
        self.measurementSignature = measurementSignature
    }

    static func == (lhs: MasonryCacheKey, rhs: MasonryCacheKey) -> Bool {
        lhs.axis == rhs.axis
            && lhs.crossAxisLength == rhs.crossAxisLength
            && lhs.tracks == rhs.tracks
            && lhs.spacing == rhs.spacing
            && lhs.placement == rhs.placement
            && lhs.subviewCount == rhs.subviewCount
            && lhs.measurementSignature == rhs.measurementSignature
    }

    private var crossAxisLength: CGFloat {
        let rawCrossAxisLength = axis == .vertical ? containerSize.width : containerSize.height
        return MasonryValidation.normalizedLength(rawCrossAxisLength)
    }
}

@available(iOS 26.0, *)
internal struct MasonryCache {
    private var key: MasonryCacheKey?
    private var cachedResult: MasonryLayoutResult?

    mutating func store(_ result: MasonryLayoutResult, for key: MasonryCacheKey) {
        self.key = key
        self.cachedResult = result
    }

    func result(for key: MasonryCacheKey) -> MasonryLayoutResult? {
        guard self.key == key else { return nil }
        return cachedResult
    }
}
