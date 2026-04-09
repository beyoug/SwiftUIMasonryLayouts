import SwiftUI
import XCTest
@testable import SwiftUIMasonryLayouts

@available(iOS 26.0, *)
final class MasonryStackCompilationTests: XCTestCase {
    @MainActor
    func test_base_public_api_compiles() {
        let _ = MasonryStack {
            Text("Default")
        }

        let _ = MasonryStack(
            axis: .horizontal,
            tracks: .fixed(3),
            spacing: 12,
            placement: .sequential
        ) {
            Text("Tracks")
        }

        let _ = MasonryLayout(
            axis: .vertical,
            tracks: .adaptive(min: 140),
            spacing: 10,
            placement: .shortestFirst
        )

        XCTAssertTrue(true)
    }
}
