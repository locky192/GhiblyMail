import XCTest
@testable import GhiblyMailCore

final class QuestEngineTests: XCTestCase {
    func testMapsProposalToDraftQuestInsideTestLabel() {
        let engine = QuestEngine(allowedLabel: "ghiblymail-test")
        let proposals = [
            QuestProposal(
                threadID: "thread-1",
                sender: "Maya",
                title: "Reply to Maya",
                summary: "Needs a concise reply.",
                category: "needs_reply",
                proposedAction: .createDraft,
                draftBody: "Draft body",
                unsubscribeURL: nil,
                risk: .medium,
                confidence: 0.8,
                evidence: ["Prior style match"]
            )
        ]

        let quests = engine.quests(from: proposals)

        XCTAssertEqual(quests.count, 1)
        XCTAssertEqual(quests[0].kind, .approveDraft)
        XCTAssertEqual(quests[0].action, .createDraft)
        XCTAssertEqual(quests[0].sourceLabel, "ghiblymail-test")
        XCTAssertEqual(quests[0].providerThreadID, "thread-1")
    }

    func testMapsMailingListProposalToManualUnsubscribeQuest() {
        let engine = QuestEngine()
        let proposals = [
            QuestProposal(
                threadID: "thread-list",
                sender: "Newsletter",
                title: "Unsubscribe",
                summary: "Recurring list.",
                category: "mailing_list",
                proposedAction: .manuallyUnsubscribe,
                draftBody: nil,
                unsubscribeURL: URL(string: "https://example.com/unsubscribe"),
                risk: .medium,
                confidence: 0.9,
                evidence: []
            )
        ]

        let quest = engine.quests(from: proposals)[0]

        XCTAssertEqual(quest.kind, .mailingList)
        XCTAssertEqual(quest.action, .manuallyUnsubscribe)
        XCTAssertEqual(quest.unsubscribeURL?.host(), "example.com")
    }
}
