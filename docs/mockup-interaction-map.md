# GhiblyMail MVP Mockup Interaction Map

Status: Draft

This map keeps the V1 home-screen mockup finite. Many clickable areas on the home screen are alternate entries into the same small set of goal-oriented work screens. Destination screens should keep the office/HUD theme, avoid conventional inbox views, and focus on approving automation outcomes quickly.

## Screen Set

| Screen | Mockup | Purpose |
| --- | --- | --- |
| Main Office Home | `Assets/Mockups/main-office-home-v1.png` | Top-level office overview and navigation hub |
| Quest Command Board | `Assets/Mockups/quest-command-board-v1.png` | Unified queue for all email quests, with grouped counts and one selected next action |
| Draft Review | `Assets/Mockups/draft-review-v1.png` | Approve, edit, or request more context for AI-drafted replies |
| Calendar Invites | `Assets/Mockups/calendar-invites-v1.png` | Review meeting invites and approve recommended calendar responses |
| Attachment Requests | `Assets/Mockups/attachment-requests-v1.png` | Resolve blocked email tasks that need files or generated attachments |
| Mailing List Cleanup | `Assets/Mockups/mailing-list-unsubscribe-v1.png` | Approve unsubscribe or keep decisions for mailing lists |
| Triage Tuning | `Assets/Mockups/triage-tuning-v1.png` | Correct automation classification and improve future filtering |
| Daily Brief & Plan | `Assets/Mockups/daily-brief-plan-v1.png` | One compact briefing, priority plan, and safe batch actions for the day |
| Settings & Connections | `Assets/Mockups/settings-connections-v1.png` | Gmail, Codex, focus mode, music, safety, and agent controls |
| Performance & Achievements | `Assets/Mockups/performance-achievements-v1.png` | Time saved, completed work, streaks, and achievement progress |

## Home Screen Interactables

| V1 control | Destination | Notes |
| --- | --- | --- |
| Top-left profile/day/status card | Daily Brief & Plan | Opens the concise day overview rather than a profile/settings page |
| Critical counter | Quest Command Board | Pre-filtered to critical responses |
| Drafts counter | Draft Review | Opens the next draft needing approval |
| Blocked counter | Attachment Requests | Blocked MVP work is primarily missing context/files |
| Invites counter | Calendar Invites | Opens invite queue |
| Lists counter | Mailing List Cleanup | Opens unsubscribe review queue |
| Focus Mode | Settings & Connections | Toggle is editable inline on the settings screen |
| Lofi Beats | Settings & Connections | Toggle is editable inline on the settings screen |
| Codex readiness | Settings & Connections | Opens integration status and agent controls |
| Gmail connection | Settings & Connections | Opens connection health and sync controls |
| Settings gear | Settings & Connections | Opens the same compact settings screen |
| Memory & Research station | Triage Tuning | Memory changes are reviewed as tuning/learning events |
| Triage Desk station | Triage Tuning | Opens classification review |
| Calendar Desk station | Calendar Invites | Same destination as Invites counter |
| Drafting Studio station | Draft Review | Same destination as Drafts counter |
| Attachment Lab station | Attachment Requests | Same destination as Blocked counter |
| Studio Activity panel | Triage Tuning | Opens recent automation review and correction history |
| Agents/status strip | Settings & Connections | Opens agent health and safety controls |
| Quick Brief | Daily Brief & Plan | Same combined brief/plan screen |
| Prioritize | Daily Brief & Plan | Opens priority tab/state within the combined screen |
| Daily Plan | Daily Brief & Plan | Opens plan tab/state within the combined screen |
| Performance | Performance & Achievements | Combined with achievements to avoid extra pages |
| Achievements | Performance & Achievements | Combined with performance to avoid extra pages |
| Today's Quests category rows | Matching work screen | Rows route to the same five work queues listed above |
| View All Quests | Quest Command Board | Full MVP command queue |

## Destination-Screen Interactables

Destination screens share these rules:

- Home/back controls return to `Assets/Mockups/main-office-home-v1.png`.
- Category tabs, sort chips, segmented controls, and toggles change state inline on the same screen; they do not create separate mockup pages.
- Primary approve/run buttons show an inline completion state or update counts on the same screen; they do not create separate confirmation pages.
- Edit actions open inline editors or lightweight sheets inside the same mockup screen.
- Destructive or external actions remain approval-based and auditable, but the MVP visual set does not add separate modal mockups unless implementation later requires them.

| Screen | New interactables | Result |
| --- | --- | --- |
| Quest Command Board | Queue filters, selected quest rows, Run Safe Batch, Open Focused Task, Home | Filters/selection update inline; focused task routes to Draft Review, Calendar Invites, Attachment Requests, Mailing List Cleanup, or Triage Tuning; Home returns to Main Office Home |
| Draft Review | Approve Draft, Edit, Needs More Context, Skip, Home | Approval/context/edit states stay on Draft Review; Home returns |
| Calendar Invites | Accept Recommended, Decline, Propose Time, Batch Accept Safe, Home | Decision states stay on Calendar Invites; Home returns |
| Attachment Requests | Upload File, Let Codex Draft, Mark Not Needed, Ask Sender, Home | File/context states stay on Attachment Requests; Home returns |
| Mailing List Cleanup | Unsubscribe, Keep, Batch Unsubscribe Safe, Undo Last, Home | Decisions stay on Mailing List Cleanup; Home returns |
| Triage Tuning | Mark Important, Move to Done, Restore to Inbox, Teach Rule, Home | Feedback and rule chips stay on Triage Tuning; Home returns |
| Daily Brief & Plan | Run Morning Agents, Approve Safe Drafts, Review Blockers, tab controls, Home | Actions update the same plan screen or route to the matching queue; Home returns |
| Settings & Connections | Gmail reconnect, Codex check, Focus/Music toggles, Agent safety controls, Home | Toggle/status changes stay on Settings & Connections; Home returns |
| Performance & Achievements | Time range tabs, badge details, Share/Export disabled for MVP, Home | Tabs/details update inline; Home returns |

## Continuity Requirements

- Every destination screen should look like it belongs on top of the V1 office: warm cream panels, teal/amber/coral/blue accents, compact game-HUD controls, 8px maximum corner radius, and restrained information density.
- Screens should never show full email body text or a dense inbox list.
- The primary user action on each work screen should be obvious and should reduce time spent in Gmail.
- The user should be able to return to the office from every destination with one click.
