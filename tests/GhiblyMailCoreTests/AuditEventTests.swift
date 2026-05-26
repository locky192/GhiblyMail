import XCTest
@testable import GhiblyMailCore

final class AuditEventTests: XCTestCase {
    func testSanitizesEmailsAndSecrets() {
        let fakeSecret = "sk-" + String(repeating: "a", count: 32)
        let event = AuditEvent(
            action: .createDraft,
            status: .proposed,
            questID: nil,
            summary: "Draft to person@example.com with \(fakeSecret)"
        )

        XCTAssertFalse(event.summary.contains("person@example.com"))
        XCTAssertFalse(event.summary.contains(fakeSecret))
        XCTAssertTrue(event.summary.contains("[email-redacted]"))
        XCTAssertTrue(event.summary.contains("[secret-redacted]"))
    }
}
