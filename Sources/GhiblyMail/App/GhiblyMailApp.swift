import GhiblyMailCore
import SwiftUI

@main
struct GhiblyMailApp: App {
    @StateObject private var store = CommandCenterStore()

    var body: some Scene {
        WindowGroup {
            GhiblyMailRootView()
                .environmentObject(store)
                .frame(minWidth: 1180, minHeight: 760)
                .ignoresSafeArea()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
