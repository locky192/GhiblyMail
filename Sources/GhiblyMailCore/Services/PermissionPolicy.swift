import Foundation

struct PermissionPolicy: Sendable {
    var allowedLabel: String = "ghiblymail-test"

    func evaluate(_ request: ActionRequest) -> PermissionDecision {
        switch request.kind {
        case .sendEmail:
            return .denied("Sending email is outside the MVP permission boundary.")
        case .autoUnsubscribe:
            return .denied("Auto-unsubscribe is disabled. Unsubscribe tasks require manual approval.")
        case .operateOutsideTestLabel:
            return .denied("The MVP may only operate inside the \(allowedLabel) label.")
        case .readGmail:
            return request.sourceLabel == allowedLabel
                ? .allowed
                : .denied("Gmail reads are limited to the \(allowedLabel) label.")
        case .queueCalendarInvite, .updateMemory:
            return .allowed
        case .createDraft, .moveToDone, .restoreFromDone, .manuallyUnsubscribe:
            guard request.sourceLabel == allowedLabel || request.sourceLabel == "mock" else {
                return .denied("Gmail writes are limited to the \(allowedLabel) label.")
            }
            guard request.userApproved else {
                return .denied("This action requires explicit user approval.")
            }
            return .allowed
        }
    }
}
