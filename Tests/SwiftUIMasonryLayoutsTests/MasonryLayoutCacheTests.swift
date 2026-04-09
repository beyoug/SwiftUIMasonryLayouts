import XCTest
@testable import SwiftUIMasonryLayouts

@available(iOS 26.0, *)
final class MasonryLayoutCacheTests: XCTestCase {
    func test_cache_hits_when_key_is_identical() {
        let key = MasonryCacheKey(
            containerSize: CGSize(width: 320, height: 640),
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 4
        )

        let result = MasonryLayoutResult(
            frames: [CGRect(x: 0, y: 0, width: 156, height: 100)],
            contentSize: CGSize(width: 320, height: 100)
        )

        var cache = MasonryCache()
        cache.store(result, for: key)

        XCTAssertEqual(cache.result(for: key), result)
    }

    func test_cache_invalidates_when_width_changes() {
        let cachedKey = MasonryCacheKey(
            containerSize: CGSize(width: 320, height: 640),
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 4
        )

        let queryKey = MasonryCacheKey(
            containerSize: CGSize(width: 375, height: 640),
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 4
        )

        var cache = MasonryCache()
        cache.store(.empty, for: cachedKey)

        XCTAssertNil(cache.result(for: queryKey))
    }

    func test_cache_invalidates_when_subview_count_changes() {
        let cachedKey = MasonryCacheKey(
            containerSize: CGSize(width: 320, height: 640),
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 4
        )

        let queryKey = MasonryCacheKey(
            containerSize: CGSize(width: 320, height: 640),
            axis: .vertical,
            tracks: .fixed(2),
            spacing: 8,
            placement: .shortestFirst,
            subviewCount: 5
        )

        var cache = MasonryCache()
        cache.store(.empty, for: cachedKey)

        XCTAssertNil(cache.result(for: queryKey))
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
        let measurementKey = MasonryCacheKey(
            containerSize: measurementMetrics.containerSize,
            axis: layout.axis,
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
        let placementKey = MasonryCacheKey(
            containerSize: placementMetrics.containerSize,
            axis: layout.axis,
            tracks: layout.tracks,
            spacing: placementMetrics.spacing,
            placement: layout.placement,
            subviewCount: 3,
            measurementSignature: measurementSignature
        )

        var cache = MasonryCache()
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
        let cachedKey = MasonryCacheKey(
            containerSize: metrics.containerSize,
            axis: layout.axis,
            tracks: layout.tracks,
            spacing: metrics.spacing,
            placement: layout.placement,
            subviewCount: 3,
            measurementSignature: cachedSignature
        )
        let updatedKey = MasonryCacheKey(
            containerSize: metrics.containerSize,
            axis: layout.axis,
            tracks: layout.tracks,
            spacing: metrics.spacing,
            placement: layout.placement,
            subviewCount: 3,
            measurementSignature: updatedSignature
        )

        XCTAssertNotEqual(cachedResult, updatedResult)

        var cache = MasonryCache()
        cache.store(cachedResult, for: cachedKey)

        XCTAssertNil(
            cache.result(for: updatedKey),
            "Cache should invalidate when intrinsic subview measurements change even if the subview count stays the same."
        )
    }
}
