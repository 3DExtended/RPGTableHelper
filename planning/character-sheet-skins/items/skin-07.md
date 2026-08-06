# [slice] skin-07 — Implement Arcane Ledger + goldens

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: done

## Parent

PRD: `docs/prd/character-sheet-skins.md`

## What to build

Implement `arcane_ledger` to mock-close fidelity using approved skin-06 assets.

## Acceptance criteria

- [x] `arcane_ledger` fully selectable and distinct from Classic
- [x] Player nine surfaces + wizard/DM/popups use Ledger tokens/chrome/decorations when active
- [x] Hybrid assets wired; geometry scales cleanly on iPad
- [x] Per-stat variants still independent
- [x] iPad-landscape goldens for major player screens under Ledger
- [x] Tests/goldens green

## Delivered (2026-08-06)

- Distinct `CustomTheme.arcaneLedgerTheme` + registry entry
- Parchment + double-rule `CharacterSheetSkinChrome` on player/DM/wizard
- `CharacterSheetLevelSeal` (empty-center plate + dynamic level text)
- Hex ability stamps when Ledger active (`PentagonWithLabel`)
- Tab surfaces transparent under Ledger so parchment shows
- Goldens: `test/goldens/arcane-ledger-playerpagescreens*` (9) + `arcane-ledger-dm-wizard-appearance`

## Blocked by

- skin-06

## User stories covered

- 17, 18, 26
