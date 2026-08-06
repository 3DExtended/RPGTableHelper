# [slice] skin-01 — Moderate golden cleanup

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/character-sheet-skins.md`

## What to build

Trim the excessive player-page golden matrix before skins land. Keep coverage of major player screens (Background, Stats, Features, Attacks, Spells, Money, Inventory, Recipes, Lore). Drop redundant device sizes and orientations beyond the canonical iPad-landscape baseline used for skin approval. Prepare naming/structure so light/dark fixtures can become `classic_light` / `classic_dark` in the next slice (or rename in this slice if low-risk).

Demoable: golden suite still passes; fewer artifacts; major screens still have at least one landscape golden each.

## Acceptance criteria

- [ ] Major player surfaces retain at least one iPad-landscape golden each
- [ ] Extra device/orientation duplicates removed (or clearly documented keep-list if a few must remain temporarily)
- [ ] Tests updated so CI does not expect deleted goldens
- [ ] Document the keep-list in the slice handoff or a short note under `planning/character-sheet-skins/`
- [ ] Suite green after cleanup

## Blocked by

None

## User stories covered

- 26
