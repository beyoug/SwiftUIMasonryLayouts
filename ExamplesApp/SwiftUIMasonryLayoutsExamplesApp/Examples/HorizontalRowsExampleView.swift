import SwiftUI
import SwiftUIMasonryLayouts

struct HorizontalRowsExampleView: View {
    let tiles = ExampleTileData.basicTiles

    var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Horizontal masonry using rows.")
                    .foregroundStyle(.secondary)

                MasonryStack(rows: 2, spacing: 12) {
                    ForEach(tiles) { tile in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tile.color)
                            .frame(width: tile.height)
                            .overlay(Text(tile.title).foregroundStyle(.white))
                    }
                }

                Text("rows: 2, spacing: 12, placement: shortestFirst")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .navigationTitle("Horizontal Rows")
    }
}

#Preview {
    NavigationStack { HorizontalRowsExampleView() }
}
