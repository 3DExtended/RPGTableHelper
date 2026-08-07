# [slice] skin-09 — Implement Night Cartographer + goldens

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: done

## Parent

PRD: `docs/prd/character-sheet-skins.md`

## What to build

Implement `night_cartographer` to mock-close fidelity using approved skin-08 assets:

- Token pack + chrome (gold linework, night frames) + hybrid decorations.
- Apply across player tabs, wizard, DM screens, and popups when Cartographer is active.
- iPad-landscape goldens for major player surfaces under `night_cartographer`.

Demoable: select Night Cartographer as default or override; surfaces match approved direction; goldens pass.

## Acceptance criteria

- [x] `night_cartographer` fully selectable and distinct from Classic and Ledger
- [x] Player nine surfaces + wizard/DM/popups use Cartographer look when active
- [x] Hybrid assets wired; readable on iPad landscape
- [x] Per-stat variants still independent
- [x] iPad-landscape goldens for major player screens under Cartographer
- [x] Full four-skin catalog shippable; tests/goldens green

## Delivered (2026-08-07)

- Distinct `CustomTheme.nightCartographerTheme` + registry entry
- Constellation + double-rule `CharacterSheetSkinChrome` for Cartographer
- Compass-ring level seal via `CharacterSheetLevelSeal.forSkin`
- House-shaped ability stamps; champagne navbar accents; shared decorated layout with Ledger
- Assets: `night_cartographer_{constellation,compass_rings,corner_ticks}.png`
- Goldens: `test/goldens/night-cartographer-playerpagescreens*` (9) + `night-cartographer-dm-wizard-appearance`

## Blocked by

- skin-08

## User stories covered

- 17, 19, 26
