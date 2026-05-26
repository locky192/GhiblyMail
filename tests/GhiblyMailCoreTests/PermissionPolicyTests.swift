import XCTest
@testable import GhiblyMailCore

final class PermissionPolicyTests: XCTestCase {
    func testSendIsAlwaysDeniedInMVP() {
        let policy = PermissionPolicy(allowedLabel: "ghiblymail-test")
        let request = ActionRequest(
            kind: .sendEmail,
            questID: nil,
            providerThreadID: "thread",
            sourceLabel: "ghiblymail-test",
            userApproved: true,
            summary: "send"
        )

        XCTAssertFalse(policy.evaluate(request).isAllowed)
    }

    func testReadIsLimitedToTestLabel() {
        let policy = PermissionPolicy(allowedLabel: "ghiblymail-test")
        let allowed = ActionRequest(
            kind: .readGmail,
            questID: nil,
            providerThreadID: nil,
            sourceLabel: "ghiblymail-test",
            userApproved: true,
            summary: "read safe label"
        )
        let denied = ActionRequest(
            kind: .readGmail,
            questID: nil,
            providerThreadID: nil,
            sourceLabel: "inbox",
            userApproved: true,
            summary: "read inbox"
        )

        XCTAssertTrue(policy.evaluate(allowed).isAllowed)
        XCTAssertFalse(policy.evaluate(denied).isAllowed)
    }

    func testWriteActionsRequireApproval() {
        let policy = PermissionPolicy(allowedLabel: "ghiblymail-test")
        let unapproved = ActionRequest(
            kind: .createDraft,
            questID: UUID(),
            providerThreadID: "thread",
            sourceLabel: "ghiblymail-test",
            userApproved: false,
            summary: "draft"
        )
        let approved = ActionRequest(
            kind: .createDraft,
            questID: UUID(),
            providerThreadID: "thread",
            sourceLabel: "ghiblymail-test",
            userApproved: true,
            summary: "draft"
        )

        XCTAssertFalse(policy.evaluate(unapproved).isAllowed)
        XCTAssertTrue(policy.evaluate(approved).isAllowed)
    }

    func testAutoUnsubscribeDenied() {
        let policy = PermissionPolicy()
        let request = ActionRequest(
            kind: .autoUnsubscribe,
            questID: UUID(),
            providerThreadID: "thread",
            sourceLabel: "ghiblymail-test",
            userApproved: true,
            summary: "auto unsubscribe"
        )

        XCTAssertFalse(policy.evaluate(request).isAllowed)
    }
}
