# [PRD] Fight / Initiative bonus config

> Local draft only (user requested local file; no forge publish). Canonical forge discussion TBD if/when this repo uses OpenGitBase planning.


## Problem Statement

When the DM asks for initiative, players get a modal to enter their roll. That modal covers the character sheet, so they can no longer see the ability modifier (or other DM-defined numeric bonus) they need to add. Stats are generic and campaign-defined, so there is no built-in “DEX mod” concept for the app to show unless the DM marks one.

## Solution

Let the DM optionally mark which character-stat value is the initiative bonus in a new **Fight / Initiative** campaign-wizard step. When a player is asked for initiative, the popup shows a short helper sentence with that character’s resolved bonus (display-only). Players still type and send the final roll integer. Existing campaigns with no setting keep today’s popup with no hint.

## User Stories

1. As a **player asked for initiative**, I want to see which bonus to add without dismissing the popup, so that I can roll correctly while the sheet is covered.
2. As a **player**, I want the hint to name the relevant label (e.g. Geschicklichkeit) and show the signed modifier, so that it matches what I know from the sheet.
3. As a **player**, I want to still enter the final total myself, so that physical dice and house rules stay under my control.
4. As a **player with a companion in the fight**, I want that companion’s popup to show *its* bonus (if configured and present), so that pet initiative is not confused with mine.
5. As a **player in an alternate form**, I want the form’s popup to resolve against that form’s stats, so that transformed sheets stay accurate.
6. As a **player whose marked stat is missing or unfilled**, I want the popup to omit the hint and still accept a roll, so that initiative is never blocked.
7. As a **player whose bonus is explicitly 0**, I want to see `(0)` in the sentence, so that I know there is no modifier rather than thinking the feature failed.
8. As a **DM configuring a campaign**, I want a dedicated **Fight / Initiative** wizard step right after Character Stats, so that fight settings are easy to find next to the stats they depend on.
9. As a **DM**, I want to leave initiative bonus as **None**, so that systems without a modifier (or unfinished campaigns) keep working.
10. As a **DM**, I want to pick any numeric-capable stat type (plain int, calculated, list-of-calculated, icon ints, HP-style max pairs), so that custom systems are not forced into a DEX-shaped field.
11. As a **DM**, when I pick a list-type stat, I want a second control for the list entry (e.g. Geschicklichkeit), so that one ability row can be the bonus source.
12. As a **DM**, when the chosen value has two numbers, I want to choose which field is the bonus (first/calculated, or current/max), so that score vs modifier (or current vs max HP) is explicit.
13. As a **DM**, I want calculated pairs to default to **Calculated value**, and HP-style pairs to default to **Current value**, so that common cases need no extra clicks.
14. As a **DM**, I want a sample preview of the player sentence only after I have selected something, so that I understand what players will see without noise when set to None.
15. As a **DM using the default D&D-ish preset**, I want Fähigkeiten → Geschicklichkeit → Calculated pre-selected, so that new campaigns work for initiative with zero setup.
16. As a **DM on an existing campaign**, I want missing config fields to deserialize as unset, so that loading old JSON never breaks.
17. As a **DM who deleted the linked stat or list entry**, I want the Fight step to show None and soft-invalidate at runtime, so that popups never crash on stale UUIDs.
18. As a **DM who opens Fight with a broken link and proceeds with None**, I want stale UUIDs cleared on save, so that zombie references do not linger.
19. As a **DM who selected a list stat but not an entry**, I want Next to warn with Stay / Leave anyway, and Leave to save as None, so that incomplete config is not silently stored as “set.”
20. As a **DM going Back to Character Stats with an incomplete draft**, I want no warning and to keep the draft in the wizard session, so that I can fix the list and return.
21. As a **localized user**, I want Fight step chrome and the helper sentence in English and German, so that the feature matches the rest of the app.
22. As a **developer**, I want a pure resolve helper (config + character → label + int?), so that popup and tests share one place for soft-invalidate rules.
23. As a **developer**, I want no SSE/API contract change for fight rolls, so that the session still exchanges a single integer roll.

## Implementation Decisions

### Campaign config (backward compatible)

Add optional fields on `RpgConfigurationModel` (JSON blob; no DB migration):

| Field | Role |
|-------|------|
| `initiativeBonusStatUuid` | `CharacterStatDefinition.statUuid`, or null = None |
| `initiativeBonusListEntryUuid` | Required for list types when set; null otherwise |
| `initiativeBonusField` | Optional enum: `value` \| `otherValue` \| `maxValue` |

- Absent keys on old campaigns → null / None.
- Base preset (`getBaseConfiguration`) prefills Fähigkeiten list → Geschicklichkeit entry → `otherValue`.
- Saving explicit or effective None clears all three fields.

### Field picker rules

| Value type | List entry picker | Field picker | Default field |
|------------|-------------------|--------------|---------------|
| `int` | No | No | `value` |
| `intWithCalculatedValue` | No | Yes | `otherValue` |
| `listOfIntWithCalculatedValues` | Yes | Yes | `otherValue` |
| `listOfIntsWithIcons` | Yes | No | `value` |
| `intWithMaxValue` | No | Yes | `value` (current) |

Field control labels reuse existing l10n: first/calculated, current/max.

### Wizard

- New step **Fight / Initiative** inserted immediately after Character Stats; subsequent steps shift by one in `allWizardConfigurations`.
- Controls: None + cascading pickers; preview sentence when selection is complete enough to describe; no preview for None.
- **Next** with incomplete selection (e.g. list without entry): confirm dialog Stay / Leave anyway; Leave saves None.
- **Back** with incomplete draft: no dialog; keep in-memory draft.
- Broken stored refs: show None; if DM leaves as None, persist clear.

### Resolve + player popup

- Deep module: given campaign initiative refs + `RpgCharacterConfiguration` → `{ label, bonus }?`.
- Label: list entry label if applicable, else stat name.
- Missing definition, missing character value, or unfilled number → null (hide hint).
- Filled `0` → show hint with `(0)`.
- Non-zero formatting: `(+N)` / `(-N)`; zero: `(0)`.
- Sentence shape (localized): `Add {label} {formattedBonus} to your roll`.
- Enrich `showAskPlayerForFightOrderRoll` / modal content with optional hint; still return `int?` total.
- Companions / alternate forms: same campaign refs, resolve against the entity being prompted.
- No auto-roll, no prefill of the text field, no sheet peek behind the modal in this PRD.

### Modules

| Module | Responsibility |
|--------|----------------|
| `RpgConfigurationModel` (+ codegen) | Optional initiative refs + field enum; base preset defaults |
| New wizard step (Fight / Initiative) | DM pickers, preview, incomplete-Next dialog, persist via existing config provider |
| `all_wizard_configurations.dart` | Insert step after Character Stats |
| Resolve helper (new small pure module) | Soft-invalidate + extract bonus/label |
| `show_ask_player_for_fight_order_roll.dart` + caller in `ServerMethodsService` | Pass character + config; render helper sentence |

### API / sync

- No change to fight-sequence DTOs or SSE payloads.
- Config sync continues to ship the whole RPG JSON; new keys are additive.

## Testing Decisions

External behavior; prefer unit tests on the resolve helper and wizard/modal widget tests in the style of existing wizard step tests.

| Behavior | Layer |
|----------|--------|
| Old JSON without initiative keys loads as None | Model / fromJson unit |
| Base preset prefills DEX/Geschicklichkeit calculated | Unit on base config |
| Resolve: list entry otherValue, plain int, current vs max | Resolve helper unit |
| Resolve: missing stat, missing entry, unfilled value → null; filled 0 → 0 | Resolve helper unit |
| Formatting: +2 / -1 / 0 | Unit (or shared formatter) |
| Incomplete Next → dialog; Leave clears; Back keeps draft | Wizard step widget test |
| Broken refs show None; save None clears fields | Wizard / provider test |
| Modal shows sentence when bonus present; hides when null; still submits int | Modal widget test |
| Companion without stat gets no hint; main char with stat does | Service or modal test with fixtures |

## Out of Scope

- Auto-rolling initiative or prefilling the roll field
- Non-blocking / peek-behind sheet while the modal is open
- Label heuristics (guessing “Dexterity” without DM config)
- Structured attack rows or a general dice roller
- Showing initiative hints on the live DM fight screen beyond existing roll flow
- Server-side roll math or schema migrations outside the config JSON

## Further Notes

- Decisions captured in the grill session: display-only marked bonus; separate wizard step after Character Stats; DM chooses field when two numbers exist; all numeric types eligible; per-entity resolve; optional forever; soft-invalidate with Fight step showing None; wipe stale on save-as-None; incomplete warns only on Next.
- Related prior art: generic stats in `RpgConfigurationModel` / `CharacterStatDefinition`; initiative modal `show_ask_player_for_fight_order_roll.dart`; fight ask flow in `ServerMethodsService.playersAreAskedForRolls`.
