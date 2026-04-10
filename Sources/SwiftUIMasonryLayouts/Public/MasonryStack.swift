import SwiftUI

public typealias Axis = SwiftUI.Axis

@available(iOS 26.0, *)
public struct MasonryStack<Content: View>: View {
    private let axis: Axis
    private let tracks: MasonryTracks
    private let spacing: CGFloat
    private let placement: MasonryPlacement
    private let content: () -> Content

    public init(
        axis: Axis = .vertical,
        tracks: MasonryTracks = .fixed(2),
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.tracks = tracks
        self.spacing = spacing
        self.placement = placement
        self.content = content
    }

    public var body: some View {
        MasonryLayout(
            axis: axis,
            tracks: tracks,
            spacing: spacing,
            placement: placement
        ) {
            content()
        }
    }
}

@available(iOS 26.0, *)
public extension MasonryStack {
    init(
        columns: Int,
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            axis: .vertical,
            tracks: .fixed(columns),
            spacing: spacing,
            placement: placement,
            content: content
        )
    }

    init(
        rows: Int,
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            axis: .horizontal,
            tracks: .fixed(rows),
            spacing: spacing,
            placement: placement,
            content: content
        )
    }

    init(
        adaptiveColumns minimum: CGFloat,
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            axis: .vertical,
            tracks: .adaptive(min: minimum),
            spacing: spacing,
            placement: placement,
            content: content
        )
    }

    init(
        adaptiveRows minimum: CGFloat,
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            axis: .horizontal,
            tracks: .adaptive(min: minimum),
            spacing: spacing,
            placement: placement,
            content: content
        )
    }
}
