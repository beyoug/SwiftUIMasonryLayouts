import XCTest
@testable import SwiftUIMasonryLayouts

@available(iOS 26.0, *)
final class MasonryLayoutCacheTests: XCTestCase {
    func test_cache_hits_when_key_is_identical() {
        let key = MasonryLayoutCacheKey(
            axis: .vertical,
            crossAxisLength: 320,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 4
        )

        let result = MasonryLayoutResult(
            frames: [CGRect(x: 0, y: 0, width: 156, height: 100)],
            contentSize: CGSize(width: 320, height: 100)
        )

        var cache = MasonryLayoutCache()
        cache.store(result, for: key)

        XCTAssertEqual(cache.result(for: key), result)
    }

    func test_cache_invalidates_when_width_changes() {
        let cachedKey = MasonryLayoutCacheKey(
            axis: .vertical,
            crossAxisLength: 320,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 4
        )

        let queryKey = MasonryLayoutCacheKey(
            axis: .vertical,
            crossAxisLength: 375,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 4
        )

        var cache = MasonryLayoutCache()
        cache.store(.empty, for: cachedKey)

        XCTAssertNil(cache.result(for: queryKey))
    }

    func test_cache_invalidates_when_subview_count_changes() {
        let cachedKey = MasonryLayoutCacheKey(
            axis: .vertical,
            crossAxisLength: 320,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 4
        )

        let queryKey = MasonryLayoutCacheKey(
            axis: .vertical,
            crossAxisLength: 320,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 5
        )

        var cache = MasonryLayoutCache()
        cache.store(.empty, for: cachedKey)

        XCTAssertNil(cache.result(for: queryKey))
    }

    func test_layout_cache_key_does_not_depend_on_measurement_phase_magic_height() {
        let measurementKey = MasonryLayoutCacheKey(
            axis: .vertical,
            crossAxisLength: 320,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 3,
            measurementSignature: [CGSize(width: 156, height: 120)]
        )
        let placementKey = MasonryLayoutCacheKey(
            axis: .vertical,
            crossAxisLength: 320,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 3,
            measurementSignature: [CGSize(width: 156, height: 120)]
        )

        XCTAssertEqual(measurementKey, placementKey)
    }

    func test_measurement_cache_signature_can_be_compared_without_layout_metadata() {
        let lhs = [
            MasonryMeasurement(axis: .vertical, trackSize: 156, measuredSize: CGSize(width: 156, height: 120)).normalizedSize,
            MasonryMeasurement(axis: .vertical, trackSize: 156, measuredSize: CGSize(width: 156, height: 80)).normalizedSize
        ]
        let rhs = [
            MasonryMeasurement(axis: .vertical, trackSize: 156, measuredSize: CGSize(width: 156, height: 120)).normalizedSize,
            MasonryMeasurement(axis: .vertical, trackSize: 156, measuredSize: CGSize(width: 156, height: 80)).normalizedSize
        ]

        XCTAssertEqual(lhs, rhs)
    }

    func test_measurement_cache_is_reused_when_placement_uses_measured_content_height() {
        let layout = MasonryLayout(
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst
        )
        let measurementMetrics = MasonryMetrics(
            containerSize: CGSize(width: 320, height: 10_000),
            axis: layout.axis,
            tracks: layout.tracks,
            spacing: layout.spacing
        )
        let measuredResult = MasonryLayoutEngine.layout(
            itemSizes: [
                CGSize(width: measurementMetrics.trackSize, height: 120),
                CGSize(width: measurementMetrics.trackSize, height: 80),
                CGSize(width: measurementMetrics.trackSize, height: 60)
            ],
            metrics: measurementMetrics,
            placement: layout.placement
        )
        let measurementSignature = [
            CGSize(width: measurementMetrics.trackSize, height: 120),
            CGSize(width: measurementMetrics.trackSize, height: 80),
            CGSize(width: measurementMetrics.trackSize, height: 60)
        ]
        let measurementKey = MasonryLayoutCacheKey(
            axis: layout.axis,
            crossAxisLength: measurementMetrics.containerSize.width,
            tracks: layout.tracks,
            spacing: measurementMetrics.spacing,
            placement: layout.placement,
            subviewCount: 3,
            measurementSignature: measurementSignature
        )
        let placementMetrics = MasonryMetrics(
            containerSize: CGSize(width: 320, height: measuredResult.contentSize.height),
            axis: layout.axis,
            tracks: layout.tracks,
            spacing: layout.spacing
        )
        let placementKey = MasonryLayoutCacheKey(
            axis: layout.axis,
            crossAxisLength: placementMetrics.containerSize.width,
            tracks: layout.tracks,
            spacing: placementMetrics.spacing,
            placement: layout.placement,
            subviewCount: 3,
            measurementSignature: measurementSignature
        )

        var cache = MasonryLayoutCache()
        cache.store(measuredResult, for: measurementKey)

        XCTAssertEqual(
            cache.result(for: placementKey),
            measuredResult,
            "Placement should be able to reuse the measurement-phase cache entry when it uses the measured content height."
        )
    }

    func test_cache_invalidates_when_measured_item_sizes_change_without_subview_count_change() {
        let layout = MasonryLayout(
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst
        )
        let metrics = MasonryMetrics(
            containerSize: CGSize(width: 320, height: 600),
            axis: layout.axis,
            tracks: layout.tracks,
            spacing: layout.spacing
        )
        let cachedResult = MasonryLayoutEngine.layout(
            itemSizes: [
                CGSize(width: metrics.trackSize, height: 120),
                CGSize(width: metrics.trackSize, height: 80),
                CGSize(width: metrics.trackSize, height: 60)
            ],
            metrics: metrics,
            placement: layout.placement
        )
        let cachedSignature = [
            CGSize(width: metrics.trackSize, height: 120),
            CGSize(width: metrics.trackSize, height: 80),
            CGSize(width: metrics.trackSize, height: 60)
        ]
        let updatedResult = MasonryLayoutEngine.layout(
            itemSizes: [
                CGSize(width: metrics.trackSize, height: 40),
                CGSize(width: metrics.trackSize, height: 200),
                CGSize(width: metrics.trackSize, height: 60)
            ],
            metrics: metrics,
            placement: layout.placement
        )
        let updatedSignature = [
            CGSize(width: metrics.trackSize, height: 40),
            CGSize(width: metrics.trackSize, height: 200),
            CGSize(width: metrics.trackSize, height: 60)
        ]
        let cachedKey = MasonryLayoutCacheKey(
            axis: layout.axis,
            crossAxisLength: metrics.containerSize.width,
            tracks: layout.tracks,
            spacing: metrics.spacing,
            placement: layout.placement,
            subviewCount: 3,
            measurementSignature: cachedSignature
        )
        let updatedKey = MasonryLayoutCacheKey(
            axis: layout.axis,
            crossAxisLength: metrics.containerSize.width,
            tracks: layout.tracks,
            spacing: metrics.spacing,
            placement: layout.placement,
            subviewCount: 3,
            measurementSignature: updatedSignature
        )

        XCTAssertNotEqual(cachedResult, updatedResult)

        var cache = MasonryLayoutCache()
        cache.store(cachedResult, for: cachedKey)

        XCTAssertNil(
            cache.result(for: updatedKey),
            "Cache should invalidate when intrinsic subview measurements change even if the subview count stays the same."
        )
    }
}
