import XCTest
@testable import GhiblyMailCore

@MainActor
final class MVPFeatureWorkflowTests: XCTestCase {
    func testAllHomeActionsRouteToFiniteScreens() {
        let store = makeStore()

        for action in HomeAction.allCases {
            let route = store.route(for: action)
            switch route {
            case .home:
                XCTFail("Home actions should open a defined destination, not no-op to home.")
            default:
                XCTAssertTrue(true)
            }
        }

        XCTAssertEqual(store.route(for: .viewAllQuests), .questBoard(.all))
        XCTAssertEqual(store.route(for: .draftsCounter), .draftReview)
        XCTAssertEqual(store.route(for: .settings), .settingsConnections)
    }

    func testQuestBoardFiltersAndFocusedRoutesByQuestKind() {
        let store = makeStore()

        store.setQuestFilter(.drafts)
        XCTAssertEqual(store.filteredQuests.map(\.kind), [.approveDraft])

        store.setQuestFilter(.blocked)
        XCTAssertTrue(store.filteredQuests.allSatisfy { $0.status == .waitingOnUser || $0.kind == .uploadAttachment || $0.kind == .provideContext })

        store.select(requiredQuest(kind: .calendarInvite, in: store))
        store.openFocusedTask()
        XCTAssertEqual(store.screen, .calendarInvites)

        store.select(requiredQuest(kind: .mailingList, in: store))
        store.openFocusedTask()
        XCTAssertEqual(store.screen, .mailingListCleanup)
    }

    func testRunSafeBatchCompletesOnlyLowRiskReadyQuestsAndAuditsEachAction() async {
        let store = makeStore()
        let highRiskID = requiredQuest(kind: .uploadAttachment, in: store).id

        await store.runSafeBatch()

        XCTAssertEqual(store.quests.first { $0.id == highRiskID }?.status, .waitingOnUser)
        XCTAssertTrue(store.quests.contains { $0.risk == .low && $0.status == .complete })
        XCTAssertTrue(store.auditEvents.contains { $0.status == .executed })
    }

    func testDraftReviewActionsUpdateDraftState() async {
        let store = makeStore()
        store.select(requiredQuest(kind: .approveDraft, in: store))

        store.editSelectedDraft(body: "Edited locally")
        XCTAssertEqual(store.selectedQuest?.draftBody, "Edited locally")
        XCTAssertEqual(store.selectedQuest?.decisionState, .edited)

        store.requestMoreContextForSelectedDraft()
        XCTAssertEqual(store.selectedQuest?.status, .waitingOnUser)
        XCTAssertEqual(store.selectedQuest?.decisionState, .needsMoreContext)

        await store.approveSelectedDraft()
        XCTAssertEqual(store.selectedQuest?.status, .complete)
        XCTAssertEqual(store.selectedQuest?.decisionState, .accepted)
    }

    func testCalendarInviteActionsAndBatchSafety() async {
        let store = makeStore()
        store.select(requiredQuest(kind: .calendarInvite, in: store))

        store.proposeTimeForSelectedInvite()
        XCTAssertEqual(store.selectedQuest?.decisionState, .proposedTime)
        XCTAssertEqual(store.selectedQuest?.status, .waitingOnUser)

        store.quests[store.quests.firstIndex { $0.kind == .calendarInvite }!].status = .ready
        await store.batchAcceptSafeInvites()
        XCTAssertEqual(store.selectedQuest?.decisionState, .accepted)
        XCTAssertEqual(store.selectedQuest?.status, .complete)
    }

    func testAttachmentActionsStayLocalAndAudited() {
        let store = makeStore()
        store.select(requiredQuest(kind: .uploadAttachment, in: store))

        store.attachLocalFilePlaceholder(name: "statement.pdf")

        XCTAssertEqual(store.selectedQuest?.localAttachmentName, "statement.pdf")
        XCTAssertEqual(store.selectedQuest?.decisionState, .attachmentAdded)
        XCTAssertTrue(store.auditEvents.contains { $0.summary.contains("statement.pdf") })

        store.undoLastDecision()
        XCTAssertEqual(store.selectedQuest?.status, .waitingOnUser)
    }

    func testMailingListDecisionsAndUndo() async {
        let store = makeStore()
        store.select(requiredQuest(kind: .mailingList, in: store))

        store.keepSelectedList()
        XCTAssertEqual(store.selectedQuest?.decisionState, .kept)
        XCTAssertEqual(store.selectedQuest?.status, .complete)

        store.undoLastDecision()
        XCTAssertEqual(store.selectedQuest?.status, .ready)
        XCTAssertEqual(store.selectedQuest?.decisionState, QuestDecisionState.none)

        await store.unsubscribeSelectedList()
        XCTAssertEqual(store.selectedQuest?.decisionState, .unsubscribed)
        XCTAssertEqual(store.selectedQuest?.status, .complete)
    }

    func testTriageTuningActionsUpdatePriorityMemoryAndAudit() {
        let store = makeStore()
        store.select(requiredQuest(kind: .triageReview, in: store))

        store.markSelectedImportant()
        XCTAssertEqual(store.selectedQuest?.priority, 1)
        XCTAssertEqual(store.selectedQuest?.decisionState, .markedImportant)

        let memoryCount = store.memoryEntries.count
        store.teachRuleFromSelected()
        XCTAssertEqual(store.memoryEntries.count, memoryCount + 1)
        XCTAssertEqual(store.selectedQuest?.decisionState, .taughtRule)

        store.moveSelectedToDone()
        XCTAssertEqual(store.selectedQuest?.status, .complete)
    }

    func testDailyBriefAndSettingsActionsAreInlineLocalState() async {
        let store = makeStore()

        store.setDailyPlanTab(.plan)
        XCTAssertEqual(store.screen, .dailyBriefPlan(.plan))

        var settings = store.settings
        settings.focusModeEnabled = false
        settings.musicVolume = 0.25
        store.updateSettings(settings)

        XCTAssertFalse(store.settings.focusModeEnabled)
        XCTAssertEqual(store.settings.musicVolume, 0.25)

        store.pauseAllAgents()
        XCTAssertTrue(store.agents.allSatisfy { $0.state == .idle })

        await store.runAllAgents()
        XCTAssertTrue(store.auditEvents.contains { $0.action == .readGmail })
    }

    func testPerformanceMetricsUpdateAndResetDoesNotDeleteAudit() async {
        let store = makeStore()
        let originalAuditCount = store.auditEvents.count

        store.setPerformanceRange(.month)
        XCTAssertEqual(store.screen, .performanceAchievements(.month))

        await store.runSafeBatch()
        let metrics = store.performanceMetrics

        XCTAssertGreaterThan(metrics.questsCompleted, 0)
        XCTAssertGreaterThan(metrics.timeSavedMinutes, 0)

        store.resetPerformanceView()
        XCTAssertEqual(store.performanceRange, .week)
        XCTAssertGreaterThanOrEqual(store.auditEvents.count, originalAuditCount)
    }

    private func makeStore() -> CommandCenterStore {
        CommandCenterStore(
            quests: [
                quest(kind: .approveDraft, action: .createDraft, risk: .low, confidence: 0.95, priority: 2, draftBody: "Draft"),
                quest(kind: .calendarInvite, action: .queueCalendarInvite, risk: .low, confidence: 0.95, priority: 2),
                quest(kind: .uploadAttachment, status: .waitingOnUser, action: .uploadAttachment, risk: .high, confidence: 0.7, priority: 1),
                quest(kind: .mailingList, action: .manuallyUnsubscribe, risk: .medium, confidence: 0.94, priority: 5),
                quest(kind: .triageReview, action: .moveToDone, risk: .low, confidence: 0.82, priority: 4)
            ],
            agents: MockData.agents,
            mockBridge: MockCodexBridge(),
            localBridge: MockCodexBridge()
        )
    }

    private func requiredQuest(kind: QuestKind, in store: CommandCenterStore) -> Quest {
        guard let quest = store.quests.first(where: { $0.kind == kind }) else {
            XCTFail("Missing quest kind \(kind)")
            return store.quests[0]
        }
        return quest
    }

    private func quest(
        kind: QuestKind,
        status: QuestStatus = .ready,
        action: QuestAction,
        risk: QuestRisk,
        confidence: Double,
        priority: Int,
        draftBody: String? = nil
    ) -> Quest {
        Quest(
            title: "\(kind.rawValue) quest",
            sender: "Local fixture",
            kind: kind,
            status: status,
            summary: "Fixture summary",
            proposedAction: "Fixture proposed action",
            requiredAction: "Fixture required action",
            threadPreview: "Fixture preview",
            priority: priority,
            estimatedMinutes: 2,
            action: action,
            risk: risk,
            sourceLabel: "ghiblymail-test",
            providerThreadID: UUID().uuidString,
            draftBody: draftBody,
            confidence: confidence,
            dueLabel: priority <= 2 ? "Today" : nil
        )
    }
}
