import SwiftUI
import SwiftUIMasonryLayouts

struct MasonryStackExample: View {
    let tiles = SampleTestData.tiles

    var body: some View {
        ScrollView {
            MasonryStack(columns: 2, spacing: 12) {
                ForEach(tiles) { tile in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(tile.color)
                        .frame(height: tile.height)
                        .overlay(
                            Text(tile.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                        )
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    MasonryStackExample()
}
