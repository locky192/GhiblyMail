# GhiblyMail Security Threat Model

Status: Draft

## Scope

This threat model covers the first production-intended version of GhiblyMail:

- macOS desktop app.
- Gmail account access.
- Calendar invite handling.
- Local email index and local memory.
- AI triage and drafting agents.
- Local Codex integration and Gmail plugin usage.
- Draft creation and approved send.
- Move-to-`done` label operations.
- Attachment task handling.
- Optional unsubscribe and web research features.

Future integrations such as iMessage, Telegram, cloud sync, and mobile apps require additional threat-model updates before implementation.

## Security Goals

- Protect real work email, contacts, attachments, calendar data, OAuth tokens, drafts, and AI memory.
- Prevent unauthorized email sending, forwarding, deleting, moving, unsubscribing, or preference changes.
- Prevent prompt injection from causing unsafe agent behavior.
- Prevent private data exfiltration through replies, web requests, logs, telemetry, or memory.
- Keep user approval mandatory for sending email.
- Make AI actions auditable and reversible where possible.
- Keep local data deletable by the user.

## Trust Boundaries

Trusted:

- Application code.
- User-initiated approvals.
- Local permission policy.
- Keychain credential storage.
- Signed app build.

Partially trusted:

- Google OAuth and Gmail APIs.
- Codex, the Codex Gmail plugin, and OpenAI/ChatGPT account services.
- OpenAI or other AI model provider, if a fallback runtime is used.
- Apple platform services.

Untrusted:

- Incoming email body, subject, sender display name, and headers.
- Attachments.
- Calendar invite descriptions.
- Mailing list unsubscribe pages.
- Websites visited during research.
- AI model outputs.
- AI-generated memory suggestions.
- Any future messaging content from iMessage or Telegram.

Important rule:

- AI output is untrusted until validated by deterministic application code.

## Assets

Sensitive assets:

- Gmail OAuth refresh tokens and access tokens.
- Codex/ChatGPT auth state and connector credentials managed by Codex.
- OpenAI or AI-provider credentials, if a fallback runtime is used.
- Gmail message bodies and metadata.
- Draft replies.
- Sent email history.
- Attachments and generated documents.
- Calendar invites and responses.
- Local CRM and memory files.
- Embeddings or retrieval indexes.
- Audit logs.
- User preferences and triage rules.

## Primary Threats

### Gmail OAuth Token Theft

Risk:

- An attacker obtains Gmail tokens and gains access to work email.

Controls:

- Store tokens only in macOS Keychain.
- Never log tokens.
- Never expose tokens to AI prompts.
- Use least-privilege OAuth scopes.
- Provide account disconnect and credential deletion.
- Keep production builds signed and notarized.

Codex plugin note:

- In the Codex-first architecture, GhiblyMail should not directly handle Gmail OAuth tokens for the initial spike. It should still treat Codex connector access as sensitive and avoid logging connector metadata, transcripts, or auth state.

### Codex Connector Misuse

Risk:

- Codex or an installed connector performs a Gmail action outside GhiblyMail's intended approval path.

Controls:

- Use Codex first in no-write proposal mode.
- Route app-server approval events through the GhiblyMail permission layer.
- Decline connector/tool actions by default unless they match an approved action.
- Keep send, label move, draft creation, calendar response, unsubscribe, and research actions as separate permission tiers.
- Audit every connector action proposal and result.

### Excessive Gmail Permissions

Risk:

- The app requests more Gmail permission than needed, increasing blast radius and verification burden.

Controls:

- Map each feature to exact scopes.
- Roll out scopes in tiers.
- Start read-only.
- Add draft, label, calendar, and send permissions only when the corresponding feature exists.
- Keep permission tier visible in development builds.

### Unauthorized Send

Risk:

- A bug, prompt injection, or mistaken agent output sends an email without approval.

Controls:

- The send tool must require explicit user approval tied to a specific draft.
- The agent cannot call send directly.
- The permission layer validates thread ID, recipients, subject, body, attachments, and approval state.
- Approval expires if the draft changes materially.
- Audit every send proposal, approval, and execution.

### Prompt Injection From Email

Risk:

- A malicious email instructs the AI to ignore system instructions, reveal data, send mail, change preferences, or perform unsafe tool calls.

Controls:

- Treat all email content as untrusted data.
- Separate trusted instructions from email content in prompts.
- Use structured model outputs.
- Validate proposed actions against an allowlist.
- Block emails from changing permissions, rules, memory, or security settings directly.
- Add red-team fixtures for prompt injection.

### Indirect Prompt Injection From Web Research

Risk:

- A website visited during research includes hidden or visible instructions that manipulate the agent.

Controls:

- Keep research content isolated as untrusted input.
- Do not give research agents write tools.
- Do not include private email content in search queries unless explicitly approved.
- Store research notes with source URLs and confidence.
- Require approval before using research findings in durable memory.

### Memory Poisoning

Risk:

- Malicious or misleading email content becomes durable memory and affects future triage or drafts.

Controls:

- Separate user-confirmed facts from AI inferences.
- Store provenance for memory entries.
- Never store prompt-like content as future instructions.
- Require review or high confidence for durable preference changes.
- Allow user inspection, editing, and deletion of memory.

### Data Exfiltration Through Drafts

Risk:

- The AI includes sensitive information from unrelated emails, CRM notes, attachments, or memory in a draft reply.

Controls:

- Retrieve only context relevant to the current thread.
- Label context sources and recipients.
- Add checks before drafts include unrelated private information.
- Show sensitive inclusions clearly in review UI.
- Require approval before sending.

### Unsafe Attachments

Risk:

- Malicious attachments exploit the app, or AI-generated attachments include private or fabricated information.

Controls:

- Do not execute attachment content.
- Treat parsed attachments as untrusted.
- Store attachments in controlled app directories.
- Require review of generated documents.
- Do not fabricate factual documents such as bank statements.
- Warn when a requested attachment must come from an external source.

### Unsafe Unsubscribe

Risk:

- Unsubscribe links are phishing or tracking links, or the app submits private data to an attacker.

Controls:

- Prefer standards-based unsubscribe headers where available.
- Treat unsubscribe webpages as untrusted.
- Require extra approval for suspicious or non-standard unsubscribe flows.
- Do not send private email context to unsubscribe pages.
- Audit unsubscribe actions.

### Overbroad Logging Or Telemetry

Risk:

- Logs, crash reports, analytics, or telemetry leak emails, secrets, attachments, or personal data.

Controls:

- Redact secrets and email bodies from logs.
- Avoid telemetry by default.
- Require explicit consent before telemetry.
- Keep local audit logs concise and privacy-aware.
- Add tests for log redaction.

### Local Device Compromise

Risk:

- A compromised Mac or another local user accesses cached email or memory.

Controls:

- Store credentials in Keychain.
- Encrypt sensitive local cache where practical.
- Use app sandboxing in production distribution where possible.
- Support local data deletion.
- Avoid world-readable cache files.

## Permission Policy

AI agents may propose actions. Application code decides whether those actions can execute.

Action categories:

- Read-only: summarize thread, classify email, identify needed attachment.
- Local draft: create local draft, create local quest, propose memory note.
- Gmail draft: create Gmail draft in existing thread.
- Gmail label: move message to `done`, restore to inbox.
- Calendar: respond yes or no to invite.
- External network: research contact, visit unsubscribe URL.
- Send: send approved draft.

Approval requirements:

- Send: always explicit user approval.
- Attach file: explicit approval before send.
- Add recipient: explicit approval.
- Forward: explicit approval.
- External research using private context: explicit approval.
- Suspicious unsubscribe: explicit approval.
- Durable memory preference change: explicit approval or user correction event.
- Bulk operations: explicit approval until proven safe.

## Prompt-Injection Test Fixtures

Create tests for:

- Email says to ignore system instructions.
- Email asks to forward all recent messages.
- Email asks to change triage rules.
- Email asks to approve or send automatically.
- Email includes hidden HTML text with malicious instructions.
- Email includes base64 or encoded malicious instruction.
- Attachment includes malicious instruction.
- Calendar invite includes malicious instruction.
- Research webpage includes malicious instruction.
- Unsubscribe page includes malicious instruction.
- Email attempts to poison CRM memory.
- Email attempts to extract unrelated private context into a reply.

Expected result:

- The app may summarize malicious content as content, but must not obey it as an instruction.
- No unauthorized tool call should execute.
- No durable memory change should occur without appropriate validation.
- No email should send without user approval.

## Audit Requirements

Audit events should record:

- Agent action proposal.
- Model confidence or rationale summary where useful.
- Validation result.
- User approval or rejection.
- Executed tool call.
- Failure details.
- Reversal or undo action.

Audit logs should not contain:

- OAuth tokens.
- API keys.
- Full email bodies unless explicitly needed and locally protected.
- Full private attachments.
- Excessive personal data.

## Security Gates Before Live Gmail

Before connecting a real Gmail account:

- OAuth scopes are mapped and documented.
- Tokens are stored in Keychain.
- Logs are redacted.
- No real email data is sent to a model unless explicitly enabled.
- Prompt-injection fixtures exist.
- Permission layer exists, even if initially simple.
- Send action is impossible without explicit approval.

Before enabling AI write actions:

- Structured action schema exists.
- Action validator exists.
- Audit events exist.
- Tests cover denied actions.
- User can inspect and reverse supported actions.

Before public distribution:

- Google OAuth verification path is understood.
- App signing and notarization are configured.
- Dependency and secret scanning are enabled.
- Local data deletion is implemented.
- Threat model is reviewed and updated.

## Open Questions

- What exact local encryption strategy should be used for email cache and memory?
- Should auto-move-to-`done` be disabled during an initial training period?
- Should unsubscribe actions default to approval-required?
- What local data should be included in audit logs versus omitted for privacy?
- Should memory writes require review for the first version?
- What is the safest way to preview external research without exposing private context?
