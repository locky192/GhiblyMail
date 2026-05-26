import SwiftUI

struct QuestDetailView: View {
    @EnvironmentObject private var store: CommandCenterStore
    var quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: quest.kind.systemImage)
                    .foregroundStyle(Theme.deepTeal)
                Text(quest.kind.rawValue)
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Text("Priority \(quest.priority)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.mutedInk)
            }

            Text(quest.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            DetailSection(title: "Summary", text: quest.summary)
            DetailSection(title: "Agent plan", text: quest.proposedAction)
            DetailSection(title: "Your move", text: quest.requiredAction)

            Text(quest.threadPreview)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.mutedInk)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.42))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            if let draftBody = quest.draftBody {
                DetailSection(title: "Draft proposal", text: draftBody)
                    .padding(10)
                    .background(Color.white.opacity(0.38))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack(spacing: 8) {
                RiskBadge(risk: quest.risk)
                Text("\(Int(quest.confidence * 100))% confidence")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.mutedInk)
                Spacer()
            }

            HStack(spacing: 8) {
                Button {
                    Task { await store.performPrimaryAction() }
                } label: {
                    Label(actionTitle, systemImage: actionIcon)
                }
                .buttonStyle(PrimaryQuestButtonStyle())
                .keyboardShortcut(.return, modifiers: [.command])

                Button {
                    store.restoreSelectedQuestToInbox()
                } label: {
                    Label("Keep visible", systemImage: "arrow.uturn.left")
                }
                .buttonStyle(SecondaryQuestButtonStyle())
            }
        }
        .padding(14)
        .background(Theme.paper.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.line)
        )
    }

    private var actionTitle: String {
        switch quest.kind {
        case .approveDraft: "Approve"
        case .provideContext: "Add Context"
        case .uploadAttachment: "Upload"
        case .calendarInvite: "Respond Yes"
        case .triageReview: "Filter Similar"
        case .moveToDone: "Move to Done"
        case .restoreToInbox: "Restore"
        case .mailingList: "Unsubscribe"
        case .codexSetup: "Check"
        }
    }

    private var actionIcon: String {
        switch quest.kind {
        case .approveDraft: "doc.badge.plus"
        case .provideContext: "text.badge.plus"
        case .uploadAttachment: "paperclip"
        case .calendarInvite: "checkmark.circle"
        case .triageReview: "line.3.horizontal.decrease.circle"
        case .moveToDone: "tray.and.arrow.down.fill"
        case .restoreToInbox: "arrow.uturn.left.circle.fill"
        case .mailingList: "link.badge.plus"
        case .codexSetup: "checkmark.seal"
        }
    }
}

private struct RiskBadge: View {
    var risk: QuestRisk

    var body: some View {
        Text("\(risk.rawValue) risk")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .frame(height: 22)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var color: Color {
        switch risk {
        case .low: Theme.leaf
        case .medium: Theme.amber
        case .high: Theme.coral
        }
    }
}

private struct DetailSection: View {
    var title: String
    var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.mutedInk)
                .textCase(.uppercase)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PrimaryQuestButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(configuration.isPressed ? Theme.deepTeal.opacity(0.82) : Theme.deepTeal)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct SecondaryQuestButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Theme.deepTeal)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(configuration.isPressed ? Theme.teal.opacity(0.18) : Color.white.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.deepTeal.opacity(0.20))
            )
    }
}
