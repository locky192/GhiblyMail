import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

struct HomeMockupScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    private let canvasSize = CGSize(width: 1672, height: 941)

    var body: some View {
        GeometryReader { proxy in
            let frame = aspectFitFrame(for: canvasSize, in: proxy.size)

            ZStack {
                Theme.deepTeal
                    .ignoresSafeArea()

                HomeMockupImage()
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.midY)

                hitTargets(in: frame)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("GhiblyMail main office home screen")
        }
    }

    private func aspectFitFrame(for source: CGSize, in container: CGSize) -> CGRect {
        guard source.width > 0, source.height > 0, container.width > 0, container.height > 0 else {
            return .zero
        }

        let scale = min(container.width / source.width, container.height / source.height)
        let width = source.width * scale
        let height = source.height * scale

        return CGRect(
            x: (container.width - width) / 2,
            y: (container.height - height) / 2,
            width: width,
            height: height
        )
    }

    private func hitTargets(in frame: CGRect) -> some View {
        ZStack {
            mockupButton("Profile Card", rect: CGRect(x: 8, y: 16, width: 318, height: 202), frame: frame) {
                store.navigateFromHome(.profileCard)
            }

            mockupButton("Critical Responses", rect: CGRect(x: 510, y: 18, width: 128, height: 101), frame: frame) {
                store.navigate(.questBoard(.critical))
            }
            mockupButton("Draft Approvals", rect: CGRect(x: 638, y: 18, width: 128, height: 101), frame: frame) {
                store.navigate(.draftReview)
            }
            mockupButton("Blocked Items", rect: CGRect(x: 766, y: 18, width: 128, height: 101), frame: frame) {
                store.navigate(.attachmentRequests)
            }
            mockupButton("Calendar Invites", rect: CGRect(x: 894, y: 18, width: 128, height: 101), frame: frame) {
                store.navigate(.calendarInvites)
            }
            mockupButton("Mailing Lists", rect: CGRect(x: 1022, y: 18, width: 128, height: 101), frame: frame) {
                store.navigate(.mailingListCleanup)
            }

            mockupButton("Focus Mode", rect: CGRect(x: 1243, y: 18, width: 84, height: 109), frame: frame) {
                store.navigate(.settingsConnections)
            }
            mockupButton("Lofi Beats", rect: CGRect(x: 1327, y: 18, width: 84, height: 109), frame: frame) {
                store.navigate(.settingsConnections)
            }
            mockupButton("Codex", rect: CGRect(x: 1411, y: 18, width: 84, height: 109), frame: frame) {
                store.navigate(.settingsConnections)
            }
            mockupButton("Gmail", rect: CGRect(x: 1495, y: 18, width: 84, height: 109), frame: frame) {
                store.navigate(.settingsConnections)
            }
            mockupButton("Settings", rect: CGRect(x: 1579, y: 18, width: 84, height: 109), frame: frame) {
                store.navigate(.settingsConnections)
            }

            mockupButton("Memory and Research", rect: CGRect(x: 411, y: 216, width: 177, height: 50), frame: frame) {
                store.navigate(.triageTuning)
            }
            mockupButton("Triage Desk", rect: CGRect(x: 754, y: 247, width: 161, height: 59), frame: frame) {
                store.navigate(.triageTuning)
            }
            mockupButton("Calendar Desk", rect: CGRect(x: 978, y: 282, width: 160, height: 50), frame: frame) {
                store.navigate(.calendarInvites)
            }
            mockupButton("Drafting Studio", rect: CGRect(x: 429, y: 461, width: 158, height: 59), frame: frame) {
                store.navigate(.draftReview)
            }
            mockupButton("Attachment Lab", rect: CGRect(x: 873, y: 527, width: 162, height: 58), frame: frame) {
                store.navigate(.attachmentRequests)
            }

            mockupButton("Studio Activity", rect: CGRect(x: 8, y: 589, width: 344, height: 262), frame: frame) {
                store.navigate(.triageTuning)
            }

            mockupButton("Quick Brief", rect: CGRect(x: 545, y: 823, width: 113, height: 104), frame: frame) {
                store.navigate(.dailyBriefPlan(.brief))
            }
            mockupButton("Prioritize", rect: CGRect(x: 658, y: 823, width: 113, height: 104), frame: frame) {
                store.navigate(.dailyBriefPlan(.priorities))
            }
            mockupButton("Daily Plan", rect: CGRect(x: 771, y: 823, width: 113, height: 104), frame: frame) {
                store.navigate(.dailyBriefPlan(.plan))
            }
            mockupButton("Performance", rect: CGRect(x: 884, y: 823, width: 113, height: 104), frame: frame) {
                store.navigate(.performanceAchievements(.week))
            }
            mockupButton("Achievements", rect: CGRect(x: 997, y: 823, width: 113, height: 104), frame: frame) {
                store.navigate(.performanceAchievements(.week))
            }

            mockupButton("Critical Responses Quest", rect: CGRect(x: 1322, y: 662, width: 338, height: 38), frame: frame) {
                store.navigate(.questBoard(.critical))
            }
            mockupButton("Draft Approvals Quest", rect: CGRect(x: 1322, y: 704, width: 338, height: 38), frame: frame) {
                store.navigate(.draftReview)
            }
            mockupButton("Calendar Invites Quest", rect: CGRect(x: 1322, y: 746, width: 338, height: 38), frame: frame) {
                store.navigate(.calendarInvites)
            }
            mockupButton("Attachments Needed Quest", rect: CGRect(x: 1322, y: 788, width: 338, height: 38), frame: frame) {
                store.navigate(.attachmentRequests)
            }
            mockupButton("Mailing List Unsubscribes Quest", rect: CGRect(x: 1322, y: 830, width: 338, height: 22), frame: frame) {
                store.navigate(.mailingListCleanup)
            }
            mockupButton("View All Quests", rect: CGRect(x: 1344, y: 854, width: 247, height: 43), frame: frame) {
                store.navigate(.questBoard(.all))
            }
        }
    }

    private func mockupButton(_ label: String, rect: CGRect, frame: CGRect, action: @escaping () -> Void) -> some View {
        let scaleX = frame.width / canvasSize.width
        let scaleY = frame.height / canvasSize.height
        let scaled = CGRect(
            x: frame.minX + rect.minX * scaleX,
            y: frame.minY + rect.minY * scaleY,
            width: rect.width * scaleX,
            height: rect.height * scaleY
        )

        return Button(action: action) {
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .frame(width: scaled.width, height: scaled.height)
        }
        .buttonStyle(.plain)
        .position(x: scaled.midX, y: scaled.midY)
        .accessibilityLabel(label)
    }
}

private struct HomeMockupImage: View {
    var body: some View {
        Group {
            if let image = Self.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                fallback
            }
        }
        .accessibilityHidden(true)
    }

    private var fallback: some View {
        ZStack {
            Rectangle()
                .fill(Theme.paper)
            Text("Home mockup missing")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.ink)
        }
    }

#if canImport(AppKit)
    private static let image: NSImage? = {
        let mainNestedURL = Bundle.main.url(
            forResource: "main-office-home-v1",
            withExtension: "png",
            subdirectory: "Mockups"
        )
        let mainRootURL = Bundle.main.url(
            forResource: "main-office-home-v1",
            withExtension: "png"
        )

        if let url = mainNestedURL ?? mainRootURL {
            return NSImage(contentsOf: url)
        }

        let nestedURL = Bundle.module.url(
            forResource: "main-office-home-v1",
            withExtension: "png",
            subdirectory: "Mockups"
        )
        let rootURL = Bundle.module.url(
            forResource: "main-office-home-v1",
            withExtension: "png"
        )

        guard let url = nestedURL ?? rootURL else {
            return nil
        }

        return NSImage(contentsOf: url)
    }()
#else
    private static let image: NSImage? = nil
#endif
}
