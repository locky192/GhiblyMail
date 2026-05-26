import Combine
import Foundation

@MainActor
final class CommandCenterStore: ObservableObject {
    @Published var quests: [Quest]
    @Published var agents: [Agent]
    @Published var selectedQuestID: Quest.ID?

    init(
        quests: [Quest] = MockData.quests,
        agents: [Agent] = MockData.agents
    ) {
        self.quests = quests
        self.agents = agents
        self.selectedQuestID = quests.first?.id
    }

    var selectedQuest: Quest? {
        quests.first { $0.id == selectedQuestID } ?? quests.first
    }

    var readyCount: Int {
        quests.filter { $0.status == .ready || $0.status == .waitingOnUser }.count
    }

    var draftCount: Int {
        quests.filter { $0.kind == .approveDraft && $0.status != .complete }.count
    }

    var blockedCount: Int {
        quests.filter { $0.status == .waitingOnUser }.count
    }

    var inviteCount: Int {
        quests.filter { $0.kind == .calendarInvite && $0.status != .complete }.count
    }

    var completedCount: Int {
        quests.filter { $0.status == .complete }.count
    }

    func select(_ quest: Quest) {
        selectedQuestID = quest.id
    }

    func completeSelectedQuest() {
        guard let selectedQuestID,
              let index = quests.firstIndex(where: { $0.id == selectedQuestID })
        else { return }

        quests[index].status = .complete
    }

    func restoreSelectedQuestToInbox() {
        guard let selectedQuestID,
              let index = quests.firstIndex(where: { $0.id == selectedQuestID })
        else { return }

        quests[index].status = .ready
        quests[index].requiredAction = "Review why this should stay visible, then save the correction."
    }
}
