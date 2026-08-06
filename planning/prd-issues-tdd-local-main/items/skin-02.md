# skin-02 — implementation record

## Summary

Added character-sheet skin core: registry + resolve helpers, `defaultSkinId` / `skinId` JSON fields, Classic Light/Dark token packs (Ledger/Cartographer stubs), `CustomThemeProvider` driven by `skinIdNotifier` (no platform brightness following), EN/DE skin labels.

## Linked Context

- PRD: `docs/prd/character-sheet-skins.md`
- Work item: `skin-02`

## Dependency Graph

### Direct dependencies (blocked by)

- skin-01

### Full chain

`skin-01 -> skin-02`

## Status

- Branch: `main`
- Tests: resolution + JSON + player page goldens passing
- Visual snapshots: player goldens still use overrideBrightness → classic_light/dark mapping
- Commit(s): pending
