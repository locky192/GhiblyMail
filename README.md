# GhiblyMail

GhiblyMail is an early-stage macOS desktop email app concept: a cozy, game-like Gmail command center where AI assistants triage work email, draft replies, manage calendar invites, and turn the remaining work into clear quests.

The project is currently in product and architecture setup. The first build target is a mock-data macOS prototype, followed by a no-write Codex/Gmail spike using the local Codex install and its Gmail plugin.

## Docs

- [Feature spec](docs/feature-spec.md)
- [Setup roadmap](docs/setup-roadmap.md)
- [Technical architecture](docs/technical-architecture.md)
- [Codex/Gmail integration plan](docs/codex-gmail-architecture.md)
- [Security threat model](docs/security-threat-model.md)
- [OAuth and AI feasibility notes](docs/oauth-and-ai-feasibility.md)
- [MVP rollout](docs/mvp-rollout.md)
- [Development setup](docs/development-setup.md)

## Current Build Plan

1. Build a native SwiftUI macOS mock prototype.
2. Add local models, quest flows, agent statuses, and permission gates.
3. Add prompt-injection test fixtures before connecting real accounts.
4. Add a local Codex bridge through `codex app-server` or the Codex SDK.
5. Use the installed Codex Gmail plugin for a no-write inbox-to-quest spike.
6. Add AI-backed recommendations only behind a deterministic permission layer.

## Local Development

The macOS app is a Swift package with a small executable target and a testable core library:

- `Sources/GhiblyMail`: app entry point.
- `Sources/GhiblyMailCore`: SwiftUI views, app state, models, Codex bridge, permission policy, memory stub, and prompt-injection guard.
- `Tests/GhiblyMailCoreTests`: focused unit tests for security-critical behavior.

```sh
swift build
swift run GhiblyMail
swift test
scripts/security-check.sh
```

This requires a working Xcode install with a matching Swift compiler and macOS SDK. See [development setup](docs/development-setup.md).

The app starts in mock mode. For live experiments, switch to Local Codex mode in the HUD, check Codex readiness, and import only the `ghiblymail-test` label. The MVP permission layer denies sending email and auto-unsubscribe.

## License

No license has been selected yet.
