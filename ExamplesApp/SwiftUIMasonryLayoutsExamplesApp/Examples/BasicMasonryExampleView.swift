import SwiftUI
import SwiftUIMasonryLayouts

struct BasicMasonryExampleView: View {
    let tiles = ExampleTileData.basicTiles

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Basic fixed-column masonry using two columns and 12pt spacing.")
                    .foregroundStyle(.secondary)

                MasonryStack(columns: 2, spacing: 12) {
                    ForEach(tiles) { tile in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tile.color)
                            .frame(height: tile.height)
                            .overlay(Text(tile.title).foregroundStyle(.white))
                    }
                }

                Text("columns: 2, spacing: 12, placement: shortestFirst")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .navigationTitle("Basic Masonry")
    }
}

#Preview {
    NavigationStack { BasicMasonryExampleView() }
}
