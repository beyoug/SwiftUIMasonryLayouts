import SwiftUI
import SwiftUIMasonryLayouts

@available(iOS 18.0, *)
struct ContentView: View {
    var body: some View {
        NavigationStack {
            PaginationDemoExample()
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    ContentView()
}
