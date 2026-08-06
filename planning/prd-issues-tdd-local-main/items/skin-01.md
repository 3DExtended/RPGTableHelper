# skin-01 — implementation record

## Summary

Narrowed Flutter golden device matrix to **iPad Pro 12.9 landscape** only (`test/test_configuration.dart`). Deleted ~1900 non-canonical golden PNGs. Added device-set guard test + keep-list. Updated README screenshot paths. Player/DM page goldens verified green on the new matrix.

**Blocked on human:** regenerate `CharacterStatValueType_*` + `user_settings_screen` goldens (see keep-list). Agent will not run `--update-goldens` for those (log volume).

## Linked Context

- PRD: `docs/prd/character-sheet-skins.md`
- Work item: `skin-01`
- Keep-list: `planning/character-sheet-skins/golden-keep-list.md`

## Dependency Graph

### Direct dependencies (blocked by)

- None

### Full chain

`skin-01`

## Status

- Branch: `main`
- Tests: device-set + player page + DM page **passing**; CharacterStat / user_settings **need `--update-goldens` by human**
- Visual snapshots: Flutter goldens (canonical device only)
- Commit(s): pending until CharacterStat goldens restored
- Item status: **awaiting human golden regen**
