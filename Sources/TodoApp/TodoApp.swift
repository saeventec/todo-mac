import SwiftUI

@main
struct TodoApp: App {
    @State private var store = TodoStore.loaded(from: .appDefault)

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
