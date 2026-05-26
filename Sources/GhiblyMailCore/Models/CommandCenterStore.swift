import Combine
import Foundation

@MainActor
public final class CommandCenterStore: ObservableObject {
    @Published var quests: [Quest]
    @Published var agents: [Agent]
    @Published var selectedQuestID: Quest.ID?
    @Published var runtimeMode: RuntimeMode
    @Published var testLabel: String
    @Published var readiness: CodexReadiness
    @Published var auditEvents: [AuditEvent]
    @Published var memoryEntries: [MemoryEntry]
    @Published var lastOperationMessage: String
    @Published var isWorking: Bool

    private let mockBridge: any CodexBridge
    private let localBridge: any CodexBridge
    private var permissionPolicy: PermissionPolicy
    private var questEngine: QuestEngine
    private var promptGuard: PromptInjectionGuard
    private var memoryStore: MemoryStore

    public convenience init() {
        self.init(
            quests: MockData.quests,
            agents: MockData.agents,
            mockBridge: MockCodexBridge(),
            localBridge: LocalCodexBridge()
        )
    }

    init(
        quests: [Quest],
        agents: [Agent],
        mockBridge: any CodexBridge = MockCodexBridge(),
        localBridge: any CodexBridge = MockCodexBridge(),
        testLabel: String = "ghiblymail-test"
    ) {
        self.quests = quests
        self.agents = agents
        self.selectedQuestID = quests.first?.id
        self.runtimeMode = .mock
        self.testLabel = testLabel
        self.readiness = .unknown
        self.auditEvents = MockData.auditEvents
        self.memoryEntries = MockData.memoryEntries
        self.lastOperationMessage = "Mock command center ready."
        self.isWorking = false
        self.mockBridge = mockBridge
        self.localBridge = localBridge
        self.permissionPolicy = PermissionPolicy(allowedLabel: testLabel)
        self.questEngine = QuestEngine(allowedLabel: testLabel)
        self.promptGuard = PromptInjectionGuard()
        self.memoryStore = MemoryStore(entries: MockData.memoryEntries)
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

    var mailingListCount: Int {
        quests.filter { $0.kind == .mailingList && $0.status != .complete }.count
    }

    var completedCount: Int {
        quests.filter { $0.status == .complete }.count
    }

    var deniedAuditCount: Int {
        auditEvents.filter { $0.status == .denied }.count
    }

    func select(_ quest: Quest) {
        selectedQuestID = quest.id
    }

    func setRuntimeMode(_ mode: RuntimeMode) {
        runtimeMode = mode
        lastOperationMessage = mode == .mock
            ? "Mock mode uses safe local proposals."
            : "Local Codex mode will still operate only on \(testLabel)."
    }

    func checkCodexReadiness() async {
        isWorking = true
        lastOperationMessage = "Checking local Codex and Gmail plugin..."
        let result = await localBridge.checkReadiness()
        readiness = result
        auditEvents.insert(
            AuditEvent(
                action: .readGmail,
                status: result.isReadyForGmailRead ? .allowed : .failed,
                questID: nil,
                summary: result.summary
            ),
            at: 0
        )
        lastOperationMessage = result.summary
        isWorking = false
    }

    func importTestLabel() async {
        let request = ActionRequest(
            kind: .readGmail,
            questID: nil,
            providerThreadID: nil,
            sourceLabel: testLabel,
            userApproved: true,
            summary: "Read Gmail label \(testLabel) and return proposal-only quests."
        )
        guard allow(request) else { return }

        isWorking = true
        lastOperationMessage = "Importing proposal-only quests from \(testLabel)..."
        do {
            let bridge = runtimeMode == .mock ? mockBridge : localBridge
            let proposals = try await bridge.importQuestProposals(label: testLabel)
            let imported = questEngine.quests(from: sanitize(proposals))
            quests.removeAll { $0.sourceLabel == testLabel }
            quests.insert(contentsOf: imported, at: 0)
            selectedQuestID = imported.first?.id ?? selectedQuestID
            auditEvents.insert(
                AuditEvent(
                    action: .readGmail,
                    status: .executed,
                    questID: nil,
                    summary: "Imported \(imported.count) proposal-only quests from \(testLabel)."
                ),
                at: 0
            )
            lastOperationMessage = "Imported \(imported.count) proposal-only quests from \(testLabel)."
        } catch {
            auditEvents.insert(
                AuditEvent(
                    action: .readGmail,
                    status: .failed,
                    questID: nil,
                    summary: error.localizedDescription
                ),
                at: 0
            )
            lastOperationMessage = error.localizedDescription
        }
        isWorking = false
    }

    func completeSelectedQuest() {
        performPrimaryAction()
    }

    func performPrimaryAction() {
        guard let selectedQuestID,
              let index = quests.firstIndex(where: { $0.id == selectedQuestID })
        else { return }

        let quest = quests[index]
        let request = ActionRequest(
            kind: actionKind(for: quest.action),
            questID: quest.id,
            providerThreadID: quest.providerThreadID,
            sourceLabel: quest.sourceLabel,
            userApproved: true,
            summary: quest.proposedAction
        )

        guard allow(request) else { return }

        quests[index].status = .complete
        auditEvents.insert(
            AuditEvent(
                action: request.kind,
                status: .executed,
                questID: quest.id,
                summary: "Completed approved quest: \(quest.title)."
            ),
            at: 0
        )
        lastOperationMessage = completionMessage(for: quest)
    }

    func restoreSelectedQuestToInbox() {
        guard let selectedQuestID,
              let index = quests.firstIndex(where: { $0.id == selectedQuestID })
        else { return }

        let quest = quests[index]
        let request = ActionRequest(
            kind: .restoreFromDone,
            questID: quest.id,
            providerThreadID: quest.providerThreadID,
            sourceLabel: quest.sourceLabel,
            userApproved: true,
            summary: "Restore \(quest.title) to inbox."
        )

        guard allow(request) else { return }

        quests[index].status = .ready
        quests[index].requiredAction = "Review why this should stay visible, then save the correction."
        auditEvents.insert(
            AuditEvent(
                action: .restoreFromDone,
                status: .executed,
                questID: quest.id,
                summary: "Restored quest to visible queue: \(quest.title)."
            ),
            at: 0
        )
        lastOperationMessage = "Restored \(quest.title) to the visible queue."
    }

    func addMemoryNote(title: String, summary: String, provenance: String) {
        let entry = MemoryEntry(
            kind: .preference,
            title: title,
            summary: summary,
            provenance: provenance,
            userConfirmed: true
        )
        memoryStore.add(entry)
        memoryEntries = memoryStore.entries
        auditEvents.insert(
            AuditEvent(
                action: .updateMemory,
                status: .executed,
                questID: nil,
                summary: "Added user-confirmed memory note: \(title)."
            ),
            at: 0
        )
    }

    private func allow(_ request: ActionRequest) -> Bool {
        auditEvents.insert(
            AuditEvent(
                action: request.kind,
                status: .proposed,
                questID: request.questID,
                summary: request.summary
            ),
            at: 0
        )

        let decision = permissionPolicy.evaluate(request)
        auditEvents.insert(
            AuditEvent(
                action: request.kind,
                status: decision.isAllowed ? .allowed : .denied,
                questID: request.questID,
                summary: decision.message
            ),
            at: 0
        )
        if !decision.isAllowed {
            lastOperationMessage = decision.message
        }
        return decision.isAllowed
    }

    private func actionKind(for action: QuestAction) -> ActionKind {
        switch action {
        case .createDraft:
            return .createDraft
        case .moveToDone:
            return .moveToDone
        case .restoreFromDone:
            return .restoreFromDone
        case .queueCalendarInvite:
            return .queueCalendarInvite
        case .manuallyUnsubscribe:
            return .manuallyUnsubscribe
        case .checkCodex, .localProposal:
            return .readGmail
        case .provideContext, .uploadAttachment:
            return .updateMemory
        }
    }

    private func completionMessage(for quest: Quest) -> String {
        switch quest.action {
        case .createDraft:
            return "Approved draft creation for \(quest.title). Sending remains disabled."
        case .moveToDone:
            return "Approved moving \(quest.title) to done."
        case .restoreFromDone:
            return "Approved restoring \(quest.title)."
        case .queueCalendarInvite:
            return "Calendar invite queued for review."
        case .manuallyUnsubscribe:
            return "Approved manual unsubscribe task for \(quest.title)."
        case .provideContext:
            return "Context captured locally."
        case .uploadAttachment:
            return "Attachment task marked handled."
        case .checkCodex:
            return "Codex setup quest handled."
        case .localProposal:
            return "Local proposal reviewed."
        }
    }

    private func sanitize(_ proposals: [QuestProposal]) -> [QuestProposal] {
        proposals.map { proposal in
            var copy = proposal
            let scanText = [
                proposal.title,
                proposal.summary,
                proposal.draftBody ?? "",
                proposal.evidence.joined(separator: " ")
            ].joined(separator: "\n")
            let report = promptGuard.scan(scanText)
            if report.isSuspicious {
                copy.risk = .high
                copy.confidence = min(copy.confidence, 0.35)
                copy.evidence += report.findings.map { "Prompt-injection guard: \($0)" }
            }
            return copy
        }
    }
}
