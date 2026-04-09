import XCTest
@testable import SwiftUIMasonryLayouts

@available(iOS 26.0, *)
final class MasonryLayoutEngineTests: XCTestCase {
    func test_shortest_first_places_next_item_in_shortest_track() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 210, height: 600),
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 10
        )

        let result = MasonryLayoutEngine.layout(
            itemSizes: [
                CGSize(width: 100, height: 300),
                CGSize(width: 100, height: 100),
                CGSize(width: 100, height: 100)
            ],
            metrics: metrics,
            placement: .shortestFirst
        )

        XCTAssertEqual(result.frames[2].origin.x, 110)
        XCTAssertEqual(result.frames[2].origin.y, 110)
    }

    func test_sequential_places_items_by_index() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 210, height: 600),
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 10
        )

        let result = MasonryLayoutEngine.layout(
            itemSizes: [
                CGSize(width: 100, height: 300),
                CGSize(width: 100, height: 100),
                CGSize(width: 100, height: 100)
            ],
            metrics: metrics,
            placement: .sequential
        )

        XCTAssertEqual(result.frames[2].origin.x, 0)
        XCTAssertEqual(result.frames[2].origin.y, 310)
    }

    func test_vertical_content_size_matches_tallest_track() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 210, height: 600),
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 10
        )

        let result = MasonryLayoutEngine.layout(
            itemSizes: [
                CGSize(width: 100, height: 100),
                CGSize(width: 100, height: 200),
                CGSize(width: 100, height: 150)
            ],
            metrics: metrics,
            placement: .shortestFirst
        )

        XCTAssertEqual(result.contentSize.width, 210)
        XCTAssertEqual(result.contentSize.height, 260)
    }

    func test_horizontal_layout_uses_rows() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 600, height: 210),
            axis: .horizontal,
            tracks: .fixed(2),
            spacing: 10
        )

        let result = MasonryLayoutEngine.layout(
            itemSizes: [
                CGSize(width: 120, height: 100),
                CGSize(width: 80, height: 100)
            ],
            metrics: metrics,
            placement: .sequential
        )

        XCTAssertEqual(result.frames[0].origin.y, 0)
        XCTAssertEqual(result.frames[1].origin.y, 110)
        XCTAssertEqual(result.frames[0].height, 100)
        XCTAssertEqual(result.frames[1].height, 100)
    }
}
