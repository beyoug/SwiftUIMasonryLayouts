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

`MasonryStack` is the preferred view-based API. The explicit initializer forwards `axis`, `tracks`, `spacing`, and `placement` directly to `MasonryLayout`.

Convenience initializers:

```swift
public init(columns: Int, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
public init(rows: Int, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
public init(adaptiveColumns minimum: CGFloat, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
public init(adaptiveRows minimum: CGFloat, spacing: CGFloat = 8, placement: MasonryPlacement = .shortestFirst, @ViewBuilder content: @escaping () -> Content)
```

- `columns` maps to `axis: .vertical` with `tracks: .fixed(columns)`
- `rows` maps to `axis: .horizontal` with `tracks: .fixed(rows)`
- `adaptiveColumns` maps to `axis: .vertical` with `tracks: .adaptive(min: minimum)`
- `adaptiveRows` maps to `axis: .horizontal` with `tracks: .adaptive(min: minimum)`

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

Use `MasonryLayout` when another container needs the raw `Layout` type instead of the `MasonryStack` view wrapper.

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

- `.shortestFirst` assigns each item to the currently shortest column or row
- `.sequential` assigns items by input order
