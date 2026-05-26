# GhiblyMail MVP Rollout

Status: Draft

## MVP Strategy

The MVP should prove the user experience and safety model before touching real work email. The first builds should use mock data, mock agents, and local state. Live Gmail and real AI should be introduced through the local Codex install only after permission boundaries and security tests exist.

## Milestone 0: Mock Command Center

Goal:

- Validate the core product experience with no external accounts.

Includes:

- Native macOS app shell.
- Cozy isometric office-inspired home screen.
- HUD counters.
- Agent avatars and work states.
- Quest board.
- Quest detail panel.
- Draft approval mock flow.
- Missing attachment mock flow.
- Calendar invite mock flow.
- Triage feedback mock flow.

Exit criteria:

- The app feels meaningfully different from a normal email client.
- The user can clear mock quests faster than reading a traditional inbox.
- The main UI can support keyboard-first operation.

## Milestone 1: Local Data And Permission Layer

Goal:

- Build the safety and data foundation before live integrations.

Includes:

- Local data models for threads, quests, drafts, agents, attachments, calendar invites, and audit events.
- Deterministic permission layer for all proposed actions.
- Mock agent action proposals.
- Red-team prompt-injection fixture directory.
- Tests proving denied actions stay denied.

Exit criteria:

- No action executes directly from AI output.
- All actions pass through validation.
- Send action is impossible without explicit approval.
- Prompt-injection fixtures exist and can be run locally.

## Milestone 2: Codex Bridge

Goal:

- Connect GhiblyMail to local Codex without using Gmail yet.

Includes:

- Codex account readiness check.
- Gmail plugin readiness check.
- Local bridge using `codex app-server` or the Codex SDK.
- Structured request/response contract for quests, drafts, and triage proposals.
- No mailbox reads, label moves, drafts, sends, or unsubscribe actions.

Exit criteria:

- The app can detect whether Codex and the Gmail plugin are available.
- The bridge can run a harmless Codex request and parse structured output.
- No secrets or tokens are logged.
- Permission-layer tests still pass.

## Milestone 3: Codex/Gmail No-Write Import

Goal:

- Use Codex and the Gmail plugin to classify a limited mailbox slice without modifying Gmail.

Includes:

- Limited Gmail plugin read.
- Triage recommendations stored locally.
- Draft replies stored locally.
- Memory retrieval experiments using local test data.
- Local email index.
- No label moves, Gmail drafts, sends, or unsubscribe actions.

Exit criteria:

- AI output is structured and validated.
- Prompt-injection tests still pass.
- No Gmail write operations are available to agents.
- User can compare AI recommendations against real inbox state.

## Milestone 4: Gmail Draft Creation

Goal:

- Let the app create drafts in Gmail, but still never send.

Includes:

- Gmail draft creation in existing threads through the approved connector path.
- Approval gate before creating a Gmail draft.
- Audit log for draft creation.
- Draft invalidation when source thread changes materially.

Exit criteria:

- Drafts appear in Gmail correctly.
- Recipients and thread IDs are validated.
- Attachments are not added without approval.
- Sending remains unavailable or separately gated.

## Milestone 5: Move-To-`done`

Goal:

- Let the app move messages out of inbox into `done`.

Includes:

- Detect user's `done` label.
- Move selected messages/threads to `done`.
- Restore from `done` to inbox.
- Triage feedback buttons.
- Conservative auto-move mode behind a training/review setting.

Exit criteria:

- Every move is auditable.
- User can undo supported moves.
- Similar-future filtering preferences are stored safely.
- App does not delete or archive mail.

## Milestone 6: Calendar Invites

Goal:

- Move calendar invite work out of the inbox.

Includes:

- Calendar invite detection.
- Invite quest list.
- Yes/no response flow.
- Calendar write permission only when needed.

Exit criteria:

- Invite responses are explicit user actions.
- Invite emails can be moved to `done` only after they are represented in the invite view.
- Calendar permissions are documented and separately gated.

## Milestone 7: Approved Send

Goal:

- Let the user send approved AI-drafted replies.

Includes:

- Explicit send approval.
- Recipient, body, attachment, and thread review.
- Audit record for approval and send.
- Send disabled if draft content changes after approval.

Exit criteria:

- No automated sending path exists.
- Send requires a user gesture.
- Approval state is specific to one draft version.

## Milestone 8: Auto-Unsubscribe

Goal:

- Automatically reduce mailing-list noise with strong safety controls.

Includes:

- List-Unsubscribe header handling.
- Suspicious-link detection.
- Approval-required mode for non-standard flows.
- Audit log and visible recent unsubscribe actions.

Exit criteria:

- No private email context is submitted to unsubscribe pages.
- Suspicious flows require approval.
- User can disable auto-unsubscribe.

## Recommended First Build

Start with Milestone 0 and Milestone 1 together:

- Build the macOS mock command center.
- Add local models and mock action proposals.
- Add the first prompt-injection fixture format.
- Keep live Gmail actions out of the app entirely.
- Use Codex only after the permission layer and bridge contract are in place.

This gives us real product progress while avoiding the biggest security and compliance risks too early.
