# Configuration Guide

## Core Concepts

- `axis`: `.vertical` creates columns, `.horizontal` creates rows
- `tracks`: use `.fixed(Int)` for a fixed number of tracks or `.adaptive(min: CGFloat)` for adaptive track resolution
- `spacing`: sets spacing between tracks and items
- `placement`: `.shortestFirst` balances heights or widths, `.sequential` places by index order

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
