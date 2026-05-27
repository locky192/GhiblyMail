import SwiftUI

struct MVPChromeView: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        VStack(spacing: 14) {
            topBar

            Group {
                switch store.screen {
                case .home:
                    HomeDashboardScreen()
                case .questBoard:
                    QuestCommandBoardScreen()
                case .draftReview:
                    DraftReviewScreen()
                case .calendarInvites:
                    CalendarInvitesScreen()
                case .attachmentRequests:
                    AttachmentRequestsScreen()
                case .mailingListCleanup:
                    MailingListCleanupScreen()
                case .triageTuning:
                    TriageTuningScreen()
                case .dailyBriefPlan:
                    DailyBriefPlanScreen()
                case .settingsConnections:
                    SettingsConnectionsScreen()
                case .performanceAchievements:
                    PerformanceAchievementsScreen()
                }
            }
            .animation(.easeInOut(duration: 0.18), value: routeKey)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var routeKey: String {
        switch store.screen {
        case .home: "home"
        case .questBoard(let filter): "quest-\(filter.rawValue)"
        case .draftReview: "draft"
        case .calendarInvites: "calendar"
        case .attachmentRequests: "attachments"
        case .mailingListCleanup: "lists"
        case .triageTuning: "triage"
        case .dailyBriefPlan(let tab): "brief-\(tab.rawValue)"
        case .settingsConnections: "settings"
        case .performanceAchievements(let range): "performance-\(range.rawValue)"
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            if store.screen != .home {
                Button {
                    store.goHome()
                } label: {
                    Label("Home", systemImage: "arrow.left")
                }
                .buttonStyle(ChromeButtonStyle(tint: Theme.paper, foreground: Theme.ink))
                .accessibilityIdentifier("home-button")
            }

            Button {
                store.navigateFromHome(.profileCard)
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    Text("GhiblyMail")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("Tuesday, May 26  •  Morning")
                        .font(.system(size: 12, weight: .bold))
                    ProgressView(value: 0.82)
                        .tint(Theme.teal)
                        .frame(width: 188)
                }
                .frame(minWidth: 220, alignment: .leading)
            }
            .buttonStyle(PlainPanelButtonStyle())

            HStack(spacing: 8) {
                statButton("Critical", value: store.readyCount, icon: "star.fill", tint: Theme.coral) {
                    store.navigate(.questBoard(.critical))
                }
                statButton("Drafts", value: store.draftCount, icon: "pencil", tint: Theme.blue) {
                    store.navigate(.draftReview)
                }
                statButton("Blocked", value: store.blockedCount, icon: "exclamationmark.octagon.fill", tint: Theme.amber) {
                    store.navigate(.attachmentRequests)
                }
                statButton("Invites", value: store.inviteCount, icon: "calendar", tint: Theme.teal) {
                    store.navigate(.calendarInvites)
                }
                statButton("Lists", value: store.mailingListCount, icon: "envelope", tint: Theme.leaf) {
                    store.navigate(.mailingListCleanup)
                }
            }
            .mvpPanel()

            Spacer(minLength: 0)

            serviceButton("Focus", icon: "leaf.fill") { store.navigate(.settingsConnections) }
            serviceButton("Lofi", icon: "music.note") { store.navigate(.settingsConnections) }
            serviceButton("Codex", icon: "externaldrive.connected.to.line.below") { store.navigate(.settingsConnections) }
            serviceButton("Gmail", icon: "envelope.fill") { store.navigate(.settingsConnections) }
            serviceButton("Settings", icon: "gearshape.fill") { store.navigate(.settingsConnections) }
        }
    }

    private func statButton(_ title: String, value: Int, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Label("\(value)", systemImage: icon)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
            }
            .frame(width: 86, height: 58)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("counter-\(title.lowercased())")
    }

    private func serviceButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.deepTeal)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                Circle()
                    .fill(Theme.leaf)
                    .frame(width: 7, height: 7)
            }
            .frame(width: 72, height: 64)
        }
        .buttonStyle(PlainPanelButtonStyle())
    }
}

private struct HomeDashboardScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                stationButtons(in: proxy.size)

                HStack(alignment: .bottom, spacing: 14) {
                    activityPanel
                    Spacer(minLength: 16)
                    bottomNav
                    Spacer(minLength: 16)
                    todayQuests
                }
            }
        }
    }

    private func stationButtons(in size: CGSize) -> some View {
        ZStack {
            station("Memory & Research", subtitle: "Learning", icon: "brain", position: CGPoint(x: 0.24, y: 0.25), size: size) {
                store.navigate(.triageTuning)
            }
            station("Triage Desk", subtitle: "Scanning inbox", icon: "tray.full", position: CGPoint(x: 0.48, y: 0.30), size: size) {
                store.navigate(.triageTuning)
            }
            station("Calendar Desk", subtitle: "\(store.inviteCount) invites", icon: "calendar", position: CGPoint(x: 0.66, y: 0.35), size: size) {
                store.navigate(.calendarInvites)
            }
            station("Drafting Studio", subtitle: "\(store.draftCount) drafts", icon: "pencil", position: CGPoint(x: 0.34, y: 0.55), size: size) {
                store.navigate(.draftReview)
            }
            station("Attachment Lab", subtitle: "\(store.blockedCount) needs files", icon: "paperclip", position: CGPoint(x: 0.58, y: 0.62), size: size) {
                store.navigate(.attachmentRequests)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func station(_ title: String, subtitle: String, icon: String, position: CGPoint, size: CGSize, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(Theme.deepTeal)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                    Text(subtitle)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.teal)
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 48)
        }
        .buttonStyle(PlainPanelButtonStyle())
        .position(x: size.width * position.x, y: size.height * position.y)
    }

    private var activityPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Studio Activity", systemImage: "dot.radiowaves.left.and.right")
                .font(.system(size: 15, weight: .bold))
            ForEach(store.auditEvents.prefix(5)) { event in
                HStack {
                    Image(systemName: icon(for: event.action))
                        .foregroundStyle(Theme.deepTeal)
                    Text(event.summary)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
            }
            Button {
                store.navigate(.triageTuning)
            } label: {
                Label("Review activity", systemImage: "chevron.down")
            }
            .buttonStyle(SecondaryMVPButtonStyle())
        }
        .frame(width: 330, alignment: .leading)
        .mvpPanel()
    }

    private var bottomNav: some View {
        HStack(spacing: 10) {
            nav("Quick Brief", "mug.fill") { store.navigate(.dailyBriefPlan(.brief)) }
            nav("Prioritize", "star.circle.fill") { store.navigate(.dailyBriefPlan(.priorities)) }
            nav("Daily Plan", "checklist") { store.navigate(.dailyBriefPlan(.plan)) }
            nav("Performance", "chart.bar.fill") { store.navigate(.performanceAchievements(.week)) }
            nav("Achievements", "trophy.fill") { store.navigate(.performanceAchievements(.week)) }
        }
        .mvpPanel()
    }

    private var todayQuests: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Today's Quests", systemImage: "flag.fill")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("\(store.completedCount) done")
                    .font(.system(size: 12, weight: .bold))
            }
            questRoute("Critical Responses", count: store.readyCount, tint: Theme.coral) { store.navigate(.questBoard(.critical)) }
            questRoute("Draft Approvals", count: store.draftCount, tint: Theme.blue) { store.navigate(.draftReview) }
            questRoute("Calendar Invites", count: store.inviteCount, tint: Theme.teal) { store.navigate(.calendarInvites) }
            questRoute("Attachments Needed", count: store.blockedCount, tint: Theme.amber) { store.navigate(.attachmentRequests) }
            questRoute("Mailing Lists", count: store.mailingListCount, tint: Theme.leaf) { store.navigate(.mailingListCleanup) }
            Button {
                store.navigate(.questBoard(.all))
            } label: {
                Label("View All Quests", systemImage: "arrow.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryMVPButtonStyle())
        }
        .frame(width: 340, alignment: .leading)
        .mvpPanel()
    }

    private func nav(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.deepTeal)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
            }
            .frame(width: 92, height: 76)
        }
        .buttonStyle(.plain)
    }

    private func questRoute(_ title: String, count: Int, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Circle().fill(tint).frame(width: 10, height: 10)
                Text(title)
                Spacer()
                Text("\(count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .frame(height: 24)
                    .background(tint.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Image(systemName: "chevron.right")
            }
            .font(.system(size: 13, weight: .bold))
        }
        .buttonStyle(.plain)
    }

    private func icon(for action: ActionKind) -> String {
        switch action {
        case .readGmail: "tray.and.arrow.down"
        case .createDraft: "pencil"
        case .moveToDone: "checkmark.circle"
        case .restoreFromDone: "arrow.uturn.left"
        case .queueCalendarInvite: "calendar"
        case .manuallyUnsubscribe, .autoUnsubscribe: "envelope.badge"
        case .sendEmail: "paperplane"
        case .operateOutsideTestLabel: "exclamationmark.triangle"
        case .updateMemory: "brain"
        }
    }
}

private struct QuestCommandBoardScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        ThreeColumnWorkbench(title: "Quest Command Board", icon: "map.fill") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Quest Categories").mvpSectionHeader()
                ForEach(QuestFilter.allCases.prefix(6)) { filter in
                    filterRow(filter)
                }
            }
        } center: {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommended Next Quest").mvpSectionHeader()
                if let quest = store.recommendedQuest {
                    QuestSummaryCard(quest: quest)
                    HStack {
                        Button("Open Focused Task") { store.openFocusedTask(for: quest) }
                            .buttonStyle(PrimaryMVPButtonStyle())
                        Button("Run Safe Batch (\(store.safeBatchCandidates.count))") {
                            Task { await store.runSafeBatch() }
                        }
                        .buttonStyle(SecondaryMVPButtonStyle())
                    }
                } else {
                    EmptyStateView(text: "No quests match this filter.")
                }
                filterChips
            }
        } trailing: {
            AutomationSummaryPanel()
        }
    }

    private var filterChips: some View {
        HStack {
            ForEach([QuestFilter.all, .highImpact, .dueToday, .waitingOnMe, .snoozed]) { filter in
                if store.questFilter == filter {
                    Button(filterLabel(filter)) { store.setQuestFilter(filter) }
                        .buttonStyle(PrimarySmallButtonStyle())
                } else {
                    Button(filterLabel(filter)) { store.setQuestFilter(filter) }
                        .buttonStyle(SecondarySmallButtonStyle())
                }
            }
            Picker("Sort", selection: Binding(get: { store.questSort }, set: { store.setSort($0) })) {
                ForEach(QuestSort.allCases) { sort in
                    Text(sort.rawValue.capitalized).tag(sort)
                }
            }
            .frame(width: 140)
        }
    }

    private func filterRow(_ filter: QuestFilter) -> some View {
        Button {
            store.setQuestFilter(filter)
        } label: {
            HStack {
                Text(filterLabel(filter))
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Text("\(store.quests.filter { matches($0, filter) }.count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Image(systemName: "chevron.right")
            }
            .padding(10)
            .background(store.questFilter == filter ? Theme.teal.opacity(0.16) : Color.white.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func filterLabel(_ filter: QuestFilter) -> String {
        switch filter {
        case .all: "All"
        case .critical: "Critical"
        case .drafts: "Drafts"
        case .blocked: "Blocked"
        case .invites: "Invites"
        case .lists: "Lists"
        case .highImpact: "High Impact"
        case .dueToday: "Due Today"
        case .waitingOnMe: "Waiting on Me"
        case .snoozed: "Snoozed"
        }
    }

    private func matches(_ quest: Quest, _ filter: QuestFilter) -> Bool {
        switch filter {
        case .all: true
        case .critical: quest.priority <= 2 && quest.status != .complete
        case .drafts: quest.kind == .approveDraft && quest.status != .complete
        case .blocked: quest.status == .waitingOnUser || quest.kind == .uploadAttachment || quest.kind == .provideContext
        case .invites: quest.kind == .calendarInvite && quest.status != .complete
        case .lists: quest.kind == .mailingList && quest.status != .complete
        case .highImpact: quest.priority <= 2
        case .dueToday: quest.dueLabel == "Today" || quest.priority <= 2
        case .waitingOnMe: quest.status == .waitingOnUser
        case .snoozed: quest.isSnoozed
        }
    }
}

private struct DraftReviewScreen: View {
    @EnvironmentObject private var store: CommandCenterStore
    @State private var editText = ""

    var body: some View {
        FocusedQuestScreen(
            title: "Draft Review",
            icon: "pencil.and.outline",
            filter: .drafts,
            primaryTitle: "Approve Draft",
            primaryIcon: "paperplane.fill",
            primaryAction: { Task { await store.approveSelectedDraft() } },
            secondary: [
                ScreenAction("Edit", "pencil") {
                    editText = store.selectedQuest?.draftBody ?? ""
                    store.editSelectedDraft(body: editText.isEmpty ? "Edited local draft" : editText)
                },
                ScreenAction("Needs More Context", "questionmark.circle") { store.requestMoreContextForSelectedDraft() },
                ScreenAction("Skip", "nosign") { store.skipSelectedDraft() }
            ],
            trailing: { ContextAuditPanel() }
        )
    }
}

private struct CalendarInvitesScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        FocusedQuestScreen(
            title: "Calendar Invites",
            icon: "calendar",
            filter: .invites,
            primaryTitle: "Batch Accept Safe",
            primaryIcon: "checkmark.circle.fill",
            primaryAction: { Task { await store.batchAcceptSafeInvites() } },
            secondary: [
                ScreenAction("Accept Recommended", "checkmark") { Task { await store.acceptSelectedInvite() } },
                ScreenAction("Decline", "nosign") { store.declineSelectedInvite() },
                ScreenAction("Propose Time", "clock") { store.proposeTimeForSelectedInvite() }
            ],
            trailing: { SchedulePanel() }
        )
    }
}

private struct AttachmentRequestsScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        FocusedQuestScreen(
            title: "Attachment Requests",
            icon: "paperclip.circle.fill",
            filter: .blocked,
            primaryTitle: "Upload File",
            primaryIcon: "icloud.and.arrow.up.fill",
            primaryAction: { store.attachLocalFilePlaceholder(name: "local-placeholder.pdf") },
            secondary: [
                ScreenAction("Let Codex Draft", "sparkles") { store.draftAttachmentWithCodex() },
                ScreenAction("Mark Not Needed", "nosign") { store.markAttachmentNotNeeded() },
                ScreenAction("Ask Sender", "envelope") { store.askSenderForAttachment() }
            ],
            trailing: { SafetyPanel() }
        )
    }
}

private struct MailingListCleanupScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        FocusedQuestScreen(
            title: "Mailing List Cleanup",
            icon: "list.bullet.rectangle.fill",
            filter: .lists,
            primaryTitle: "Batch Unsubscribe Safe",
            primaryIcon: "shield.checkered",
            primaryAction: { Task { await store.batchUnsubscribeSafeLists() } },
            secondary: [
                ScreenAction("Unsubscribe", "trash") { Task { await store.unsubscribeSelectedList() } },
                ScreenAction("Keep", "heart") { store.keepSelectedList() },
                ScreenAction("Undo Last", "arrow.uturn.left") { store.undoLastDecision() }
            ],
            trailing: { RulesAuditPanel() }
        )
    }
}

private struct TriageTuningScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        FocusedQuestScreen(
            title: "Triage Tuning",
            icon: "brain.head.profile",
            filter: .all,
            primaryTitle: "Mark Important",
            primaryIcon: "star.fill",
            primaryAction: { store.markSelectedImportant() },
            secondary: [
                ScreenAction("Move to Done", "checkmark.circle") { store.moveSelectedToDone() },
                ScreenAction("Restore to Inbox", "tray.and.arrow.up") { store.restoreSelectedQuestToInbox() },
                ScreenAction("Teach Rule", "brain") { store.teachRuleFromSelected() }
            ],
            trailing: { LearnedPreferencesPanel() }
        )
    }
}

private struct DailyBriefPlanScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        WorkbenchFrame(title: "Daily Brief & Plan", icon: "sun.max.fill") {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today in 5 Minutes").mvpSectionHeader()
                    metricRow("Emails to handle", value: store.quests.filter { $0.status != .complete }.count, tint: Theme.blue)
                    metricRow("Urgent items", value: store.readyCount, tint: Theme.coral)
                    metricRow("Drafts awaiting you", value: store.draftCount, tint: Theme.blue)
                    metricRow("Calendar invites", value: store.inviteCount, tint: Theme.teal)
                    metricRow("Attachments needed", value: store.blockedCount, tint: Theme.amber)
                    metricRow("Lists to clean up", value: store.mailingListCount, tint: Theme.leaf)
                    Spacer()
                }
                .mvpPanel()

                VStack(alignment: .leading, spacing: 12) {
                    Picker("Daily Plan", selection: Binding(get: { store.dailyPlanTab }, set: { store.setDailyPlanTab($0) })) {
                        ForEach(DailyPlanTab.allCases) { tab in
                            Text(tab.rawValue.capitalized).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    planCard("1", "Handle Critical Items", detail: "\(store.readyCount) items • high impact", tint: Theme.coral)
                    planCard("2", "Approve Drafts", detail: "\(store.draftCount) drafts • ready to send", tint: Theme.blue)
                    planCard("3", "Triage & Clean Up", detail: "Lists, invites, attachments", tint: Theme.leaf)
                    Spacer()
                }
                .mvpPanel()

                AutomationSummaryPanel()
            }

            HStack {
                Button("Run Morning Agents") { Task { await store.runAllAgents() } }
                    .buttonStyle(PrimaryMVPButtonStyle())
                Button("Approve Safe Drafts") { Task { await store.approveSafeDrafts() } }
                    .buttonStyle(SecondaryMVPButtonStyle())
                Button("Review Blockers") { store.navigate(.attachmentRequests) }
                    .buttonStyle(SecondaryMVPButtonStyle())
                Button("Open Quest Board") { store.navigate(.questBoard(.all)) }
                    .buttonStyle(SecondaryMVPButtonStyle())
            }
        }
    }

    private func metricRow(_ title: String, value: Int, tint: Color) -> some View {
        HStack {
            Circle().fill(tint).frame(width: 12, height: 12)
            Text(title)
            Spacer()
            Text("\(value)").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(tint)
        }
        .font(.system(size: 14, weight: .bold))
    }

    private func planCard(_ number: String, _ title: String, detail: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(tint)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(title).font(.system(size: 17, weight: .bold))
                Text(detail).font(.system(size: 12, weight: .medium)).foregroundStyle(Theme.mutedInk)
            }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(12)
        .background(Color.white.opacity(0.36))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct SettingsConnectionsScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        WorkbenchFrame(title: "Settings & Connections", icon: "gearshape.fill") {
            HStack(spacing: 14) {
                settingsPanel("Integrations") {
                    connectionRow("Gmail", "Connected", "envelope.fill")
                    connectionRow("Codex", store.readiness.isReadyForGmailRead ? "Ready" : "Check needed", "externaldrive.connected.to.line.below")
                    connectionRow("Calendar", "Connected", "calendar")
                    connectionRow("Local Memory", "Enabled", "brain")
                    Button("Check All Connections") { Task { await store.checkCodexReadiness() } }
                        .buttonStyle(SecondaryMVPButtonStyle())
                }

                settingsPanel("Focus & Safety") {
                    Toggle("Focus Mode", isOn: settingsBinding(\.focusModeEnabled))
                    Toggle("Lofi Beats", isOn: settingsBinding(\.lofiBeatsEnabled))
                    Slider(value: settingsBinding(\.musicVolume), in: 0...1) {
                        Text("Volume")
                    }
                    Picker("Safety", selection: settingsBinding(\.safetyMode)) {
                        ForEach(SafetyMode.allCases) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Auto-approve safe local actions", isOn: settingsBinding(\.autoApproveSafeActions))
                }

                settingsPanel("Agent Health") {
                    ForEach(AgentRole.allCases) { role in
                        Button {
                            store.toggleAgent(role: role)
                        } label: {
                            HStack {
                                Image(systemName: role.systemImage)
                                Text("\(role.rawValue) Agent")
                                Spacer()
                                Text(store.agents.first { $0.role == role }?.state.rawValue ?? "Idle")
                                    .foregroundStyle(Theme.mutedInk)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    Button("Run All Agents Now") { Task { await store.runAllAgents() } }
                        .buttonStyle(SecondaryMVPButtonStyle())
                }
            }

            HStack {
                Button("Save Changes") { store.updateSettings(store.settings) }
                    .buttonStyle(PrimaryMVPButtonStyle())
                Button("Test Connections") { Task { await store.checkCodexReadiness() } }
                    .buttonStyle(SecondaryMVPButtonStyle())
                Button("Pause Agents") { store.pauseAllAgents() }
                    .buttonStyle(SecondaryMVPButtonStyle())
                Button("Back to Home") { store.goHome() }
                    .buttonStyle(SecondaryMVPButtonStyle())
            }
        }
    }

    private func settingsBinding<Value>(_ keyPath: WritableKeyPath<AppSettings, Value>) -> Binding<Value> {
        Binding(
            get: { store.settings[keyPath: keyPath] },
            set: { newValue in
                var settings = store.settings
                settings[keyPath: keyPath] = newValue
                store.settings = settings
            }
        )
    }

    private func settingsPanel<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).mvpSectionHeader()
            content()
            Spacer()
        }
        .mvpPanel()
    }

    private func connectionRow(_ name: String, _ status: String, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(Theme.deepTeal)
            VStack(alignment: .leading) {
                Text(name).font(.system(size: 14, weight: .bold))
                Text(status).font(.system(size: 12, weight: .medium)).foregroundStyle(Theme.mutedInk)
            }
            Spacer()
            Text("Healthy")
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 8)
                .frame(height: 22)
                .background(Theme.leaf.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

private struct PerformanceAchievementsScreen: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        let metrics = store.performanceMetrics
        WorkbenchFrame(title: "Performance & Achievements", icon: "trophy.fill") {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("This \(store.performanceRange.rawValue.capitalized)").mvpSectionHeader()
                    metricTile("Time Saved", value: "\(metrics.timeSavedMinutes / 60)h \(metrics.timeSavedMinutes % 60)m", icon: "clock.fill", tint: Theme.leaf)
                    metricTile("Gmail Trips Avoided", value: "\(metrics.gmailTripsAvoided)", icon: "paperplane.fill", tint: Theme.blue)
                    metricTile("Quests Completed", value: "\(metrics.questsCompleted)", icon: "list.bullet", tint: Theme.deepTeal)
                    metricTile("Safe Automation Rate", value: "\(Int(metrics.safeAutomationRate * 100))%", icon: "shield.fill", tint: Theme.amber)
                    Spacer()
                }
                .mvpPanel()

                VStack(alignment: .leading, spacing: 12) {
                    Picker("Range", selection: Binding(get: { store.performanceRange }, set: { store.setPerformanceRange($0) })) {
                        ForEach(PerformanceRange.allCases) { range in
                            Text(range.rawValue.capitalized).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text("Progress by Category").mvpSectionHeader()
                    progressRow("Critical Responses", value: Double(store.readyCount), total: 15, tint: Theme.coral)
                    progressRow("Draft Approvals", value: Double(store.draftCount), total: 35, tint: Theme.blue)
                    progressRow("Calendar Invites", value: Double(store.inviteCount), total: 12, tint: Theme.teal)
                    progressRow("Attachments Resolved", value: Double(max(0, 8 - store.blockedCount)), total: 8, tint: Theme.amber)
                    progressRow("Mailing Lists Cleaned", value: Double(max(0, 20 - store.mailingListCount)), total: 20, tint: Theme.leaf)
                    Spacer()
                }
                .mvpPanel()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Achievements").mvpSectionHeader()
                    ForEach(metrics.achievements) { achievement in
                        HStack {
                            Image(systemName: achievement.isUnlocked ? "checkmark.seal.fill" : "seal")
                                .foregroundStyle(achievement.isUnlocked ? Theme.leaf : Theme.mutedInk)
                            VStack(alignment: .leading) {
                                Text(achievement.title).font(.system(size: 14, weight: .bold))
                                Text(achievement.summary).font(.system(size: 12)).foregroundStyle(Theme.mutedInk)
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .mvpPanel()
            }

            HStack {
                Button("Back to Office") { store.goHome() }
                    .buttonStyle(PrimaryMVPButtonStyle())
                Button("View Quest Board") { store.navigate(.questBoard(.all)) }
                    .buttonStyle(SecondaryMVPButtonStyle())
                Button("Reset Week View") { store.resetPerformanceView() }
                    .buttonStyle(SecondaryMVPButtonStyle())
            }
        }
    }

    private func metricTile(_ title: String, value: String, icon: String, tint: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(tint)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(title).font(.system(size: 13, weight: .bold))
                Text(value).font(.system(size: 24, weight: .bold, design: .rounded))
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.36))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func progressRow(_ title: String, value: Double, total: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title).font(.system(size: 13, weight: .bold))
                Spacer()
                Text("\(Int(value)) / \(Int(total))")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            ProgressView(value: min(value / total, 1))
                .tint(tint)
        }
    }
}

private struct FocusedQuestScreen<Trailing: View>: View {
    @EnvironmentObject private var store: CommandCenterStore
    let title: String
    let icon: String
    let filter: QuestFilter
    let primaryTitle: String
    let primaryIcon: String
    let primaryAction: () -> Void
    let secondary: [ScreenAction]
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        WorkbenchFrame(title: title, icon: icon) {
            HStack(spacing: 14) {
                queue
                selectedQuestPanel
                trailing()
            }

            HStack {
                Button {
                    primaryAction()
                } label: {
                    Label(primaryTitle, systemImage: primaryIcon)
                }
                .buttonStyle(PrimaryMVPButtonStyle())

                ForEach(secondary) { action in
                    Button {
                        action.action()
                    } label: {
                        Label(action.title, systemImage: action.icon)
                    }
                    .buttonStyle(SecondaryMVPButtonStyle())
                }
            }
        }
        .onAppear {
            store.setQuestFilter(filter)
        }
    }

    private var queue: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Queue").mvpSectionHeader()
            ForEach(store.filteredQuests) { quest in
                Button {
                    store.select(quest)
                } label: {
                    QuestQueueRow(quest: quest, selected: store.selectedQuest?.id == quest.id)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .frame(maxWidth: 330)
        .mvpPanel()
    }

    private var selectedQuestPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Item").mvpSectionHeader()
            if let quest = store.selectedQuest {
                QuestSummaryCard(quest: quest)
                Text("Preview")
                    .mvpSectionHeader()
                Text(quest.threadPreview)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.mutedInk)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.36))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                if let draft = quest.draftBody {
                    Text(draft)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.mutedInk)
                        .lineLimit(5)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.30))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                HStack {
                    Label("\(Int(quest.confidence * 100))% confidence", systemImage: "gauge.with.dots.needle.67percent")
                    Spacer()
                    Text(quest.risk.rawValue)
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.deepTeal)
            } else {
                EmptyStateView(text: "No selected quest.")
            }
            Spacer()
        }
        .mvpPanel()
    }
}

private struct WorkbenchFrame<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Spacer()
            }
            content()
        }
        .frame(maxWidth: 1460, maxHeight: .infinity)
        .padding(18)
        .mvpPanel(strong: true)
    }
}

private struct ThreeColumnWorkbench<Leading: View, Center: View, Trailing: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let leading: () -> Leading
    @ViewBuilder let center: () -> Center
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        WorkbenchFrame(title: title, icon: icon) {
            HStack(alignment: .top, spacing: 14) {
                leading().frame(maxWidth: 340).mvpPanel()
                center().mvpPanel()
                trailing().frame(maxWidth: 360).mvpPanel()
            }
            Spacer(minLength: 0)
        }
    }
}

private struct QuestSummaryCard: View {
    let quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: quest.kind.systemImage)
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(color)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(quest.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("\(quest.kind.rawValue) • \(quest.estimatedMinutes)m")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.mutedInk)
                }
                Spacer()
                Text(quest.status.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 8)
                    .frame(height: 24)
                    .background(color.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            Text(quest.summary)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
            Text(quest.proposedAction)
                .font(.system(size: 13, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.white.opacity(0.40))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var color: Color {
        switch quest.kind {
        case .approveDraft: Theme.blue
        case .calendarInvite: Theme.teal
        case .uploadAttachment, .provideContext: Theme.amber
        case .mailingList: Theme.leaf
        case .triageReview, .moveToDone, .restoreToInbox: Theme.coral
        case .codexSetup: Theme.deepTeal
        }
    }
}

private struct QuestQueueRow: View {
    let quest: Quest
    let selected: Bool

    var body: some View {
        HStack {
            Image(systemName: quest.kind.systemImage)
                .foregroundStyle(Theme.deepTeal)
            VStack(alignment: .leading, spacing: 2) {
                Text(quest.title)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                Text(quest.status.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.mutedInk)
            }
            Spacer()
            Text("\(quest.estimatedMinutes)m")
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .padding(10)
        .background(selected ? Theme.teal.opacity(0.18) : Color.white.opacity(0.30))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct AutomationSummaryPanel: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Automation Summary").mvpSectionHeader()
            summary("AI Drafts Ready", store.draftCount, Theme.blue)
            summary("Waiting on You", store.blockedCount, Theme.amber)
            summary("Moved to Done", store.completedCount, Theme.leaf)
            summary("Safe Batch", store.safeBatchCandidates.count, Theme.deepTeal)
            Divider()
            Text("All actions are review-safe and audited.")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.mutedInk)
            Spacer()
        }
    }

    private func summary(_ title: String, _ value: Int, _ tint: Color) -> some View {
        HStack {
            Circle().fill(tint).frame(width: 10, height: 10)
            Text(title)
            Spacer()
            Text("\(value)").font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .font(.system(size: 13, weight: .bold))
    }
}

private struct ContextAuditPanel: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Context & Memory").mvpSectionHeader()
            ForEach(store.memoryEntries.prefix(3)) { entry in
                Text(entry.title)
                    .font(.system(size: 12, weight: .bold))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.teal.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
            Text("Audit Trail").mvpSectionHeader()
            AuditRows(limit: 4)
            Spacer()
        }
        .frame(maxWidth: 340)
        .mvpPanel()
    }
}

private struct SchedulePanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Schedule").mvpSectionHeader()
            schedule("9:00", "Focus Block", Theme.leaf)
            schedule("11:00", "Design Review", Theme.amber)
            schedule("2:00", "Vendor Demo", Theme.coral)
            Text("Codex Reasoning").mvpSectionHeader()
            Text("Safe invites avoid focus blocks and conflicts.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.mutedInk)
            Spacer()
        }
        .frame(maxWidth: 340)
        .mvpPanel()
    }

    private func schedule(_ time: String, _ title: String, _ tint: Color) -> some View {
        HStack {
            Text(time).font(.system(size: 12, weight: .bold, design: .rounded))
            Text(title).font(.system(size: 13, weight: .bold))
            Spacer()
        }
        .padding(9)
        .background(tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

private struct SafetyPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Audit & Safety").mvpSectionHeader()
            bullet("Codex can draft documents from local context.")
            bullet("Codex will not send without approval.")
            bullet("Codex will not guess sensitive missing data.")
            bullet("Every action is logged.")
            Spacer()
        }
        .frame(maxWidth: 340)
        .mvpPanel()
    }

    private func bullet(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.shield")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.mutedInk)
    }
}

private struct RulesAuditPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Automation Rules").mvpSectionHeader()
            Toggle("Smart frequency filter", isOn: .constant(true))
            Toggle("Low engagement", isOn: .constant(true))
            Toggle("Safe sender check", isOn: .constant(true))
            Text("Audit Log").mvpSectionHeader()
            AuditRows(limit: 4)
            Spacer()
        }
        .frame(maxWidth: 340)
        .mvpPanel()
    }
}

private struct LearnedPreferencesPanel: View {
    @EnvironmentObject private var store: CommandCenterStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learned Preferences").mvpSectionHeader()
            ForEach(store.memoryEntries.prefix(4)) { entry in
                VStack(alignment: .leading) {
                    Text(entry.title).font(.system(size: 13, weight: .bold))
                    Text(entry.summary).font(.system(size: 11, weight: .medium)).foregroundStyle(Theme.mutedInk).lineLimit(2)
                }
                .padding(9)
                .background(Theme.leaf.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }
            Text("Audit Trail").mvpSectionHeader()
            AuditRows(limit: 3)
            Spacer()
        }
        .frame(maxWidth: 340)
        .mvpPanel()
    }
}

private struct AuditRows: View {
    @EnvironmentObject private var store: CommandCenterStore
    let limit: Int

    var body: some View {
        ForEach(store.auditEvents.prefix(limit)) { event in
            HStack(alignment: .top) {
                Circle()
                    .fill(event.status == .denied ? Theme.coral : Theme.leaf)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)
                Text(event.summary)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.mutedInk)
                    .lineLimit(2)
            }
        }
    }
}

private struct EmptyStateView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Theme.mutedInk)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ScreenAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let action: () -> Void

    init(_ title: String, _ icon: String, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}

private extension View {
    func mvpPanel(strong: Bool = false) -> some View {
        padding(14)
            .background(strong ? Theme.panelStrong : Theme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.line))
            .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 8)
    }

    func mvpSectionHeader() -> some View {
        font(.system(size: 12, weight: .bold))
            .foregroundStyle(Theme.mutedInk)
            .textCase(.uppercase)
    }
}

private struct PlainPanelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(configuration.isPressed ? Theme.paper.opacity(0.88) : Theme.panelStrong)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.line))
    }
}

private struct ChromeButtonStyle: ButtonStyle {
    var tint: Color
    var foreground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(configuration.isPressed ? tint.opacity(0.72) : tint)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.line))
    }
}

private struct PrimaryMVPButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(configuration.isPressed ? Theme.deepTeal.opacity(0.82) : Theme.deepTeal)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct SecondaryMVPButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Theme.deepTeal)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(configuration.isPressed ? Theme.teal.opacity(0.16) : Color.white.opacity(0.50))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.deepTeal.opacity(0.18)))
    }
}

private struct PrimarySmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(Theme.deepTeal.opacity(configuration.isPressed ? 0.82 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct SecondarySmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Theme.deepTeal)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(Color.white.opacity(configuration.isPressed ? 0.65 : 0.42))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
