# Development Setup

Status: Draft

## Required Local Tooling

For native macOS development:

- Xcode with a matching macOS SDK and Swift compiler.
- Active developer directory pointing at Xcode, not only Command Line Tools.
- Codex CLI for the first real Gmail/AI spike.
- Installed and enabled Codex Gmail plugin for live Gmail experiments.

Check:

```sh
xcode-select -p
xcodebuild -version
swift --version
swift build
swift test
codex --version
codex login status
scripts/security-check.sh
```

Expected:

- `xcode-select -p` should usually point to `/Applications/Xcode.app/Contents/Developer`.
- `xcodebuild -version` should print an installed Xcode version.
- `swift build` should compile the Swift package.

## Current Local Environment Note

On 2026-05-26, Xcode was installed from the App Store and selected as the active developer directory:

```text
xcode-select -p
/Applications/Xcode.app/Contents/Developer
```

`swift build` now completes successfully for the mock prototype scaffold.

Codex is also installed locally and logged in with ChatGPT-managed auth. The Gmail plugin is installed and enabled for the planned no-write Gmail spike.

## Build Commands

Once Xcode is installed and selected:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
swift build
swift run GhiblyMail
swift test
scripts/security-check.sh
```

## Project Structure

```text
Sources/GhiblyMail/App
Sources/GhiblyMailCore/Models
Sources/GhiblyMailCore/Services
Sources/GhiblyMailCore/Support
Sources/GhiblyMailCore/Views
Tests/GhiblyMailCoreTests
tests/security/prompt-injection-fixtures
docs
```

## First Prototype Scope

The current scaffold is intentionally mock-only:

- No live Gmail reads.
- No live Codex calls.
- No local email cache.
- No real sends, drafts, label moves, unsubscribe actions, or calendar writes.

The first runnable goal is to validate the command-center loop: HUD, agent statuses, quests, draft approvals, missing attachments, invite decisions, and triage corrections.

## MVP Guardrails

The local-developer MVP defaults to mock mode. Live experiments should use Local Codex mode only after the readiness check passes.

Current enforced boundaries:

- Gmail reads are limited to the `ghiblymail-test` label.
- Gmail draft creation, move-to-done, restore-from-done, and manual unsubscribe actions require explicit user approval in the app.
- Sending email is denied.
- Auto-unsubscribe is denied.
- Audit events redact email addresses and secret-shaped strings.
- Prompt-injection fixtures live under `tests/security/prompt-injection-fixtures`.

Live Gmail smoke test note:

- Create a Gmail label named `ghiblymail-test`.
- Add only safe test threads to that label.
- Use Local Codex mode only after the readiness check passes.
- If the label is missing or empty, live import should return no quests rather than reading the general inbox.
