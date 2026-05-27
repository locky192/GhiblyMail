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
    @Published var screen: AppScreen
    @Published var questFilter: QuestFilter
    @Published var questSort: QuestSort
    @Published var dailyPlanTab: DailyPlanTab
    @Published var performanceRange: PerformanceRange
    @Published var settings: AppSettings
    @Published var lastReversibleDecision: ReversibleDecision?

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
        self.screen = .home
        self.questFilter = .all
        self.questSort = .priority
        self.dailyPlanTab = .brief
        self.performanceRange = .week
        self.settings = AppSettings()
        self.lastReversibleDecision = nil
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

    var filteredQuests: [Quest] {
        sorted(quests.filter { matchesFilter($0, filter: questFilter) })
    }

    var recommendedQuest: Quest? {
        filteredQuests.first { $0.status == .ready || $0.status == .waitingOnUser }
    }

    var safeBatchCandidates: [Quest] {
        quests.filter { quest in
            quest.status == .ready &&
            quest.risk == .low &&
            quest.confidence >= settings.lowImpactThreshold &&
            quest.action != .uploadAttachment &&
            quest.action != .provideContext
        }
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

    func navigate(_ screen: AppScreen) {
        self.screen = screen
        switch screen {
        case .questBoard(let filter):
            setQuestFilter(filter)
        case .dailyBriefPlan(let tab):
            dailyPlanTab = tab
        case .performanceAchievements(let range):
            performanceRange = range
        default:
            break
        }
    }

    func goHome() {
        screen = .home
    }

    func route(for action: HomeAction) -> AppScreen {
        switch action {
        case .profileCard, .quickBrief:
            return .dailyBriefPlan(.brief)
        case .prioritize:
            return .dailyBriefPlan(.priorities)
        case .dailyPlan:
            return .dailyBriefPlan(.plan)
        case .criticalCounter:
            return .questBoard(.critical)
        case .viewAllQuests:
            return .questBoard(.all)
        case .draftsCounter, .draftingStation:
            return .draftReview
        case .blockedCounter, .attachmentStation:
            return .attachmentRequests
        case .invitesCounter, .calendarStation:
            return .calendarInvites
        case .listsCounter:
            return .mailingListCleanup
        case .focusMode, .lofiBeats, .codexStatus, .gmailStatus, .settings, .agentStatus:
            return .settingsConnections
        case .memoryStation, .triageStation, .studioActivity:
            return .triageTuning
        case .performance, .achievements:
            return .performanceAchievements(.week)
        }
    }

    func navigateFromHome(_ action: HomeAction) {
        navigate(route(for: action))
    }

    func openFocusedTask(for quest: Quest? = nil) {
        let target = quest ?? selectedQuest ?? recommendedQuest
        guard let target else {
            navigate(.questBoard(.all))
            return
        }

        selectedQuestID = target.id
        switch target.kind {
        case .approveDraft:
            navigate(.draftReview)
        case .calendarInvite:
            navigate(.calendarInvites)
        case .uploadAttachment, .provideContext:
            navigate(.attachmentRequests)
        case .mailingList:
            navigate(.mailingListCleanup)
        case .triageReview, .moveToDone, .restoreToInbox:
            navigate(.triageTuning)
        case .codexSetup:
            navigate(.settingsConnections)
        }
    }

    func setQuestFilter(_ filter: QuestFilter) {
        questFilter = filter
        let filtered = sorted(quests.filter { matchesFilter($0, filter: filter) })
        if let selectedQuestID,
           filtered.contains(where: { $0.id == selectedQuestID }) {
            return
        }
        selectedQuestID = filtered.first?.id ?? quests.first?.id
    }

    func setSort(_ sort: QuestSort) {
        questSort = sort
        setQuestFilter(questFilter)
    }

    func setDailyPlanTab(_ tab: DailyPlanTab) {
        dailyPlanTab = tab
        screen = .dailyBriefPlan(tab)
    }

    func setPerformanceRange(_ range: PerformanceRange) {
        performanceRange = range
        screen = .performanceAchievements(range)
    }

    func resetPerformanceView() {
        performanceRange = .week
        lastOperationMessage = "Performance view reset to this week. Audit history is unchanged."
    }

    func setRuntimeMode(_ mode: RuntimeMode) {
        runtimeMode = mode
        lastOperationMessage = mode == .mock
            ? "Mock mode uses safe local proposals."
            : "Local Codex mode will still operate only on \(testLabel)."
    }

    func runSafeBatch() async {
        let candidates = safeBatchCandidates
        guard !candidates.isEmpty else {
            lastOperationMessage = "No safe batch actions are available."
            return
        }
        for quest in candidates {
            selectedQuestID = quest.id
            await performPrimaryAction()
        }
        lastOperationMessage = "Ran \(candidates.count) safe local actions."
    }

    func approveSafeDrafts() async {
        let drafts = quests.filter {
            $0.kind == .approveDraft &&
            $0.status == .ready &&
            $0.risk == .low &&
            $0.confidence >= settings.lowImpactThreshold
        }
        for quest in drafts {
            selectedQuestID = quest.id
            await approveSelectedDraft()
        }
        lastOperationMessage = drafts.isEmpty ? "No safe drafts are ready." : "Approved \(drafts.count) safe drafts."
    }

    func approveSelectedDraft() async {
        await mutateSelected(
            decision: .accepted,
            action: .createDraft,
            completed: true,
            message: "Approved draft for review-safe creation."
        )
    }

    func editSelectedDraft(body: String) {
        guard let index = selectedQuestIndex else { return }
        quests[index].draftBody = body
        quests[index].draftEdited = true
        quests[index].decisionState = .edited
        audit(.updateMemory, .executed, questID: quests[index].id, summary: "Edited local draft proposal.")
        lastOperationMessage = "Draft edit saved locally."
    }

    func requestMoreContextForSelectedDraft() {
        mutateSelectedSync(
            decision: .needsMoreContext,
            action: .updateMemory,
            status: .waitingOnUser,
            message: "Draft marked as needing more context."
        )
    }

    func skipSelectedDraft() {
        mutateSelectedSync(
            decision: .skipped,
            action: .moveToDone,
            status: .complete,
            message: "Skipped draft and removed it from active review."
        )
    }

    func acceptSelectedInvite() async {
        await mutateSelected(
            decision: .accepted,
            action: .queueCalendarInvite,
            completed: true,
            message: "Accepted recommended invite locally."
        )
    }

    func declineSelectedInvite() {
        mutateSelectedSync(
            decision: .declined,
            action: .queueCalendarInvite,
            status: .complete,
            message: "Declined selected invite locally."
        )
    }

    func proposeTimeForSelectedInvite() {
        mutateSelectedSync(
            decision: .proposedTime,
            action: .queueCalendarInvite,
            status: .waitingOnUser,
            message: "Prepared alternate-time proposal."
        )
    }

    func batchAcceptSafeInvites() async {
        let invites = quests.filter {
            $0.kind == .calendarInvite &&
            $0.status == .ready &&
            $0.risk == .low &&
            $0.confidence >= settings.lowImpactThreshold
        }
        for quest in invites {
            selectedQuestID = quest.id
            await acceptSelectedInvite()
        }
        lastOperationMessage = invites.isEmpty ? "No safe invites are ready." : "Accepted \(invites.count) safe invites."
    }

    func attachLocalFilePlaceholder(name: String) {
        guard let index = selectedQuestIndex else { return }
        rememberDecision(for: quests[index], summary: "Recorded local attachment placeholder.")
        quests[index].localAttachmentName = name
        quests[index].decisionState = .attachmentAdded
        quests[index].status = .complete
        audit(.updateMemory, .executed, questID: quests[index].id, summary: "Recorded local attachment placeholder: \(name).")
        lastOperationMessage = "Attachment placeholder recorded locally."
    }

    func draftAttachmentWithCodex() {
        mutateSelectedSync(
            decision: .codexDrafted,
            action: .updateMemory,
            status: .waitingOnUser,
            message: "Created local attachment draft placeholder for approval."
        )
    }

    func markAttachmentNotNeeded() {
        mutateSelectedSync(
            decision: .notNeeded,
            action: .moveToDone,
            status: .complete,
            message: "Marked attachment as not needed."
        )
    }

    func askSenderForAttachment() {
        mutateSelectedSync(
            decision: .senderAsked,
            action: .createDraft,
            status: .waitingOnUser,
            message: "Prepared local request draft for sender."
        )
    }

    func unsubscribeSelectedList() async {
        await mutateSelected(
            decision: .unsubscribed,
            action: .manuallyUnsubscribe,
            completed: true,
            message: "Approved manual unsubscribe task."
        )
    }

    func keepSelectedList() {
        mutateSelectedSync(
            decision: .kept,
            action: .moveToDone,
            status: .complete,
            message: "Kept mailing list and removed it from cleanup."
        )
    }

    func batchUnsubscribeSafeLists() async {
        let lists = quests.filter {
            $0.kind == .mailingList &&
            $0.status == .ready &&
            $0.confidence >= settings.mediumImpactThreshold &&
            $0.risk != .high
        }
        for quest in lists {
            selectedQuestID = quest.id
            await unsubscribeSelectedList()
        }
        lastOperationMessage = lists.isEmpty ? "No safe mailing-list cleanup actions are ready." : "Unsubscribed from \(lists.count) safe lists."
    }

    func undoLastDecision() {
        guard let decision = lastReversibleDecision,
              let index = quests.firstIndex(where: { $0.id == decision.questID })
        else {
            lastOperationMessage = "Nothing to undo."
            return
        }
        quests[index].status = decision.previousStatus
        quests[index].decisionState = decision.previousDecisionState
        selectedQuestID = decision.questID
        audit(.restoreFromDone, .executed, questID: decision.questID, summary: "Undid local decision: \(decision.summary).")
        lastReversibleDecision = nil
        lastOperationMessage = "Undid last local decision."
    }

    func markSelectedImportant() {
        guard let index = selectedQuestIndex else { return }
        quests[index].priority = min(quests[index].priority, 1)
        quests[index].decisionState = .markedImportant
        audit(.updateMemory, .executed, questID: quests[index].id, summary: "Marked triage item important.")
        lastOperationMessage = "Marked item important and updated local triage feedback."
    }

    func moveSelectedToDone() {
        mutateSelectedSync(
            decision: .accepted,
            action: .moveToDone,
            status: .complete,
            message: "Moved selected item to done."
        )
    }

    func teachRuleFromSelected() {
        guard let quest = selectedQuest else { return }
        addMemoryNote(
            title: "Rule from \(quest.kind.rawValue)",
            summary: "Prefer this handling for similar \(quest.sender) items.",
            provenance: "Triage tuning"
        )
        if let index = selectedQuestIndex {
            quests[index].decisionState = .taughtRule
        }
        lastOperationMessage = "Saved a local triage rule."
    }

    func updateSettings(_ settings: AppSettings) {
        self.settings = settings
        audit(.updateMemory, .executed, questID: nil, summary: "Saved local settings.")
        lastOperationMessage = "Settings saved locally."
    }

    func toggleAgent(role: AgentRole) {
        guard let index = agents.firstIndex(where: { $0.role == role }) else { return }
        agents[index].state = agents[index].state == .idle ? .working : .idle
        audit(.updateMemory, .executed, questID: nil, summary: "Toggled \(role.rawValue) agent.")
        lastOperationMessage = "\(role.rawValue) agent \(agents[index].state == .idle ? "paused" : "resumed")."
    }

    func pauseAllAgents() {
        for index in agents.indices {
            agents[index].state = .idle
        }
        audit(.updateMemory, .executed, questID: nil, summary: "Paused all local agents.")
        lastOperationMessage = "All agents paused locally."
    }

    func runAllAgents() async {
        await importTestLabel()
        for index in agents.indices {
            agents[index].state = .working
            agents[index].progress = min(1, max(agents[index].progress, 0.2))
        }
        lastOperationMessage = "Morning agents ran locally."
    }

    var performanceMetrics: PerformanceMetrics {
        let completed = completedCount
        let timeSaved = auditEvents.filter { $0.status == .executed }.count * 5 + completed * 3
        let denied = max(deniedAuditCount, 0)
        let totalDecisions = max(auditEvents.filter { $0.status == .executed || $0.status == .denied }.count, 1)
        let rate = Double(totalDecisions - denied) / Double(totalDecisions)
        return PerformanceMetrics(
            timeSavedMinutes: timeSaved,
            gmailTripsAvoided: completed * 2,
            questsCompleted: completed,
            safeAutomationRate: rate,
            achievements: [
                Achievement(id: "time-saver", title: "Time Saver", summary: "Save 10 hours in a week", isUnlocked: timeSaved >= 600),
                Achievement(id: "clean-inbox", title: "Clean Inbox Keeper", summary: "Maintain 95% safe automation", isUnlocked: rate >= 0.95),
                Achievement(id: "quest-conqueror", title: "Quest Conqueror", summary: "Complete 40 quests", isUnlocked: completed >= 40)
            ]
        )
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
        Task { await performPrimaryAction() }
    }

    func performPrimaryAction() async {
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

        if runtimeMode == .localCodex && requiresConnectorExecution(request.kind) {
            await executeConnectorAction(for: quest, request: request, index: index)
            return
        }

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

    private var selectedQuestIndex: Int? {
        guard let selectedQuestID else { return quests.indices.first }
        return quests.firstIndex { $0.id == selectedQuestID }
    }

    private func mutateSelected(
        decision: QuestDecisionState,
        action: ActionKind,
        completed: Bool,
        message: String
    ) async {
        guard let index = selectedQuestIndex else { return }
        selectedQuestID = quests[index].id
        rememberDecision(for: quests[index], summary: message)
        if completed {
            await performPrimaryAction()
        } else {
            quests[index].decisionState = decision
            audit(action, .executed, questID: quests[index].id, summary: message)
            lastOperationMessage = message
        }
        if let updatedIndex = selectedQuestIndex {
            quests[updatedIndex].decisionState = decision
        }
    }

    private func mutateSelectedSync(
        decision: QuestDecisionState,
        action: ActionKind,
        status: QuestStatus,
        message: String
    ) {
        guard let index = selectedQuestIndex else { return }
        rememberDecision(for: quests[index], summary: message)
        quests[index].status = status
        quests[index].decisionState = decision
        audit(action, .executed, questID: quests[index].id, summary: message)
        lastOperationMessage = message
    }

    private func rememberDecision(for quest: Quest, summary: String) {
        lastReversibleDecision = ReversibleDecision(
            questID: quest.id,
            previousStatus: quest.status,
            previousDecisionState: quest.decisionState,
            summary: summary
        )
    }

    private func audit(_ action: ActionKind, _ status: AuditStatus, questID: UUID?, summary: String) {
        auditEvents.insert(
            AuditEvent(
                action: action,
                status: status,
                questID: questID,
                summary: summary
            ),
            at: 0
        )
    }

    private func matchesFilter(_ quest: Quest, filter: QuestFilter) -> Bool {
        switch filter {
        case .all:
            return true
        case .critical:
            return quest.status != .complete && quest.priority <= 2
        case .drafts:
            return quest.kind == .approveDraft && quest.status != .complete
        case .blocked:
            return (quest.status == .waitingOnUser || quest.kind == .uploadAttachment || quest.kind == .provideContext) && quest.status != .complete
        case .invites:
            return quest.kind == .calendarInvite && quest.status != .complete
        case .lists:
            return quest.kind == .mailingList && quest.status != .complete
        case .highImpact:
            return quest.priority <= 2 && quest.status != .complete
        case .dueToday:
            return quest.dueLabel == "Today" || quest.priority <= 2
        case .waitingOnMe:
            return quest.status == .waitingOnUser
        case .snoozed:
            return quest.isSnoozed
        }
    }

    private func sorted(_ quests: [Quest]) -> [Quest] {
        switch questSort {
        case .priority:
            return quests.sorted { lhs, rhs in
                if lhs.priority == rhs.priority {
                    return lhs.estimatedMinutes < rhs.estimatedMinutes
                }
                return lhs.priority < rhs.priority
            }
        case .time:
            return quests.sorted { $0.estimatedMinutes < $1.estimatedMinutes }
        case .confidence:
            return quests.sorted { $0.confidence > $1.confidence }
        case .urgency:
            return quests.sorted {
                ($0.status == .waitingOnUser ? 0 : $0.priority) < ($1.status == .waitingOnUser ? 0 : $1.priority)
            }
        }
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

    private func requiresConnectorExecution(_ action: ActionKind) -> Bool {
        switch action {
        case .createDraft, .moveToDone, .restoreFromDone, .manuallyUnsubscribe:
            return true
        default:
            return false
        }
    }

    private func executeConnectorAction(for quest: Quest, request: ActionRequest, index: Int) async {
        isWorking = true
        quests[index].status = .inProgress
        lastOperationMessage = "Running approved \(request.kind.rawValue) through Local Codex..."

        let action = ApprovedCodexAction(
            kind: request.kind,
            providerThreadID: quest.providerThreadID,
            sourceLabel: quest.sourceLabel,
            draftBody: quest.draftBody,
            unsubscribeURL: quest.unsubscribeURL,
            summary: quest.proposedAction
        )

        do {
            let result = try await localBridge.executeApprovedAction(action)
            quests[index].status = .complete
            auditEvents.insert(
                AuditEvent(
                    action: request.kind,
                    status: .executed,
                    questID: quest.id,
                    summary: result
                ),
                at: 0
            )
            lastOperationMessage = result
        } catch {
            quests[index].status = .failed
            auditEvents.insert(
                AuditEvent(
                    action: request.kind,
                    status: .failed,
                    questID: quest.id,
                    summary: error.localizedDescription
                ),
                at: 0
            )
            lastOperationMessage = error.localizedDescription
        }

        isWorking = false
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
