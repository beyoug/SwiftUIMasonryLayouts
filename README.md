# SwiftUIMasonryLayouts

SwiftUI masonry layout primitives for iOS 26.

## Requirements

- iOS 26.0+
- Swift 6.0+

## Installation

Add the package URL in Xcode:

```text
https://github.com/beyoug/SwiftUIMasonryLayouts.git
```

## Quick Start

```swift
import SwiftUIMasonryLayouts

MasonryStack(columns: 2, spacing: 12) {
    ForEach(items) { item in
        ItemCard(item)
    }
}
```

### Direct `Layout` Usage

```swift
MasonryLayout(
    axis: .vertical,
    tracks: .adaptive(min: 160),
    spacing: 12,
    placement: .shortestFirst
) {
    // subviews
}
```

## Examples

Example source files live in the repository's root `Examples/` directory. They are for preview and demonstration only and are not part of the published library product.

## Documentation

- [API Reference](Documents/API-Reference.md)
- [Configuration Guide](Documents/Configuration-Guide.md)
