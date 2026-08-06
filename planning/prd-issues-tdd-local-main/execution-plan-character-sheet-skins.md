# Character sheet skins — execution plan

Parent PRD: [`docs/prd/character-sheet-skins.md`](../../docs/prd/character-sheet-skins.md)  
Items: [`planning/character-sheet-skins/`](../character-sheet-skins/)

> Local-only run (no forge/ogb). Flutter goldens stand in for Playwright visual snapshots. No Docker Compose requirement for skin UI slices unless API/migrations appear (none planned for skins).

**Branch strategy: `main`** (all work items committed sequentially on default branch).

## Dependency graph

```
skin-01 → skin-02 → skin-03 ─┐
                  ↘ skin-04 ─┴→ skin-05 → skin-06 → skin-07 → skin-08 → skin-09
```

## Ordered work items

| Order | ID | Title | Type | Status | Blocked by |
|-------|-----|--------|------|--------|------------|
| 1 | skin-01 | Moderate golden cleanup | AFK | done | — |
| 2 | skin-02 | Skin registry, resolution, persistence, Classic tokens, theme wiring | AFK | done | skin-01 |
| 3 | skin-03 | DM campaign default (wizard step 1 + campagne edit) | AFK | done | skin-02 |
| 4 | skin-04 | Player Appearance picker + override persistence | AFK | done | skin-02 |
| 5 | skin-05 | Apply skins to DM/player surfaces (Classic fidelity) | AFK | done | skin-03, skin-04 |
| 6 | skin-06 | HITL: Arcane Ledger mocks (9 surfaces) | HITL | done | skin-05 |
| 7 | skin-07 | Implement Arcane Ledger + goldens | AFK | done | skin-06 |
| 8 | skin-08 | HITL: Night Cartographer mocks (9 surfaces) | HITL | pending — needs user | skin-07 |
| 9 | skin-09 | Implement Night Cartographer + goldens | AFK | pending | skin-08 |

## Adaptations from skill defaults

- No `ogb` publish/comments/`docs pull`
- Visual regression = Flutter `golden_toolkit` (not Playwright / `__visual__`)
- Pause for user at HITL items (skin-06, skin-08)
