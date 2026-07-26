# Progress log — Fight / Initiative bonus config

## 2026-07-26 — Run start

- PRD: `docs/prd/fight-initiative-bonus-config.md`
- Items: `planning/fight-initiative-bonus/`
- Branch: `main`
- Plan: init-01 → init-02 → init-03 → init-04
- Post-run: `applications/rpg_table_helper/updategoldens.sh`

## init-01 complete

- Config fields + resolve/format helper + unit tests green
- Next: init-02

## init-02 complete

- Popup helper sentence + service wiring; commit `a3a098c7`
- Next: init-03

## init-03 complete

- Fight / Initiative wizard step + tests green
- User updated goldens manually; committing initiative-related `withBonusHint` only
- Next: init-04

## init-04 complete

- Incomplete Next dialog + Back draft provider
- All fight-initiative slices done on `main`

