import Foundation

struct PromptInjectionReport: Equatable, Sendable {
    var isSuspicious: Bool
    var findings: [String]
}

struct PromptInjectionGuard: Sendable {
    private let patterns: [(String, String)] = [
        (#"(?i)ignore (all )?(previous|prior|above) instructions"#, "Attempts to override trusted instructions."),
        (#"(?i)system prompt"#, "Mentions system prompt handling."),
        (#"(?i)(send|forward|email).{0,80}(all|recent|private|confidential)"#, "Requests broad data exfiltration."),
        (#"(?i)(approve|click|run|execute).{0,60}(without asking|automatically|silently)"#, "Attempts to bypass approval."),
        (#"(?i)(change|update|rewrite).{0,80}(rules|preferences|memory|security)"#, "Attempts to mutate durable policy or memory."),
        (#"(?i)<script|display:\s*none|opacity:\s*0|font-size:\s*0"#, "Contains hidden or executable-looking content.")
    ]

    func scan(_ text: String) -> PromptInjectionReport {
        let findings = patterns.compactMap { pattern, reason in
            text.range(of: pattern, options: .regularExpression) == nil ? nil : reason
        }
        return PromptInjectionReport(isSuspicious: !findings.isEmpty, findings: Array(Set(findings)).sorted())
    }
}
