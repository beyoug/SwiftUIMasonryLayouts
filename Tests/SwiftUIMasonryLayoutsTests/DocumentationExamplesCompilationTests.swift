import SwiftUI
import XCTest
import SwiftUIMasonryLayouts

@available(iOS 26.0, *)
final class DocumentationExamplesCompilationTests: XCTestCase {
    @MainActor
    func test_public_readme_examples_compile() {
        let _ = MasonryStack(columns: 2, spacing: 12) {
            Text("Column")
        }

        let _ = MasonryStack(rows: 2, spacing: 12, placement: .sequential) {
            Text("Row")
        }

        let _ = MasonryStack(adaptiveColumns: 140, spacing: 10) {
            Text("Adaptive")
        }

        let _ = MasonryStack(adaptiveRows: 96, spacing: 8) {
            Text("Adaptive Row")
        }

        let _ = MasonryLayout(
            axis: .vertical,
            tracks: .adaptive(min: 160),
            spacing: 12,
            placement: .shortestFirst
        ) {
            Text("Subview")
        }

        XCTAssertTrue(true)
    }
}
