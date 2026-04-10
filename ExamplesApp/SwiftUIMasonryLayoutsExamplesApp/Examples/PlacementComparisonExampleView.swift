import SwiftUI
import SwiftUIMasonryLayouts

struct PlacementComparisonExampleView: View {
    let tiles = ExampleTileData.comparisonTiles

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Compare `.shortestFirst` balancing with `.sequential` index-order placement using the same data.")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    Text("shortestFirst")
                        .font(.headline)

                    MasonryStack(columns: 2, spacing: 12, placement: .shortestFirst) {
                        ForEach(tiles) { tile in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(tile.color)
                                .frame(height: tile.height)
                                .overlay(Text(tile.title).foregroundStyle(.white))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("sequential")
                        .font(.headline)

                    MasonryStack(columns: 2, spacing: 12, placement: .sequential) {
                        ForEach(tiles) { tile in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(tile.color)
                                .frame(height: tile.height)
                                .overlay(Text(tile.title).foregroundStyle(.white))
                        }
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Placement Comparison")
    }
}

#Preview {
    NavigationStack { PlacementComparisonExampleView() }
}
