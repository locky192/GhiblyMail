import SwiftUI

struct OfficeSceneView: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                roomShell(in: proxy.size)
                greenery(in: proxy.size)
                windows(in: proxy.size)
                floorDetails(in: proxy.size)
                desks(in: proxy.size)
                agents(in: proxy.size)
                statusStrip
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
            )
        }
    }

    private func roomShell(in size: CGSize) -> some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: size.width * 0.08, y: size.height * 0.34))
                path.addLine(to: CGPoint(x: size.width * 0.50, y: size.height * 0.13))
                path.addLine(to: CGPoint(x: size.width * 0.92, y: size.height * 0.34))
                path.addLine(to: CGPoint(x: size.width * 0.92, y: size.height * 0.78))
                path.addLine(to: CGPoint(x: size.width * 0.50, y: size.height * 0.97))
                path.addLine(to: CGPoint(x: size.width * 0.08, y: size.height * 0.78))
                path.closeSubpath()
            }
            .fill(Theme.teal)

            Path { path in
                path.move(to: CGPoint(x: size.width * 0.08, y: size.height * 0.34))
                path.addLine(to: CGPoint(x: size.width * 0.50, y: size.height * 0.13))
                path.addLine(to: CGPoint(x: size.width * 0.92, y: size.height * 0.34))
                path.addLine(to: CGPoint(x: size.width * 0.50, y: size.height * 0.54))
                path.closeSubpath()
            }
            .fill(Theme.warmWall)
        }
        .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 12)
    }

    private func windows(in size: CGSize) -> some View {
        HStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.72, green: 0.87, blue: 0.91))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.white.opacity(0.75), lineWidth: 2)
                    )
                    .frame(width: size.width * 0.10, height: size.height * 0.12)
            }
        }
        .rotationEffect(.degrees(0))
        .position(x: size.width * 0.50, y: size.height * 0.29)
    }

    private func greenery(in size: CGSize) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<10, id: \.self) { index in
                Circle()
                    .fill(index.isMultiple(of: 2) ? Theme.leaf : Color(red: 0.42, green: 0.62, blue: 0.36))
                    .frame(width: 26, height: 26)
            }
        }
        .blur(radius: 0.4)
        .position(x: size.width * 0.50, y: size.height * 0.18)
    }

    private func floorDetails(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                Path { path in
                    let y = size.height * (0.44 + Double(index) * 0.065)
                    path.move(to: CGPoint(x: size.width * 0.18, y: y))
                    path.addLine(to: CGPoint(x: size.width * 0.82, y: y))
                }
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }

            RoundedRectangle(cornerRadius: 5)
                .fill(Theme.paper.opacity(0.9))
                .frame(width: size.width * 0.16, height: size.height * 0.055)
                .rotationEffect(.degrees(-12))
                .position(x: size.width * 0.72, y: size.height * 0.68)

            RoundedRectangle(cornerRadius: 5)
                .fill(Theme.deepTeal.opacity(0.38))
                .frame(width: size.width * 0.13, height: size.height * 0.08)
                .rotationEffect(.degrees(10))
                .position(x: size.width * 0.33, y: size.height * 0.72)
        }
    }

    private func desks(in size: CGSize) -> some View {
        ZStack {
            DeskCluster()
                .frame(width: size.width * 0.25, height: size.height * 0.18)
                .position(x: size.width * 0.36, y: size.height * 0.50)

            DeskCluster()
                .frame(width: size.width * 0.25, height: size.height * 0.18)
                .position(x: size.width * 0.64, y: size.height * 0.50)

            MeetingTable()
                .frame(width: size.width * 0.20, height: size.height * 0.14)
                .position(x: size.width * 0.52, y: size.height * 0.73)

            Bookshelf()
                .frame(width: size.width * 0.13, height: size.height * 0.19)
                .position(x: size.width * 0.22, y: size.height * 0.38)

            WaterCooler()
                .frame(width: size.width * 0.06, height: size.height * 0.14)
                .position(x: size.width * 0.80, y: size.height * 0.40)
        }
    }

    private func agents(in size: CGSize) -> some View {
        ZStack {
            ForEach(Array(store.agents.enumerated()), id: \.element.id) { index, agent in
                AgentAvatarView(agent: agent)
                    .frame(width: 76, height: 104)
                    .position(agentPosition(index: index, in: size))
            }
        }
    }

    private func agentPosition(index: Int, in size: CGSize) -> CGPoint {
        let points = [
            CGPoint(x: size.width * 0.30, y: size.height * 0.48),
            CGPoint(x: size.width * 0.43, y: size.height * 0.54),
            CGPoint(x: size.width * 0.59, y: size.height * 0.47),
            CGPoint(x: size.width * 0.70, y: size.height * 0.55),
            CGPoint(x: size.width * 0.50, y: size.height * 0.74)
        ]
        return points[index % points.count]
    }

    private var statusStrip: some View {
        HStack(spacing: 8) {
            Image(systemName: "building.2")
                .foregroundStyle(Theme.deepTeal)
            Text("Studio floor")
                .font(.system(size: 13, weight: .bold))
            Text("Agents are processing mock mail")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.mutedInk)
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

private struct DeskCluster: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Theme.wood)
                .rotationEffect(.degrees(-8))
                .shadow(color: .black.opacity(0.20), radius: 5, x: 0, y: 4)

            ForEach(0..<2, id: \.self) { index in
                CRTView()
                    .frame(width: 54, height: 44)
                    .offset(x: CGFloat(index * 56 - 28), y: -10)
            }

            Circle()
                .fill(Theme.paper)
                .frame(width: 14, height: 14)
                .offset(x: 52, y: 24)
        }
    }
}

private struct CRTView: View {
    var body: some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.78, green: 0.70, blue: 0.58))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.deepTeal.opacity(0.82))
                        .padding(6)
                )
                .frame(height: 30)

            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.64, green: 0.57, blue: 0.46))
                .frame(width: 28, height: 8)
        }
    }
}

private struct AgentAvatarView: View {
    var agent: Agent

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(colorForRole.opacity(0.24))
                    .frame(width: 58, height: 58)

                Circle()
                    .fill(Color(red: 0.96, green: 0.74, blue: 0.58))
                    .frame(width: 28, height: 28)
                    .offset(y: -8)

                RoundedRectangle(cornerRadius: 8)
                    .fill(colorForRole)
                    .frame(width: 38, height: 28)
                    .offset(y: 18)

                Image(systemName: agent.role.systemImage)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(y: 18)
            }

            Text(agent.name)
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 7)
                .frame(height: 20)
                .background(Theme.panelStrong)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .accessibilityLabel("\(agent.name), \(agent.role.rawValue), \(agent.state.rawValue)")
    }

    private var colorForRole: Color {
        switch agent.role {
        case .triage: Theme.teal
        case .drafting: Theme.blue
        case .calendar: Theme.amber
        case .memory: Theme.leaf
        case .attachments: Theme.coral
        }
    }
}

private struct MeetingTable: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.52, green: 0.32, blue: 0.18))
                .shadow(color: .black.opacity(0.16), radius: 5, x: 0, y: 4)
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(Theme.paper)
                    .frame(width: 13, height: 13)
                    .offset(
                        x: cos(Double(index) * .pi / 2) * 50,
                        y: sin(Double(index) * .pi / 2) * 28
                    )
            }
        }
    }
}

private struct Bookshelf: View {
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill([Theme.blue, Theme.coral, Theme.amber, Theme.leaf, Theme.paper][(row + index) % 5])
                            .frame(width: 8, height: 22)
                    }
                }
            }
        }
        .padding(8)
        .background(Theme.wood)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

private struct WaterCooler: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.55, green: 0.78, blue: 0.88).opacity(0.85))
                .frame(height: 48)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.76, green: 0.76, blue: 0.70))
                .frame(height: 42)
        }
    }
}
