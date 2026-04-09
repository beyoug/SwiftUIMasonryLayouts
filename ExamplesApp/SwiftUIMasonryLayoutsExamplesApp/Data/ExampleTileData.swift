import SwiftUI

enum ExampleTileData {
    static let basicTiles: [ExampleTile] = [
        ExampleTile(id: 1, title: "One", color: .blue, height: 120),
        ExampleTile(id: 2, title: "Two", color: .purple, height: 180),
        ExampleTile(id: 3, title: "Three", color: .orange, height: 150),
        ExampleTile(id: 4, title: "Four", color: .pink, height: 220),
        ExampleTile(id: 5, title: "Five", color: .green, height: 140),
        ExampleTile(id: 6, title: "Six", color: .indigo, height: 200)
    ]

    static let comparisonTiles: [ExampleTile] = [
        ExampleTile(id: 31, title: "A", color: .blue, height: 300),
        ExampleTile(id: 32, title: "B", color: .orange, height: 100),
        ExampleTile(id: 33, title: "C", color: .green, height: 100),
        ExampleTile(id: 34, title: "D", color: .pink, height: 220),
        ExampleTile(id: 35, title: "E", color: .purple, height: 120),
        ExampleTile(id: 36, title: "F", color: .indigo, height: 180)
    ]

    static let edgeCaseTallTiles: [ExampleTile] = [
        ExampleTile(id: 11, title: "Tall", color: .blue, height: 320),
        ExampleTile(id: 12, title: "Tiny", color: .orange, height: 40),
        ExampleTile(id: 13, title: "Wide", color: .green, height: 180),
        ExampleTile(id: 14, title: "Huge", color: .pink, height: 420)
    ]

    static let singleTile: [ExampleTile] = [
        ExampleTile(id: 21, title: "Single", color: .teal, height: 180)
    ]

    static let emptyTiles: [ExampleTile] = []
}
