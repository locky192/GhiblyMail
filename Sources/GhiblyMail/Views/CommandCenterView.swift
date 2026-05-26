import SwiftUI

struct CommandCenterView: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background

                VStack(spacing: 14) {
                    HUDView()
                        .padding(.horizontal, 18)
                        .padding(.top, 14)

                    HStack(spacing: 14) {
                        OfficeSceneView()
                            .frame(width: max(660, proxy.size.width * 0.58))
                            .frame(maxHeight: .infinity)

                        QuestBoardView()
                            .frame(width: min(430, max(360, proxy.size.width * 0.34)))
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                }
            }
        }
        .foregroundStyle(Theme.ink)
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.87, green: 0.91, blue: 0.86),
                Theme.cream,
                Color(red: 0.78, green: 0.88, blue: 0.86)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
