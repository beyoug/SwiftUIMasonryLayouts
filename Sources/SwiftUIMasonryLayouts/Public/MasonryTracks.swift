import CoreGraphics

@available(iOS 26.0, *)
public enum MasonryTracks: Hashable, Sendable {
    case fixed(Int)
    case adaptive(min: CGFloat)
}
