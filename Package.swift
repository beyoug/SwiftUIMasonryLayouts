// swift-tools-version: 6.0

/**
*  SwiftUIMasonryLayouts
*  Copyright (c) Beyoug 2025
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "SwiftUIMasonryLayouts",
    platforms: [
        .iOS(.v18)
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
            resources: [
                .process("Examples/SampleData200.json")
            ],
            swiftSettings: [
                // 只保留在 Swift 6 中仍然需要显式启用的功能
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "SwiftUIMasonryLayoutsTests",
            dependencies: ["SwiftUIMasonryLayouts"]
        )
    ]
)
