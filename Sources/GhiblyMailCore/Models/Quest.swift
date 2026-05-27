import Foundation

enum QuestKind: String, CaseIterable, Identifiable, Codable, Sendable {
    case approveDraft = "Approve draft"
    case provideContext = "Provide context"
    case uploadAttachment = "Upload attachment"
    case calendarInvite = "Calendar invite"
    case triageReview = "Triage review"
    case moveToDone = "Move to done"
    case restoreToInbox = "Restore"
    case mailingList = "Mailing list"
    case codexSetup = "Codex setup"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .approveDraft: "checkmark.message"
        case .provideContext: "text.bubble"
        case .uploadAttachment: "paperclip.circle"
        case .calendarInvite: "calendar"
        case .triageReview: "slider.horizontal.3"
        case .moveToDone: "tray.and.arrow.down"
        case .restoreToInbox: "arrow.uturn.left.circle"
        case .mailingList: "envelope.badge"
        case .codexSetup: "externaldrive.connected.to.line.below"
        }
    }
}

enum QuestStatus: String, Codable, Sendable {
    case ready = "Ready"
    case waitingOnUser = "Waiting on you"
    case inProgress = "Agent working"
    case complete = "Complete"
    case failed = "Failed"
}

enum QuestRisk: String, Codable, CaseIterable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum QuestAction: String, Codable, CaseIterable, Sendable {
    case localProposal
    case createDraft
    case moveToDone
    case restoreFromDone
    case queueCalendarInvite
    case manuallyUnsubscribe
    case provideContext
    case uploadAttachment
    case checkCodex
}

struct Quest: Identifiable, Codable, Equatable, Sendable {
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
    var action: QuestAction
    var risk: QuestRisk
    var sourceLabel: String
    var providerThreadID: String?
    var draftBody: String?
    var unsubscribeURL: URL?
    var confidence: Double
    var evidence: [String]
    var dueLabel: String?
    var decisionState: QuestDecisionState
    var localAttachmentName: String?
    var draftEdited: Bool
    var isSnoozed: Bool
    var categoryTags: [String]

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
        estimatedMinutes: Int,
        action: QuestAction = .localProposal,
        risk: QuestRisk = .low,
        sourceLabel: String = "mock",
        providerThreadID: String? = nil,
        draftBody: String? = nil,
        unsubscribeURL: URL? = nil,
        confidence: Double = 0.8,
        evidence: [String] = [],
        dueLabel: String? = nil,
        decisionState: QuestDecisionState = .none,
        localAttachmentName: String? = nil,
        draftEdited: Bool = false,
        isSnoozed: Bool = false,
        categoryTags: [String] = []
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
        self.action = action
        self.risk = risk
        self.sourceLabel = sourceLabel
        self.providerThreadID = providerThreadID
        self.draftBody = draftBody
        self.unsubscribeURL = unsubscribeURL
        self.confidence = confidence
        self.evidence = evidence
        self.dueLabel = dueLabel
        self.decisionState = decisionState
        self.localAttachmentName = localAttachmentName
        self.draftEdited = draftEdited
        self.isSnoozed = isSnoozed
        self.categoryTags = categoryTags
    }
}
