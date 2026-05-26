# GhiblyMail Asset Manifest

Status: Draft

This manifest tracks production visual assets for the cozy office UI. Source assets should live in `Assets/` until they are wired into the Swift package resource bundle.

## Naming

Use stable, descriptive, versioned filenames:

- `office-background-empty-v1.png`
- `agent-triage-typing-v1.png`
- `agent-drafting-typing-v1.png`
- `prop-crt-glow-v1.png`
- `fx-quest-complete-sparkle-v1.png`

Keep generated source prompts in this file or in nearby `.prompt.md` files when an asset needs a long prompt.

## Planned Asset Set

| Asset | Path | Purpose | Status |
| --- | --- | --- | --- |
| Empty office background | `Assets/Office/office-background-empty-v1.png` | Main scene base with no people or HUD | Planned |
| Triage assistant typing loop | `Assets/Agents/triage/agent-triage-typing-v1.png` | Agent working at inbox sorting station | Planned |
| Drafting assistant typing loop | `Assets/Agents/drafting/agent-drafting-typing-v1.png` | Agent composing reply drafts | Planned |
| Calendar assistant idle loop | `Assets/Agents/calendar/agent-calendar-idle-v1.png` | Calendar invite queue station | Planned |
| Attachment assistant waiting | `Assets/Agents/attachments/agent-attachment-waiting-v1.png` | Missing attachment quest state | Planned |
| CRT glow overlay | `Assets/Props/prop-crt-glow-v1.png` | Animated screen pulse overlay | Planned |
| Paper sorting overlay | `Assets/Props/prop-paper-sort-v1.png` | Small mail sorting animation | Planned |
| Quest complete effect | `Assets/Effects/fx-quest-complete-sparkle-v1.png` | Lightweight completion feedback | Planned |

## Background Prompt V1

Use case: stylized-concept

Asset type: macOS app main scene background for a 2.5D SpriteKit/SwiftUI office simulation.

Primary request: Create an original high-quality isometric cozy indie game studio office background inspired by warm hand-painted anime backgrounds and management-sim games. The image should be an empty office environment with no people and no app HUD.

Scene/backdrop: High interior-only isometric angle, open-plan office, teal carpet, warm cream walls, large windows with soft daylight and lush greenery outside, wooden desk clusters, retro beige CRT computers, bookshelves, potted plants, mugs, notebooks, papers, water cooler, bulletin board, small meeting table, and a few abstract retro game posters with no readable words.

Composition: Wide desktop scene, clear isometric perspective, enough open floor and wall space for UI overlays, furniture arranged in logical work zones, foreground and background both readable, calm visual hierarchy.

Style: Original cozy hand-painted anime management-sim concept art, painterly texture, soft shadows, nostalgic 1990s/early-2000s creative studio mood, high polish, warm and low-stress.

Avoid: Studio Ghibli copy, recognizable copyrighted characters, readable text, brand logos, watermark, UI panels, email windows, floating HUD, harsh lighting, photorealism, clutter that obscures future sprites.

## Sprite Prompt Pattern

Use case: stylized-concept

Asset type: isolated game sprite for a macOS app office simulation.

Primary request: Create an original cozy anime-style office assistant character sprite for GhiblyMail. The assistant should be shown in an isometric perspective compatible with the office background.

Scene/backdrop: Perfectly flat solid chroma-key background for later removal. No floor plane, no shadow, no props that are not part of the sprite.

Style: Match the office background: hand-painted, warm, soft shadows, game-sprite readability, friendly and professional.

Avoid: Studio Ghibli copy, copyrighted characters, readable text, logos, watermark, exaggerated stress expressions.

## Acceptance Checks

Before an asset is used in the app:

- Inspect at full size and at the smallest supported app window.
- Confirm no accidental readable text, logos, or watermarks.
- Confirm the asset supports the intended layer boundaries.
- Confirm HUD panels remain legible on top of the background.
- Confirm character sprites do not visually clash with the background.
- Commit the asset and prompt together.
