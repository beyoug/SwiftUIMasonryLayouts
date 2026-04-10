import SwiftUI
import XCTest
@testable import SwiftUIMasonryLayouts

@available(iOS 26.0, *)
final class MasonryMeasurementTests: XCTestCase {
    func test_unknown_main_axis_is_explicitly_represented_without_magic_constant() {
        let proposal = ProposedViewSize(width: 320, height: nil)

        XCTAssertNil(proposal.height)
    }

    func test_layout_resolution_keeps_unknown_vertical_main_axis_nil() {
        let layout = MasonryLayout(axis: .vertical, tracks: .fixed(2), spacing: 8, placement: .shortestFirst)

        let context = layout.containerContext(
            for: ProposedViewSize(width: 320, height: nil),
            fallbackSize: CGSize(width: 120, height: 240)
        )

        XCTAssertEqual(context.crossAxisLength, 320)
        XCTAssertNil(context.proposedMainAxisLength)
    }

    func test_vertical_measurement_uses_track_width_and_measured_height() {
        let measurement = MasonryMeasurement(
            axis: .vertical,
            trackSize: 120,
            measuredSize: CGSize(width: 999, height: 80)
        )

        XCTAssertEqual(measurement.normalizedSize.width, 120)
        XCTAssertEqual(measurement.normalizedSize.height, 80)
    }

    func test_horizontal_measurement_uses_track_height_and_measured_width() {
        let measurement = MasonryMeasurement(
            axis: .horizontal,
            trackSize: 96,
            measuredSize: CGSize(width: 140, height: 999)
        )

        XCTAssertEqual(measurement.normalizedSize.width, 140)
        XCTAssertEqual(measurement.normalizedSize.height, 96)
    }

    func test_non_finite_measurements_are_clamped_to_safe_lengths() {
        let measurement = MasonryMeasurement(
            axis: .vertical,
            trackSize: 120,
            measuredSize: CGSize(width: CGFloat.infinity, height: CGFloat.nan)
        )

        XCTAssertEqual(measurement.normalizedSize.width, 120)
        XCTAssertEqual(measurement.normalizedSize.height, 0)
    }

    func test_measurements_compare_equal_when_normalized_size_matches() {
        let lhs = MasonryMeasurement(
            axis: .vertical,
            trackSize: 120,
            measuredSize: CGSize(width: 999, height: CGFloat.nan)
        )
        let rhs = MasonryMeasurement(
            axis: .vertical,
            trackSize: 120,
            measuredSize: CGSize(width: 0, height: -20)
        )

        XCTAssertEqual(lhs.normalizedSize, rhs.normalizedSize)
        XCTAssertEqual(lhs, rhs)
    }
}
