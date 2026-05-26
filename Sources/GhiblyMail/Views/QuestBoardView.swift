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
                Text("Mock mail only")
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
        }
    }

    private var statusTint: Color {
        switch quest.status {
        case .ready: Theme.deepTeal
        case .waitingOnUser: Theme.amber
        case .inProgress: Theme.blue
        case .complete: Theme.leaf
        }
    }
}
