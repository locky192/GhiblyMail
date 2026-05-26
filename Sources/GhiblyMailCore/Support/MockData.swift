import Foundation

enum MockData {
    static let agents: [Agent] = [
        Agent(
            name: "Mika",
            role: .triage,
            state: .working,
            currentTask: "Sorting cold outreach into done",
            progress: 0.72
        ),
        Agent(
            name: "Ren",
            role: .drafting,
            state: .needsReview,
            currentTask: "Draft ready for partner reply",
            progress: 1.0
        ),
        Agent(
            name: "Aya",
            role: .calendar,
            state: .waiting,
            currentTask: "Two invites need yes or no",
            progress: 0.45
        ),
        Agent(
            name: "Sol",
            role: .memory,
            state: .working,
            currentTask: "Indexing past sent threads",
            progress: 0.38
        ),
        Agent(
            name: "Nori",
            role: .attachments,
            state: .waiting,
            currentTask: "Waiting for bank statement upload",
            progress: 0.2
        )
    ]

    static let quests: [Quest] = [
        Quest(
            title: "Approve partner follow-up",
            sender: "Maya Chen",
            kind: .approveDraft,
            status: .ready,
            summary: "Maya asked for a quick update on the launch timeline and whether next Friday still works.",
            proposedAction: "Send the drafted reply confirming Friday and summarizing the current launch blockers.",
            requiredAction: "Review the draft and approve send.",
            threadPreview: "The agent matched your usual tone from three prior launch-planning threads and kept the reply short.",
            priority: 1,
            estimatedMinutes: 2,
            action: .createDraft,
            risk: .medium,
            sourceLabel: "mock",
            providerThreadID: "mock-partner-follow-up",
            draftBody: "Hi Maya,\n\nYes, next Friday still works. The main launch blockers are final QA and partner copy review. I will send a tighter update once those land.\n\nBest,\nLachlan",
            confidence: 0.86,
            evidence: ["Matched prior launch-planning replies.", "Send remains disabled."]
        ),
        Quest(
            title: "Upload requested statement",
            sender: "Northstar Finance",
            kind: .uploadAttachment,
            status: .waitingOnUser,
            summary: "Finance requested a current bank statement before they can finish the account review.",
            proposedAction: "The agent prepared the reply but cannot create the factual attachment.",
            requiredAction: "Upload the bank statement, then approve the prepared reply.",
            threadPreview: "The reply is ready except for the missing attachment. No financial document was generated.",
            priority: 2,
            estimatedMinutes: 4,
            action: .uploadAttachment,
            risk: .high,
            evidence: ["Factual attachment must come from the user."]
        ),
        Quest(
            title: "Decide on investor intro call",
            sender: "Leo Martins",
            kind: .calendarInvite,
            status: .ready,
            summary: "Leo sent a calendar invite for a 30-minute intro call tomorrow afternoon.",
            proposedAction: "Accept the invite and move the email thread to done.",
            requiredAction: "Choose yes or no.",
            threadPreview: "No conflict detected in mock calendar data. This will require Calendar write permission later.",
            priority: 2,
            estimatedMinutes: 1,
            action: .queueCalendarInvite,
            risk: .low,
            providerThreadID: "mock-investor-call",
            evidence: ["Invite is queued only; no RSVP is sent."]
        ),
        Quest(
            title: "Add context for article request",
            sender: "Elena Rao",
            kind: .provideContext,
            status: .waitingOnUser,
            summary: "Elena asked for a short article draft on your market outlook. The agent can draft it but needs your angle.",
            proposedAction: "Provide three bullet points, then let the attachment assistant draft the article.",
            requiredAction: "Add the viewpoint you want the article to take.",
            threadPreview: "The agent found similar past emails, but no prior article with the exact position requested.",
            priority: 3,
            estimatedMinutes: 5,
            action: .provideContext,
            risk: .medium,
            evidence: ["Needs user-provided viewpoint before drafting."]
        ),
        Quest(
            title: "Tune cold outreach filter",
            sender: "Growth Pilot",
            kind: .triageReview,
            status: .ready,
            summary: "A cold sales email survived the filter and stayed in the critical inbox.",
            proposedAction: "Move this thread to done and teach the triage assistant to filter similar outreach.",
            requiredAction: "Confirm filter similar, optionally add a reason.",
            threadPreview: "This is a mock correction path for future AI triage feedback.",
            priority: 4,
            estimatedMinutes: 1,
            action: .moveToDone,
            risk: .low,
            providerThreadID: "mock-cold-outreach",
            evidence: ["Cold outreach can move to done after approval."]
        ),
        Quest(
            title: "Review newsletter unsubscribe",
            sender: "SaaS Weekly",
            kind: .mailingList,
            status: .ready,
            summary: "The triage assistant found a mailing list in the test queue and prepared a manual unsubscribe task.",
            proposedAction: "Open the unsubscribe action after explicit approval.",
            requiredAction: "Approve one-click unsubscribe, or keep the list.",
            threadPreview: "This mock flow never auto-unsubscribes. It records approval before any action.",
            priority: 5,
            estimatedMinutes: 1,
            action: .manuallyUnsubscribe,
            risk: .medium,
            sourceLabel: "mock",
            unsubscribeURL: URL(string: "https://example.com/unsubscribe"),
            confidence: 0.9,
            evidence: ["Manual-only unsubscribe task."]
        )
    ]

    static let auditEvents: [AuditEvent] = [
        AuditEvent(
            action: .readGmail,
            status: .allowed,
            questID: nil,
            summary: "Mock mode initialized. No live Gmail data loaded."
        )
    ]

    static let memoryEntries: [MemoryEntry] = [
        MemoryEntry(
            kind: .style,
            title: "Default reply style",
            summary: "Keep replies concise, direct, warm, and practical. Avoid long preambles.",
            provenance: "User product spec",
            userConfirmed: true
        ),
        MemoryEntry(
            kind: .preference,
            title: "Inbox philosophy",
            summary: "Only emails requiring attention should remain visible; non-actionable mail moves to done.",
            provenance: "User product spec",
            userConfirmed: true
        )
    ]
}
