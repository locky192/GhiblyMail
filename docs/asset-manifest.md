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
| Empty office background | `Assets/Office/office-background-empty-v1.png` | Main scene base with no people or HUD | Integrated V1 |
| Triage assistant typing loop | Code-native in `HomeMockupScreen` | Agent working at inbox sorting station | Implemented SwiftUI layer |
| Drafting assistant typing loop | Code-native in `HomeMockupScreen` | Agent composing reply drafts | Implemented SwiftUI layer |
| Calendar assistant idle loop | Code-native in `HomeMockupScreen` | Calendar invite queue station | Implemented SwiftUI layer |
| Attachment assistant waiting | Code-native in `HomeMockupScreen` | Missing attachment quest state | Implemented SwiftUI layer |
| CRT glow overlay | Code-native in `HomeMockupScreen` | Animated screen pulse overlay | Implemented SwiftUI layer |
| Paper sorting overlay | Code-native in `HomeMockupScreen` | Small mail sorting animation | Implemented SwiftUI layer |
| Quest complete effect | Code-native in `HomeMockupScreen` | Lightweight completion feedback | Implemented SwiftUI layer |
| Main office home mockup V1 | `Assets/Mockups/main-office-home-v1.png` | Preferred flat home-screen direction | Preferred V1 |
| Main office home mockup V2 | `Assets/Mockups/main-office-home-v2.png` | Cleaner alternate exploration | Alternate V2 |
| Quest command board mockup V1 | `Assets/Mockups/quest-command-board-v1.png` | Unified MVP quest queue destination | Draft |
| Draft review mockup V1 | `Assets/Mockups/draft-review-v1.png` | AI draft approval workflow destination | Draft |
| Calendar invites mockup V1 | `Assets/Mockups/calendar-invites-v1.png` | Meeting invite approval workflow destination | Draft |
| Attachment requests mockup V1 | `Assets/Mockups/attachment-requests-v1.png` | Blocked file/context workflow destination | Draft |
| Mailing list cleanup mockup V1 | `Assets/Mockups/mailing-list-unsubscribe-v1.png` | Mailing list unsubscribe workflow destination | Draft |
| Triage tuning mockup V1 | `Assets/Mockups/triage-tuning-v1.png` | Automation classification correction workflow destination | Draft |
| Daily brief and plan mockup V1 | `Assets/Mockups/daily-brief-plan-v1.png` | Combined brief, prioritization, and plan destination | Draft |
| Settings and connections mockup V1 | `Assets/Mockups/settings-connections-v1.png` | Compact service, focus, music, and agent settings destination | Draft |
| Performance and achievements mockup V1 | `Assets/Mockups/performance-achievements-v1.png` | Combined outcome tracking and achievement destination | Draft |

## Background Prompt V1

Use case: stylized-concept

Asset type: macOS app main scene background for a 2.5D SpriteKit/SwiftUI office simulation.

Primary request: Create an original high-quality isometric cozy indie game studio office background inspired by warm hand-painted anime backgrounds and management-sim games. The image should be an empty office environment with no people and no app HUD.

Scene/backdrop: High interior-only isometric angle, open-plan office, teal carpet, warm cream walls, large windows with soft daylight and lush greenery outside, wooden desk clusters, retro beige CRT computers, bookshelves, potted plants, mugs, notebooks, papers, water cooler, bulletin board, small meeting table, and a few abstract retro game posters with no readable words.

Composition: Wide desktop scene, clear isometric perspective, enough open floor and wall space for UI overlays, furniture arranged in logical work zones, foreground and background both readable, calm visual hierarchy.

Style: Original cozy hand-painted anime management-sim concept art, painterly texture, soft shadows, nostalgic 1990s/early-2000s creative studio mood, high polish, warm and low-stress.

Avoid: Studio Ghibli copy, recognizable copyrighted characters, readable text, brand logos, watermark, UI panels, email windows, floating HUD, harsh lighting, photorealism, clutter that obscures future sprites.

Generated output:

- Workspace path: `Assets/Office/office-background-empty-v1.png`
- App bundle path: `Sources/GhiblyMailCore/Resources/Office/office-background-empty-v1.png`
- Dimensions: 1672 x 941 PNG
- Generation mode: built-in image generation
- Initial review: strong fit for the target scene, no people or baked HUD, clear work zones, and enough open floor space for assistant sprites and overlays.
- Integration status: bundled through SwiftPM resources and displayed by `OfficeSceneView` for focused routes and by the interactive Home Screen as the production scene plate.

## Interactive Home Production Notes

- Runtime Home Screen implementation: `Sources/GhiblyMailCore/Views/HomeMockupScreen.swift`
- Scene plate: `Sources/GhiblyMailCore/Resources/Office/office-background-empty-v1.png`
- Flat mockup status: retained only as design reference in `Assets/Mockups/main-office-home-v1.png`
- Production approach: live SwiftUI components and code-native animated layers over the clean office background.

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
