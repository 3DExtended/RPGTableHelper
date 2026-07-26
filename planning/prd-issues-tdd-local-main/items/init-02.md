# init-02 — implementation record

## Summary

Initiative modal shows a localized helper sentence when `InitiativeBonusHint` is present; `ServerMethodsService` resolves per main/companion/form character. EN/DE strings added. Widget test covers show/hide; golden config `withBonusHint` added (baselines updated at end of run).

## Linked Context

- PRD: `docs/prd/fight-initiative-bonus-config.md`
- Work item: init-02

## Dependency Graph

### Direct dependencies (blocked by)

- init-01

### Full chain

`init-01 -> init-02`

## Status

- Branch: `main`
- Tests: `flutter test test/helpers/modals/show_ask_player_for_fight_order_roll_test.dart --name "shows helper"`; resolver suite
- Visual snapshots: golden configs pending `updategoldens.sh`
- Commit(s): pending
