import Foundation

struct QuestEngine: Sendable {
    var allowedLabel: String = "ghiblymail-test"

    func quests(from proposals: [QuestProposal]) -> [Quest] {
        proposals.enumerated().map { index, proposal in
            Quest(
                title: proposal.title,
                sender: proposal.sender,
                kind: kind(for: proposal),
                status: .ready,
                summary: proposal.summary,
                proposedAction: proposal.proposedAction.rawValue,
                requiredAction: requiredAction(for: proposal.proposedAction),
                threadPreview: proposal.evidence.joined(separator: " "),
                priority: index + 1,
                estimatedMinutes: estimatedMinutes(for: proposal.proposedAction),
                action: proposal.proposedAction,
                risk: proposal.risk,
                sourceLabel: allowedLabel,
                providerThreadID: proposal.threadID,
                draftBody: proposal.draftBody,
                unsubscribeURL: proposal.unsubscribeURL,
                confidence: proposal.confidence,
                evidence: proposal.evidence
            )
        }
    }

    private func kind(for proposal: QuestProposal) -> QuestKind {
        switch proposal.proposedAction {
        case .createDraft:
            return .approveDraft
        case .moveToDone:
            return .moveToDone
        case .restoreFromDone:
            return .restoreToInbox
        case .queueCalendarInvite:
            return .calendarInvite
        case .manuallyUnsubscribe:
            return .mailingList
        case .provideContext:
            return .provideContext
        case .uploadAttachment:
            return .uploadAttachment
        case .checkCodex:
            return .codexSetup
        case .localProposal:
            return .triageReview
        }
    }

    private func requiredAction(for action: QuestAction) -> String {
        switch action {
        case .createDraft:
            return "Review and approve creating a Gmail draft. Nothing sends automatically."
        case .moveToDone:
            return "Approve moving this thread to done."
        case .restoreFromDone:
            return "Approve restoring this thread to the inbox."
        case .queueCalendarInvite:
            return "Review the invite queue entry."
        case .manuallyUnsubscribe:
            return "Approve a one-click unsubscribe task. No unsubscribe runs automatically."
        case .provideContext:
            return "Add the missing context."
        case .uploadAttachment:
            return "Attach the requested factual document."
        case .checkCodex:
            return "Check local Codex and Gmail plugin readiness."
        case .localProposal:
            return "Review the local AI proposal."
        }
    }

    private func estimatedMinutes(for action: QuestAction) -> Int {
        switch action {
        case .queueCalendarInvite, .moveToDone, .restoreFromDone, .manuallyUnsubscribe:
            return 1
        case .createDraft, .provideContext:
            return 3
        case .uploadAttachment:
            return 5
        case .checkCodex, .localProposal:
            return 2
        }
    }
}
