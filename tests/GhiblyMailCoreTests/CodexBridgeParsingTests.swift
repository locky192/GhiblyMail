import XCTest
@testable import GhiblyMailCore

final class CodexBridgeParsingTests: XCTestCase {
    func testDecodesQuestJSONWrappedInText() throws {
        let text = """
        Here is the JSON:
        {"quests":[{"threadID":"abc","sender":"A","title":"T","summary":"S","category":"needs_reply","proposedAction":"createDraft","draftBody":"Hi","unsubscribeURL":null,"risk":"Low","confidence":0.7,"evidence":["e"]}]}
        """

        let proposals = try LocalCodexBridge.decodeQuestProposals(from: text)

        XCTAssertEqual(proposals.count, 1)
        XCTAssertEqual(proposals[0].threadID, "abc")
        XCTAssertEqual(proposals[0].proposedAction, .createDraft)
    }

    func testDecodesEmptyQuestArrayForMissingLabel() throws {
        let proposals = try LocalCodexBridge.decodeQuestProposals(from: #"{"quests":[]}"#)

        XCTAssertEqual(proposals, [])
    }
}
