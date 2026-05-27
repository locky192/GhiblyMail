import GhiblyMailCore
import SwiftUI

@main
struct GhiblyMailApp: App {
    @StateObject private var store = CommandCenterStore()

    var body: some Scene {
        WindowGroup {
            GhiblyMailRootView()
                .environmentObject(store)
                .frame(minWidth: 1180, minHeight: 720)
                .ignoresSafeArea()
        }
        .defaultSize(width: 1500, height: 860)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
    }
}
