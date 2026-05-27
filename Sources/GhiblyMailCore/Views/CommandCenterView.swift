import SwiftUI

public struct GhiblyMailRootView: View {
    public init() {}

    public var body: some View {
        CommandCenterView()
    }
}

struct CommandCenterView: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Theme.deepTeal
                    .ignoresSafeArea()

                if store.screen == .home {
                    HomeMockupScreen()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .ignoresSafeArea()
                } else {
                    OfficeSceneView()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .ignoresSafeArea()

                    Color.black.opacity(0.34)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    MVPChromeView()
                        .padding(18)
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .foregroundStyle(Theme.ink)
    }
}
