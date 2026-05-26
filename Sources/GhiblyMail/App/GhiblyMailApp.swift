import SwiftUI

@main
struct GhiblyMailApp: App {
    @StateObject private var store = CommandCenterStore()

    var body: some Scene {
        WindowGroup {
            CommandCenterView()
                .environmentObject(store)
                .frame(minWidth: 1180, minHeight: 760)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
