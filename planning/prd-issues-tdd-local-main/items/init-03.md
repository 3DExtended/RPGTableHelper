# init-03 — implementation record

## Summary

Added Fight / Initiative wizard step after Character Stats with None + cascading pickers, preview sentence, soft-invalidate broken refs, and persist via rpgConfigurationProvider. Extended resolver with eligible-type helpers.

## Linked Context

- PRD: `docs/prd/fight-initiative-bonus-config.md`
- Work item: init-03

## Dependency Graph

### Direct dependencies (blocked by)

- init-01, init-02

### Full chain

`init-01 -> init-02 -> init-03`

## Status

- Branch: `main`
- Tests: `flutter test test/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_2b_fight_initiative_test.dart` — passing
- Visual snapshots: `withBonusHint` goldens for initiative popup (from init-02); step goldens N/A
- Commit(s): pending
