import SwiftUI

struct HUDView: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        HStack(spacing: 10) {
            StatTile(title: "Critical", value: "\(store.readyCount)", image: "exclamationmark.bubble", tint: Theme.coral)
            StatTile(title: "Drafts", value: "\(store.draftCount)", image: "checkmark.message", tint: Theme.blue)
            StatTile(title: "Blocked", value: "\(store.blockedCount)", image: "paperclip", tint: Theme.amber)
            StatTile(title: "Invites", value: "\(store.inviteCount)", image: "calendar", tint: Theme.teal)

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                Image(systemName: "music.note")
                Text("Lo-fi off")
            }
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Theme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Theme.line)
            )

            Button {
                store.completeSelectedQuest()
            } label: {
                Label("Complete Quest", systemImage: "checkmark.circle.fill")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(HUDButtonStyle(tint: Theme.deepTeal))
            .keyboardShortcut(.return, modifiers: [.command])
        }
    }
}

private struct StatTile: View {
    var title: String
    var value: String
    var image: String
    var tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: image)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.mutedInk)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 50)
        .background(Theme.panelStrong)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.line)
        )
    }
}

private struct HUDButtonStyle: ButtonStyle {
    var tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(configuration.isPressed ? tint.opacity(0.82) : tint)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
