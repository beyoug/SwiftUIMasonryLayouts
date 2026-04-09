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

Use the local Example App at `ExamplesApp/SwiftUIMasonryLayoutsExamplesApp.xcodeproj` to preview and run the demo UI.

- Open `ExamplesApp/SwiftUIMasonryLayoutsExamplesApp.xcodeproj`
- Select the `SwiftUIMasonryLayoutsExamplesApp` scheme
- Open `MasonryStackExample.swift`
- Use Canvas / `#Preview` or run the app in iOS Simulator

The Example App is for local preview and demonstration only and is not part of the published package product.

## Documentation

- [API Reference](Documents/API-Reference.md)
- [Configuration Guide](Documents/Configuration-Guide.md)
