import SwiftUI

struct ExamplesHomeView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Basic Masonry") { BasicMasonryExampleView() }
                NavigationLink("Horizontal Rows") { HorizontalRowsExampleView() }
                NavigationLink("Adaptive Columns") { AdaptiveColumnsExampleView() }
                NavigationLink("Adaptive Rows") { AdaptiveRowsExampleView() }
                NavigationLink("Placement Comparison") { PlacementComparisonExampleView() }
                NavigationLink("Direct Layout") { DirectLayoutExampleView() }
                NavigationLink("Edge Cases") { EdgeCasesExampleView() }
            }
            .navigationTitle("Masonry Examples")
        }
    }
}

#Preview {
    ExamplesHomeView()
}
