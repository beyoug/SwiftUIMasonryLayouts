// swift-tools-version: 6.2

/**
*  SwiftUIMasonryLayouts
*  Copyright (c) Beyoug 2025
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "SwiftUIMasonryLayouts",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "SwiftUIMasonryLayouts",
            targets: ["SwiftUIMasonryLayouts"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftUIMasonryLayouts",
            dependencies: [],
            swiftSettings: [
                // 只保留在 Swift 6 中仍然需要显式启用的功能
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "SwiftUIMasonryLayoutsExamples",
            dependencies: ["SwiftUIMasonryLayouts"],
            path: "Examples"
        ),
        .testTarget(
            name: "SwiftUIMasonryLayoutsTests",
            dependencies: [
                "SwiftUIMasonryLayouts",
                "SwiftUIMasonryLayoutsExamples"
            ]
        )
    ]
)
