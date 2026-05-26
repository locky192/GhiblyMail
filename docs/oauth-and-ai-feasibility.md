# OAuth And AI Feasibility Notes

Status: Draft

Last reviewed: 2026-05-26

## Summary

Two feasibility questions affect the implementation plan:

1. What Google OAuth scopes are required for Gmail and Calendar features?
2. Can GhiblyMail use the user's existing ChatGPT/Codex account and limits instead of API usage-based billing?

Current recommendation:

- Build the first prototype with mock data.
- Use the local Codex installation as the first AI runtime.
- Use the installed Codex Gmail plugin for the first live Gmail experiment.
- Keep the first live Gmail milestone no-write: read limited mailbox data and return quest proposals only.
- Avoid any server-side handling of Gmail restricted-scope data unless absolutely necessary.
- Keep direct Google OAuth and OpenAI API integration as fallback paths, not the first implementation path.

Verified local state on 2026-05-26:

- Codex CLI is installed.
- Codex is logged in with ChatGPT-managed auth on a Pro plan.
- `gmail@openai-curated` is installed and enabled.

## Google OAuth Findings

Google's Gmail API scope documentation says apps should choose the most narrowly focused scopes possible and avoid scopes they do not require. It classifies many Gmail scopes needed by GhiblyMail as restricted.

Relevant Gmail scopes:

| Feature | Likely Scope | Classification | Notes |
| --- | --- | --- | --- |
| See/edit labels | `https://www.googleapis.com/auth/gmail.labels` | Non-sensitive | Useful for discovering and managing labels, but not enough to read messages. |
| Read message metadata only | `https://www.googleapis.com/auth/gmail.metadata` | Restricted | Headers and labels only, no body. Could support early indexing experiments. |
| Read message bodies | `https://www.googleapis.com/auth/gmail.readonly` | Restricted | Needed to analyze historical threads and draft replies. |
| Create/manage drafts | `https://www.googleapis.com/auth/gmail.compose` | Restricted | Needed to create drafts in Gmail. |
| Send only | `https://www.googleapis.com/auth/gmail.send` | Sensitive | May support approved sending, but not reading or composing drafts. |
| Read, compose, and send, including label modification | `https://www.googleapis.com/auth/gmail.modify` | Restricted | Likely needed for the full app if it reads mail, creates drafts, sends, and moves messages to `done`. |
| Full mailbox including permanent delete | `https://mail.google.com/` | Restricted | Avoid. Google notes this should be requested only when immediate permanent deletion is needed. GhiblyMail does not need this. |

Relevant Calendar scopes:

| Feature | Likely Scope | Notes |
| --- | --- | --- |
| Read calendar events | `https://www.googleapis.com/auth/calendar.events.readonly` | Enough for invite visibility in some flows. |
| Read any calendar | `https://www.googleapis.com/auth/calendar.readonly` | Broader read access. |
| View and edit events | `https://www.googleapis.com/auth/calendar.events` | Likely needed to RSVP yes/no to invites. |
| Full calendar access | `https://www.googleapis.com/auth/calendar` | Avoid unless needed; broader than event-level access. |

## Google Verification Implications

Production concerns:

- Gmail read, compose, metadata, and modify scopes are restricted.
- Sensitive or restricted scopes generally require OAuth app verification unless an exception applies.
- Google says restricted scopes provide wide access to Google user data and require restricted-scope verification.
- If restricted-scope data is stored on or transmitted through servers, Google states a security assessment is required.
- Development, testing, and staging projects can use test users without production verification, but users may see warning screens and token limits can apply.

Architecture implication:

- A local-first desktop app with no server-side Gmail processing may reduce the security-assessment burden, but this must be confirmed before public launch.
- If the app ever syncs Gmail data through a backend, that becomes a major compliance and security milestone.

## Recommended Gmail Rollout

1. Mock data only.
2. Codex bridge readiness check.
3. Codex Gmail plugin no-write inbox read.
4. Structured quest JSON from Codex.
5. Local read-only index.
6. Draft-only flow after explicit user action.
7. Label movement to `done` after approval or configured training-mode rules.
8. Approved send, still requiring a user gesture.
9. Calendar read-only invite view.
10. Calendar RSVP using event write permissions.

Open implementation question:

- Whether packaged GhiblyMail should continue using Codex's Gmail plugin, own a direct Google OAuth client, or support both.
- If direct OAuth is needed later, whether `gmail.modify` alone can cover the practical full Gmail MVP more cleanly than combining several narrower scopes. Even if so, the app should still maintain its own internal permission tiers.

## Codex Account-Based Access Findings

Desired product behavior:

- User signs in with ChatGPT/Codex.
- App uses the user's existing ChatGPT Pro plan and Codex usage limits.
- App avoids API usage-based billing.

Current finding:

- Codex app-server exposes ChatGPT-managed authentication, rate-limit/account state, conversation threads, approvals, app connectors, and plugin state.
- Codex SDK documentation describes integrating Codex within an application.
- Codex plugin documentation explicitly includes a Gmail plugin for reading and managing Gmail.
- The official Codex inbox use case describes using the Gmail plugin to review Gmail, find messages needing attention, and draft replies.
- The local machine now has the Gmail plugin installed and enabled.

Conclusion:

- For local development and the first MVP spike, Codex direct is viable and preferable to OpenClaw.
- Use Codex app-server or the Codex SDK as the supported integration surface.
- Do not build against OpenAI API billing for the first Gmail experiment.
- Treat long-term redistribution, App Store packaging, iOS/iPadOS support, and multi-user production terms as open product/legal checks.

Architecture implication:

- The app should keep an `AgentRuntime` abstraction, but its first real implementation should be Codex-backed.
- GhiblyMail should call Codex through a narrow local bridge, not through a terminal UI.
- GhiblyMail should own the permission layer and audit log even when Codex owns Gmail connector access.
- The Gmail plugin should be used first in read/proposal mode, with writes added only after approval handling is proven.

Candidate AI access options:

1. Mock agent runtime for UI and security development.
2. Codex app-server through a local bridge.
3. Codex SDK through a local Node helper.
4. API-backed runtime using OpenAI Platform billing, with user-controlled API key or a backend service.
5. Local model runtime for some classification or drafting tasks, depending on quality and hardware constraints.
6. Hybrid runtime where low-risk triage uses a smaller/local model and high-value drafting uses Codex or another stronger remote model.

## References

- [Google Gmail API scopes](https://developers.google.com/workspace/gmail/api/auth/scopes)
- [Google restricted scope verification](https://developers.google.com/identity/protocols/oauth2/production-readiness/restricted-scope-verification)
- [Google Workspace API user data and developer policy](https://developers.google.com/workspace/workspace-api-user-data-developer-policy)
- [Google Calendar API scopes](https://developers.google.com/workspace/calendar/api/auth)
- [OpenAI ChatGPT and API billing systems](https://help.openai.com/en/articles/9039756-managing-billing-settings-on-chatgpt-web-and-platform)
- [OpenAI ChatGPT Pro help](https://help.openai.com/en/articles/9793128-what-is-chatgpt-pro/)
- [OpenAI API authentication](https://developers.openai.com/api/reference/overview)
- [OpenAI Apps SDK](https://developers.openai.com/apps-sdk)
- [Codex plugins](https://developers.openai.com/codex/plugins)
- [Codex app-server](https://developers.openai.com/codex/app-server)
- [Codex SDK](https://developers.openai.com/codex/sdk)
- [Codex manage your inbox use case](https://developers.openai.com/codex/use-cases/manage-your-inbox)
