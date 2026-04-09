import SwiftUI
import SwiftUIMasonryLayouts

struct AdaptiveColumnsExampleView: View {
    let tiles = ExampleTileData.basicTiles

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Adaptive columns resize based on available width.")
                    .foregroundStyle(.secondary)

                MasonryStack(adaptiveColumns: 140, spacing: 10) {
                    ForEach(tiles) { tile in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tile.color)
                            .frame(height: tile.height)
                            .overlay(Text(tile.title).foregroundStyle(.white))
                    }
                }

                Text("adaptiveColumns: 140, spacing: 10, placement: shortestFirst")
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
