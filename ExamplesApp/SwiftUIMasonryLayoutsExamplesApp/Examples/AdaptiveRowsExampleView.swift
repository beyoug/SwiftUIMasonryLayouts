import SwiftUI
import SwiftUIMasonryLayouts

struct AdaptiveRowsExampleView: View {
    let tiles = ExampleTileData.basicTiles

    var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Adaptive rows resize based on available height.")
                    .foregroundStyle(.secondary)

                MasonryStack(adaptiveRows: 96, spacing: 8) {
                    ForEach(tiles) { tile in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tile.color)
                            .frame(width: tile.height)
                            .overlay(Text(tile.title).foregroundStyle(.white))
                    }
                }

                Text("adaptiveRows: 96, spacing: 8, placement: shortestFirst")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .navigationTitle("Adaptive Rows")
    }
}

#Preview {
    NavigationStack { AdaptiveRowsExampleView() }
}
