# GhiblyMail Screen Mockups

Status: Draft

This document tracks flat screen mockups before implementation. The purpose is to decide the UX and visual target for each app scene before splitting art into production assets.

## Main Office Home

Primary mockup:

- `Assets/Mockups/main-office-home-v1.png`

Alternate exploration:

- `Assets/Mockups/main-office-home-v2.png`

Intent:

- The office fills the entire app view.
- HUD elements float over the office.
- The main screen is an overview, not an inbox.
- No full email bodies or dense inbox lists.
- Rich overview text is acceptable when it feels like management-sim status, activity, or quest information rather than a traditional email client.
- Integration brand marks are acceptable for active connected services, such as Gmail and OpenAI/Codex, when used as small status/control indicators.
- Users should understand that counters, station markers, and bottom navigation open deeper task views.
- The style should feel like a cozy management sim while staying fast and productive.

V1 direction:

- Keep top-level counters for critical responses, draft approvals, blockers, invites, and mailing lists.
- Keep station markers for triage, drafting, calendar, attachments, and memory.
- Keep bottom navigation for brief, prioritize, plan, stats, and achievements.
- Keep the richer game HUD composition from v1, including the status card, activity panel, station callouts, quest summary, and bottom navigation.
- Small brand logos for integrations are allowed in the connection/readiness controls.
- Activity-feed rows are allowed on the home screen when they are concise, generic, and operational rather than exposing sensitive email content.
- Preserve the office-first composition: panels should support the scene, not turn it into a conventional inbox.

Prompt used for V1:

```text
Use case: ui-mockup / stylized-concept
Asset type: flat full-screen visual mockup for the GhiblyMail macOS app main home screen.
Input image: use the visible generated office background only as loose reference for mood, isometric camera, teal carpet, warm cream walls, wooden desks, plants, windows, and retro CRT office props. Create a new original mockup, not a direct copy. Fix the issue where any CRT monitors face the wrong direction: every workstation monitor should face the seated assistant or the room in a plausible isometric orientation.

Primary request: Create a high-quality flat mockup of the app's main screen when the user opens GhiblyMail. It should feel like the overview screen of a cozy video game management sim, not a normal email client. The office image fills the entire app view edge to edge. All HUD, icons, buttons, stats, agent indicators, and interactive hints are included in this one flat mockup image for now.

Scene: Original isometric cozy indie office with warm hand-painted anime/game background style, teal carpet, cream walls, daylight windows with greenery outside, wooden desk clusters, retro beige CRTs, bookshelves, plants, bulletin boards, small meeting table, water cooler, cozy clutter. Add cute AI assistant characters working at desks with subtle game-like status indicators above them. The office should be calm and productive, not busy or stressful.

Main-screen UX concept: This is the top-level command center before opening any task. It should show overview information only, with no detailed email subject lines, no email body text, and no dense inbox list. Include a polished management-sim HUD overlay with top-left profile/day panel, top-center resource counters, top-right service/status controls, station markers, bottom-left activity ticker, bottom-right quest summary, and bottom navigation.

Style guidelines: Original cozy hand-painted anime management-sim UI; polished macOS game-like interface; warm, low-stress, premium; translucent cream glass panels with teal/amber/coral/blue accents; rounded corners no more than 8px; crisp iconography; readable but not dense; no big marketing hero text; no corporate SaaS dashboard feel. HUD should feel diegetic and game-like but still efficient.

Avoid: literal Studio Ghibli style or copyrighted references, recognizable characters, fake email subjects, email body text, detailed message lists, overwhelming tiny text, photorealism, sci-fi hologram clutter, harsh alert colors, red unread badge stress, giant cards covering the office, blank margins outside the office, watermarks.
```

V2 notes:

- V2 remains a useful alternate exploration for a cleaner, more minimal HUD.
- V2 is not the preferred main-screen target.
- Do not treat v2's "no brand logos" or "no detailed activity rows" choices as product requirements.

Open review questions:

- Should the top-left profile/status panel stay visible at all times, or collapse after load?
- Should station markers be labels, icons only, or labels on hover?
- Should the bottom navigation be persistent or replaced by clickable room zones?
- Should the quest summary show counts only, or also one recommended next action?
