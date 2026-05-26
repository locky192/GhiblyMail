# MVP Production-Readiness Checklist

Status: Draft

This checklist defines what must be true before calling the local-developer MVP production-ready.

## Automated Checks

Run:

```sh
scripts/mvp-check.sh
```

This verifies:

- Swift package builds.
- Unit tests pass.
- Security check script passes.
- Prompt-injection fixtures exist.
- Obvious secret patterns are not committed.
- Codex is installed and logged in.
- `gmail@openai-curated` is installed and enabled.

Optional no-write Gmail label smoke test:

```sh
GHIBLYMAIL_CHECK_GMAIL_LABEL=1 scripts/mvp-check.sh
```

This asks Codex/Gmail only whether `ghiblymail-test` exists and how many matching threads are available, without returning subjects, senders, snippets, or message bodies.

## Manual Checks

- Create the Gmail label `ghiblymail-test`.
- Add a small number of safe test threads to that label.
- Launch the app with `swift run GhiblyMail`.
- Confirm the app opens in mock mode.
- Confirm the HUD shows quest counts, runtime mode, Codex readiness, and import controls.
- Switch to Local Codex mode and run the readiness check.
- Import the `ghiblymail-test` label.
- Confirm imported quests are proposal-only and do not modify Gmail.
- Approve one draft creation task only after checking that sending is not offered.
- Approve move-to-done and restore only on test-label threads.
- Confirm manual unsubscribe tasks require approval and do not auto-run.
- Confirm the audit panel records proposals, approvals, denials, executions, and failures.

## Current Known Gap

The local environment currently has the Codex Gmail plugin installed and enabled, but the `ghiblymail-test` Gmail label must exist before live import can be fully verified.
