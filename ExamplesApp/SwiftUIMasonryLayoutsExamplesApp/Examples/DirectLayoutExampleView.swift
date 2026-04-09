import SwiftUI
import SwiftUIMasonryLayouts

struct DirectLayoutExampleView: View {
    let tiles = ExampleTileData.basicTiles

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("This example uses MasonryLayout directly instead of MasonryStack.")
                    .foregroundStyle(.secondary)

                MasonryLayout(
                    axis: .vertical,
                    tracks: .adaptive(min: 160),
                    spacing: 12,
                    placement: .shortestFirst
                ) {
                    ForEach(tiles) { tile in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tile.color)
                            .frame(height: tile.height)
                            .overlay(Text(tile.title).foregroundStyle(.white))
                    }
                }

                Text("MasonryLayout(axis: .vertical, tracks: .adaptive(min: 160), spacing: 12)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .navigationTitle("Direct Layout")
    }
}

#Preview {
    NavigationStack { DirectLayoutExampleView() }
}
