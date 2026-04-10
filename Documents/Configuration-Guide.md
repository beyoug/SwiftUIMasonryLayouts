# Configuration Guide

## Core Concepts

- `axis`: `.vertical` creates columns, `.horizontal` creates rows
- `tracks`: use `.fixed(Int)` for a fixed number of tracks or `.adaptive(min: CGFloat)` to resolve as many tracks as fit while honoring the minimum track size
- `spacing`: sets spacing between tracks and items
- `placement`: `.shortestFirst` places each item into the currently shortest column or row, `.sequential` preserves input order when assigning tracks

## Convenience Initializers

- `MasonryStack(columns:)` maps to `axis: .vertical` with `tracks: .fixed(...)`
- `MasonryStack(rows:)` maps to `axis: .horizontal` with `tracks: .fixed(...)`
- `MasonryStack(adaptiveColumns:)` maps to `axis: .vertical` with `tracks: .adaptive(min: ...)`
- `MasonryStack(adaptiveRows:)` maps to `axis: .horizontal` with `tracks: .adaptive(min: ...)`

## Common Setups

```swift
MasonryStack(columns: 2, spacing: 12) {
    // content
}

MasonryStack(adaptiveColumns: 140, spacing: 10) {
    // content
}

MasonryStack(rows: 2, spacing: 8, placement: .sequential) {
    // content
}
```
