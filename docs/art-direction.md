# GhiblyMail Art Direction

Status: Draft

## Intent

GhiblyMail should feel like a cozy management sim for work email: the user supervises a calm office of AI assistants who sort, draft, research, and prepare quests. The interface must stay productive, but the emotional tone should be the opposite of a normal inbox.

The visual direction is original cozy hand-painted anime and indie game office art. It should not copy Studio Ghibli characters, scenes, house style, logos, or protected trade dress.

## Primary Scene

The main view is an isometric office seen from a high interior-only angle. The scene should read clearly at desktop sizes and still preserve small discoveries when viewed full screen.

Core environment:

- Warm cream walls.
- Teal carpet.
- Large windows with soft daylight and greenery outside.
- Wooden desk clusters with retro beige CRT computers.
- Bookshelves, potted plants, mugs, notebooks, loose papers, bulletin boards, water cooler, small meeting table, and playful retro posters with no readable branded text.
- Soft painterly shadows and nostalgic 1990s or early-2000s creative studio energy.

The office is the core app surface, not a decorative hero image. HUD elements, quest panels, agent states, and overlays sit on top of it.

## Scene Layering

Use a layered 2.5D production approach:

1. Empty office background: floor, walls, windows, desks, shelves, plants, fixed furniture, and lighting.
2. Agent sprites: characters at desks, walking, thinking, celebrating, waiting, and presenting a quest.
3. Interactive prop overlays: glowing CRT screens, document stacks, upload tray, calendar board, mailbox sorter, and progress indicators.
4. HUD layer: quest queue, agent status, inbox counts, mode controls, audit/memory controls, and user approvals.
5. Effects layer: typing loops, screen flicker, paper sorting, small completion sparkles, soft focus pulses, and subtle ambient motion.

This keeps the high-quality painted scene while letting the app animate and respond to real state.

## Animation Language

Animations should be small, readable, and loopable:

- Typing: gentle shoulder and hand movement, screen glow pulse.
- Thinking: brief pause, small thought bubble or soft icon pulse.
- Sorting: paper/mail cards move between desk piles.
- Draft ready: assistant turns slightly or screen emits a warm notification glow.
- Blocked quest: assistant pauses beside a clear icon, never a panic state.
- Quest complete: quick sparkle, desk light pulse, and optional soft sound cue.

Animations must never slow the core workflow. Approval, edit, upload, and calendar actions should respond immediately.

## HUD Principles

The HUD should be readable and task-first:

- Use compact panels with restrained opacity so the office remains visible.
- Show only actionable counts by default: draft approvals, blocked quests, missing attachments, calendar invites, and agent work.
- Avoid aggressive red badges except for true urgency.
- Avoid a default wall of subject lines.
- Keep controls familiar: icon buttons, tooltips, segmented controls, toggles, tabs, and concise action buttons.
- Support keyboard shortcuts and batch actions for productivity.

## Quality Bar

The first production-quality scene pass should satisfy:

- Original copyright-safe art.
- Clear isometric perspective.
- No readable generated text.
- No HUD, buttons, labels, watermark, or fake UI baked into the background.
- Enough negative space for overlays.
- Good contrast behind translucent HUD panels.
- Warm, calm, high-detail office mood.
- Stable layout that can be sliced into layers or redrawn as needed.

## Production Path

The recommended path is:

1. Generate a high-quality empty office background.
2. Review it at desktop and compact window sizes.
3. Generate a small set of agent poses against chroma-key backgrounds.
4. Remove chroma key locally for sprite alpha.
5. Build a SpriteKit or SwiftUI canvas scene that composites the background, sprites, props, and HUD.
6. Add animation states driven by quest and agent status.
7. Add visual regression screenshots for desktop and compact windows.

SpriteKit is the likely best first implementation path because it gives us deterministic sprite layering, animation loops, hit testing, and particle effects while still embedding cleanly inside SwiftUI.
