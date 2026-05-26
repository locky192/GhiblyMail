import Foundation

private final class JSONLineBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [[String: Any]] = []

    func append(data: Data) {
        guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
        let parsed = text.split(separator: "\n").compactMap { line -> [String: Any]? in
            guard let data = line.data(using: .utf8) else { return nil }
            return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        }

        guard !parsed.isEmpty else { return }
        lock.lock()
        storage.append(contentsOf: parsed)
        lock.unlock()
    }

    var snapshot: [[String: Any]] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }
}

protocol CodexBridge: Sendable {
    func checkReadiness() async -> CodexReadiness
    func importQuestProposals(label: String) async throws -> [QuestProposal]
    func executeApprovedAction(_ action: ApprovedCodexAction) async throws -> String
}

enum CodexBridgeError: Error, LocalizedError, Sendable {
    case codexNotReady(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .codexNotReady(let reason):
            return reason
        case .invalidResponse:
            return "Codex returned a response that GhiblyMail could not parse."
        }
    }
}

struct MockCodexBridge: CodexBridge {
    func checkReadiness() async -> CodexReadiness {
        CodexReadiness(
            codexInstalled: true,
            codexVersion: "mock",
            loggedIn: true,
            planType: "mock",
            gmailPluginInstalled: true,
            gmailPluginEnabled: true,
            checkedAt: Date(),
            issues: []
        )
    }

    func importQuestProposals(label: String) async throws -> [QuestProposal] {
        [
            QuestProposal(
                threadID: "mock-thread-draft",
                sender: "Maya Chen",
                title: "Draft partner timeline reply",
                summary: "Maya asked whether the next launch checkpoint still works and needs a concise update.",
                category: "needs_reply",
                proposedAction: .createDraft,
                draftBody: "Hi Maya,\n\nYes, next Friday still works. The main launch blockers are the final QA pass and partner copy review. I will send a tighter update once those land.\n\nBest,\nLachlan",
                unsubscribeURL: nil,
                risk: .medium,
                confidence: 0.86,
                evidence: ["Matched prior short update replies.", "No send action proposed."]
            ),
            QuestProposal(
                threadID: "mock-thread-done",
                sender: "Growth Pilot",
                title: "Move cold outreach to done",
                summary: "Cold sales outreach survived the inbox filter and does not need a response.",
                category: "cold_outreach",
                proposedAction: .moveToDone,
                draftBody: nil,
                unsubscribeURL: nil,
                risk: .low,
                confidence: 0.94,
                evidence: ["No prior relationship found.", "Generic outbound sales language."]
            ),
            QuestProposal(
                threadID: "mock-thread-list",
                sender: "SaaS Weekly",
                title: "Unsubscribe from SaaS Weekly",
                summary: "A recurring mailing-list message was found in the test label.",
                category: "mailing_list",
                proposedAction: .manuallyUnsubscribe,
                draftBody: nil,
                unsubscribeURL: URL(string: "https://example.com/unsubscribe"),
                risk: .medium,
                confidence: 0.89,
                evidence: ["List-Unsubscribe-like signal present.", "Manual approval required."]
            ),
            QuestProposal(
                threadID: "mock-thread-calendar",
                sender: "Leo Martins",
                title: "Review intro call invite",
                summary: "Leo sent a calendar invitation that should be surfaced outside the inbox.",
                category: "calendar_invite",
                proposedAction: .queueCalendarInvite,
                draftBody: nil,
                unsubscribeURL: nil,
                risk: .low,
                confidence: 0.82,
                evidence: ["Calendar invite detected.", "No RSVP action proposed."]
            )
        ]
    }

    func executeApprovedAction(_ action: ApprovedCodexAction) async throws -> String {
        switch action.kind {
        case .createDraft:
            return "Mock Gmail draft created. No email was sent."
        case .moveToDone:
            return "Mock thread moved to done."
        case .restoreFromDone:
            return "Mock thread restored to inbox."
        case .manuallyUnsubscribe:
            return "Mock manual unsubscribe completed."
        default:
            return "Mock action recorded locally."
        }
    }
}

final class LocalCodexBridge: CodexBridge, @unchecked Sendable {
    private let codexPath: String
    private let timeout: TimeInterval

    init(codexPath: String = "/opt/homebrew/bin/codex", timeout: TimeInterval = 20) {
        self.codexPath = codexPath
        self.timeout = timeout
    }

    func checkReadiness() async -> CodexReadiness {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let readiness = self.checkReadinessSync()
                continuation.resume(returning: readiness)
            }
        }
    }

    func importQuestProposals(label: String) async throws -> [QuestProposal] {
        let readiness = await checkReadiness()
        guard readiness.isReadyForGmailRead else {
            throw CodexBridgeError.codexNotReady(readiness.summary)
        }

        // MVP guardrail: local Codex reads are constrained by prompt and permission policy.
        // The app permission layer still treats returned items as proposals only.
        let prompt = """
        Use the installed Gmail plugin only for label:\(label). Do not modify Gmail. Do not create drafts, move labels, send, unsubscribe, or RSVP.
        Return only compact JSON with a top-level "quests" array. Each item must include threadID, sender, title, summary, category, proposedAction, risk, confidence, and evidence.
        Allowed proposedAction values: createDraft, moveToDone, restoreFromDone, queueCalendarInvite, manuallyUnsubscribe, provideContext, uploadAttachment, localProposal.
        """

        let response = try await runCodexTurn(prompt: prompt)
        return try Self.decodeQuestProposals(from: response)
    }

    func executeApprovedAction(_ action: ApprovedCodexAction) async throws -> String {
        let readiness = await checkReadiness()
        guard readiness.isReadyForGmailRead else {
            throw CodexBridgeError.codexNotReady(readiness.summary)
        }

        let prompt = actionPrompt(for: action)
        return try await runCodexTurn(prompt: prompt)
    }

    private func actionPrompt(for action: ApprovedCodexAction) -> String {
        let thread = action.providerThreadID ?? "unknown"
        let base = """
        You are executing a user-approved GhiblyMail action through the Gmail plugin.
        Hard limits:
        - Operate only on Gmail label:\(action.sourceLabel).
        - Operate only on thread id:\(thread).
        - Never send email.
        - Never delete mail.
        - If the requested thread is not inside label:\(action.sourceLabel), stop and report that no action was taken.
        - Return a concise plain-text result.
        """

        switch action.kind {
        case .createDraft:
            return """
            \(base)
            Create a Gmail draft reply in the existing thread using this exact draft body:
            \(action.draftBody ?? "")
            """
        case .moveToDone:
            return """
            \(base)
            Move the thread to the user's done label/folder and remove it from the inbox if Gmail supports that operation. Do not archive unless that is the only way Gmail represents removing from inbox while adding done.
            """
        case .restoreFromDone:
            return """
            \(base)
            Restore the thread to the inbox and keep or remove the done label according to normal Gmail label behavior. Do not send or delete anything.
            """
        case .manuallyUnsubscribe:
            return """
            \(base)
            The user approved a manual unsubscribe task. Use only standards-based Gmail unsubscribe capability or List-Unsubscribe metadata if available. Do not visit arbitrary unsubscribe web pages. If standards-based unsubscribe is unavailable, report no action taken. URL hint: \(action.unsubscribeURL?.absoluteString ?? "none")
            """
        default:
            return """
            \(base)
            Report that this action kind is not executable through the Gmail connector.
            """
        }
    }

    private func checkReadinessSync() -> CodexReadiness {
        guard FileManager.default.isExecutableFile(atPath: codexPath) else {
            return CodexReadiness(
                codexInstalled: false,
                codexVersion: nil,
                loggedIn: false,
                planType: nil,
                gmailPluginInstalled: false,
                gmailPluginEnabled: false,
                checkedAt: Date(),
                issues: ["Codex was not found at \(codexPath)."]
            )
        }

        let version = runProcess(arguments: ["--version"]).trimmingCharacters(in: .whitespacesAndNewlines)
        let loginStatus = runProcess(arguments: ["login", "status"])
        let loggedIn = loginStatus.localizedCaseInsensitiveContains("logged in")
        let appServer = runAppServerProbe()

        var issues: [String] = []
        if !loggedIn {
            issues.append("Codex is not logged in.")
        }
        if !appServer.gmailInstalled {
            issues.append("The Codex Gmail plugin is not installed.")
        }
        if !appServer.gmailEnabled {
            issues.append("The Codex Gmail plugin is not enabled.")
        }

        return CodexReadiness(
            codexInstalled: true,
            codexVersion: version.isEmpty ? nil : version,
            loggedIn: loggedIn,
            planType: appServer.planType,
            gmailPluginInstalled: appServer.gmailInstalled,
            gmailPluginEnabled: appServer.gmailEnabled,
            checkedAt: Date(),
            issues: issues
        )
    }

    private func runProcess(arguments: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: codexPath)
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }

    private struct AppServerProbe {
        var gmailInstalled: Bool
        var gmailEnabled: Bool
        var planType: String?
    }

    private func runAppServerProbe() -> AppServerProbe {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: codexPath)
        process.arguments = ["app-server"]

        let input = Pipe()
        let output = Pipe()
        process.standardInput = input
        process.standardOutput = output
        process.standardError = Pipe()

        let buffer = JSONLineBuffer()
        output.fileHandleForReading.readabilityHandler = { handle in
            buffer.append(data: handle.availableData)
        }

        do {
            try process.run()
            let requests = [
                #"{"method":"initialize","id":1,"params":{"clientInfo":{"name":"ghiblymail","title":"GhiblyMail","version":"0.1.0"}}}"#,
                #"{"method":"initialized","params":{}}"#,
                #"{"method":"account/read","id":2,"params":{"refreshToken":false}}"#,
                #"{"method":"plugin/list","id":3,"params":{"limit":200}}"#
            ]
            for request in requests {
                input.fileHandleForWriting.write(Data((request + "\n").utf8))
            }
            Thread.sleep(forTimeInterval: min(timeout, 5))
            process.terminate()
            output.fileHandleForReading.readabilityHandler = nil
        } catch {
            return AppServerProbe(gmailInstalled: false, gmailEnabled: false, planType: nil)
        }

        var planType: String?
        var gmailInstalled = false
        var gmailEnabled = false

        for message in buffer.snapshot {
            if message["id"] as? Int == 2,
               let result = message["result"] as? [String: Any],
               let account = result["account"] as? [String: Any] {
                planType = account["planType"] as? String
            }

            if message["id"] as? Int == 3,
               let result = message["result"] as? [String: Any],
               let marketplaces = result["marketplaces"] as? [[String: Any]] {
                for marketplace in marketplaces {
                    let plugins = marketplace["plugins"] as? [[String: Any]] ?? []
                    for plugin in plugins where plugin["id"] as? String == "gmail@openai-curated" {
                        gmailInstalled = plugin["installed"] as? Bool ?? false
                        gmailEnabled = plugin["enabled"] as? Bool ?? false
                    }
                }
            }
        }

        return AppServerProbe(gmailInstalled: gmailInstalled, gmailEnabled: gmailEnabled, planType: planType)
    }

    private func runCodexTurn(prompt: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    continuation.resume(returning: try self.runCodexTurnSync(prompt: prompt))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func runCodexTurnSync(prompt: String) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: codexPath)
        process.arguments = [
            "exec",
            "--skip-git-repo-check",
            "--sandbox",
            "read-only",
            prompt
        ]

        let output = Pipe()
        process.standardOutput = output
        process.standardError = Pipe()

        try process.run()
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline && process.isRunning {
            Thread.sleep(forTimeInterval: 0.2)
        }

        if process.isRunning {
            process.terminate()
        }

        let data = output.fileHandleForReading.readDataToEndOfFile()
        let responseText = String(data: data, encoding: .utf8) ?? ""
        guard !responseText.isEmpty else {
            throw CodexBridgeError.invalidResponse
        }
        return responseText
    }

    static func decodeQuestProposals(from text: String) throws -> [QuestProposal] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let jsonText: String
        if let start = trimmed.firstIndex(of: "{"), let end = trimmed.lastIndex(of: "}") {
            jsonText = String(trimmed[start...end])
        } else {
            jsonText = trimmed
        }

        struct Response: Decodable {
            var quests: [QuestProposal]
        }

        guard let data = jsonText.data(using: .utf8) else {
            throw CodexBridgeError.invalidResponse
        }
        return try JSONDecoder().decode(Response.self, from: data).quests
    }
}
