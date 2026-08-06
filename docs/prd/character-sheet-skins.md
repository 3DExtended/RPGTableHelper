# [PRD] Character sheet skins

> Local draft only (user requested local file; no forge/ogb publish). Canonical forge discussion TBD if/when this repo uses OpenGitBase planning.

## Problem Statement

The player character sheet has a single clean, minimal look (warm parchment / classic dark). Players and DMs want distinct table aesthetics—especially richer designs like Arcane Ledger and Night Cartographer—without forking the whole UI into duplicate widget trees. Today there is only global light/dark, which is not a first-class “campaign look,” cannot be set as a DM default with per-character override, and does not cover wizard/DM chrome or mock-close atmosphere.

## Solution

Introduce named **character sheet skins**: fixed visual identities (tokens + chrome + mock-close decorations) that theme the player page, wizards, DM screens, and popups. The DM sets a **campaign default** (first RPG configuration wizard step). Players may **override per character**. Skins are data packs over one widget tree—not copied screens. v1 ships four skins; more can be added later via stable `skinId`s. Per-stat visualization variants remain independent.

## User Stories

1. As a **DM creating a campaign**, I want the first wizard step to be choosing a default sheet skin, so that the table’s look is set before other campaign config.
2. As a **DM in the wizard**, I want every step after skin selection to render in the chosen skin, so that I preview the table aesthetic while configuring.
3. As a **DM**, I want campaign management and other DM screens to use the campaign default skin, so that the DM experience matches the table look.
4. As a **DM**, I want DM-opened popups/modals to use the campaign default skin, so that chrome is consistent.
5. As a **DM**, I want to change the campaign default later without redoing the whole wizard, so that the table can restyle mid-campaign.
6. As a **player**, I want to open Appearance on my character sheet and pick a skin, so that my sheet can differ from the campaign default.
7. As a **player**, I want “Use campaign default” to clear my override, so that I inherit when the DM changes the default.
8. As a **player with incomplete required stats**, I want picking a skin to apply immediately from thumbnails, so that setup stays fast.
9. As a **player with all required campaign stats**, I want live preview on the open sheet with Save/Cancel, so that I can compare looks without accidental commits.
10. As a **player**, I want my override stored on my character and synced, so that the look follows the character across devices.
11. As a **player**, I want companions and alternate forms to use my main character’s resolved skin, so that transformations don’t suddenly restyle chrome.
12. As a **DM viewing a player’s sheet**, I want to see that character’s resolved skin, so that what I see matches what the player sees.
13. As a **DM**, I do not want to edit another character’s skin override, so that players own their sheet look.
14. As a **player or DM**, I want all four v1 skins available (no allowlist), so that choice isn’t artificially restricted.
15. As a **user before a campaign skin exists**, I want Classic Dark, so that pre-campaign screens have a deterministic fallback.
16. As a **user with an unknown/future `skinId`**, I want Classic Dark rendering while preserving the stored id, so that older clients degrade safely.
17. As a **player on Inventory / Money / Lore / Recipes / Background / Features / Attacks / Spells**, I want the same skin language as Stats (mock-close), so that swiping tabs stays coherent.
18. As a **player**, I want Arcane Ledger to feel like a manuscript (parchment, seals, double-rules, atmosphere), so that the sheet matches the approved mock direction.
19. As a **player**, I want Night Cartographer to feel like a night atlas (navy, constellation atmosphere, gold linework), so that the sheet matches the approved mock direction.
20. As a **player**, I want Classic Light and Classic Dark as first-class skins (not system brightness), so that “light” and “dark” are explicit choices.
21. As a **user**, I want the old global light/dark toggle removed/hidden, so that theming has one mental model: skins.
22. As a **localized user**, I want skin labels in English and German, so that Appearance matches the rest of the app.
23. As a **player**, I want per-stat visualization variants unchanged by skin choice, so that layout knobs stay independent of atmosphere.
24. As a **designer/developer**, I want skins as token + chrome + decoration packs, so that we don’t duplicate widget trees per skin.
25. As a **developer**, I want stable snake_case `skinId`s, so that new skins can ship without schema breaks.
26. As a **QA / developer**, I want lean iPad-landscape goldens per skin for major player surfaces, so that mock-close regressions are caught without today’s device matrix sprawl.
27. As a **DM/player**, I want missing campaign default to resolve to Classic Dark, so that upgrades behave predictably.
28. As a **future contributor**, I want a clear extension point to add skins (e.g. Stone Reliquary), so that v1 isn’t a dead end.

## Implementation Decisions

### Skin catalog (v1)

| `skinId` | EN | DE (draft) | Notes |
|----------|----|------------|-------|
| `classic_light` | Classic Light | Klassisch Hell | Today’s light parchment look, elevated to a named skin |
| `classic_dark` | Classic Dark | Klassisch Dunkel | Today’s dark look; **fallback** when default/skin missing or unknown |
| `arcane_ledger` | Arcane Ledger | Arkanes Foliant | Mock-close manuscript skin |
| `night_cartographer` | Night Cartographer | Nachtkartograph | Mock-close night-atlas skin |

Labels via `intl_en.arb` / `intl_de.arb`. IDs never localized.

### Resolution rules

```
resolvedSkinId =
  character.skinId
  ?? campaign.defaultSkinId
  ?? "classic_dark"

if resolvedSkinId not in registry → render as classic_dark (keep stored id)
```

- **Campaign default** themes: RPG wizard (after step 1), DM screens, DM popups/modals.
- **Resolved character skin** themes: that character’s player page (all tabs + navbar), player popups from that sheet.
- **Pre-campaign / no skin yet**: Classic Dark.
- Companions / alternate forms: main character’s resolved skin only (no nested `skinId`).

### Persistence

- `RpgConfigurationModel.defaultSkinId` (`String?`) — campaign default; synced with existing RPG config revision flow.
- `RpgCharacterConfiguration.skinId` (`String?`) — per-character override; `null` = inherit; synced with existing character config revision flow.
- No per-character field on alternate/companion configs.

### Architecture (low maintenance)

- **One widget tree**; skins are data: colors, typography, chrome (frame style, radii, borders), background decoration id, optional raster plates.
- Extend / replace `CustomTheme` + `CustomThemeProvider` so active skin supplies tokens; remove user-facing brightness toggle.
- Shared chrome: `SheetFrame`, background painters/plates, level badge / navbar accents parameterized by skin—not forked screens.
- Decorative delivery: **hybrid** — raster plates for atmosphere (parchment wash, constellation, wax seal); code-drawn geometry for rules, HUD brackets, gold strokes.
- **Do not** encode per-stat layouts in the skin; keep existing `variant` system.
- Player Appearance entry on live player page navbar/settings area.
- DM: new **first** wizard step for default skin; same field editable from campagne management later.

### Visual fidelity

- Target **mock-close** for Ledger and Cartographer (not palette-only).
- Approve designs on **iPad landscape**; phone/portrait inherit tokens/chrome without separate mock approval.
- Before implementing Ledger/Cartographer non-Stats tabs: generate and approve dedicated mocks for all nine player surfaces × both skins (Background, Stats, Features, Attacks, Spells, Money, Inventory, Recipes, Lore). Classic skins lean on cleaned goldens.

### Build sequencing (vertical slices)

1. **Moderate golden cleanup** — keep major player-screen coverage; drop extra devices/orientations; collapse light/dark into `classic_light` / `classic_dark`.
2. **Infrastructure** — skin registry, resolution, persistence fields, theme provider wiring, remove brightness toggle, DM wizard step 1 + campagne edit, player Appearance picker (hybrid UX), Classic Light/Dark.
3. **Arcane Ledger** — mocks for all nine surfaces → assets/painters → implement across player tabs, wizard, DM, popups.
4. **Night Cartographer** — same as Ledger.

### Modules (indicative)

| Module | Responsibility |
|--------|----------------|
| Skin registry / `CharacterSheetSkin` tokens | Catalog, fallback, token packs |
| Theme provider | Active skin → colors/fonts/chrome for subtree |
| Campaign + character JSON models | `defaultSkinId` / `skinId` |
| Wizard step 1 + campagne management | DM default |
| Player Appearance modal | Override / inherit + preview rules |
| Shared chrome + background decorations | Frames, plates, painters |
| Golden tests | iPad landscape per skin as skins land |

### Related work

- Orthogonal to [character-stat-visualization-variants](./character-stat-visualization-variants.md) (layout variants vs sheet skins).

## Testing Decisions

- **Unit:** skin resolution (null inherit, unknown id → classic_dark, override wins); JSON round-trip for new fields on campaign + character configs.
- **Widget/UI:** Appearance picker modes (immediate-apply vs Save/Cancel based on missing required stats); “Use campaign default” clears override.
- **Goldens:** After moderate cleanup, one **iPad landscape** golden per major player surface × skin as each skin ships; wizard step 1 and a representative DM/modal surface get at least Classic + one ornate skin smoke golden.
- **Prior art:** existing player page goldens under `test/goldens/playerpagescreens*`; migrate light/dark naming to skin ids rather than growing device matrix.
- External behavior: choosing a skin changes presentation only—no change to stored stat values or per-stat `variant` indices unless the user edits those separately.

## Out of Scope

- Skins beyond the four listed in v1 (Stone Reliquary, Field Codex, sci-fi set, etc.)—registry must allow later adds.
- DM allowlist of permitted skins.
- Per-companion / per-alternate-form skin overrides.
- DM editing another character’s `skinId`.
- Phone/portrait-specific mock approval passes.
- Changing per-stat visualization variant catalogs as part of skin work.
- Reintroducing a user-facing global brightness toggle alongside skins.
- Forge/ogb publish of this PRD (local file only by request).

## Further Notes

- Design refs (local agent assets): Arcane Ledger, Night Cartographer, and comparison boards under Cursor project assets; regenerate higher-res plates as implementation needs them.
- Picker thumbnail art can reuse approved mock crops.
- When campaign default changes, characters with `skinId == null` update on next config sync/render; explicit overrides unchanged.
)