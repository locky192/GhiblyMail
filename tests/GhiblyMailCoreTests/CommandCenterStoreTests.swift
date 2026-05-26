import XCTest
@testable import GhiblyMailCore

@MainActor
final class CommandCenterStoreTests: XCTestCase {
    func testMockImportAddsProposalOnlyQuests() async {
        let store = CommandCenterStore(
            quests: [],
            agents: [],
            mockBridge: MockCodexBridge(),
            localBridge: MockCodexBridge()
        )

        await store.importTestLabel()

        XCTAssertFalse(store.quests.isEmpty)
        XCTAssertTrue(store.quests.allSatisfy { $0.sourceLabel == "ghiblymail-test" })
        XCTAssertTrue(store.auditEvents.contains { $0.status == .executed && $0.action == .readGmail })
    }

    func testApprovedQuestCreatesAuditTrail() {
        let quest = Quest(
            title: "Move cold mail",
            sender: "Sales",
            kind: .moveToDone,
            status: .ready,
            summary: "Cold outreach.",
            proposedAction: "Move to done.",
            requiredAction: "Approve.",
            threadPreview: "No relationship.",
            priority: 1,
            estimatedMinutes: 1,
            action: .moveToDone,
            sourceLabel: "ghiblymail-test",
            providerThreadID: "thread"
        )
        let store = CommandCenterStore(
            quests: [quest],
            agents: [],
            mockBridge: MockCodexBridge(),
            localBridge: MockCodexBridge()
        )

        store.performPrimaryAction()

        XCTAssertEqual(store.quests[0].status, .complete)
        XCTAssertTrue(store.auditEvents.contains { $0.status == .executed && $0.action == .moveToDone })
    }
}
