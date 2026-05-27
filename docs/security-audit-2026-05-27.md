# GhiblyMail MVP Security Audit

Date: 2026-05-27

Status: Passed for local-only MVP.

## Scope

Audited the current local macOS MVP implementation against the security goals in `docs/security-threat-model.md`, `docs/mvp-implementation-plan.md`, and the existing security tests.

The MVP is not a hosted system. It uses local SwiftUI state, local mock data, optional local Codex/Gmail bridge calls, and approval-gated actions.

## Findings

No release-blocking issues found in the current local MVP.

## Controls Verified

- Gmail/Codex write-like actions remain approval-gated through `PermissionPolicy`.
- Sending email remains denied in the MVP.
- Auto-unsubscribe remains denied by policy; unsubscribe work is manual/approval based.
- Read/import is constrained to the configured `ghiblymail-test` label.
- Prompt-injection guard scans imported proposal text and downgrades suspicious proposals.
- Audit events sanitize email addresses and API-key-like secrets.
- Mutating local workflow commands create audit events.
- Batch actions exclude high-risk, low-confidence, and waiting-on-user tasks.
- App settings, performance metrics, memory rules, file placeholders, and decisions are local state only.
- No cloud storage, server endpoint, or background hosted service was introduced.
- No secrets were detected by the repository secret scan.

## Verification Evidence

- `swift test`: 25 tests passing.
- `scripts/security-check.sh`: passing, including tests, secret scan, and prompt-injection fixture checks.
- `scripts/build-app-bundle.sh /private/tmp/GhiblyMailSmoke2.app`: produces a signed local app bundle with the office image copied into the bundle.
- UI smoke screenshot: `/private/tmp/ghiblymail-app-bundle-smoke-6.png` showed the signed app rendering the office HUD. The visible crash alert in that screenshot was from an earlier invalid-signature smoke launch; current signed app processes were running behind it and were stopped after verification.

## Residual Risks

- Live Gmail behavior still depends on the local Codex/Gmail plugin environment and should be retested with `GHIBLYMAIL_CHECK_GMAIL_LABEL=1 scripts/mvp-check.sh` before any real mailbox pilot.
- The app bundle is ad-hoc signed for local testing only, not notarized or distribution-signed.
- File upload is represented as a local filename placeholder in the MVP; any future real file ingestion must add file-type validation, file-size limits, and content handling tests before reading file contents.
- Settings persistence is in-memory for the MVP; future disk persistence should use a scoped app container and avoid storing secrets.
- UI smoke verification is manual/screenshot based; a future Xcode UI test target should automate route clicking once the project has an app-bundle test harness.

## Production-Readiness Notes

The current MVP is production-ready only in the local prototype sense: it is safe to run locally against mock data and controlled `ghiblymail-test` proposal flows. It should not be treated as a distributed production Gmail client until OAuth storage, notarized packaging, live connector tests, and user-facing privacy copy are completed.
