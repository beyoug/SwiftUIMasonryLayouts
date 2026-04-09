// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftUIMasonryLayouts",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "SwiftUIMasonryLayouts",
            targets: ["SwiftUIMasonryLayouts"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftUIMasonryLayouts",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SwiftUIMasonryLayoutsTests",
            dependencies: ["SwiftUIMasonryLayouts"]
        )
    ]
)
