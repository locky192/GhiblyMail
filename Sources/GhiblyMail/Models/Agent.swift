import Foundation

enum AgentRole: String, CaseIterable, Identifiable {
    case triage = "Triage"
    case drafting = "Drafting"
    case calendar = "Calendar"
    case memory = "Memory"
    case attachments = "Attachments"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .triage: "tray.full"
        case .drafting: "pencil.and.outline"
        case .calendar: "calendar.badge.clock"
        case .memory: "person.crop.rectangle.stack"
        case .attachments: "paperclip"
        }
    }
}

enum AgentState: String {
    case working = "Working"
    case waiting = "Waiting"
    case needsReview = "Needs review"
    case idle = "Idle"
}

struct Agent: Identifiable {
    let id: UUID
    var name: String
    var role: AgentRole
    var state: AgentState
    var currentTask: String
    var progress: Double

    init(
        id: UUID = UUID(),
        name: String,
        role: AgentRole,
        state: AgentState,
        currentTask: String,
        progress: Double
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.state = state
        self.currentTask = currentTask
        self.progress = progress
    }
}
