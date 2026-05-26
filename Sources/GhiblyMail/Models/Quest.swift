import Foundation

enum QuestKind: String, CaseIterable, Identifiable {
    case approveDraft = "Approve draft"
    case provideContext = "Provide context"
    case uploadAttachment = "Upload attachment"
    case calendarInvite = "Calendar invite"
    case triageReview = "Triage review"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .approveDraft: "checkmark.message"
        case .provideContext: "text.bubble"
        case .uploadAttachment: "paperclip.circle"
        case .calendarInvite: "calendar"
        case .triageReview: "slider.horizontal.3"
        }
    }
}

enum QuestStatus: String {
    case ready = "Ready"
    case waitingOnUser = "Waiting on you"
    case inProgress = "Agent working"
    case complete = "Complete"
}

struct Quest: Identifiable {
    let id: UUID
    var title: String
    var sender: String
    var kind: QuestKind
    var status: QuestStatus
    var summary: String
    var proposedAction: String
    var requiredAction: String
    var threadPreview: String
    var priority: Int
    var estimatedMinutes: Int

    init(
        id: UUID = UUID(),
        title: String,
        sender: String,
        kind: QuestKind,
        status: QuestStatus,
        summary: String,
        proposedAction: String,
        requiredAction: String,
        threadPreview: String,
        priority: Int,
        estimatedMinutes: Int
    ) {
        self.id = id
        self.title = title
        self.sender = sender
        self.kind = kind
        self.status = status
        self.summary = summary
        self.proposedAction = proposedAction
        self.requiredAction = requiredAction
        self.threadPreview = threadPreview
        self.priority = priority
        self.estimatedMinutes = estimatedMinutes
    }
}
