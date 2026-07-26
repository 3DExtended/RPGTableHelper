# [PRD] Character stat visualization variants

> Local draft (no OpenGitBase repo for this project yet — `ogb issue create` returned Not Found). Canonical forge discussion TBD after repo exists. Commit on demand only.


## Problem Statement

Character sheets use a small set of visualization variants. `intWithMaxValue` has five looks; most other stat types have one flat treatment. At the table, players and DMs struggle to glance ability modifiers, skim long skill lists, tell HP apart from spell points, and recognize companions—everything reads like the same generic number-or-text block.

## Solution

Add selectable visual variants for existing `CharacterStatValueType` renderers (same data model, new `variant` looks). Focus on glanceability, game metaphors, and density—not new stat types. Players/DMs pick a look per field; combat and lore tabs can feel different without schema changes.

## User Stories

1. As a **player in combat**, I want ability scores to show the modifier first and score second, so that I can read `+3` without hunting.
2. As a **player**, I want each ability in a hard-edged tile (hex/shield), so that the six scores read as one ability block at a glance.
3. As a **player**, I want a classic ability block (label, big modifier, small score box), so that the sheet matches familiar TTRPG muscle memory.
4. As a **player reviewing character identity**, I want an optional radar of the ability list, so that overall build shape is visible (not for live edits).
5. As a **player**, I want icon stats (AC, speed, …) as stamped medallions with huge numbers, so that defenses pop across the table.
6. As a **player on a crowded tab**, I want icon stats as a single horizontal ribbon, so that secondary numbers stay compact.
7. As a **player**, I want one primary icon stat oversized with secondaries smaller beside it, so that AC (or similar) is the hero value.
8. As a **player tracking HP**, I want a heart-shaped reservoir fill, so that hit points feel distinct from other resources.
9. As a **caster tracking spell points**, I want a gem/crystal reservoir fill, so that magic resources have their own metaphor.
10. As a **player with a small max resource** (slots, death saves), I want a segmented/notched track, so that each point is a discrete pip.
11. As a **player at low HP**, I want wound-ring visuals that empty outward, so that danger is obvious without rainbow bars.
12. As a **player on a dense combat layout**, I want a compact chip `[−] 12/17 HP [+]`, so that resources fit without ornament.
13. As a **player with proficient skills/saves**, I want selected options as filled chips (and multi-count/expertise marking), so that lists scan faster than bullet rows.
14. As a **player**, I want a two-column checklist showing all multiselect options, so that I can see gaps and selections like a paper sheet.
15. As a **player mid-combat**, I want a multiselect icon grid with selected vs muted tiles, so that I recognize skills without reading long labels.
16. As a **player**, I want skills grouped under ability headers (STR/DEX/…), so that “Fertigkeiten” matches how the game is taught.
17. As a **player**, I want character name + level as a banner with a level seal, so that identity is header-grade, not a side widget.
18. As a **player**, I want a portrait-led identity card (level ring + name + captions), so that the character face anchors the sheet when an image is nearby.
19. As a **player on a crowded layout**, I want a minimal identity line (`Name · Lvl · Volk · Klasse`), so that identity costs almost no vertical space.
20. As a **player reading lore**, I want long text stats as collapsible panels, so that Features/Attacks do not dominate the screen until opened.
21. As a **player**, I want personality/lore text in a soft parchment/quote frame, so that narrative blocks feel distinct from mechanical stats.
22. As a **player**, I want character image variants (silhouette frame, polaroid, full-bleed tile), so that portrait presence matches sheet style.
23. As a **player with companions**, I want mini companion cards (name + placeholder art + tap), so that allies feel like characters, not plain buttons.
24. As a **player in an alternate form**, I want an active-form banner with clear return affordance, so that transformation state is obvious.
25. As a **campaign designer / player**, I want to pick visualization variants without changing stored values, so that looks are presentation-only.
26. As a **localized user**, I want any new chrome labels in English and German, so that variants match the rest of the app.
27. As a **developer**, I want new variants registered in `numberOfVariantsForValueTypes` and rendered in the existing switch, so that the current variant pipeline stays the single extension point.

## Implementation Decisions

### Scope of variants (by value type)

| Value type | New visual variants to add |
|------------|----------------------------|
| `intWithMaxValue` | Heart reservoir; gem/crystal reservoir; segmented pip track; wound rings; compact combat chip |
| `intWithCalculatedValue` | Modifier-first stack; classic ability block (reuse for single score) |
| `listOfIntWithCalculatedValues` | Modifier-first tiles; hex/shield grid; classic ability blocks; optional radar overview |
| `listOfIntsWithIcons` | Medallion/badge cluster; horizontal ribbon; primary-hero + secondary strip |
| `multiselect` | Proficiency chips; two-column checklist; icon grid; ability-grouped sections |
| `characterNameWithLevelAndAdditionalDetails` | Banner + level seal; portrait-led card; minimal identity line |
| `multiLineText` / `singleLineText` | Collapsible lore panel; parchment/quote frame |
| `singleImage` | Silhouette frame; polaroid; full-bleed tile |
| `companionSelector` | Mini character cards |
| `transformIntoAlternateFormBtn` | Active-form banner + return control |
| `int` | Optional large-numeral tile (keep plain stack as default) |

### Architecture

- **Extend, don’t fork**: keep `getPlayerVisualizationWidget` / per-type `render*` functions; branch on `characterValue.variant` as today.
- **Bump** `numberOfVariantsForValueTypes` for each type that gains looks.
- **No schema/API change**: same serialized JSON; variants are presentation indices only.
- **Theme**: use `CustomThemeProvider` colors/fonts; avoid one-off purple/glow aesthetics; match existing parchment/dark RPG look.
- **Edit affordances**: preserve `CharacterStatEditType.oneTap` +/- for max-value variants that support live edits.
- **Empty/edge states**: define depleted (0), full, and over-max presentation where the type allows; multiselect empty stays explicit.
- **Out of band for this PRD**: restructuring Attacks/Spells from free markdown into typed attack rows (called out as follow-up).

### Modules

| Module | Responsibility |
|--------|----------------|
| `get_player_visualization_widget.dart` | Variant dispatch + renderers |
| Small presentational widgets (e.g. reservoir, medallion, chip row) | Reusable shapes used by multiple variants |
| Prototype gallery (throwaway ok) | Side-by-side / switchable preview of sample data before absorbing winners |

## Testing Decisions

- Widget/golden or screenshot tests for each new variant with fixed sample JSON (HP, ability list, multiselect skills, identity, companion list).
- Regression: existing variants (especially `intWithMaxValue` 0–4 and pentagon calculated) still render and oneTap still mutates `serializedValue`.
- No API/backend tests (presentation-only).
- Manual tablet pass: glance from ~1–2m; oneTap on reservoirs/chips; DE/EN labels.

## Out of Scope

- New `CharacterStatValueType`s or changes to serialized value shapes
- Backend/API/config sync changes
- Fully structured Attacks/Spells/Features data models (markdown remains)
- Dice roller integration or animated damage flash
- DM-side aggregate party dashboard
- Auto-picking variant from stat name (e.g. “HP” → heart); selection stays manual via variant index

## Further Notes

- Highest leverage first: modifier-first ability visuals, multiselect chips/grouping, resource metaphors (HP vs spell points), companion mini-cards.
- Prototype throwaway Flutter gallery before absorbing variants into production renderers; delete gallery once winners are chosen.
- Existing pentagon / accent bar / health bar / dots remain; new looks are additive variants, not replacements.
- Prior art: `PentagonWithLabel`, `ProgressIndicatorForCharacterScreen`, `numberOfVariantsForValueTypes`, companion/transform TODOs in current renderers.
