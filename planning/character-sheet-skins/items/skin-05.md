# [slice] skin-05 — Apply skins to DM/player surfaces (Classic fidelity)

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/character-sheet-skins.md`

## What to build

End-to-end Classic skin application across surfaces (mock-close ornate skins still later):

- **Campaign default** themes DM screens and DM popups/modals.
- **Resolved character skin** themes full player page (all tabs + navbar) and player popups from that sheet.
- Shared chrome hooks (frames/backgrounds) work for Classic Light/Dark even if ornate decorations are no-ops.
- iPad-landscape goldens for major player surfaces under `classic_light` and `classic_dark` (post-cleanup baseline).

Demoable: switch campaign default and character override; DM vs player surfaces follow resolution rules with Classic skins.

## Acceptance criteria

- [ ] DM pageview + representative DM modal use campaign `defaultSkinId`
- [ ] Player page (all enabled tabs) + representative player modal use resolved character skin
- [ ] Navbar/chrome follow active skin tokens
- [ ] Classic Light/Dark goldens updated/passing for major player screens (iPad landscape)
- [ ] No regression to per-stat variant selection
- [ ] Tests/goldens green for Classic path

## Blocked by

- skin-03
- skin-04

## User stories covered

- 3, 4, 17 (Classic depth)
