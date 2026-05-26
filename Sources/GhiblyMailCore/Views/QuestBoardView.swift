import SwiftUI

struct QuestBoardView: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        VStack(spacing: 12) {
            header

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(store.quests) { quest in
                        QuestRowView(
                            quest: quest,
                            isSelected: store.selectedQuest?.id == quest.id
                        )
                        .onTapGesture {
                            store.select(quest)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(minHeight: 220)

            if let selectedQuest = store.selectedQuest {
                QuestDetailView(quest: selectedQuest)
            }

            StatusPanel()
            AuditPanel()
            MemoryPanel()
        }
        .padding(14)
        .background(Theme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.line)
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "map")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.deepTeal)

            VStack(alignment: .leading, spacing: 2) {
                Text("Quest Board")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("\(store.runtimeMode.rawValue) / \(store.testLabel)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.mutedInk)
            }

            Spacer()

            Text("\(store.completedCount) done")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.deepTeal)
                .padding(.horizontal, 8)
                .frame(height: 26)
                .background(Theme.teal.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

private struct QuestRowView: View {
    var quest: Quest
    var isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: quest.kind.systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(iconTint)
                .frame(width: 32, height: 32)
                .background(iconTint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 3) {
                Text(quest.title)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(1)
                Text(quest.sender)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.mutedInk)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(quest.estimatedMinutes)m")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text(quest.status.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(statusTint)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .frame(height: 64)
        .background(isSelected ? Theme.paper : Theme.panelStrong)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Theme.deepTeal.opacity(0.45) : Theme.line, lineWidth: isSelected ? 2 : 1)
        )
    }

    private var iconTint: Color {
        switch quest.kind {
        case .approveDraft: Theme.blue
        case .provideContext: Theme.deepTeal
        case .uploadAttachment: Theme.amber
        case .calendarInvite: Theme.teal
        case .triageReview: Theme.coral
        case .moveToDone: Theme.leaf
        case .restoreToInbox: Theme.deepTeal
        case .mailingList: Theme.amber
        case .codexSetup: Theme.blue
        }
    }

    private var statusTint: Color {
        switch quest.status {
        case .ready: Theme.deepTeal
        case .waitingOnUser: Theme.amber
        case .inProgress: Theme.blue
        case .complete: Theme.leaf
        case .failed: Theme.coral
        }
    }
}

private struct StatusPanel: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: store.isWorking ? "hourglass" : "sparkles")
                    .foregroundStyle(Theme.deepTeal)
                Text("Operations")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Text("\(store.deniedAuditCount) denied")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(store.deniedAuditCount == 0 ? Theme.leaf : Theme.coral)
            }
            Text(store.lastOperationMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.mutedInk)
                .lineLimit(2)
        }
        .padding(10)
        .background(Theme.panelStrong)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.line))
    }
}

private struct AuditPanel: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "list.clipboard")
                    .foregroundStyle(Theme.deepTeal)
                Text("Audit Trail")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Text("\(store.auditEvents.count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.mutedInk)
            }

            ForEach(store.auditEvents.prefix(3)) { event in
                HStack(spacing: 8) {
                    Circle()
                        .fill(color(for: event.status))
                        .frame(width: 7, height: 7)
                    Text(event.summary)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.mutedInk)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(10)
        .background(Theme.paper.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.line))
    }

    private func color(for status: AuditStatus) -> Color {
        switch status {
        case .proposed: Theme.blue
        case .allowed: Theme.teal
        case .denied, .failed: Theme.coral
        case .executed: Theme.leaf
        }
    }
}

private struct MemoryPanel: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.crop.rectangle.stack")
                    .foregroundStyle(Theme.deepTeal)
                Text("Memory")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Text("\(store.memoryEntries.count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.mutedInk)
            }

            ForEach(store.memoryEntries.prefix(2)) { entry in
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.system(size: 11, weight: .bold))
                        .lineLimit(1)
                    Text(entry.summary)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.mutedInk)
                        .lineLimit(2)
                }
            }
        }
        .padding(10)
        .background(Theme.panelStrong)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.line))
    }
}
