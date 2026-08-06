# [slice] skin-09 — Implement Night Cartographer + goldens

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/character-sheet-skins.md`

## What to build

Implement `night_cartographer` to mock-close fidelity using approved skin-08 assets:

- Token pack + chrome (gold linework, night frames) + hybrid decorations.
- Apply across player tabs, wizard, DM screens, and popups when Cartographer is active.
- iPad-landscape goldens for major player surfaces under `night_cartographer`.

Demoable: select Night Cartographer as default or override; surfaces match approved direction; goldens pass.

## Acceptance criteria

- [ ] `night_cartographer` fully selectable and distinct from Classic and Ledger
- [ ] Player nine surfaces + wizard/DM/popups use Cartographer look when active
- [ ] Hybrid assets wired; readable on iPad landscape
- [ ] Per-stat variants still independent
- [ ] iPad-landscape goldens for major player screens under Cartographer
- [ ] Full four-skin catalog shippable; tests/goldens green

## Blocked by

- skin-08

## User stories covered

- 17, 19, 26
