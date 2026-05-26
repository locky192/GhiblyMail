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

            HStack(spacing: 8) {
                Button {
                    store.completeSelectedQuest()
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
        }
    }

    private var actionIcon: String {
        switch quest.kind {
        case .approveDraft: "paperplane.fill"
        case .provideContext: "text.badge.plus"
        case .uploadAttachment: "paperclip"
        case .calendarInvite: "checkmark.circle"
        case .triageReview: "line.3.horizontal.decrease.circle"
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
