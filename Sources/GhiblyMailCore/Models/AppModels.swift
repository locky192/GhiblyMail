import Foundation

enum RuntimeMode: String, CaseIterable, Identifiable, Sendable {
    case mock = "Mock"
    case localCodex = "Local Codex"

    var id: String { rawValue }
}

enum AppScreen: Equatable, Sendable {
    case home
    case questBoard(QuestFilter = .all)
    case draftReview
    case calendarInvites
    case attachmentRequests
    case mailingListCleanup
    case triageTuning
    case dailyBriefPlan(DailyPlanTab = .brief)
    case settingsConnections
    case performanceAchievements(PerformanceRange = .week)
}

enum HomeAction: String, CaseIterable, Sendable {
    case profileCard
    case criticalCounter
    case draftsCounter
    case blockedCounter
    case invitesCounter
    case listsCounter
    case focusMode
    case lofiBeats
    case codexStatus
    case gmailStatus
    case settings
    case memoryStation
    case triageStation
    case calendarStation
    case draftingStation
    case attachmentStation
    case studioActivity
    case agentStatus
    case quickBrief
    case prioritize
    case dailyPlan
    case performance
    case achievements
    case viewAllQuests
}

enum QuestFilter: String, CaseIterable, Identifiable, Codable, Sendable {
    case all
    case critical
    case drafts
    case blocked
    case invites
    case lists
    case highImpact
    case dueToday
    case waitingOnMe
    case snoozed

    var id: String { rawValue }
}

enum QuestSort: String, CaseIterable, Identifiable, Codable, Sendable {
    case priority
    case time
    case confidence
    case urgency

    var id: String { rawValue }
}

enum DailyPlanTab: String, CaseIterable, Identifiable, Codable, Sendable {
    case brief
    case priorities
    case plan

    var id: String { rawValue }
}

enum PerformanceRange: String, CaseIterable, Identifiable, Codable, Sendable {
    case today
    case week
    case month

    var id: String { rawValue }
}

enum SafetyMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case relaxed
    case balanced
    case strict

    var id: String { rawValue }
}

enum QuestDecisionState: String, Codable, Equatable, Sendable {
    case none
    case edited
    case skipped
    case needsMoreContext
    case accepted
    case declined
    case proposedTime
    case attachmentAdded
    case codexDrafted
    case notNeeded
    case senderAsked
    case unsubscribed
    case kept
    case markedImportant
    case taughtRule
}

struct AppSettings: Codable, Equatable, Sendable {
    var focusModeEnabled: Bool = true
    var lofiBeatsEnabled: Bool = true
    var musicVolume: Double = 0.6
    var focusWindowMinutes: Int = 60
    var safetyMode: SafetyMode = .balanced
    var autoApproveSafeActions: Bool = false
    var lowImpactThreshold: Double = 0.80
    var mediumImpactThreshold: Double = 0.90
    var highImpactThreshold: Double = 0.95
}

struct PerformanceMetrics: Equatable, Sendable {
    var timeSavedMinutes: Int
    var gmailTripsAvoided: Int
    var questsCompleted: Int
    var safeAutomationRate: Double
    var achievements: [Achievement]

    static let empty = PerformanceMetrics(
        timeSavedMinutes: 0,
        gmailTripsAvoided: 0,
        questsCompleted: 0,
        safeAutomationRate: 1,
        achievements: []
    )
}

struct Achievement: Identifiable, Equatable, Sendable {
    var id: String
    var title: String
    var summary: String
    var isUnlocked: Bool
}

struct ReversibleDecision: Equatable, Sendable {
    var questID: UUID
    var previousStatus: QuestStatus
    var previousDecisionState: QuestDecisionState
    var summary: String
}

enum ActionKind: String, Codable, CaseIterable, Sendable {
    case readGmail
    case createDraft
    case moveToDone
    case restoreFromDone
    case queueCalendarInvite
    case manuallyUnsubscribe
    case sendEmail
    case autoUnsubscribe
    case operateOutsideTestLabel
    case updateMemory
}

struct ActionRequest: Codable, Equatable, Sendable {
    var kind: ActionKind
    var questID: UUID?
    var providerThreadID: String?
    var sourceLabel: String
    var userApproved: Bool
    var summary: String
}

enum PermissionDecision: Equatable, Sendable {
    case allowed
    case denied(String)

    var isAllowed: Bool {
        if case .allowed = self {
            return true
        }
        return false
    }

    var message: String {
        switch self {
        case .allowed:
            return "Allowed"
        case .denied(let reason):
            return reason
        }
    }
}

enum AuditStatus: String, Codable, Sendable {
    case proposed
    case allowed
    case denied
    case executed
    case failed
}

struct AuditEvent: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var timestamp: Date
    var action: ActionKind
    var status: AuditStatus
    var questID: UUID?
    var summary: String

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        action: ActionKind,
        status: AuditStatus,
        questID: UUID?,
        summary: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.action = action
        self.status = status
        self.questID = questID
        self.summary = AuditEvent.sanitize(summary)
    }

    static func sanitize(_ value: String) -> String {
        let emailPattern = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
        let apiKeyPattern = #"sk-[A-Za-z0-9_-]{20,}"#
        var result = value.replacingOccurrences(
            of: emailPattern,
            with: "[email-redacted]",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: apiKeyPattern,
            with: "[secret-redacted]",
            options: .regularExpression
        )
        return String(result.prefix(260))
    }
}

struct MemoryEntry: Identifiable, Codable, Equatable, Sendable {
    enum Kind: String, Codable, CaseIterable, Sendable {
        case style
        case contact
        case company
        case preference
    }

    var id: UUID
    var kind: Kind
    var title: String
    var summary: String
    var provenance: String
    var userConfirmed: Bool

    init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        summary: String,
        provenance: String,
        userConfirmed: Bool
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.summary = summary
        self.provenance = provenance
        self.userConfirmed = userConfirmed
    }
}

struct CodexReadiness: Codable, Equatable, Sendable {
    var codexInstalled: Bool
    var codexVersion: String?
    var loggedIn: Bool
    var planType: String?
    var gmailPluginInstalled: Bool
    var gmailPluginEnabled: Bool
    var checkedAt: Date?
    var issues: [String]

    static let unknown = CodexReadiness(
        codexInstalled: false,
        codexVersion: nil,
        loggedIn: false,
        planType: nil,
        gmailPluginInstalled: false,
        gmailPluginEnabled: false,
        checkedAt: nil,
        issues: ["Codex readiness has not been checked."]
    )

    var isReadyForGmailRead: Bool {
        codexInstalled && loggedIn && gmailPluginInstalled && gmailPluginEnabled
    }

    var summary: String {
        if isReadyForGmailRead {
            return "Codex and Gmail plugin are ready."
        }
        return issues.joined(separator: " ")
    }
}

struct QuestProposal: Codable, Equatable, Sendable {
    var threadID: String
    var sender: String
    var title: String
    var summary: String
    var category: String
    var proposedAction: QuestAction
    var draftBody: String?
    var unsubscribeURL: URL?
    var risk: QuestRisk
    var confidence: Double
    var evidence: [String]
}

struct ApprovedCodexAction: Codable, Equatable, Sendable {
    var kind: ActionKind
    var providerThreadID: String?
    var sourceLabel: String
    var draftBody: String?
    var unsubscribeURL: URL?
    var summary: String
}
