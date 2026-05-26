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

                OfficeSceneView()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    HUDView()
                        .padding(.horizontal, 18)
                        .padding(.top, 14)

                    HStack {
                        Spacer(minLength: 0)

                        QuestBoardView()
                            .frame(width: min(430, max(360, proxy.size.width * 0.34)))
                            .frame(maxHeight: max(520, proxy.size.height - 112))
                            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .foregroundStyle(Theme.ink)
    }
}
