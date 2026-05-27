# GhiblyMail Feature-Complete MVP Implementation Plan

Status: Draft

This plan converts the V1 home mockup and destination mockups into a finite, local-only MVP implementation. The MVP should feel like the mockups, but the product constraint is more important than literal decoration: every implemented control must either shorten time spent in email, explain automation state, or return the user to the office.

## Scope Rules

- Local-only MVP: no hosted services, no cloud database, no background server.
- Gmail/Codex actions remain proposal-first and approval-gated. Live connector execution stays behind the existing local Codex bridge and label policy.
- No dense inbox, no full email body reader, and no unmanaged nested pages.
- Every visible button must either perform a local state transition, route to one of the finite screens, open an inline panel/sheet, or be visibly disabled with an MVP reason.
- All destructive or external actions must create audit events.

## Navigation Model

Implement a shallow app router with these screens:

| Screen | Route | Source mockup |
| --- | --- | --- |
| Office Home | `home` | `Assets/Mockups/main-office-home-v1.png` |
| Quest Command Board | `questBoard(filter:)` | `Assets/Mockups/quest-command-board-v1.png` |
| Draft Review | `draftReview` | `Assets/Mockups/draft-review-v1.png` |
| Calendar Invites | `calendarInvites` | `Assets/Mockups/calendar-invites-v1.png` |
| Attachment Requests | `attachmentRequests` | `Assets/Mockups/attachment-requests-v1.png` |
| Mailing List Cleanup | `mailingListCleanup` | `Assets/Mockups/mailing-list-unsubscribe-v1.png` |
| Triage Tuning | `triageTuning` | `Assets/Mockups/triage-tuning-v1.png` |
| Daily Brief & Plan | `dailyBriefPlan(tab:)` | `Assets/Mockups/daily-brief-plan-v1.png` |
| Settings & Connections | `settingsConnections` | `Assets/Mockups/settings-connections-v1.png` |
| Performance & Achievements | `performanceAchievements(range:)` | `Assets/Mockups/performance-achievements-v1.png` |

Inline-only controls:

- Filter chips, segmented tabs, sort menus, confidence/range controls, and selected row changes.
- `More Options`, `Manage rules`, `View full history`, `View all preferences`, `Learn more`, `View activity log`, `View all achievements`, and badge details.
- Edit/context/file/note panels that can be represented with local sheet state.

## Feature Inventory By Mockup

### Office Home

Features:

- Edge-to-edge cozy office scene with agent station markers.
- Top-left day/status/profile card opens Daily Brief & Plan.
- Top counters route to focused work screens: Critical to Quest Board, Drafts to Draft Review, Blocked to Attachment Requests, Invites to Calendar Invites, Lists to Mailing List Cleanup.
- Top-right service controls route to Settings & Connections.
- Station markers route to their workbench screens.
- Studio Activity and agent/status strip route to Triage Tuning and Settings & Connections.
- Bottom nav routes to Daily Brief & Plan, Performance & Achievements, and Quest Board.
- Today’s Quests rows route to the matching work screen.

Definition of Done:

- Home screen visually follows V1: office-first, floating HUD, compact counters, station markers, bottom quest/activity panels.
- Every clickable home control routes deterministically.
- Counts are derived from local store state, not hard-coded view literals.
- No home control opens an undefined screen.

Automated tests:

- Store/router test: all `HomeAction` values map to valid `AppScreen` routes.
- Store test: category counts update after quest actions.
- View model test: station and quest row actions select the expected screen/filter.

### Quest Command Board

Features:

- Unified category list with counts and current filter.
- Recommended next quest based on priority, status, and filter.
- Automation summary: drafts ready, waiting on user, moved to done, safe batch count, time saved.
- Quick filters and sort update inline.
- `Open Focused Task` routes to the selected quest’s focused screen.
- `Run Safe Batch` completes low-risk safe quests locally after audit proposal/approval.

Definition of Done:

- Board can filter by all, critical, drafts, blocked, invites, lists, high impact, due today, waiting, and snoozed where data exists.
- Selected quest remains valid when filters change.
- Safe batch never includes high-risk quests or waiting-on-user blockers.
- Safe batch creates audit events per quest and updates performance metrics.

Automated tests:

- `testQuestBoardFiltersByCategoryAndStatus`.
- `testRecommendedQuestChoosesHighestPriorityReadyQuest`.
- `testOpenFocusedTaskRoutesByQuestKind`.
- `testRunSafeBatchCompletesOnlyLowRiskReadyQuestsAndAuditsEachAction`.

### Draft Review

Features:

- Draft queue grouped by all drafts, needs approval, safe to send, needs more context, edited, skipped.
- Selected draft card with generic metadata, confidence, tone, safety check, context/memory chips, audit trail.
- `Approve Draft` creates an approved local draft action or marks the mock quest complete.
- `Edit` opens inline editor state and marks the draft edited by user.
- `Needs More Context` changes status to waiting on user and records a context request.
- `Skip` marks the draft skipped/moved to done without external send.

Definition of Done:

- Draft Review shows only draft-related quests.
- Draft body preview is concise and bounded; no full inbox/thread reader appears.
- Approval requires explicit user action and records audit history.
- Edit/context/skip states are reversible enough for MVP via audit and selection.

Automated tests:

- `testApproveDraftCompletesDraftAndRecordsAudit`.
- `testEditDraftUpdatesDraftBodyAndEditedState`.
- `testNeedsMoreContextMovesDraftToWaitingAndAddsAudit`.
- `testSkipDraftMovesQuestOutOfActiveDraftQueue`.

### Calendar Invites

Features:

- Invite queue grouped by safe to accept, needs decision, conflicts, maybe.
- Selected invite cards with generic title, time, conflict status, recommended response.
- Daily mini timeline from local mock calendar data.
- Codex reasoning notes.
- `Batch Accept Safe`, `Accept Recommended`, `Decline`, and `Propose Time` update invite decision state locally and audit.

Definition of Done:

- Calendar screen shows invite quests only and no full calendar app clone.
- Conflict and safe decisions are visible.
- Batch accept excludes conflicts and maybe decisions.
- Calendar write actions are queued/audited, not silently executed.

Automated tests:

- `testCalendarInviteGroupsSafeDecisionAndConflictItems`.
- `testAcceptRecommendedCompletesSelectedInviteAndAudits`.
- `testBatchAcceptSafeSkipsConflicts`.
- `testProposeTimeStoresPendingProposalState`.

### Attachment Requests

Features:

- Blocked queue grouped by upload needed, Codex can draft, ask sender.
- Selected blocker with required checklist, file drop/select affordance, optional note.
- Safety panel showing what Codex can and cannot do.
- `Upload File` records a local attachment placeholder.
- `Let Codex Draft` creates a local generated-document placeholder and marks it pending approval.
- `Mark Not Needed` resolves the blocker with audit.
- `Ask Sender` creates a local request-draft action.
- `More Options` opens an inline options sheet for MVP.

Definition of Done:

- Attachment screen shows upload/provide-context blockers only.
- File selection is local-only; no file contents are exfiltrated.
- Generated document placeholders are clearly drafts and require approval.
- Every resolution creates audit history.

Automated tests:

- `testUploadFileAddsLocalAttachmentReferenceWithoutReadingContents`.
- `testLetCodexDraftCreatesPendingAttachmentDraft`.
- `testMarkNotNeededCompletesBlockedQuestAndAudits`.
- `testAskSenderCreatesRequestDraftAuditEvent`.

### Mailing List Cleanup

Features:

- Mailing list queue grouped by safe to unsubscribe, review, keep likely.
- Selected candidate with frequency, confidence, engagement, unsubscribe safety preview.
- Automation rules panel with inline toggles.
- Audit log.
- `Batch Unsubscribe Safe`, `Unsubscribe`, `Keep`, and `Undo Last`.

Definition of Done:

- Unsubscribe actions require approval and are auditable.
- Batch unsubscribe only includes safe high-confidence list quests.
- Keep removes the item from active cleanup without external action.
- Undo restores the last local mailing-list decision.

Automated tests:

- `testBatchUnsubscribeOnlyCompletesSafeHighConfidenceLists`.
- `testUnsubscribeSelectedListAuditsManualApproval`.
- `testKeepListMarksQuestCompleteWithoutExternalAction`.
- `testUndoLastMailingListDecisionRestoresQuestStatus`.

### Triage Tuning

Features:

- Recent automation decisions grouped by review classification, memory learned, moved to done, needs correction.
- Selected decision with confidence, classification reason, influenced rules, learned preferences, audit trail.
- `Mark Important`, `Move to Done`, `Restore to Inbox`, and `Teach Rule`.
- `Adjust Confidence`, rule chip details, history, and preferences are inline panels.

Definition of Done:

- Triage screen supports correcting classifications without showing a full inbox.
- Feedback updates local preferences/memory and audit trail.
- Restore/move actions obey the existing permission policy.
- Teach Rule creates a user-confirmed local memory/rule entry.

Automated tests:

- `testMarkImportantRaisesPriorityAndAuditsCorrection`.
- `testMoveToDoneCompletesTriageQuestAndAudits`.
- `testRestoreToInboxSetsReadyAndAddsRequiredAction`.
- `testTeachRuleAddsUserConfirmedMemoryEntry`.

### Daily Brief & Plan

Features:

- Tabs for Brief, Priorities, and Plan as inline state.
- Today-in-five-minutes summary from local counts.
- Recommended ordered plan with time estimates and time saved.
- Automation readiness and safe batch suggestions.
- `Run Morning Agents`, `Approve Safe Drafts`, `Review Blockers`, and `Open Quest Board`.

Definition of Done:

- Daily brief derives summaries from store state.
- Tabs switch inline without routing to new screens.
- Run Morning Agents refreshes local mock proposals and audit state.
- Safe draft/blocker buttons route or act predictably.

Automated tests:

- `testDailyBriefSummariesReflectQuestCounts`.
- `testDailyBriefTabSelectionIsInlineState`.
- `testRunMorningAgentsImportsProposalOnlyQuests`.
- `testApproveSafeDraftsCompletesOnlySafeDrafts`.

### Settings & Connections

Features:

- Integration health for Gmail, Codex, Calendar, Drive, Local Memory, and Studio Storage.
- Focus mode, focus window, lofi music, and volume controls.
- Safety mode and approval thresholds.
- Agent health toggles and run-all-agents action.
- `Save Changes`, `Test Connections`, `Pause Agents`, and `Back to Home`.

Definition of Done:

- All settings are local app preferences.
- Agent toggles change local agent state and do not delete data.
- Test Connections uses existing readiness checks.
- Safety thresholds are enforced by batch actions where applicable.

Automated tests:

- `testFocusAndMusicSettingsPersistInStore`.
- `testAgentTogglePausesAndResumesAgentLocally`.
- `testPauseAgentsPausesAllAgents`.
- `testSafetyThresholdBlocksUnsafeBatchActions`.
- `testTestConnectionsUpdatesReadinessAndAudit`.

### Performance & Achievements

Features:

- Time range chips for Today, Week, Month as inline state.
- Metrics: time saved, Gmail trips avoided, quests completed, safe automation rate.
- Trend chart and category completion bars.
- Achievement badges and streaks.
- `Back to Office`, `View Quest Board`, and `Reset Week View`.

Definition of Done:

- Metrics derive from local action history/performance model.
- Range changes update displayed aggregate data inline.
- Reset Week View resets presentation filters only, not audit history.
- Achievements unlock from local metrics and are deterministic in tests.

Automated tests:

- `testPerformanceMetricsUpdateAfterQuestCompletion`.
- `testPerformanceRangeSelectionChangesAggregateWindow`.
- `testAchievementsUnlockFromMetrics`.
- `testResetWeekViewDoesNotDeleteAuditHistory`.

## Cross-Cutting Features

### Audit Trail

Definition of Done:

- Every approval, batch action, setting test, rule creation, memory update, and connector write proposal creates audit events.
- Audit entries include action type, status, quest ID where relevant, and a concise summary.

Automated tests:

- `testEveryMutatingCommandProducesAuditEvent`.
- `testDeniedActionsRemainVisibleInAuditTrail`.

### Permission And Safety

Definition of Done:

- Existing `PermissionPolicy` remains the gate for Gmail/Codex write-like actions.
- Local batch actions evaluate risk/confidence before acting.
- Prompt-injection guard still scans imported proposal content.
- No secrets are checked in.

Automated tests:

- Existing permission and prompt-injection tests continue to pass.
- `testBatchSafetyRejectsHighRiskOrLowConfidenceItems`.
- `scripts/security-check.sh` passes.

### Accessibility And UI Testability

Definition of Done:

- Major buttons and routes have stable accessibility labels/identifiers.
- UI is keyboard navigable for primary routes/actions.
- Text fits at the default desktop size and no required control is hidden behind the office background.

Automated tests:

- View-model routing tests cover all route-producing controls.
- If a UI test target is added, smoke-test launch, route navigation, and primary actions.

## Technical Implementation Plan

### Data Model

Add local app state types:

- `AppScreen`: shallow route enum.
- `QuestFilter`, `QuestSort`, `DailyPlanTab`, `PerformanceRange`, `SafetyMode`.
- `AppSettings`: focus mode, music, volume, safety mode, thresholds, pause window.
- `AgentControlState`: enabled/paused states by role.
- `PerformanceMetrics`: derived counts, time saved, safe automation rate, achievements, streaks.
- `DecisionHistory`: last reversible local decision for undo.

Extend `Quest` only where needed and keep Codable/Sendable compatibility:

- Optional `dueLabel`, `decisionState`, `localAttachmentName`, `draftEdited`, `isSnoozed`, and `categoryTags` if the current fields cannot express mockup state cleanly.

### Store/Reducer

Keep `CommandCenterStore` as the central local store, but split command logic into clear public methods:

- Navigation: `navigate(_:)`, `goHome()`, `openFocusedTask(for:)`.
- Filtering/selection: `setQuestFilter(_:)`, `setSort(_:)`, `selectQuest(id:)`.
- Batch: `runSafeBatch()`, `approveSafeDrafts()`, `batchAcceptSafeInvites()`, `batchUnsubscribeSafeLists()`.
- Drafts: `approveSelectedDraft()`, `editSelectedDraft(body:)`, `requestMoreContextForSelectedDraft()`, `skipSelectedDraft()`.
- Calendar: `acceptSelectedInvite()`, `declineSelectedInvite()`, `proposeTimeForSelectedInvite()`.
- Attachments: `attachLocalFilePlaceholder(name:)`, `draftAttachmentWithCodex()`, `markAttachmentNotNeeded()`, `askSenderForAttachment()`.
- Mailing lists: `unsubscribeSelectedList()`, `keepSelectedList()`, `undoLastDecision()`.
- Triage: `markSelectedImportant()`, `moveSelectedToDone()`, `teachRuleFromSelected()`.
- Settings: `updateSettings(_:)`, `toggleAgent(role:)`, `pauseAllAgents()`, `runAllAgents()`.
- Performance: `setPerformanceRange(_:)`, `resetPerformanceView()`.

### UI Structure

Create reusable components to match the mockups:

- `AppChromeView`: office background, top status card, counters, service controls, and routed content.
- `HUDPanel`, `StatCounterButton`, `RouteButton`, `ActionBar`, `QueueList`, `MetricTile`, `AuditMiniPanel`.
- One view per route: `HomeDashboardView`, `QuestCommandBoardView`, `DraftReviewScreen`, `CalendarInvitesScreen`, `AttachmentRequestsScreen`, `MailingListCleanupScreen`, `TriageTuningScreen`, `DailyBriefPlanScreen`, `SettingsConnectionsScreen`, `PerformanceAchievementsScreen`.

Keep the existing `OfficeSceneView`, placeholder agent sprites, background, theme, bridge, permission, guard, and memory services unless a change is required.

### Assets

Initial implementation can use the existing office background plus SwiftUI-drawn panels/icons/sprites. Generate additional raster sprites only if SwiftUI placeholders materially fail to match the mockups.

Needed local assets if generated later:

- Agent role sprites for triage, drafting, calendar, attachment, memory.
- Small quest completion sparkle/effect.
- Optional paper/file/upload props for attachment screen.

### Verification Commands

- `swift test`
- `swift build`
- `scripts/security-check.sh`
- `scripts/mvp-check.sh` where local Codex/Gmail environment is available.

## Implementation Task List

1. Add route/settings/filter/performance models.
2. Expand `CommandCenterStore` with navigation, derived data, and screen action methods.
3. Add store tests for routing, filters, batches, focused workbench actions, settings, performance, and audit behavior.
4. Build shared HUD/chrome components.
5. Replace the single-board root with route-driven screen rendering.
6. Implement Office Home controls and station routing.
7. Implement Quest Command Board.
8. Implement Draft Review.
9. Implement Calendar Invites.
10. Implement Attachment Requests.
11. Implement Mailing List Cleanup.
12. Implement Triage Tuning.
13. Implement Daily Brief & Plan.
14. Implement Settings & Connections.
15. Implement Performance & Achievements.
16. Add polish: keyboard shortcuts, hover/pressed states, subtle animation, disabled MVP affordance handling.
17. Run full verification and repair failures.
18. Perform final security audit and document results.

## Completion Checklist

- [x] Functional feature inventory implemented.
- [x] Every visible route/action has defined behavior.
- [x] Automated tests cover every feature group above.
- [x] UI visually aligns with the mockups at default desktop size.
- [x] Local-only safety constraints hold.
- [x] Security audit completed and documented.
- [x] Full verification passes.
