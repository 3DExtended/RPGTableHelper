# [slice] skin-03 — DM campaign default (wizard step 1 + campagne edit)

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: done

## Parent

PRD: `docs/prd/character-sheet-skins.md`

## What to build

DM sets campaign `defaultSkinId`:

- New **first** step in the RPG configuration wizard: pick among all four skins (thumbnails OK; Classic fidelity required, ornate may use placeholder art until later).
- Choosing a skin writes `defaultSkinId` and themes **subsequent wizard steps** with the campaign default skin.
- Campagne management (or equivalent) can change the default later without re-running the full wizard; same field.
- All four skins selectable (no allowlist).

Demoable: create/edit campaign default; wizard steps 2+ visibly follow the selected Classic skin.

## Acceptance criteria

- [x] Wizard step order: skin selection is first
- [x] Selecting a skin persists `defaultSkinId` on campaign config via existing sync/save path
- [x] Later wizard steps render with campaign default skin tokens
- [x] DM can change default later from campagne management; inheriting characters pick it up on next resolve
- [x] All four skin ids offered
- [x] EN/DE copy for the step/controls
- [x] Tests: wizard/config persistence of `defaultSkinId` (widget or unit as fits prior art)

## Blocked by

- skin-02

## User stories covered

- 1, 2, 5, 14, 22
