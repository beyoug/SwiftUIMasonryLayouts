import SwiftUI
import SwiftUIMasonryLayouts

struct EdgeCasesExampleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("These pages cover extreme heights, single-item, empty-data, and tight-spacing scenarios.")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Tall tiles")
                        .font(.headline)
                    MasonryStack(columns: 2, spacing: 4) {
                        ForEach(ExampleTileData.edgeCaseTallTiles) { tile in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(tile.color)
                                .frame(height: tile.height)
                                .overlay(Text(tile.title).foregroundStyle(.white))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Single tile")
                        .font(.headline)
                    MasonryStack(columns: 2, spacing: 12) {
                        ForEach(ExampleTileData.singleTile) { tile in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(tile.color)
                                .frame(height: tile.height)
                                .overlay(Text(tile.title).foregroundStyle(.white))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Empty data")
                        .font(.headline)
                    MasonryStack(columns: 2, spacing: 12) {
                        ForEach(ExampleTileData.emptyTiles) { tile in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(tile.color)
                                .frame(height: tile.height)
                        }
                    }
                    .frame(minHeight: 40)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.tertiary))
                }
            }
            .padding(16)
        }
        .navigationTitle("Edge Cases")
    }
}

#Preview {
    NavigationStack { EdgeCasesExampleView() }
}
