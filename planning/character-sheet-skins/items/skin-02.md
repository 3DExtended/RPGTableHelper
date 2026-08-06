# [slice] skin-02 — Skin registry, resolution, persistence, Classic tokens, theme wiring

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/character-sheet-skins.md`

## What to build

Add the skin system core without ornate skins yet:

- Registry with stable ids: `classic_light`, `classic_dark`, `arcane_ledger`, `night_cartographer` (last two may be stubs/placeholder tokens until later slices).
- Resolution: `character.skinId ?? campaign.defaultSkinId ?? classic_dark`; unknown id renders as Classic Dark but preserves stored value.
- Persist `defaultSkinId` on campaign RPG config JSON and nullable `skinId` on main character config JSON (not companions/alternates).
- Token packs for Classic Light and Classic Dark from today’s themes.
- Wire theme provider so an active skin supplies colors/fonts/chrome; remove/hide user-facing global brightness toggle.
- Pre-campaign / no-skin surfaces use Classic Dark.
- EN/DE labels for the four skins in l10n (even if ornate skins are not visually done yet).

Demoable: unit tests for resolve + JSON round-trip; app boots with Classic skins via provider; brightness toggle gone.

## Acceptance criteria

- [ ] Optional `defaultSkinId` / `skinId` deserialize as null when absent; serialize when set
- [ ] Resolution unit tests: inherit, override wins, missing → classic_dark, unknown → render classic_dark keep id
- [ ] Classic Light/Dark token packs match prior light/dark look closely enough for existing Classic goldens (after rename if applicable)
- [ ] Theme provider selects tokens from active skin id
- [ ] User-facing brightness toggle removed/hidden
- [ ] Pre-campaign UI uses Classic Dark
- [ ] Skin labels localized EN/DE
- [ ] Per-stat `variant` behavior unchanged
- [ ] Unit tests cover the above

## Blocked by

- skin-01

## User stories covered

- 15, 16, 20, 21, 23, 24, 25, 27, 28
