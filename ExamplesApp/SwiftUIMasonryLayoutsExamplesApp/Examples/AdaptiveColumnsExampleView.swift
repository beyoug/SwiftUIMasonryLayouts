import SwiftUI
import SwiftUIMasonryLayouts

struct AdaptiveColumnsExampleView: View {
    let tiles = ExampleTileData.basicTiles

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Adaptive columns resolve from a minimum track width of 140 points as available width changes.")
                    .foregroundStyle(.secondary)

                MasonryStack(adaptiveColumns: 140, spacing: 10) {
                    ForEach(tiles) { tile in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tile.color)
                            .frame(height: tile.height)
                            .overlay(Text(tile.title).foregroundStyle(.white))
                    }
                }

                Text("MasonryStack(adaptiveColumns: 140, spacing: 10, placement: .shortestFirst)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .navigationTitle("Adaptive Columns")
    }
}

#Preview {
    NavigationStack { AdaptiveColumnsExampleView() }
}
