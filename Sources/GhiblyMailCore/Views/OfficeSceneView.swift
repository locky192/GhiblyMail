import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

struct OfficeSceneView: View {
    @EnvironmentObject private var store: CommandCenterStore

    private let imageAspectRatio: CGFloat = 1672.0 / 941.0

    var body: some View {
        GeometryReader { proxy in
            let sceneFrame = filledSceneFrame(in: proxy.size)

            ZStack {
                ZStack {
                    OfficeBackgroundImage()
                        .frame(width: sceneFrame.width, height: sceneFrame.height)

                    stationLayer(in: sceneFrame.size)
                    ambientLayer(in: sceneFrame.size)
                    agentLayer(in: sceneFrame.size)

                    statusStrip
                        .padding(sceneFrame.width * 0.018)
                        .frame(
                            width: sceneFrame.width,
                            height: sceneFrame.height,
                            alignment: .bottomLeading
                        )
                }
                .frame(width: sceneFrame.width, height: sceneFrame.height)
                .position(x: sceneFrame.midX, y: sceneFrame.midY)
            }
            .clipped()
            .accessibilityElement(children: .contain)
            .accessibilityLabel("GhiblyMail office command center")
        }
    }

    private func filledSceneFrame(in container: CGSize) -> CGRect {
        guard container.width > 0, container.height > 0 else {
            return .zero
        }

        let containerRatio = container.width / container.height
        let width: CGFloat
        let height: CGFloat

        if containerRatio > imageAspectRatio {
            width = container.width
            height = width / imageAspectRatio
        } else {
            height = container.height
            width = height * imageAspectRatio
        }

        return CGRect(
            x: (container.width - width) / 2,
            y: (container.height - height) / 2,
            width: width,
            height: height
        )
    }

    private func stationLayer(in size: CGSize) -> some View {
        ZStack {
            ForEach(OfficeStation.allCases) { station in
                StationBeacon(station: station)
                    .frame(width: size.width * 0.07, height: size.width * 0.07)
                    .position(station.point(in: size))
            }
        }
    }

    private func ambientLayer(in size: CGSize) -> some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                ForEach(0..<4, id: \.self) { index in
                    ScreenGlow(delay: Double(index) * 0.9, time: t)
                        .frame(width: size.width * 0.033, height: size.height * 0.042)
                        .position(crtGlowPosition(index, in: size))
                }

                PaperSortEffect(time: t)
                    .frame(width: size.width * 0.09, height: size.height * 0.06)
                    .position(x: size.width * 0.36, y: size.height * 0.48)
            }
        }
        .allowsHitTesting(false)
    }

    private func agentLayer(in size: CGSize) -> some View {
        ZStack {
            ForEach(store.agents) { agent in
                let station = OfficeStation(role: agent.role)

                PlaceholderAgentSprite(agent: agent)
                    .frame(width: max(62, size.width * 0.060), height: max(76, size.width * 0.080))
                    .position(station.agentPoint(in: size))
            }
        }
    }

    private func crtGlowPosition(_ index: Int, in size: CGSize) -> CGPoint {
        let points = [
            CGPoint(x: size.width * 0.297, y: size.height * 0.454),
            CGPoint(x: size.width * 0.420, y: size.height * 0.401),
            CGPoint(x: size.width * 0.520, y: size.height * 0.418),
            CGPoint(x: size.width * 0.632, y: size.height * 0.739)
        ]
        return points[index % points.count]
    }

    private var statusStrip: some View {
        HStack(spacing: 8) {
            Image(systemName: "building.2")
                .foregroundStyle(Theme.deepTeal)

            Text("Studio floor")
                .font(.system(size: 13, weight: .bold))

            Text(store.lastOperationMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.mutedInk)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Theme.panelStrong)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.line)
        )
    }
}

private struct OfficeBackgroundImage: View {
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
                .fill(Theme.teal)

            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.system(size: 28, weight: .semibold))
                Text("Office background missing")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundStyle(.white.opacity(0.82))
        }
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

private struct PlaceholderAgentSprite: View {
    let agent: Agent

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let phase = time * speed + Double(agent.name.count)
            let bob = agent.state == .working ? sin(phase) * 2.4 : 0
            let armSwing = agent.state == .working ? sin(phase * 2.1) * 5 : 0

            ZStack {
                Ellipse()
                    .fill(.black.opacity(0.18))
                    .frame(width: 42, height: 13)
                    .offset(y: 38)
                    .blur(radius: 2)

                VStack(spacing: 0) {
                    ZStack {
                        HairShape()
                            .fill(Color(red: 0.17, green: 0.13, blue: 0.11))
                            .frame(width: 32, height: 24)
                            .offset(y: -12)

                        Circle()
                            .fill(Color(red: 0.95, green: 0.74, blue: 0.58))
                            .frame(width: 27, height: 27)
                            .offset(y: -7)

                        HStack(spacing: 7) {
                            Circle().fill(Theme.ink).frame(width: 2.5, height: 2.5)
                            Circle().fill(Theme.ink).frame(width: 2.5, height: 2.5)
                        }
                        .offset(y: -8)
                    }
                    .zIndex(1)

                    ZStack {
                        RoundedRectangle(cornerRadius: 11)
                            .fill(roleColor)
                            .frame(width: 36, height: 34)
                            .overlay(
                                RoundedRectangle(cornerRadius: 11)
                                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                            )

                        HStack(spacing: 20) {
                            Capsule()
                                .fill(Color(red: 0.95, green: 0.74, blue: 0.58))
                                .frame(width: 7, height: 24)
                                .rotationEffect(.degrees(-10 + armSwing))

                            Capsule()
                                .fill(Color(red: 0.95, green: 0.74, blue: 0.58))
                                .frame(width: 7, height: 24)
                                .rotationEffect(.degrees(10 - armSwing))
                        }
                        .offset(y: 4)

                        Image(systemName: agent.role.systemImage)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .offset(y: -1)
                    }
                }
                .offset(y: bob)

                stateBadge(time: time)
                    .offset(x: 28, y: -30)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(agent.name), \(agent.role.rawValue), \(agent.state.rawValue)")
    }

    private var speed: Double {
        switch agent.state {
        case .working: 2.6
        case .needsReview: 1.5
        case .waiting: 1.1
        case .idle: 0.8
        }
    }

    private var roleColor: Color {
        switch agent.role {
        case .triage: Theme.teal
        case .drafting: Theme.blue
        case .calendar: Theme.amber
        case .memory: Theme.leaf
        case .attachments: Theme.coral
        }
    }

    @ViewBuilder
    private func stateBadge(time: TimeInterval) -> some View {
        let pulse = (sin(time * 2.0 + Double(agent.name.count)) + 1) / 2

        ZStack {
            Circle()
                .fill(badgeColor.opacity(0.22 + pulse * 0.12))
                .frame(width: 30, height: 30)

            Circle()
                .fill(Theme.panelStrong)
                .frame(width: 22, height: 22)
                .overlay(Circle().stroke(Theme.line, lineWidth: 1))

            Image(systemName: badgeIcon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(badgeColor)
        }
        .scaleEffect(agent.state == .needsReview ? 1.0 + pulse * 0.08 : 1.0)
    }

    private var badgeColor: Color {
        switch agent.state {
        case .working: Theme.teal
        case .waiting: Theme.amber
        case .needsReview: Theme.coral
        case .idle: Theme.mutedInk
        }
    }

    private var badgeIcon: String {
        switch agent.state {
        case .working: "ellipsis"
        case .waiting: "clock"
        case .needsReview: "exclamationmark"
        case .idle: "checkmark"
        }
    }
}

private struct StationBeacon: View {
    let station: OfficeStation

    var body: some View {
        TimelineView(.animation) { timeline in
            let pulse = (sin(timeline.date.timeIntervalSinceReferenceDate * 1.8 + station.phase) + 1) / 2

            ZStack {
                Circle()
                    .stroke(station.color.opacity(0.18 + pulse * 0.20), lineWidth: 2)
                    .scaleEffect(0.72 + pulse * 0.16)

                Circle()
                    .fill(station.color.opacity(0.08 + pulse * 0.05))
                    .scaleEffect(0.56)

                Image(systemName: station.icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(station.color.opacity(0.86))
                    .padding(7)
                    .background(Theme.panelStrong.opacity(0.90))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1))
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct ScreenGlow: View {
    let delay: Double
    let time: TimeInterval

    var body: some View {
        let pulse = (sin((time + delay) * 2.4) + 1) / 2

        RoundedRectangle(cornerRadius: 4)
            .fill(Theme.teal.opacity(0.12 + pulse * 0.24))
            .blur(radius: 1.4)
            .blendMode(.screen)
    }
}

private struct PaperSortEffect: View {
    let time: TimeInterval

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                let progress = (sin(time * 1.7 + Double(index) * 1.2) + 1) / 2

                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.paper.opacity(0.70))
                    .frame(width: 18, height: 12)
                    .rotationEffect(.degrees(-9 + progress * 18))
                    .offset(x: -20 + CGFloat(index) * 18 + progress * 5, y: -6 + CGFloat(index) * 4)
                    .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
            }
        }
    }
}

private struct HairShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.maxY),
            control1: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.05),
            control2: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.minY + rect.height * 0.05)
        )
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.20, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.34, y: rect.maxY - rect.height * 0.16))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.48, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.63, y: rect.maxY - rect.height * 0.14))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private enum OfficeStation: CaseIterable, Identifiable {
    case triage
    case drafting
    case calendar
    case memory
    case attachments

    var id: Self { self }

    init(role: AgentRole) {
        switch role {
        case .triage: self = .triage
        case .drafting: self = .drafting
        case .calendar: self = .calendar
        case .memory: self = .memory
        case .attachments: self = .attachments
        }
    }

    var icon: String {
        switch self {
        case .triage: "tray.full"
        case .drafting: "pencil.and.outline"
        case .calendar: "calendar.badge.clock"
        case .memory: "person.crop.rectangle.stack"
        case .attachments: "paperclip"
        }
    }

    var color: Color {
        switch self {
        case .triage: Theme.teal
        case .drafting: Theme.blue
        case .calendar: Theme.amber
        case .memory: Theme.leaf
        case .attachments: Theme.coral
        }
    }

    var phase: Double {
        switch self {
        case .triage: 0.2
        case .drafting: 1.1
        case .calendar: 1.8
        case .memory: 2.5
        case .attachments: 3.2
        }
    }

    func point(in size: CGSize) -> CGPoint {
        let normalized: CGPoint = switch self {
        case .triage: CGPoint(x: 0.302, y: 0.495)
        case .drafting: CGPoint(x: 0.455, y: 0.424)
        case .calendar: CGPoint(x: 0.735, y: 0.466)
        case .memory: CGPoint(x: 0.198, y: 0.274)
        case .attachments: CGPoint(x: 0.618, y: 0.734)
        }

        return CGPoint(x: size.width * normalized.x, y: size.height * normalized.y)
    }

    func agentPoint(in size: CGSize) -> CGPoint {
        let normalized: CGPoint = switch self {
        case .triage: CGPoint(x: 0.306, y: 0.567)
        case .drafting: CGPoint(x: 0.454, y: 0.498)
        case .calendar: CGPoint(x: 0.745, y: 0.535)
        case .memory: CGPoint(x: 0.246, y: 0.322)
        case .attachments: CGPoint(x: 0.606, y: 0.817)
        }

        return CGPoint(x: size.width * normalized.x, y: size.height * normalized.y)
    }
}
