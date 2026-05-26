import Foundation

struct MemoryStore: Sendable {
    private(set) var entries: [MemoryEntry]

    init(entries: [MemoryEntry] = []) {
        self.entries = entries
    }

    mutating func add(_ entry: MemoryEntry) {
        entries.append(entry)
    }

    func relevantEntries(for query: String) -> [MemoryEntry] {
        let tokens = Set(query.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init))
        guard !tokens.isEmpty else { return entries.filter(\.userConfirmed) }

        return entries.filter { entry in
            let haystack = "\(entry.title) \(entry.summary)".lowercased()
            return entry.userConfirmed && tokens.contains { haystack.contains($0) }
        }
    }
}
