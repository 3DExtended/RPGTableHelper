# Handoff: skin-01

## PRD

`docs/prd/character-sheet-skins.md` — moderate golden cleanup before skins (keep major player screens; drop extra devices/orientations; light/dark → classic rename deferred to skin-02).

## Work item

- ID: skin-01
- Title: Moderate golden cleanup
- Acceptance: see `planning/character-sheet-skins/items/skin-01.md`

## Dependencies

- Direct: none
- Chain: `skin-01`

## Branch

`main`

## Project notes

- Flutter `testDevices` in `test/test_configuration.dart` currently has 5 devices; dark mode already only uses index 0.
- Canonical keep: **iPad Pro 12.9 landscape** only.
- Visual tests = goldens, not Playwright.
