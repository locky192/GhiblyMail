import GhiblyMailCore
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

@main
struct GhiblyMailApp: App {
    @StateObject private var store = CommandCenterStore()

    var body: some Scene {
        WindowGroup {
            GhiblyMailRootView()
                .environmentObject(store)
                .frame(minWidth: 1180, minHeight: 664.25)
                .ignoresSafeArea()
                .background(WindowAspectConfigurator())
        }
        .defaultSize(width: 1280, height: 720.57)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
    }
}

#if canImport(AppKit)
private struct WindowAspectConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            configure(window: view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(window: nsView.window)
        }
    }

    private func configure(window: NSWindow?) {
        guard let window else { return }

        let contentSize = NSSize(width: 1280, height: 1280 * 941 / 1672)
        let minimumSize = NSSize(width: 1180, height: 1180 * 941 / 1672)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.contentAspectRatio = contentSize
        window.minSize = minimumSize

        let current = window.contentLayoutRect.size
        let isMockupRatio = abs((current.width / max(current.height, 1)) - (contentSize.width / contentSize.height)) < 0.01
        if !isMockupRatio {
            window.setContentSize(contentSize)
            window.center()
        }
    }
}
#else
private struct WindowAspectConfigurator: View {
    var body: some View {
        EmptyView()
    }
}
#endif
