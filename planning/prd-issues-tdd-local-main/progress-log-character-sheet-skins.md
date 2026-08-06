# Progress log — character sheet skins

## 2026-08-06 — Run start

- Mode: local files only (no ogb)
- Branch: `main`
- PRD: `docs/prd/character-sheet-skins.md`
- Items: `planning/character-sheet-skins/`
- Starting: skin-01

## 2026-08-06 — skin-01 paused for human goldens

- Device matrix reduced to `ipad pro 12-9 landscape`; orphaned device PNGs deleted; README paths updated.
- Player + DM page goldens pass.
- CharacterStat suite slimmed to variant0 / en / light; leftover matrix PNGs deleted. Human still needs `--update-goldens` for ~75 CharacterStat screenshots.

## 2026-08-06 — skin-02 done

- Registry + resolve + JSON fields + Classic theme wiring + l10n labels committed on `main`.
- Next: skin-03 (DM wizard default) and skin-04 (player Appearance) in parallel dependency-wise after skin-02.

## 2026-08-06 — skin-03 / skin-04 / skin-05 done (HITL pause)

- **skin-03:** Wizard step 0 skin picker (first); persists `defaultSkinId` on select; themes later steps via `setActiveSkinId`. Campagne management Appearance section.
- **skin-04:** Player gear menu → Appearance; hybrid immediate vs Save/Cancel via `hasMissingRequiredCampaignStats`; clear override with null `skinId`; companions inherit main.
- **skin-05:** Player + DM pages apply resolved/campaign skin; campaign-management goldens updated; page tests seed Classic light/dark to match brightness matrix.
- **Paused at skin-06** — need user Arcane Ledger mocks (9 surfaces) before skin-07.

---
