# [slice] init-01 — Config fields + resolve/format helper

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/fight-initiative-bonus-config.md`

## What to build

Add optional initiative-bonus references on `RpgConfigurationModel` (`initiativeBonusStatUuid`, `initiativeBonusListEntryUuid`, `initiativeBonusField` enum: `value` | `otherValue` | `maxValue`). Old JSON without these keys loads as None. Prefill the base D&D-ish preset to Fähigkeiten → Geschicklichkeit → `otherValue`.

Add a pure resolve/format helper: given campaign refs + character config → `{ label, bonus }?` (or null on soft-invalidate / missing / unfilled). Label = list entry label if applicable, else stat name. Support all numeric value types per PRD field rules. Format bonuses as `(+N)` / `(-N)` / `(0)`.

Demoable: unit tests prove old JSON → None, base preset prefill, and resolve/format cases including filled `0` vs missing.

## Acceptance criteria

- [ ] Optional initiative fields deserialize as null when absent; serialize when set
- [ ] `getBaseConfiguration()` prefills Geschicklichkeit list entry + `otherValue`
- [ ] Resolve returns null for missing definition, missing list entry, missing/unfilled character value
- [ ] Resolve returns bonus `0` (and label) when the stored number is explicitly 0
- [ ] Resolve reads the correct JSON field per type (`value` / `otherValue` / `maxValue`) including list entries
- [ ] Formatter produces `(+2)`, `(-1)`, `(0)` as specified
- [ ] Unit tests cover the above

## Blocked by

None — can start immediately

## User stories covered

- 2, 6, 7, 15, 16, 22
