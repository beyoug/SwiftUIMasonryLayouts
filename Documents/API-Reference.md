# API Reference

## Public Types

### MasonryStack

```swift
public struct MasonryStack<Content: View>: View {
    public init(
        axis: Axis = .vertical,
        tracks: MasonryTracks = .fixed(2),
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst,
        @ViewBuilder content: @escaping () -> Content
    )
}
```

Convenience initializers:

```swift
init(columns: Int, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
init(rows: Int, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
init(adaptiveColumns minimum: CGFloat, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
init(adaptiveRows minimum: CGFloat, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
```

### MasonryLayout

```swift
public struct MasonryLayout: Layout {
    public init(
        axis: Axis = .vertical,
        tracks: MasonryTracks = .fixed(2),
        spacing: CGFloat = 8,
        placement: MasonryPlacement = .shortestFirst
    )
}
```

### MasonryTracks

```swift
public enum MasonryTracks: Hashable, Sendable {
    case fixed(Int)
    case adaptive(min: CGFloat)
}
```

### MasonryPlacement

```swift
public enum MasonryPlacement: Hashable, Sendable {
    case shortestFirst
    case sequential
}
```
