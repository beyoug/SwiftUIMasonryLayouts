import XCTest
@testable import SwiftUIMasonryLayouts

@available(iOS 26.0, *)
final class MasonryStackBridgeTests: XCTestCase {
    func test_columns_initializer_maps_to_vertical_fixed_tracks() {
        let stack = MasonryStack(columns: 3) { }

        let mirror = Mirror(reflecting: stack)
        let axis = mirror.descendant("axis") as? Axis
        let tracks = mirror.descendant("tracks") as? MasonryTracks

        XCTAssertEqual(axis, .vertical)
        XCTAssertEqual(tracks, .fixed(3))
    }

    func test_rows_initializer_maps_to_horizontal_fixed_tracks() {
        let stack = MasonryStack(rows: 2) { }

        let mirror = Mirror(reflecting: stack)
        let axis = mirror.descendant("axis") as? Axis
        let tracks = mirror.descendant("tracks") as? MasonryTracks

        XCTAssertEqual(axis, .horizontal)
        XCTAssertEqual(tracks, .fixed(2))
    }

    func test_adaptive_columns_initializer_maps_to_vertical_adaptive_tracks() {
        let stack = MasonryStack(adaptiveColumns: 140) { }

        let mirror = Mirror(reflecting: stack)
        let axis = mirror.descendant("axis") as? Axis
        let tracks = mirror.descendant("tracks") as? MasonryTracks

        XCTAssertEqual(axis, .vertical)
        XCTAssertEqual(tracks, .adaptive(min: 140))
    }

    func test_adaptive_rows_initializer_maps_to_horizontal_adaptive_tracks() {
        let stack = MasonryStack(adaptiveRows: 96) { }

        let mirror = Mirror(reflecting: stack)
        let axis = mirror.descendant("axis") as? Axis
        let tracks = mirror.descendant("tracks") as? MasonryTracks

        XCTAssertEqual(axis, .horizontal)
        XCTAssertEqual(tracks, .adaptive(min: 96))
    }

    func test_placement_parameter_is_preserved_by_stack() {
        let stack = MasonryStack(columns: 2, spacing: 12, placement: .sequential) { }

        let mirror = Mirror(reflecting: stack)
        let placement = mirror.descendant("placement") as? MasonryPlacement

        XCTAssertEqual(placement, .sequential)
    }
}
