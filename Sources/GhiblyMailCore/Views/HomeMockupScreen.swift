import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

private enum HomeAnimation {
    static let frameInterval: TimeInterval = 1.0 / 3.0
}

struct HomeMockupScreen: View {
    @EnvironmentObject private var store: CommandCenterStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hoveredTarget: HomeTarget?
    @State private var cursor = CGPoint(x: 0.5, y: 0.5)

    private let canvasSize = CGSize(width: 1672, height: 941)

    var body: some View {
        GeometryReader { proxy in
            let frame = aspectFitFrame(for: canvasSize, in: proxy.size)

            ZStack {
                Theme.deepTeal
                    .ignoresSafeArea()

                scene(in: frame.size)
                    .frame(width: frame.width, height: frame.height)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.28), radius: 28, x: 0, y: 18)
                    .position(x: frame.midX, y: frame.midY)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("GhiblyMail interactive main office home screen")
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

    private func scene(in size: CGSize) -> some View {
        let parallax = reduceMotion ? CGSize.zero : CGSize(
            width: (cursor.x - 0.5) * -10,
            height: (cursor.y - 0.5) * -7
        )

        return TimelineView(.periodic(from: .now, by: HomeAnimation.frameInterval)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                HomeOfficeBackgroundImage()
                    .scaleEffect(1.012)
                    .offset(parallax)
                    .frame(width: size.width, height: size.height)

                RoomLightingLayer(
                    focusModeEnabled: store.settings.focusModeEnabled,
                    cursor: cursor,
                    reduceMotion: reduceMotion,
                    time: time
                )
                .allowsHitTesting(false)

                stationAuraLayer(in: size, time: time)
                    .allowsHitTesting(false)

                stationAgentLayer(in: size, time: time)

                WorkbenchMotionLayer(reduceMotion: reduceMotion, time: time)
                    .allowsHitTesting(false)

                profileCard(in: size, time: time)
                counterStrip(in: size, time: time)
                serviceStrip(in: size, time: time)
                stationLabelLayer(in: size)
                activityPanel(in: size)
                bottomNav(in: size)
                statusStrip(in: size)
                todayQuestsPanel(in: size, time: time)
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .onContinuousHover { phase in
            guard !reduceMotion else { return }
            switch phase {
            case .active(let point):
                cursor = CGPoint(
                    x: min(max(point.x / max(size.width, 1), 0), 1),
                    y: min(max(point.y / max(size.height, 1), 0), 1)
                )
            case .ended:
                cursor = CGPoint(x: 0.5, y: 0.5)
            }
        }
    }

    private func stationAuraLayer(in size: CGSize, time: TimeInterval) -> some View {
        ZStack {
            ForEach(stationSpecs) { spec in
                StationAura(
                    tint: spec.tint,
                    isActive: hoveredTarget == spec.target || spec.agent.state == .working,
                    phase: spec.phase,
                    reduceMotion: reduceMotion,
                    time: time
                )
                .frame(width: size.width * spec.ringSize.width, height: size.height * spec.ringSize.height)
                .position(scaled(spec.ringPoint, in: size))
            }
        }
    }

    private func stationAgentLayer(in size: CGSize, time: TimeInterval) -> some View {
        ZStack {
            ForEach(stationSpecs) { spec in
                PremiumAgentSprite(
                    agent: spec.agent,
                    tint: spec.tint,
                    isHighlighted: hoveredTarget == spec.target,
                    reduceMotion: reduceMotion,
                    time: time
                )
                .frame(width: size.width * spec.agentSize.width, height: size.height * spec.agentSize.height)
                .position(scaled(spec.agentPoint, in: size))
                .accessibilityHidden(true)

                SpeechBubbleIcon(
                    icon: spec.bubbleIcon,
                    tint: spec.tint,
                    isHighlighted: hoveredTarget == spec.target,
                    reduceMotion: reduceMotion,
                    time: time
                )
                .frame(width: size.width * 0.045, height: size.height * 0.060)
                .position(scaled(spec.bubblePoint, in: size))
                .accessibilityHidden(true)
            }
        }
    }

    private func stationLabelLayer(in size: CGSize) -> some View {
        ZStack {
            ForEach(stationSpecs) { spec in
                AliveButton(target: spec.target, hoveredTarget: $hoveredTarget) {
                    store.navigateFromHome(spec.action)
                } content: { hovering in
                    StationLabelCard(spec: spec, isHovering: hovering)
                }
                .frame(width: size.width * spec.labelSize.width, height: size.height * spec.labelSize.height)
                .position(scaled(spec.labelPoint, in: size))
            }
        }
    }

    private func profileCard(in size: CGSize, time: TimeInterval) -> some View {
        AliveButton(target: .profile, hoveredTarget: $hoveredTarget) {
            store.navigateFromHome(.profileCard)
        } content: { hovering in
            ProfileStatusCard(
                questsOpen: store.readyCount,
                blockedCount: store.blockedCount,
                completedCount: store.completedCount,
                isHovering: hovering,
                reduceMotion: reduceMotion,
                time: time
            )
        }
        .frame(width: size.width * 0.195, height: size.height * 0.218)
        .position(x: size.width * 0.101, y: size.height * 0.123)
    }

    private func counterStrip(in size: CGSize, time: TimeInterval) -> some View {
        HStack(spacing: 0) {
            QuestCounterButton(
                target: .criticalCounter,
                hoveredTarget: $hoveredTarget,
                title: "Critical",
                value: store.readyCount,
                icon: "star.fill",
                tint: Theme.coral,
                pulse: store.readyCount > 0,
                time: time,
                action: { store.navigate(.questBoard(.critical)) }
            )
            QuestCounterButton(
                target: .draftsCounter,
                hoveredTarget: $hoveredTarget,
                title: "Drafts",
                value: store.draftCount,
                icon: "pencil",
                tint: Theme.blue,
                pulse: store.draftCount > 0,
                time: time,
                action: { store.navigate(.draftReview) }
            )
            QuestCounterButton(
                target: .blockedCounter,
                hoveredTarget: $hoveredTarget,
                title: "Blocked",
                value: store.blockedCount,
                icon: "exclamationmark.octagon.fill",
                tint: Theme.amber,
                pulse: store.blockedCount > 0,
                time: time,
                action: { store.navigate(.attachmentRequests) }
            )
            QuestCounterButton(
                target: .invitesCounter,
                hoveredTarget: $hoveredTarget,
                title: "Invites",
                value: store.inviteCount,
                icon: "calendar",
                tint: Theme.teal,
                pulse: store.inviteCount > 0,
                time: time,
                action: { store.navigate(.calendarInvites) }
            )
            QuestCounterButton(
                target: .listsCounter,
                hoveredTarget: $hoveredTarget,
                title: "Lists",
                value: store.mailingListCount,
                icon: "envelope.fill",
                tint: Theme.leaf,
                pulse: store.mailingListCount > 0,
                time: time,
                action: { store.navigate(.mailingListCleanup) }
            )
        }
        .premiumPanel(cornerRadius: 12)
        .frame(width: size.width * 0.384, height: size.height * 0.112)
        .position(x: size.width * 0.496, y: size.height * 0.073)
    }

    private func serviceStrip(in size: CGSize, time: TimeInterval) -> some View {
        HStack(spacing: 0) {
            ServiceTile(
                target: .focusMode,
                hoveredTarget: $hoveredTarget,
                title: "Focus Mode",
                icon: "leaf.fill",
                tint: Theme.leaf,
                isOn: store.settings.focusModeEnabled,
                showsEqualizer: false,
                time: time,
                action: toggleFocusMode
            )
            ServiceTile(
                target: .lofiBeats,
                hoveredTarget: $hoveredTarget,
                title: "Lofi Beats",
                icon: "music.note",
                tint: Theme.wood,
                isOn: store.settings.lofiBeatsEnabled,
                showsEqualizer: true,
                time: time,
                action: toggleLofiBeats
            )
            ServiceTile(
                target: .codexStatus,
                hoveredTarget: $hoveredTarget,
                title: "Codex",
                icon: "server.rack",
                tint: Theme.deepTeal,
                isOn: true,
                showsEqualizer: false,
                time: time,
                action: { store.navigate(.settingsConnections) }
            )
            ServiceTile(
                target: .gmailStatus,
                hoveredTarget: $hoveredTarget,
                title: "Gmail",
                icon: "envelope.fill",
                tint: Theme.coral,
                isOn: true,
                showsEqualizer: false,
                time: time,
                action: { store.navigate(.settingsConnections) }
            )
            ServiceTile(
                target: .settings,
                hoveredTarget: $hoveredTarget,
                title: "Settings",
                icon: "gearshape.fill",
                tint: Theme.mutedInk,
                isOn: true,
                showsEqualizer: false,
                time: time,
                action: { store.navigate(.settingsConnections) }
            )
        }
        .premiumPanel(cornerRadius: 12)
        .frame(width: size.width * 0.270, height: size.height * 0.122)
        .position(x: size.width * 0.860, y: size.height * 0.078)
    }

    private func activityPanel(in size: CGSize) -> some View {
        AliveButton(target: .studioActivity, hoveredTarget: $hoveredTarget) {
            store.navigate(.triageTuning)
        } content: { hovering in
            StudioActivityPanel(events: Array(store.auditEvents.prefix(5)), isHovering: hovering)
        }
        .frame(width: size.width * 0.206, height: size.height * 0.284)
        .position(x: size.width * 0.108, y: size.height * 0.761)
    }

    private func bottomNav(in size: CGSize) -> some View {
        HStack(spacing: 0) {
            BottomNavButton(
                target: .quickBrief,
                hoveredTarget: $hoveredTarget,
                title: "Quick Brief",
                icon: "mug.fill",
                tint: Theme.wood,
                action: { store.navigate(.dailyBriefPlan(.brief)) }
            )
            BottomNavButton(
                target: .prioritize,
                hoveredTarget: $hoveredTarget,
                title: "Prioritize",
                icon: "medal.star.fill",
                tint: Theme.amber,
                action: { store.navigate(.dailyBriefPlan(.priorities)) }
            )
            BottomNavButton(
                target: .dailyPlan,
                hoveredTarget: $hoveredTarget,
                title: "Daily Plan",
                icon: "checklist",
                tint: Theme.mutedInk,
                action: { store.navigate(.dailyBriefPlan(.plan)) }
            )
            BottomNavButton(
                target: .performance,
                hoveredTarget: $hoveredTarget,
                title: "Performance",
                icon: "chart.bar.fill",
                tint: Theme.teal,
                action: { store.navigate(.performanceAchievements(.week)) }
            )
            BottomNavButton(
                target: .achievements,
                hoveredTarget: $hoveredTarget,
                title: "Achievements",
                icon: "trophy.fill",
                tint: Theme.amber,
                action: { store.navigate(.performanceAchievements(.week)) }
            )
        }
        .premiumPanel(cornerRadius: 13)
        .frame(width: size.width * 0.338, height: size.height * 0.110)
        .position(x: size.width * 0.497, y: size.height * 0.932)
    }

    private func statusStrip(in size: CGSize) -> some View {
        AliveButton(target: .agentStatus, hoveredTarget: $hoveredTarget) {
            store.navigate(.settingsConnections)
        } content: { hovering in
            HomeStatusStrip(
                agentsOnline: store.agents.filter { $0.state != .idle }.count,
                safeRate: store.performanceMetrics.safeAutomationRate,
                mood: studioMood,
                isHovering: hovering
            )
        }
        .frame(width: size.width * 0.300, height: size.height * 0.060)
        .position(x: size.width * 0.151, y: size.height * 0.953)
    }

    private func todayQuestsPanel(in size: CGSize, time: TimeInterval) -> some View {
        TodayQuestsPanel(
            hoveredTarget: $hoveredTarget,
            rows: questRows,
            completedCount: store.completedCount,
            totalCount: max(store.completedCount + store.readyCount, 1),
            time: time,
            viewAllAction: { store.navigate(.questBoard(.all)) }
        )
        .frame(width: size.width * 0.206, height: size.height * 0.292)
        .position(x: size.width * 0.892, y: size.height * 0.794)
    }

    private var stationSpecs: [HomeStationSpec] {
        [
            HomeStationSpec(
                target: .memoryStation,
                action: .memoryStation,
                title: "Memory & Research",
                subtitle: "Learning...",
                icon: "brain.head.profile",
                bubbleIcon: "book.pages.fill",
                tint: Theme.leaf,
                agent: agent(for: .memory),
                labelPoint: CGPoint(x: 0.300, y: 0.260),
                labelSize: CGSize(width: 0.185, height: 0.060),
                agentPoint: CGPoint(x: 0.366, y: 0.425),
                agentSize: CGSize(width: 0.066, height: 0.135),
                bubblePoint: CGPoint(x: 0.349, y: 0.384),
                ringPoint: CGPoint(x: 0.366, y: 0.479),
                ringSize: CGSize(width: 0.182, height: 0.106),
                phase: 0.2
            ),
            HomeStationSpec(
                target: .triageStation,
                action: .triageStation,
                title: "Triage Desk",
                subtitle: "Scanning inbox",
                icon: "tray.full.fill",
                bubbleIcon: "envelope.fill",
                tint: Theme.teal,
                agent: agent(for: .triage),
                labelPoint: CGPoint(x: 0.513, y: 0.308),
                labelSize: CGSize(width: 0.164, height: 0.066),
                agentPoint: CGPoint(x: 0.568, y: 0.492),
                agentSize: CGSize(width: 0.068, height: 0.135),
                bubblePoint: CGPoint(x: 0.632, y: 0.440),
                ringPoint: CGPoint(x: 0.550, y: 0.536),
                ringSize: CGSize(width: 0.178, height: 0.116),
                phase: 1.0
            ),
            HomeStationSpec(
                target: .calendarStation,
                action: .calendarStation,
                title: "Calendar Desk",
                subtitle: "\(store.inviteCount) invites",
                icon: "calendar",
                bubbleIcon: "calendar.badge.clock",
                tint: Theme.amber,
                agent: agent(for: .calendar),
                labelPoint: CGPoint(x: 0.646, y: 0.344),
                labelSize: CGSize(width: 0.165, height: 0.066),
                agentPoint: CGPoint(x: 0.746, y: 0.506),
                agentSize: CGSize(width: 0.066, height: 0.130),
                bubblePoint: CGPoint(x: 0.792, y: 0.486),
                ringPoint: CGPoint(x: 0.735, y: 0.579),
                ringSize: CGSize(width: 0.182, height: 0.124),
                phase: 1.8
            ),
            HomeStationSpec(
                target: .draftingStation,
                action: .draftingStation,
                title: "Drafting Studio",
                subtitle: "\(store.draftCount) drafts",
                icon: "pencil",
                bubbleIcon: "pencil",
                tint: Theme.blue,
                agent: agent(for: .drafting),
                labelPoint: CGPoint(x: 0.306, y: 0.516),
                labelSize: CGSize(width: 0.165, height: 0.066),
                agentPoint: CGPoint(x: 0.374, y: 0.706),
                agentSize: CGSize(width: 0.070, height: 0.145),
                bubblePoint: CGPoint(x: 0.427, y: 0.708),
                ringPoint: CGPoint(x: 0.372, y: 0.782),
                ringSize: CGSize(width: 0.196, height: 0.126),
                phase: 2.7
            ),
            HomeStationSpec(
                target: .attachmentStation,
                action: .attachmentStation,
                title: "Attachment Lab",
                subtitle: "\(store.blockedCount) needs files",
                icon: "paperclip",
                bubbleIcon: "paperclip",
                tint: Theme.coral,
                agent: agent(for: .attachments),
                labelPoint: CGPoint(x: 0.571, y: 0.601),
                labelSize: CGSize(width: 0.168, height: 0.066),
                agentPoint: CGPoint(x: 0.667, y: 0.823),
                agentSize: CGSize(width: 0.070, height: 0.145),
                bubblePoint: CGPoint(x: 0.729, y: 0.808),
                ringPoint: CGPoint(x: 0.688, y: 0.864),
                ringSize: CGSize(width: 0.184, height: 0.120),
                phase: 3.4
            )
        ]
    }

    private var questRows: [TodayQuestRowModel] {
        [
            TodayQuestRowModel(target: .questCritical, title: "Critical Responses", count: store.readyCount, icon: "star.fill", tint: Theme.coral, action: { store.navigate(.questBoard(.critical)) }),
            TodayQuestRowModel(target: .questDrafts, title: "Draft Approvals", count: store.draftCount, icon: "pencil", tint: Theme.blue, action: { store.navigate(.draftReview) }),
            TodayQuestRowModel(target: .questCalendar, title: "Calendar Invites", count: store.inviteCount, icon: "calendar", tint: Theme.amber, action: { store.navigate(.calendarInvites) }),
            TodayQuestRowModel(target: .questAttachments, title: "Attachments Needed", count: store.blockedCount, icon: "paperclip", tint: Theme.coral, action: { store.navigate(.attachmentRequests) }),
            TodayQuestRowModel(target: .questLists, title: "Mailing List Unsubscribes", count: store.mailingListCount, icon: "envelope.fill", tint: Theme.leaf, action: { store.navigate(.mailingListCleanup) })
        ]
    }

    private var studioMood: String {
        if store.blockedCount >= 3 {
            return "Needs Files"
        }
        if store.readyCount >= 6 {
            return "Focused"
        }
        return "Great"
    }

    private func agent(for role: AgentRole) -> Agent {
        store.agents.first { $0.role == role } ?? Agent(
            name: role.rawValue,
            role: role,
            state: .idle,
            currentTask: "Standing by",
            progress: 0
        )
    }

    private func scaled(_ point: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * point.x, y: size.height * point.y)
    }

    private func toggleFocusMode() {
        var settings = store.settings
        settings.focusModeEnabled.toggle()
        store.updateSettings(settings)
    }

    private func toggleLofiBeats() {
        var settings = store.settings
        settings.lofiBeatsEnabled.toggle()
        store.updateSettings(settings)
    }
}

private enum HomeTarget: String, Hashable {
    case profile
    case criticalCounter
    case draftsCounter
    case blockedCounter
    case invitesCounter
    case listsCounter
    case focusMode
    case lofiBeats
    case codexStatus
    case gmailStatus
    case settings
    case memoryStation
    case triageStation
    case calendarStation
    case draftingStation
    case attachmentStation
    case studioActivity
    case agentStatus
    case quickBrief
    case prioritize
    case dailyPlan
    case performance
    case achievements
    case questCritical
    case questDrafts
    case questCalendar
    case questAttachments
    case questLists
    case viewAllQuests
}

private struct HomeStationSpec: Identifiable {
    var id: HomeTarget { target }
    var target: HomeTarget
    var action: HomeAction
    var title: String
    var subtitle: String
    var icon: String
    var bubbleIcon: String
    var tint: Color
    var agent: Agent
    var labelPoint: CGPoint
    var labelSize: CGSize
    var agentPoint: CGPoint
    var agentSize: CGSize
    var bubblePoint: CGPoint
    var ringPoint: CGPoint
    var ringSize: CGSize
    var phase: Double
}

private struct TodayQuestRowModel: Identifiable {
    var id: HomeTarget { target }
    var target: HomeTarget
    var title: String
    var count: Int
    var icon: String
    var tint: Color
    var action: () -> Void
}

private struct AliveButton<Content: View>: View {
    let target: HomeTarget
    @Binding var hoveredTarget: HomeTarget?
    let action: () -> Void
    @ViewBuilder let content: (Bool) -> Content

    var body: some View {
        let hovering = hoveredTarget == target

        Button(action: action) {
            content(hovering)
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            if isHovering {
                hoveredTarget = target
            } else if hoveredTarget == target {
                hoveredTarget = nil
            }
        }
        .animation(.spring(response: 0.24, dampingFraction: 0.78), value: hovering)
    }
}

private struct HomeOfficeBackgroundImage: View {
    var body: some View {
        Group {
            if let image = Self.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Rectangle()
                        .fill(Theme.teal)
                    Text("Office background missing")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .accessibilityHidden(true)
    }

#if canImport(AppKit)
    private static let image: NSImage? = {
        let mainNestedURL = Bundle.main.url(
            forResource: "office-background-empty-v1",
            withExtension: "png",
            subdirectory: "Office"
        )
        let mainRootURL = Bundle.main.url(
            forResource: "office-background-empty-v1",
            withExtension: "png"
        )

        if let url = mainNestedURL ?? mainRootURL {
            return NSImage(contentsOf: url)
        }

        let nestedURL = Bundle.module.url(
            forResource: "office-background-empty-v1",
            withExtension: "png",
            subdirectory: "Office"
        )
        let rootURL = Bundle.module.url(
            forResource: "office-background-empty-v1",
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

private struct RoomLightingLayer: View {
    let focusModeEnabled: Bool
    let cursor: CGPoint
    let reduceMotion: Bool
    let time: TimeInterval

    var body: some View {
        let pulse = (sin(time * 0.75) + 1) / 2

        ZStack {
            LinearGradient(
                colors: [
                    Color.white.opacity(0.22 + pulse * 0.03),
                    Color.white.opacity(0.03),
                    Color.clear
                ],
                startPoint: UnitPoint(x: 0.05 + cursor.x * 0.04, y: 0.02),
                endPoint: UnitPoint(x: 0.70, y: 0.72)
            )
            .blendMode(.screen)

            GeometryReader { proxy in
                Path { path in
                    let size = proxy.size
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: size.width * 0.34, y: 0))
                    path.addLine(to: CGPoint(x: size.width * 0.70, y: size.height))
                    path.addLine(to: CGPoint(x: size.width * 0.32, y: size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.16 + pulse * 0.05), Color.white.opacity(0.01)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.screen)
            }

            RadialGradient(
                colors: [Theme.amber.opacity(focusModeEnabled ? 0.17 : 0.08), .clear],
                center: UnitPoint(x: 0.72, y: 0.38),
                startRadius: 18,
                endRadius: 300
            )
            .blendMode(.screen)

            RadialGradient(
                colors: [Theme.teal.opacity(0.13), .clear],
                center: UnitPoint(x: 0.48, y: 0.50),
                startRadius: 10,
                endRadius: 340
            )
            .blendMode(.screen)

            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [.clear, Color.black.opacity(focusModeEnabled ? 0.10 : 0.05)],
                        center: .center,
                        startRadius: 260,
                        endRadius: 890
                    )
                )

            DustMoteLayer(time: time, reduceMotion: reduceMotion)
        }
    }
}

private struct DustMoteLayer: View {
    let time: TimeInterval
    let reduceMotion: Bool

    var body: some View {
        Canvas { context, size in
            guard !reduceMotion else { return }

            for index in 0..<16 {
                let seed = Double(index + 3)
                let x = size.width * CGFloat((sin(seed * 12.9898) * 43758.5453).fractionalPart)
                let baseY = (sin(seed * 78.233) * 12733.313).fractionalPart
                let drift = (time * (0.010 + seed.truncatingRemainder(dividingBy: 5) * 0.002))
                let y = size.height * CGFloat((baseY + drift).truncatingRemainder(dividingBy: 1))
                let radius = CGFloat(0.9 + seed.truncatingRemainder(dividingBy: 4) * 0.38)
                let alpha = 0.10 + 0.08 * (sin(time * 1.2 + seed) + 1) / 2

                let rect = CGRect(x: x, y: y, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(alpha)))
            }
        }
        .blendMode(.screen)
    }
}

private struct StationAura: View {
    let tint: Color
    let isActive: Bool
    let phase: Double
    let reduceMotion: Bool
    let time: TimeInterval

    var body: some View {
        let pulse = (sin(time * 1.8 + phase) + 1) / 2

        ZStack {
            Ellipse()
                .stroke(tint.opacity((isActive ? 0.48 : 0.25) + pulse * 0.18), lineWidth: isActive ? 4 : 3)
                .blur(radius: 0.8)
                .scaleEffect(0.88 + pulse * (isActive ? 0.08 : 0.04))

            Ellipse()
                .fill(tint.opacity((isActive ? 0.18 : 0.09) + pulse * 0.05))
                .blur(radius: 5)
                .scaleEffect(0.82)
        }
        .blendMode(.screen)
    }
}

private struct WorkbenchMotionLayer: View {
    let reduceMotion: Bool
    let time: TimeInterval

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                screenGlow(time: time, x: 0.405, y: 0.405, delay: 0.0, in: size)
                screenGlow(time: time, x: 0.542, y: 0.474, delay: 0.7, in: size)
                screenGlow(time: time, x: 0.720, y: 0.542, delay: 1.1, in: size)
                screenGlow(time: time, x: 0.675, y: 0.812, delay: 1.8, in: size)
                FloatingPapers(time: time, reduceMotion: reduceMotion)
                    .frame(width: size.width * 0.10, height: size.height * 0.10)
                    .position(x: size.width * 0.341, y: size.height * 0.548)
            }
        }
    }

    private func screenGlow(time: TimeInterval, x: CGFloat, y: CGFloat, delay: Double, in size: CGSize) -> some View {
        let pulse = (sin((time + delay) * 2.2) + 1) / 2
        return RoundedRectangle(cornerRadius: 5)
            .fill(Theme.teal.opacity(0.06 + pulse * 0.12))
            .frame(width: size.width * 0.029, height: size.height * 0.034)
            .position(x: size.width * x, y: size.height * y)
            .blur(radius: 2)
            .blendMode(.screen)
    }
}

private struct FloatingPapers: View {
    let time: TimeInterval
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                let motion = reduceMotion ? 0 : sin(time * 1.7 + Double(index) * 0.85)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.paper.opacity(0.72))
                    .frame(width: 18, height: 13)
                    .rotationEffect(.degrees(-10 + motion * 9))
                    .offset(x: CGFloat(index) * 20 - 38 + CGFloat(motion * 5), y: CGFloat(index % 2) * 8 - 8)
                    .shadow(color: .black.opacity(0.16), radius: 2, x: 0, y: 1)
            }
        }
    }
}

private struct ProfileStatusCard: View {
    let questsOpen: Int
    let blockedCount: Int
    let completedCount: Int
    let isHovering: Bool
    let reduceMotion: Bool
    let time: TimeInterval

    private var xp: Int { min(3000, 2450 + completedCount * 40) }
    private var mood: String {
        if blockedCount > 0 { return "Needs your eye" }
        if questsOpen > 4 { return "Studio is humming" }
        return "The studio is calm"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 10) {
                AnimatedStamp(reduceMotion: reduceMotion, time: time)
                    .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text("GhiblyMail")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                    HStack(spacing: 8) {
                        Text(Self.dayFormatter.string(from: Date()))
                        Image(systemName: "sun.max.fill")
                            .foregroundStyle(Theme.amber)
                        Text(periodName)
                            .foregroundStyle(Theme.leaf)
                    }
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
                }
            }

            Divider().opacity(0.55)

            HStack(spacing: 10) {
                Image(systemName: blockedCount > 0 ? "tray.and.arrow.down.fill" : "leaf.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(blockedCount > 0 ? Theme.amber : Theme.leaf)
                VStack(alignment: .leading, spacing: 2) {
                    Text(mood)
                        .font(.system(size: 13, weight: .bold))
                    Text(questsOpen == 0 ? "No open quests." : "\(questsOpen) open quests waiting.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.mutedInk)
                }
                Spacer()
                Image(systemName: "face.smiling")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.ink.opacity(0.84))
            }

            HStack(spacing: 8) {
                Text("Lv. 12")
                    .font(.system(size: 13, weight: .bold))
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.black.opacity(0.12))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.teal, Theme.leaf],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * CGFloat(Double(xp) / 3000.0))
                            .animation(.spring(response: 0.7, dampingFraction: 0.82), value: xp)
                    }
                }
                .frame(height: 11)
                Text("\(xp.formatted()) / 3,000 XP")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.mutedInk)
                    .frame(width: 94, alignment: .trailing)
            }
        }
        .padding(12)
        .premiumPanel(isHovering: isHovering, cornerRadius: 12)
    }

    private var periodName: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
}

private struct AnimatedStamp: View {
    let reduceMotion: Bool
    let time: TimeInterval

    var body: some View {
        let lift = reduceMotion ? 0 : sin(time * 1.8) * 1.5

        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.81, green: 0.92, blue: 0.86))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [2, 2]))
                        .foregroundStyle(Theme.deepTeal.opacity(0.58))
                )
                .rotationEffect(.degrees(-3))

            CloudMascotFace(time: time)
                .padding(9)
                .offset(y: lift)
        }
    }
}

private struct CloudMascotFace: View {
    let time: TimeInterval

    var body: some View {
        let blink = (sin(time * 2.1) + 1) / 2 > 0.96
        ZStack {
            Circle()
                .fill(Theme.paper)
                .overlay(Circle().stroke(Theme.deepTeal.opacity(0.20), lineWidth: 1))
            HStack(spacing: 7) {
                Capsule()
                    .fill(Theme.ink)
                    .frame(width: 3, height: blink ? 1 : 5)
                Capsule()
                    .fill(Theme.ink)
                    .frame(width: 3, height: blink ? 1 : 5)
            }
            .offset(y: -2)
            Capsule()
                .fill(Theme.coral.opacity(0.28))
                .frame(width: 12, height: 5)
                .offset(y: 9)
        }
    }
}

private struct QuestCounterButton: View {
    let target: HomeTarget
    @Binding var hoveredTarget: HomeTarget?
    let title: String
    let value: Int
    let icon: String
    let tint: Color
    let pulse: Bool
    let time: TimeInterval
    let action: () -> Void

    var body: some View {
        AliveButton(target: target, hoveredTarget: $hoveredTarget, action: action) { hovering in
            let beat = pulse ? (sin(time * 2.4) + 1) / 2 : 0

            VStack(spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 9) {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(tint)
                        .scaleEffect(hovering ? 1.10 : 1.0 + beat * 0.03)
                    Text("\(value)")
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                }
                Text(title)
                    .font(.system(size: 13, weight: .bold))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hovering ? tint.opacity(0.08) : Color.clear)
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(Theme.line)
                    .frame(width: 1)
            }
            .scaleEffect(hovering ? 1.035 : 1)
        }
    }
}

private struct ServiceTile: View {
    let target: HomeTarget
    @Binding var hoveredTarget: HomeTarget?
    let title: String
    let icon: String
    let tint: Color
    let isOn: Bool
    let showsEqualizer: Bool
    let time: TimeInterval
    let action: () -> Void

    var body: some View {
        AliveButton(target: target, hoveredTarget: $hoveredTarget, action: action) { hovering in
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(tint)
                    .rotationEffect(.degrees(target == .settings && hovering ? 18 : 0))
                    .scaleEffect(hovering ? 1.12 : 1)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)

                if target == .focusMode {
                    FocusSwitch(isOn: isOn)
                        .frame(width: 48, height: 20)
                } else if showsEqualizer {
                    EqualizerBars(isOn: isOn, time: time)
                        .frame(width: 36, height: 20)
                } else {
                    Circle()
                        .fill(isOn ? Theme.leaf : Theme.mutedInk.opacity(0.5))
                        .frame(width: 10, height: 10)
                        .shadow(color: (isOn ? Theme.leaf : Theme.mutedInk).opacity(0.45), radius: isOn ? 5 : 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hovering ? tint.opacity(0.08) : Color.clear)
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(Theme.line)
                    .frame(width: 1)
            }
            .scaleEffect(hovering ? 1.035 : 1)
        }
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

private struct FocusSwitch: View {
    let isOn: Bool

    var body: some View {
        Capsule()
            .fill(isOn ? Theme.leaf.opacity(0.72) : Theme.mutedInk.opacity(0.25))
            .overlay(Capsule().stroke(Color.white.opacity(0.45), lineWidth: 1))
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle()
                    .fill(Theme.paper)
                    .padding(3)
                    .shadow(color: .black.opacity(0.20), radius: 2, x: 0, y: 1)
            }
            .overlay {
                Text(isOn ? "ON" : "OFF")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(.white)
                    .offset(x: isOn ? -6 : 6)
            }
    }
}

private struct EqualizerBars: View {
    let isOn: Bool
    let time: TimeInterval

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(0..<4, id: \.self) { index in
                let motion = isOn ? (sin(time * 4 + Double(index)) + 1) / 2 : 0.15
                RoundedRectangle(cornerRadius: 2)
                    .fill(isOn ? Theme.leaf : Theme.mutedInk.opacity(0.35))
                    .frame(width: 5, height: 5 + CGFloat(motion) * 14)
            }
        }
    }
}

private struct StationLabelCard: View {
    let spec: HomeStationSpec
    let isHovering: Bool

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: spec.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(spec.tint)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(spec.title)
                    .font(.system(size: 15, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(spec.subtitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(spec.tint)
                    .contentTransition(.numericText())
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .premiumPanel(isHovering: isHovering, cornerRadius: 10)
        .overlay(alignment: .bottom) {
            Triangle()
                .fill(Theme.paper.opacity(0.92))
                .frame(width: 14, height: 7)
                .offset(y: 6)
        }
    }
}

private struct SpeechBubbleIcon: View {
    let icon: String
    let tint: Color
    let isHighlighted: Bool
    let reduceMotion: Bool
    let time: TimeInterval

    var body: some View {
        let bob = reduceMotion ? 0 : sin(time * 1.7) * (isHighlighted ? 2.6 : 1.3)

        ZStack {
            BubbleShape()
                .fill(Theme.paper.opacity(0.94))
                .overlay(BubbleShape().stroke(Theme.line, lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 3)

            Image(systemName: icon)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(tint)
        }
        .offset(y: bob)
        .scaleEffect(isHighlighted ? 1.10 : 1)
    }
}

private struct PremiumAgentSprite: View {
    let agent: Agent
    let tint: Color
    let isHighlighted: Bool
    let reduceMotion: Bool
    let time: TimeInterval

    var body: some View {
        let speed = agent.state == .working ? 2.4 : 1.1
        let bob = reduceMotion ? 0 : sin(time * speed + Double(agent.name.count)) * (agent.state == .idle ? 0.6 : 2.2)
        let typeMotion = reduceMotion ? 0 : sin(time * 9 + Double(agent.name.count))

        ZStack {
            Ellipse()
                .fill(.black.opacity(0.22))
                .frame(width: 58, height: 18)
                .offset(y: 47)
                .blur(radius: 3)

            VStack(spacing: -2) {
                ZStack {
                    HairShapePremium()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.10, green: 0.08, blue: 0.07), Color(red: 0.26, green: 0.18, blue: 0.13)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 43, height: 34)
                        .offset(y: -13)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.98, green: 0.77, blue: 0.58), Color(red: 0.89, green: 0.62, blue: 0.45)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(Color.white.opacity(0.26), lineWidth: 1))
                        .offset(y: -5)

                    AgentEyes(time: time, reduceMotion: reduceMotion)
                        .offset(y: -7)
                }
                .zIndex(2)

                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.92), tint.opacity(0.66)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(isHighlighted ? 0.72 : 0.32), lineWidth: 1.4)
                        )
                        .shadow(color: tint.opacity(isHighlighted ? 0.50 : 0.22), radius: isHighlighted ? 12 : 6)

                    HStack(spacing: 27) {
                        Capsule()
                            .fill(Color(red: 0.94, green: 0.70, blue: 0.52))
                            .frame(width: 8, height: 28)
                            .rotationEffect(.degrees(-12 + typeMotion * 6))
                        Capsule()
                            .fill(Color(red: 0.94, green: 0.70, blue: 0.52))
                            .frame(width: 8, height: 28)
                            .rotationEffect(.degrees(12 - typeMotion * 6))
                    }
                    .offset(y: 7)

                    Image(systemName: agent.role.systemImage)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .offset(y: -2)
                }
            }
            .offset(y: bob)
            .scaleEffect(isHighlighted ? 1.06 : 1)

            AgentStateBadge(agent: agent, tint: tint, time: time)
                .offset(x: 34, y: -34)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(agent.name), \(agent.role.rawValue), \(agent.state.rawValue)")
    }
}

private struct AgentEyes: View {
    let time: TimeInterval
    let reduceMotion: Bool

    var body: some View {
        let blink = !reduceMotion && (sin(time * 1.9) + 1) / 2 > 0.965
        HStack(spacing: 9) {
            Capsule()
                .fill(Theme.ink)
                .frame(width: 3.5, height: blink ? 1.2 : 5)
            Capsule()
                .fill(Theme.ink)
                .frame(width: 3.5, height: blink ? 1.2 : 5)
        }
    }
}

private struct AgentStateBadge: View {
    let agent: Agent
    let tint: Color
    let time: TimeInterval

    var body: some View {
        let pulse = (sin(time * 2.3 + Double(agent.name.count)) + 1) / 2
        ZStack {
            Circle()
                .fill(stateColor.opacity(0.18 + pulse * 0.12))
                .frame(width: 33, height: 33)
            Circle()
                .fill(Theme.paper.opacity(0.95))
                .frame(width: 24, height: 24)
                .overlay(Circle().stroke(Color.white.opacity(0.60), lineWidth: 1))
            Image(systemName: stateIcon)
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(stateColor)
        }
    }

    private var stateColor: Color {
        switch agent.state {
        case .working: return tint
        case .needsReview: return Theme.coral
        case .waiting: return Theme.amber
        case .idle: return Theme.mutedInk
        }
    }

    private var stateIcon: String {
        switch agent.state {
        case .working: return "ellipsis"
        case .needsReview: return "exclamationmark"
        case .waiting: return "clock.fill"
        case .idle: return "checkmark"
        }
    }
}

private struct StudioActivityPanel: View {
    let events: [AuditEvent]
    let isHovering: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Studio Activity", systemImage: "dot.radiowaves.left.and.right")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.mutedInk)
                    .rotationEffect(.degrees(isHovering ? 180 : 0))
            }
            Divider().opacity(0.55)

            if events.isEmpty {
                Text("No local activity yet.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.mutedInk)
                Spacer()
            } else {
                ForEach(events) { event in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: icon(for: event.action))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(color(for: event.action))
                            .frame(width: 18)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Self.timeFormatter.string(from: event.timestamp))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.ink)
                            Text(event.summary)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Theme.mutedInk)
                                .lineLimit(1)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer(minLength: 0)
            }
        }
        .padding(13)
        .premiumPanel(isHovering: isHovering, cornerRadius: 12)
    }

    private func icon(for action: ActionKind) -> String {
        switch action {
        case .readGmail: return "tray.and.arrow.down.fill"
        case .createDraft: return "pencil"
        case .moveToDone: return "checkmark.circle.fill"
        case .restoreFromDone: return "arrow.uturn.left"
        case .queueCalendarInvite: return "calendar"
        case .manuallyUnsubscribe, .autoUnsubscribe: return "envelope.badge.fill"
        case .sendEmail: return "paperplane.fill"
        case .operateOutsideTestLabel: return "exclamationmark.triangle.fill"
        case .updateMemory: return "brain.head.profile"
        }
    }

    private func color(for action: ActionKind) -> Color {
        switch action {
        case .readGmail, .queueCalendarInvite: return Theme.teal
        case .createDraft: return Theme.blue
        case .moveToDone, .restoreFromDone, .updateMemory: return Theme.leaf
        case .manuallyUnsubscribe, .autoUnsubscribe: return Theme.amber
        case .sendEmail, .operateOutsideTestLabel: return Theme.coral
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter
    }()
}

private struct BottomNavButton: View {
    let target: HomeTarget
    @Binding var hoveredTarget: HomeTarget?
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        AliveButton(target: target, hoveredTarget: $hoveredTarget, action: action) { hovering in
            VStack(spacing: 7) {
                IconMedallion(icon: icon, tint: tint, isHovering: hovering)
                    .frame(width: 48, height: 48)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hovering ? tint.opacity(0.08) : Color.clear)
            .scaleEffect(hovering ? 1.045 : 1)
        }
    }
}

private struct IconMedallion: View {
    let icon: String
    let tint: Color
    let isHovering: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.22), tint.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(Circle().stroke(Color.white.opacity(0.44), lineWidth: 1))
                .shadow(color: tint.opacity(isHovering ? 0.42 : 0.18), radius: isHovering ? 9 : 4)

            Image(systemName: icon)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(tint)
                .scaleEffect(isHovering ? 1.12 : 1)
        }
    }
}

private struct HomeStatusStrip: View {
    let agentsOnline: Int
    let safeRate: Double
    let mood: String
    let isHovering: Bool

    var body: some View {
        HStack(spacing: 12) {
            Label("\(agentsOnline) Online", systemImage: "person.3.fill")
            Divider().frame(height: 20)
            Label("\(Int(safeRate * 100))%", systemImage: "battery.100percent")
            Divider().frame(height: 20)
            Label("Mood: \(mood)", systemImage: "leaf.fill")
            Image(systemName: "face.smiling")
                .foregroundStyle(Theme.leaf)
        }
        .font(.system(size: 11, weight: .bold))
        .foregroundStyle(Theme.paper)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.deepTeal.opacity(0.86))
                .shadow(color: Theme.teal.opacity(isHovering ? 0.35 : 0.16), radius: isHovering ? 12 : 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
    }
}

private struct TodayQuestsPanel: View {
    @Binding var hoveredTarget: HomeTarget?
    let rows: [TodayQuestRowModel]
    let completedCount: Int
    let totalCount: Int
    let time: TimeInterval
    let viewAllAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Today's Quests", systemImage: "flag.fill")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Text("\(progressPercent)%")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.mutedInk)
            }
            Divider().opacity(0.55)

            ForEach(rows) { row in
                AliveButton(target: row.target, hoveredTarget: $hoveredTarget, action: row.action) { hovering in
                    HStack(spacing: 8) {
                        Image(systemName: row.icon)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(row.tint)
                            .frame(width: 19)
                        Text(row.title)
                            .font(.system(size: 12, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                        Spacer(minLength: 4)
                        Text("\(row.count)")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 22)
                            .background(row.tint)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .contentTransition(.numericText())
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(Theme.mutedInk)
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 6)
                    .background(hovering ? row.tint.opacity(0.10) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 9) {
                AliveButton(target: .viewAllQuests, hoveredTarget: $hoveredTarget, action: viewAllAction) { hovering in
                    HStack {
                        Text("View All Quests")
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .black))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Theme.teal)
                            .shadow(color: Theme.teal.opacity(hovering ? 0.42 : 0.18), radius: hovering ? 9 : 4)
                    )
                    .scaleEffect(hovering ? 1.025 : 1)
                }

                MiniMascot(isExcited: completedCount > 0, time: time)
                    .frame(width: 43, height: 43)
            }
        }
        .padding(13)
        .premiumPanel(cornerRadius: 12)
    }

    private var progressPercent: Int {
        Int((Double(completedCount) / Double(max(totalCount, 1)) * 100).rounded())
    }
}

private struct MiniMascot: View {
    let isExcited: Bool
    let time: TimeInterval

    var body: some View {
        let wave = isExcited ? sin(time * 4.0) * 8 : sin(time * 1.4) * 2

        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .fill(Color(red: 0.18, green: 0.22, blue: 0.21))
                .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.white.opacity(0.25), lineWidth: 1))

            HStack(spacing: 8) {
                Circle().fill(Theme.paper).frame(width: 5, height: 5)
                Circle().fill(Theme.paper).frame(width: 5, height: 5)
            }
            .offset(y: -3)

            RoundedRectangle(cornerRadius: 3)
                .fill(Theme.teal)
                .frame(width: 18, height: 4)
                .offset(y: 9)

            Capsule()
                .fill(Color(red: 0.18, green: 0.22, blue: 0.21))
                .frame(width: 8, height: 20)
                .rotationEffect(.degrees(-28 + wave))
                .offset(x: -25, y: 5)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct BubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: rect.width * 0.44)
        path.move(to: CGPoint(x: rect.midX - 4, y: rect.maxY - 7))
        path.addLine(to: CGPoint(x: rect.midX + 9, y: rect.maxY + 7))
        path.addLine(to: CGPoint(x: rect.midX + 6, y: rect.maxY - 7))
        path.closeSubpath()
        return path
    }
}

private struct HairShapePremium: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.10, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.10, y: rect.maxY),
            control1: CGPoint(x: rect.minX + rect.width * 0.03, y: rect.minY),
            control2: CGPoint(x: rect.maxX - rect.width * 0.03, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.30, y: rect.maxY - rect.height * 0.14))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.44, y: rect.midY + 1))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.60, y: rect.maxY - rect.height * 0.13))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct PremiumPanelModifier: ViewModifier {
    var isHovering: Bool
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.paper.opacity(isHovering ? 0.98 : 0.92),
                                Color(red: 0.96, green: 0.89, blue: 0.76).opacity(isHovering ? 0.94 : 0.86)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(isHovering ? 0.18 : 0.10))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(isHovering ? 0.72 : 0.42), lineWidth: 1)
            )
            .shadow(color: .black.opacity(isHovering ? 0.22 : 0.14), radius: isHovering ? 16 : 8, x: 0, y: isHovering ? 9 : 4)
            .shadow(color: Color.white.opacity(isHovering ? 0.22 : 0.08), radius: isHovering ? 9 : 3, x: 0, y: -1)
            .scaleEffect(isHovering ? 1.018 : 1)
    }
}

private extension View {
    func premiumPanel(isHovering: Bool = false, cornerRadius: CGFloat) -> some View {
        modifier(PremiumPanelModifier(isHovering: isHovering, cornerRadius: cornerRadius))
    }
}

private extension Double {
    var fractionalPart: Double {
        self - floor(self)
    }
}
