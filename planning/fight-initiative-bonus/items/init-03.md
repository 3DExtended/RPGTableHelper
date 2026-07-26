# [slice] init-03 — Fight / Initiative wizard step

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/fight-initiative-bonus-config.md`

## What to build

Insert a new campaign-wizard step **Fight / Initiative** immediately after Character Stats (shift later steps). DM can set None or pick: numeric-capable stat → list entry when needed → field when the type has two numbers (defaults: calculated / current per PRD). Show a sample player-facing preview sentence only when a selection is present (reuse init-01/02 formatter + labels). Persist via existing RPG config provider.

Broken stored refs soft-invalidate in the UI as None; saving None clears all three config fields.

Demoable: open wizard, change initiative source, save; player popup (init-02) reflects the new mark after config sync.

## Acceptance criteria

- [ ] New step appears right after Character Stats with title Fight / Initiative (EN/DE)
- [ ] None option leaves/clears all initiative fields
- [ ] Cascading pickers cover eligible numeric types; list entry and field controls appear only when required
- [ ] Field defaults: `otherValue` for calculated pairs, `value` for HP-style pairs
- [ ] Preview sentence visible only when something is selected; hidden for None
- [ ] Broken refs display as None; persisting None wipes stale UUIDs/field
- [ ] Config updates flow through existing provider/sync (no new API)
- [ ] Wizard step widget tests cover None, list+field selection, broken→None wipe, preview visibility

## Blocked by

- init-01
- init-02 (reuse sentence formatting/preview)

## User stories covered

- 8, 9, 10, 11, 12, 13, 14, 17, 18, 21 (chrome)
