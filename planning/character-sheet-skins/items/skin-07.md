# [slice] skin-07 — Implement Arcane Ledger + goldens

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: in progress (tokens + seal + parchment chrome landed; deepen mock-close next)

## Parent

PRD: `docs/prd/character-sheet-skins.md`

## What to build

Implement `arcane_ledger` to mock-close fidelity using approved skin-06 assets:

- Token pack + chrome (double-rules, manuscript frames) + hybrid decorations (rasters + painters).
- Apply across player tabs, wizard (campaign default), DM screens, and popups when Ledger is the active resolved/default skin.
- iPad-landscape goldens for major player surfaces under `arcane_ledger`.
- Do not fork widget trees; extend shared chrome/decoration hooks.

Demoable: select Arcane Ledger as default or override; all skinned surfaces match approved direction closely; goldens pass.

## Acceptance criteria

- [ ] `arcane_ledger` fully selectable and distinct from Classic
- [ ] Player nine surfaces + wizard/DM/popups use Ledger tokens/chrome/decorations when active
- [ ] Hybrid assets wired; geometry scales cleanly on iPad
- [ ] Per-stat variants still independent
- [ ] iPad-landscape goldens for major player screens under Ledger
- [ ] Tests/goldens green

## Blocked by

- skin-06

## User stories covered

- 17, 18, 26
