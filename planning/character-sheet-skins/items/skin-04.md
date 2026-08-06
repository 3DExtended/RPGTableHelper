# [slice] skin-04 — Player Appearance picker + override persistence

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/character-sheet-skins.md`

## What to build

Player-facing Appearance on the live character sheet:

- Entry from player page navbar/settings area.
- Four skins + “Use campaign default” (clears `skinId` to null).
- **Hybrid UX:** if required campaign stats are missing → immediate-apply from thumbnails; if all required stats present → live preview on sheet with Save/Cancel.
- Persist override on main `RpgCharacterConfiguration.skinId` only; companions/alternates use main resolved skin.
- DM does not edit another character’s override; when DM views a sheet, resolved skin is shown (no special DM override UI).
- Badge/indicator for which option is the current campaign default.

Demoable: set/clear override; hybrid picker modes; resolve uses override over default.

## Acceptance criteria

- [ ] Appearance reachable from player sheet
- [ ] Immediate-apply when required stats missing; Save/Cancel + live preview when complete
- [ ] Save writes `skinId`; Cancel restores previous; “Use campaign default” sets null
- [ ] Companions/alternates do not store their own skin; chrome uses main resolved skin
- [ ] DM has no UI to set another character’s `skinId`
- [ ] Campaign default marked in picker
- [ ] EN/DE strings
- [ ] Tests cover mode switch predicate, persist/clear, resolution with override

## Blocked by

- skin-02

## User stories covered

- 6, 7, 8, 9, 10, 11, 12, 13, 22
