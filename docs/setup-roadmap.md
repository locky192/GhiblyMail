# GhiblyMail Setup Roadmap

Status: Draft

This roadmap turns the product spec into the setup work needed before real Gmail and AI-agent development begins.

## Working Assumptions

- Initial app target is macOS.
- Preferred app stack is native Swift and SwiftUI unless a later decision changes this.
- First usable build should use mock email data before connecting to real Gmail.
- Gmail access, Codex agent access, local memory, and prompt-injection protections are high-risk areas and need explicit design before live account integration.
- The app should remain local-first unless a server becomes necessary.
- First live Gmail work should use the installed Codex Gmail plugin in no-write mode.

## Step 1: Product Spec

Status: Complete enough to start setup.

Artifact:

- `docs/feature-spec.md`

Current understanding:

- GhiblyMail is a cozy, game-like Gmail command center.
- AI assistants triage email, draft replies, manage calendar invites, maintain lightweight memory, and turn remaining work into quests.
- The app must be calm and playful, but faster than a traditional email client.
- AI must never send email without user approval.

## Step 2: Technical Architecture

Status: Drafted.

Artifact:

- `docs/technical-architecture.md`

Decisions to capture:

- App stack and project structure.
- UI shell and mock-data prototype.
- Gmail sync model.
- AI agent orchestration model.
- Local storage and memory model.
- Permission layer for AI-proposed actions.
- Future portability to iOS and iPadOS.

## Step 3: Security Threat Model

Status: Drafted.

Artifact:

- `docs/security-threat-model.md`

Decisions to capture:

- Gmail OAuth risks.
- Local email cache and CRM memory risks.
- Prompt-injection risks.
- Agent tool permission boundaries.
- Draft/send approval rules.
- Logging and telemetry constraints.
- Abuse cases and test fixtures.

## Step 4: Google OAuth And Gmail Feasibility

Status: Initial validation complete; direct Google OAuth is now a fallback for the first spike.

Output:

- Exact Gmail and Calendar scopes needed for MVP.
- Google verification implications.
- Local-first versus server-backed compliance implications.
- Permission rollout strategy for read, draft, label move, calendar response, and send.
- Codex Gmail plugin path for the first live Gmail experiment.

## Step 5: Codex Agent Access Feasibility

Status: Initial validation complete for local development.

Output:

- Local Codex is installed and logged in with ChatGPT-managed auth.
- The Gmail plugin is installed and enabled.
- `codex app-server` and the Codex SDK are the preferred integration surfaces.
- OpenAI API billing is not needed for the first Gmail spike.

## Step 6: MVP Permission Rollout

Status: Drafted.

Candidate rollout:

1. Mock-data only prototype.
2. Codex bridge with no Gmail use.
3. Codex Gmail no-write inbox-to-quest proposals.
4. Local AI analysis with no Gmail writes.
5. Draft creation.
6. Move-to-`done` label changes.
7. Calendar invite responses.
8. Approved send.
9. Auto-unsubscribe with safety gates.

## Step 7: Repo Development Basics

Status: Initial setup complete.

Expected setup:

- `.gitignore`
- README update.
- License decision.
- CI workflow.
- Formatting and linting strategy.
- Dependency and secret scanning.
- Security test fixture directory.

## Step 8: Mock-Data App Prototype

Status: Scaffolded and build verified.

Goal:

- Build the first local prototype without real Gmail or real AI.

Prototype should show:

- Isometric office command center.
- HUD counters.
- Agent avatars and statuses.
- Quest list.
- Draft approval flow.
- Missing attachment task flow.
- Calendar invite task flow.
- Triage correction controls.

Current scaffold:

- `Package.swift`
- `Sources/GhiblyMail/App`
- `Sources/GhiblyMail/Models`
- `Sources/GhiblyMail/Support`
- `Sources/GhiblyMail/Views`

Build note:

- Xcode is installed and selected.
- `swift build` completes successfully.
- See `docs/development-setup.md`.

## Current Next Actions

- Commit the setup docs and mock SwiftUI scaffold.
- Build the local Codex bridge spike.
- Ask Codex/Gmail for structured no-write quest JSON from a small mailbox slice.
- Add tests around prompt-injection fixtures and action-permission validation.
- Decide whether the bridge uses app-server JSON-RPC directly or a local SDK helper.
