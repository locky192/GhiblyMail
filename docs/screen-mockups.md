# GhiblyMail Screen Mockups

Status: Draft

This document tracks flat screen mockups before implementation. The purpose is to decide the UX and visual target for each app scene before splitting art into production assets.

## Main Office Home

Primary mockup:

- `Assets/Mockups/main-office-home-v2.png`

Exploration pass:

- `Assets/Mockups/main-office-home-v1.png`

Intent:

- The office fills the entire app view.
- HUD elements float over the office.
- The main screen is an overview, not an inbox.
- No email subject lines, message bodies, contact names, or detailed message lists.
- Users should understand that counters, station markers, and bottom navigation open deeper task views.
- The style should feel like a cozy management sim while staying fast and productive.

V2 direction:

- Keep top-level counters for critical responses, draft approvals, blockers, invites, and mailing lists.
- Keep station markers for triage, drafting, calendar, attachments, and memory.
- Keep bottom navigation for brief, prioritize, plan, stats, and achievements.
- Keep bottom-right quest summary compact and category-based.
- Avoid brand logos in connection/readiness controls.
- Avoid detailed activity-feed rows on the home screen.

Prompt used for V2:

```text
Use case: ui-mockup / stylized-concept
Asset type: cleaner v2 flat full-screen visual mockup for the GhiblyMail macOS app main home screen.
Reference: use the previous generated mockup only as a loose reference for the isometric cozy office, assistant workstations, station markers, and management-sim HUD concept. Create a new original image. Correct problems from v1: no brand logos, no Gmail logo, no detailed activity feed rows, fewer words, calmer overview, more game-like icon/status UI.

Primary request: Create a high-quality flat mockup of the GhiblyMail main home screen when the app opens. The office fills the entire 16:9 app view edge to edge. The screen should look like a cozy video game management sim overview screen, where the user supervises AI assistants who are handling email. It should not look like a standard email client or SaaS dashboard.

Scene: Original isometric cozy indie office, warm hand-painted anime/game background style, teal carpet, cream walls, large daylight windows with greenery, wooden desk clusters, retro beige CRT computers, plants, bookshelves, bulletin boards, meeting table, water cooler. Add cute assistant characters at workstations. Every CRT monitor must face the seated assistant or the room plausibly; no backwards-facing monitors. The office should feel calm, premium, playful, and productive.

HUD/UX: Show overview information only. No email subject lines, no email body text, no message list, no real names. Use mostly icons, counters, progress bars, badges, and short labels. Include: top-left compact player/status panel; top-center icon resource bar; top-right small icon controls for focus mode, music, AI readiness, mail connection, settings; subtle station labels/glow rings over office zones; bottom-left studio status strip; bottom-center game-style navigation dock; bottom-right compact quest summary.

Style guidelines: original cozy hand-painted anime management-sim UI; translucent cream glass panels; teal, amber, coral, blue, and leaf-green accents; rounded corners no more than 8px; crisp readable icons; low-stress and playful; no corporate dashboard feel; no huge cards covering the office. The office remains the dominant visual.

Avoid: Studio Ghibli copy, copyrighted characters, brand logos, Gmail logo, Google colors/logos, readable email content, detailed activity rows, inbox lists, dense text, fake subject lines, fake body text, photorealism, sci-fi hologram clutter, harsh alert colors, blank margins outside the office, watermark.
```

Open review questions:

- Should the top-left profile/status panel stay visible at all times, or collapse after load?
- Should station markers be labels, icons only, or labels on hover?
- Should the bottom navigation be persistent or replaced by clickable room zones?
- Should the quest summary show counts only, or also one recommended next action?
