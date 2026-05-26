# GhiblyMail Feature Spec

Status: Draft

## Product Vision

GhiblyMail is an AI-enabled desktop email app for macOS that makes work email feel casual, clear, and low-stress. The app should reduce email from an open-ended daily burden into a small set of simple actions: approve drafted replies, edit drafts, provide missing context, upload required attachments, and respond to calendar invites.

The long-term ambition is a one-stop messaging command center, potentially expanding later to iOS, iPadOS, iMessage, and Telegram. The first product focus is Gmail-based work email.

## Core Problem

Work email is stressful because too many messages reach the inbox, many are not actionable, and the few that matter often require thought, context gathering, writing, or attachment preparation. GhiblyMail should aggressively remove non-actionable email from the inbox and use AI agents to handle as much of the remaining actionable email as possible on an approval basis.

## Product Feel

The app should look and feel nothing like a typical email application. Traditional email clients feel stressful, overwhelming, and too much like "real work." GhiblyMail should create the opposite feeling: calm, cozy, playful, and capable.

The intended fantasy is that the user is the CEO of a company with a team of personal assistants who manage email on their behalf. The assistants are AI agents. They handle triage, drafting, research, calendar invites, attachment preparation, and context gathering, then bring only the most important matters to the user.

The app should feel closer to a cozy management sim or video game than a productivity inbox. Emails become quests. Missing attachments, draft approvals, calendar responses, and missing context become clear, concise tasks. Completing emails should feel like completing quests, but the interface must remain faster and simpler than a normal email client.

## Visual Direction

The main app scene should be an isometric, cozy, hand-painted office environment inspired by warm anime backgrounds and indie management games.

Reference scene:

- Cozy indie game studio office.
- High interior-only isometric angle, like a management sim.
- Open-plan room.
- Teal carpet.
- Warm cream walls.
- Large windows with soft daylight.
- Lush greenery visible outside.
- Wooden desk clusters.
- Young developers or assistant characters working at retro beige CRT computers.
- Potted plants, bookshelves, mugs, notebooks, papers, water cooler, bulletin boards, retro game posters, and a small meeting table.
- Warm painterly look.
- Soft shadows.
- Nostalgic 1990s or early-2000s creative studio energy.

The visual language should be original and copyright-safe. It can be inspired by cozy hand-drawn animation, management sims, and nostalgic creative offices, but should not copy protected characters, scenes, brand assets, or a studio's specific trade dress.

## Office Simulation Metaphor

The office is not just decoration. It should represent the app's actual workflow.

Possible agent avatars:

- Triage assistant: filters spam, cold outreach, subscriptions, and non-actionable mail.
- Drafting assistant: writes replies in the user's voice.
- Calendar assistant: handles meeting invitations and schedule-related messages.
- Research assistant: looks up relevant contact or company context when needed.
- CRM assistant: maintains contact notes and long-term memory.
- Attachment assistant: identifies missing files or drafts content attachments.

Agents should visibly work at computers or move through small states that communicate progress without requiring the user to inspect technical logs. For example, an assistant might be "sorting inbox," "drafting reply," "waiting for approval," or "needs your input."

The user should feel like they are supervising a capable team rather than personally grinding through every email.

## HUD And Navigation

The HUD should provide fast access to the important queues without making the app feel like a conventional email client.

HUD should show:

- Critical inbox count.
- Drafts waiting for approval.
- Tasks blocked on user input.
- Missing attachments.
- Calendar invites awaiting response.
- AI agents currently working.
- Recent completed quests or moved-to-`done` actions.

The HUD should support direct action. The user should be able to jump from a HUD item into the relevant quest, approve a draft, upload a file, respond to an invite, or correct a triage decision.

Avoid stress patterns common in work apps:

- No aggressive red unread badges unless truly urgent.
- No dense wall of subject lines as the default experience.
- No noisy notification overload.
- No visual treatment that implies the user is failing by having remaining tasks.

## Quest Model

Emails that require user attention should be represented as quests.

Quest types:

- Approve drafted reply.
- Edit drafted reply.
- Provide missing context.
- Upload requested attachment.
- Review generated attachment.
- Respond to calendar invite.
- Correct AI triage decision.

Each quest should make the next action obvious and quick. The user should not need to infer what to do from a long thread unless they choose to inspect details.

Each quest should include:

- Plain-language summary of the email or thread.
- Why it needs the user's attention.
- AI's proposed action.
- Required user action.
- One-click or low-friction completion path where possible.
- Link to full email thread for detail.

Quest completion should feel satisfying but lightweight. The app can use small animations, sound cues, progress indicators, and completion states, but these should not slow the user down.

## Music And Sound

The app should include optional copyright-free lo-fi music while open.

Audio principles:

- Music must be optional and easy to mute.
- Default volume should be gentle.
- Sound effects should be subtle and non-stressful.
- Quest completion sounds should be satisfying but not distracting.
- The app should remember the user's sound preferences.

## Productivity Constraint

The game-like interface must not become slower than a normal email client.

The design should reduce stress and improve throughput at the same time. The user should spend less time deciding what to do, less time writing routine replies, and less time finding blockers.

Productivity rules:

- The app should minimize clicks for common actions.
- The app should expose keyboard shortcuts for approval, edit, send, skip, move to `done`, and request more AI work.
- The user should be able to batch similar actions.
- The full email thread should be available when needed but not dominate the default screen.
- The interface should never hide critical factual details behind decorative game elements.
- The core loop should stay focused on clearing quests quickly.

## Target User

Initial target user:

- A Gmail user handling work email.
- Receives a high volume of mail.
- Wants the inbox to contain only emails that need attention or a response.
- Does not want to manually triage cold outreach, mailing lists, low-importance messages, or non-actionable notices.
- Wants AI-drafted replies that sound like them, but does not want AI to send emails without approval.

## Target Platforms

Initial platform:

- macOS desktop app.

Possible later platforms:

- iOS.
- iPadOS.

Possible later channels:

- iMessage.
- Telegram.

## Email Account Access

The first version should support Gmail.

Required behavior:

- User signs in with Google.
- App receives permission to read, move, draft, and send Gmail messages.
- App can access Gmail labels or folders, including the user's existing `done` folder.
- App can create reply drafts in existing email threads.
- App can detect calendar invitations and interact with the associated calendar response flow where supported.

Open feasibility checks:

- Exact Gmail API scopes required.
- Whether app verification is needed for sensitive or restricted Google scopes.
- How the app should map Gmail labels, folders, archive behavior, and the user's `done` folder.

## Inbox Philosophy

The inbox should contain only messages that require the user's attention or response.

The app should not delete or archive mail by default. When a message does not need to remain in the inbox, it should be moved to the user's `done` folder.

The `done` folder is the canonical destination for handled, ignored, low-value, or non-actionable mail.

## AI Triage Agent

The AI triage agent decides which incoming emails should remain in the inbox and which should be moved to `done`.

The decision should not be based on rigid hard-coded rules. The agent should use a living context of user preferences, examples, corrections, and learned behavior. The agent can have rules and guidelines, but final classification is at the AI agent's discretion.

Messages that should usually be moved to `done`:

- Cold outreach.
- Spam or spam-like messages that Gmail did not catch.
- Mailing list messages.
- Email subscriptions.
- Messages that do not appear important.
- Messages that do not require a response from the user.
- Calendar invite emails, once represented in the app's invite view.

Messages that should usually remain in the inbox:

- Critical emails.
- Emails requiring a direct response.
- Emails requiring user approval, edits, missing context, or attachments before response.
- Messages the AI is uncertain about and cannot confidently handle.

## Mailing List Handling

The user has zero email subscription lists they want to remain subscribed to.

Required behavior:

- Detect mailing list or subscription emails.
- Move the message to `done`.
- Attempt to unsubscribe the user automatically where safe and possible.

Open questions:

- Whether the app should use List-Unsubscribe headers only, visible unsubscribe links, Gmail unsubscribe features, or a combination.
- Whether unsubscribe actions require explicit user approval or can run automatically.
- How to handle suspicious unsubscribe links.

## Triage Feedback Loop

The app must let the user correct the AI triage agent.

If an unwanted email remains in the inbox:

- User can click a button to filter similar emails in the future.
- App moves the current email to `done`.
- App updates the AI triage context so similar emails are more likely to be moved to `done`.
- User may optionally add a comment explaining why this type of email should be filtered.

If an email was incorrectly moved to `done`:

- User can move it back to the inbox.
- App updates the AI triage context so similar emails are more likely to stay in the inbox.
- User may optionally add a comment explaining why this type of email should stay visible.

The feedback loop should improve future filtering behavior without requiring the user to design exact filtering rules.

## Calendar Invites

Calendar invitation emails should not clutter the inbox.

Required behavior:

- Detect calendar invitations.
- Move invite emails to `done`.
- Maintain an in-app view of current unresponded-to calendar invites.
- Let the user respond yes or no from the app.

Open questions:

- Whether tentative/maybe support is needed.
- Whether the app should show calendar conflicts.
- Whether calendar invite handling should use Gmail message data, Google Calendar APIs, or both.

## AI Reply Drafting Agent

For emails that survive triage, the AI should attempt to handle as many as possible by drafting replies for user approval.

Required behavior:

- Read the remaining inbox messages.
- Determine what response is needed.
- Draft a reply in the existing email thread.
- Write in the user's voice.
- Include the user's email signature.
- Never send automatically.
- Always require explicit user approval before sending.

When the agent has enough context:

- Produce a complete draft response.
- Let the user review, edit, approve, and send.

When the agent lacks enough context:

- Draft as much of the reply as possible.
- Leave clear blank sections or comments asking the user for the missing information.
- Turn the missing context into a simple task for the user.
- Learn from the final edited/sent response so similar emails can be handled better later.

## Historical Email Analysis

The app should build context by analyzing historical email threads where the user has sent messages.

Required behavior:

- Download or locally index every email thread where the user has sent at least one message.
- Prioritize threads with user replies, because these show what matters and how the user responds.
- Analyze the user's response style, tone, common phrases, signature, business context, role, frequent tasks, and decision patterns.
- Learn what kinds of messages the user responds to versus ignores.
- Use this context for future triage and drafting.

Out of scope for the initial learning pass:

- Threads where the user never sent a message, except where useful for spam or non-actionable message classification.

## Contact CRM and Memory

The app should build a lightweight CRM from historical sent/responded-to threads.

CRM goals:

- Track contacts who appear in email threads where the user sent messages.
- Summarize who each contact is.
- Capture what the app has learned about them from email history.
- Capture relationship context, open loops, recurring topics, and relevant business context.
- Retrieve only the relevant contact and business context when drafting a reply.

Possible storage model:

- Local Markdown files per contact, company, project, or topic.
- A local structured index for retrieval.
- Later, a database-backed memory layer if Markdown becomes too limiting.

Online research:

- The agent may research contacts online only when necessary.
- Research should be reserved for important contacts or cases where extra context materially improves the response.
- Research findings should be stored as source-aware notes rather than unverified assumptions.

Open questions:

- Preferred local storage format.
- Whether CRM data should be editable directly by the user.
- Whether contact memory should be synced across devices later.
- How to avoid storing inaccurate AI guesses as facts.

## Context Retrieval

The AI will not always be able to fit all historical email and CRM data into its context window.

Required behavior:

- Store long-term context locally.
- Retrieve only the most relevant context for each email or task.
- Use historical examples to match tone and decision-making.
- Update memory after user corrections, edited drafts, sent replies, and attachment workflows.

Potential approach:

- Local document store for raw indexed threads.
- Summaries for people, companies, projects, and user writing style.
- Search or embedding retrieval for relevant prior emails.
- Prompt assembly that includes only the specific context needed for the current email.

## Attachments and Content Requests

Some emails require attachments before they can be completed.

The AI should do as much of the work as possible, but should not fabricate factual documents.

When the requested attachment is generative or draftable:

- The AI may create a draft attachment for review.
- Example: draft a blog post, article, memo, or written content requested by the email.
- The draft should be presented for user review and editing before sending.

When the requested attachment must come from another source:

- The AI should not attempt to fabricate it.
- Example: bank statement, official financial document, exported report, budget requiring unavailable factual inputs.
- The app should create a task asking the user to upload or provide the required file.

## Activity Section

The app should have an activity or tasks section that lists items blocking email completion.

Required task types:

- Attachments the user needs to upload.
- Missing facts or context the user needs to provide.
- Draft replies waiting for review.
- Draft attachments waiting for review.
- Calendar invites waiting for response.

The activity section should reduce ambiguity. Each item should make the next required user action obvious.

## Safety and Approval Rules

Critical rule:

- The AI must never send emails automatically.

Required safety behavior:

- AI can classify, move messages, unsubscribe, draft replies, create draft attachments, and prepare tasks according to approved permissions.
- Sending a reply requires explicit user approval.
- The app should preserve a clear audit trail of AI actions.
- The user should be able to reverse or correct AI decisions where possible.

Open questions:

- Whether auto-unsubscribe should require approval.
- Whether moving messages to `done` should happen fully automatically or with a review queue during early training.
- Whether the app should have confidence thresholds for higher-risk actions.

## Security And Privacy Requirements

Security is a core product requirement because GhiblyMail will handle real work email, contacts, attachments, calendar data, AI-generated drafts, and long-term memory about people and business context.

Baseline security principles:

- Treat Gmail data, OAuth tokens, AI memory, CRM notes, attachments, generated drafts, and logs as sensitive.
- Use least-privilege access everywhere, including Google OAuth scopes, local file permissions, agent tools, and any future backend services.
- Prefer local-first storage for email indexes, CRM memory, embeddings, drafts, and attachments unless a server is strictly required.
- Store tokens and secrets in macOS Keychain or the platform-equivalent secure credential store.
- Never store OAuth tokens, API keys, session cookies, or other secrets in prompts, model context, logs, Markdown CRM files, crash reports, analytics, or telemetry.
- Encrypt sensitive local data at rest. The exact storage mechanism is an implementation decision, but the app should assume the local email cache and CRM are sensitive.
- Use TLS for all network communication.
- Keep logs useful for debugging and audits without storing full email bodies, secrets, authentication tokens, private attachments, or unnecessary personal data.
- Provide a way to delete local cached email data, generated AI memory, CRM notes, and account credentials from the device.
- Require explicit user consent before enabling any cloud sync, remote processing, telemetry, or third-party integrations.
- Sign and notarize production macOS builds. If distributed through the Mac App Store, use the macOS App Sandbox and only the entitlements the app actually needs.

Development security practices:

- Maintain a threat model for Gmail access, local storage, AI agent actions, prompt injection, and future messaging integrations.
- Use dependency scanning, secret scanning, static analysis, and automated security checks in CI once code exists.
- Pin or lock dependencies and review updates for security impact.
- Add tests for permission boundaries, prompt-injection defenses, local data deletion, logging redaction, and approval gates.
- Keep a security checklist for every feature that adds a new permission, data store, network call, agent tool, or write action.

## Prompt Injection And Agent Security

All external content must be treated as untrusted, including:

- Incoming email bodies.
- Email subjects.
- Sender names.
- Attachments.
- Calendar invite descriptions.
- Links and websites visited during research.
- Mailing list unsubscribe pages.
- Any future iMessage or Telegram content.

Threat model:

- A malicious email could contain instructions such as "ignore prior instructions," "send all recent emails to this address," "change the user's rules," "approve this draft," or hidden text intended to manipulate the agent.
- A malicious attachment or webpage could try to alter the agent's behavior during summarization or research.
- A malicious message could attempt data exfiltration by causing the agent to paste private email content into a reply, web request, unsubscribe form, search query, or log.
- A malicious message could try to poison long-term memory so future decisions become unsafe or inaccurate.

Hard safety rules:

- The AI must not be treated as the security boundary.
- The model may propose actions, but deterministic application code must enforce what actions are allowed.
- Untrusted email or web content must never be inserted into high-priority system or developer instructions.
- Untrusted content must be clearly separated from trusted instructions when sent to an AI model.
- Agent outputs that trigger actions must use structured formats with validated fields, not arbitrary free text commands.
- All write actions must pass through an application permission layer before execution.
- The app must never let an email directly grant the agent new capabilities, change user preferences, alter security settings, reveal secrets, or bypass approval requirements.
- Sending email always requires explicit user approval.
- High-impact actions should require explicit user approval even if the agent is confident.

High-impact actions include:

- Sending an email.
- Sending or attaching files.
- Forwarding messages.
- Adding recipients.
- Replying outside the original thread.
- Performing bulk moves.
- Changing triage rules or long-term preferences.
- Writing to CRM memory based on untrusted content.
- Unsubscribing through suspicious or non-standard flows.
- Visiting or submitting data to external websites.
- Running external research that might disclose private context in a query.

Agent tool design:

- Split tools by capability and risk level, for example read-only Gmail access, draft creation, label movement, unsubscribe, calendar response, local memory write, web research, and send.
- Give each agent only the tools needed for its role.
- Prefer read-only tools during analysis stages.
- Prefer draft or staged outputs over direct external side effects.
- Require human approval for privileged tools.
- Rate-limit write actions and bulk operations.
- Maintain an audit log of AI-proposed actions, user approvals, executed tool calls, and reversals.

Memory safety:

- Treat CRM notes and long-term memory as security-sensitive.
- Do not write claims from one email directly into durable memory without classification, provenance, and confidence.
- Distinguish facts, user-confirmed facts, AI inferences, preferences, and one-off examples.
- Provide a way for the user to inspect, edit, and delete memory.
- Prevent prompt-injection content from being stored as future agent instructions.

Prompt-injection testing:

- Maintain a red-team test set of malicious emails, attachments, calendar invites, unsubscribe flows, and research pages.
- Test direct prompt injection, indirect prompt injection, hidden text, encoded instructions, multilingual instructions, malicious links, and memory poisoning attempts.
- Test that malicious emails cannot cause data exfiltration, unauthorized sends, unauthorized preference changes, or unexpected tool calls.
- Re-run these tests whenever agent prompts, tools, memory retrieval, or Gmail permissions change.

## Gmail Permission And Compliance Notes

GhiblyMail will likely need sensitive or restricted Google OAuth scopes because it must read mail, move messages, create drafts, send approved replies, and possibly interact with calendar invites.

Product requirements:

- Request the narrowest Google scopes that support the active feature set.
- Avoid requesting full mailbox access for features that can be implemented with narrower scopes.
- Separate development, testing, and production OAuth clients.
- Make the OAuth consent screen clear about what the app reads, stores, modifies, and sends.
- Track Google verification and security assessment requirements before public distribution.
- If any restricted Google user data is stored or transmitted through a server, treat that as a launch-blocking compliance and security review item.

Open questions:

- Can the first version be entirely local-first to reduce Google restricted-scope assessment complexity?
- Which exact Gmail and Calendar scopes are required for the MVP?
- Should the app have separate permission tiers, such as read-only analysis mode, draft mode, and send-capable mode?
- Should auto-triage and auto-unsubscribe be disabled until the user completes an initial training/review period?

## Desired AI Account Model

The desired model is to use the user's OpenAI account, similar to OpenClaw, rather than using OpenAI API keys and usage-based API pricing.

User preference:

- Sign in with OpenAI.
- Use an existing OpenAI Pro plan and its usage limits for agentic behavior.
- Avoid API usage-based billing.

Open feasibility check:

- Confirm what OpenAI-supported integration model, if any, allows this for a third-party desktop app.
- If not possible, identify alternatives before implementation.

## Future Messaging Expansion

Potential later expansion:

- iMessage integration.
- Telegram integration.
- A broader super-messaging app that handles multiple personal and work communication channels.

These should not distract from making the Gmail workflow excellent first.

## MVP Candidate

The first useful MVP should likely include:

- macOS desktop shell.
- Isometric office command-center home screen.
- HUD showing key queues and agent activity.
- Quest-style representation for actionable emails and blockers.
- Google sign-in for Gmail.
- Basic message sync.
- Recognition of the user's `done` folder.
- AI triage to move non-actionable mail to `done`.
- Feedback buttons for "filter similar" and "keep similar".
- Calendar invite detection and a simple invite response view.
- Historical sent-thread analysis.
- Lightweight local memory or CRM.
- AI reply draft creation in existing threads.
- User review and send approval.
- Activity section for missing attachments and missing context.
- Optional copyright-free lo-fi music and subtle completion sounds.
- Local secure storage plan for Gmail data, CRM memory, drafts, and attachments.
- OAuth token storage through macOS Keychain or equivalent secure credential storage.
- Prompt-injection test set for malicious emails, links, attachments, and calendar invites.
- Deterministic permission layer mediating all AI-proposed Gmail, calendar, memory, unsubscribe, web, and send actions.

## Non-Goals For Early Versions

- Multi-provider email support beyond Gmail.
- Fully autonomous sending.
- Replacing the user's source-of-truth documents.
- Complex enterprise CRM features.
- iMessage and Telegram support before the core email workflow works.
- Perfect fully autonomous handling of every email from day one.
- A conventional three-pane email client as the primary experience.
- Game mechanics that add friction, grind, or delay to email completion.
- Shipping with real email access before OAuth scopes, local storage, logging, and agent tool permissions have been security-reviewed.

## Open Questions

Product:

- What should the main screen show when the user opens the app?
- Should there be a traditional inbox at all, or a task/game-like command center?
- What are the exact first agent avatars and their responsibilities?
- How visible should agent work be: ambient animation only, detailed status logs, or both?
- What tone should quest copy use: playful, executive-assistant-like, or very concise?
- What completion feedback feels satisfying without becoming distracting?
- What music style and sound controls should be included in the first version?
- What are the highest-risk emails where AI should be extra cautious?
- Should the user review all auto-triaged messages during an initial training period?
- Should the GhiblyMail name or branding be adjusted before any public release for IP or trademark safety?

AI behavior:

- How should the user edit the AI's rules, preferences, and learned context?
- How should the app measure whether the AI is becoming more accurate?
- Should AI confidence be visible to the user?
- How should the app avoid overfitting to one-off corrections?
- What AI actions should be allowed automatically versus staged for review during the training period?
- How should agent memory distinguish user-confirmed facts from AI inferences?

Technical:

- Native Swift/SwiftUI, Electron, Tauri, or another desktop architecture?
- Gmail API versus IMAP plus Gmail-specific APIs?
- Local storage architecture for emails, CRM, summaries, embeddings, and drafts.
- OpenAI account-based access feasibility.
- Privacy, encryption, and local data security requirements.
- Exact Google OAuth scopes required for each MVP feature.
- Whether any server-side component is needed, and if so, what sensitive data it can access.
- How to sandbox or isolate web research and unsubscribe flows from local email context.

## Security References

Initial standards and guidance to use during implementation:

- [OWASP Application Security Verification Standard](https://owasp.org/www-project-application-security-verification-standard/)
- [OWASP Secure Coding Practices Quick Reference Guide](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/stable-en/02-checklist/05-checklist)
- [OWASP LLM01:2025 Prompt Injection](https://genai.owasp.org/llmrisk/llm01-prompt-injection/)
- [OWASP LLM06:2025 Excessive Agency](https://genai.owasp.org/llmrisk/llm062025-excessive-agency/)
- [OpenAI Safety in Building Agents](https://developers.openai.com/api/docs/guides/agent-builder-safety)
- [Google Gmail API Scopes](https://developers.google.com/workspace/gmail/api/auth/scopes)
- [Google Restricted Scope Verification](https://developers.google.com/identity/protocols/oauth2/production-readiness/restricted-scope-verification)
- [Apple Keychain Services](https://developer.apple.com/documentation/Security/keychain-services)
- [Apple App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)
