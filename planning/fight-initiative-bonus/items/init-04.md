# [slice] init-04 — Incomplete-Next confirm + Back keeps draft

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/fight-initiative-bonus-config.md`

## What to build

On the Fight / Initiative step, if the DM has an incomplete selection (e.g. list-type stat chosen but no list entry) and presses **Next**, show a confirm dialog: selection incomplete; initiative bonus will be cleared — **Stay** / **Leave anyway**. Leave anyway saves as None (clear all three fields) and proceeds. **Back** with an incomplete draft does not warn and keeps the in-memory draft for the wizard session.

Demoable: pick list stat without entry → Next → dialog → Stay remains; Leave clears and advances; Back to Character Stats and return still shows the incomplete draft.

## Acceptance criteria

- [ ] Next with incomplete selection shows Stay / Leave anyway dialog
- [ ] Stay keeps the draft and does not advance
- [ ] Leave anyway persists None (clears fields) and advances
- [ ] Back with incomplete draft shows no dialog and preserves draft when returning to the step
- [ ] Complete selection on Next saves normally without dialog
- [ ] Widget tests cover incomplete Next Stay/Leave and Back draft retention

## Blocked by

- init-03

## User stories covered

- 19, 20
