import XCTest
@testable import SwiftUIMasonryLayouts

@available(iOS 26.0, *)
final class MasonryTracksTests: XCTestCase {
    func test_fixed_tracks_normalize_to_at_least_one() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 320, height: 480),
            axis: .vertical,
            tracks: .fixed(0),
            spacing: -8
        )

        XCTAssertEqual(metrics.trackCount, 1)
        XCTAssertEqual(metrics.spacing, 0)
        XCTAssertEqual(metrics.trackSize, 320)
    }

    func test_adaptive_columns_resolve_from_minimum_width() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 250, height: 480),
            axis: .vertical,
            tracks: .adaptive(min: 120),
            spacing: 10
        )

        XCTAssertEqual(metrics.trackCount, 2)
        XCTAssertEqual(metrics.trackSize, 120)
    }

    func test_adaptive_rows_resolve_from_minimum_height() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 320, height: 270),
            axis: .horizontal,
            tracks: .adaptive(min: 80),
            spacing: 10
        )

        XCTAssertEqual(metrics.trackCount, 3)
        XCTAssertEqual(metrics.trackSize, 83.3333333333, accuracy: 0.001)
    }

    func test_fractional_adaptive_minimum_is_preserved() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 2, height: 480),
            axis: .vertical,
            tracks: .adaptive(min: 0.5),
            spacing: 0
        )

        XCTAssertEqual(metrics.trackCount, 4)
        XCTAssertEqual(metrics.trackSize, 0.5, accuracy: 0.0001)
    }

    func test_adaptive_track_count_saturates_for_extremely_large_container_lengths() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: CGFloat(Int.max) * 2, height: 480),
            axis: .vertical,
            tracks: .adaptive(min: 0.5),
            spacing: 0
        )

        XCTAssertEqual(metrics.trackCount, Int.max)
        XCTAssertTrue(metrics.trackSize.isFinite)
        XCTAssertGreaterThan(metrics.trackSize, 0)
    }

    func test_adaptive_track_count_stays_small_when_large_finite_sums_would_overflow() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 480),
            axis: .vertical,
            tracks: .adaptive(min: CGFloat.greatestFiniteMagnitude),
            spacing: CGFloat.greatestFiniteMagnitude
        )

        XCTAssertEqual(metrics.trackCount, 1)
        XCTAssertEqual(metrics.trackSize, CGFloat.greatestFiniteMagnitude)
    }

    func test_adaptive_track_count_saturates_for_tiny_positive_minimum_without_collapsing_to_one() {
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 320, height: 480),
            axis: .vertical,
            tracks: .adaptive(min: CGFloat.leastNonzeroMagnitude),
            spacing: 0
        )

        XCTAssertEqual(metrics.trackCount, Int.max)
        XCTAssertTrue(metrics.trackSize.isFinite)
        XCTAssertGreaterThan(metrics.trackSize, 0)
    }
}
