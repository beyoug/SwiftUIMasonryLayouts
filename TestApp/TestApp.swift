import SwiftUI

@main
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 18.0, *) {
                ContentView()
            } else {
                Text("需要 iOS 18.0 或更高版本")
            }
        }
    }
}
