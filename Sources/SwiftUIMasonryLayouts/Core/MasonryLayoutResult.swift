import CoreGraphics

@available(iOS 26.0, *)
internal struct MasonryLayoutResult: Equatable {
    let frames: [CGRect]
    let contentSize: CGSize

    static let empty = MasonryLayoutResult(frames: [], contentSize: .zero)
}
