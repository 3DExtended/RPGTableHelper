# Character sheet skins — work items

Parent PRD: [`docs/prd/character-sheet-skins.md`](../../docs/prd/character-sheet-skins.md)

> Local-only planning (no forge publish). Forge discussion numbers TBD.

| ID | Title | Type | Status | Blocked by | Forge |
|----|--------|------|--------|------------|-------|
| skin-01 | Moderate golden cleanup | AFK | done | — | local |
| skin-02 | Skin registry, resolution, persistence, Classic tokens, theme wiring | AFK | done | skin-01 | local |
| skin-03 | DM campaign default (wizard step 1 + campagne edit) | AFK | done | skin-02 | local |
| skin-04 | Player Appearance picker + override persistence | AFK | done | skin-02 | local |
| skin-05 | Apply skins to DM/player surfaces (Classic fidelity) | AFK | done | skin-03, skin-04 | local |
| skin-06 | HITL: Arcane Ledger mocks (9 surfaces) | HITL | ready | skin-05 | local |
| skin-07 | Implement Arcane Ledger + goldens | AFK | ready | skin-06 | local |
| skin-08 | HITL: Night Cartographer mocks (9 surfaces) | HITL | ready | skin-07 | local |
| skin-09 | Implement Night Cartographer + goldens | AFK | ready | skin-08 | local |

## Dependency graph

```
skin-01 → skin-02 → skin-03 ─┐
                  ↘ skin-04 ─┴→ skin-05 → skin-06 → skin-07 → skin-08 → skin-09
```

## HITL pause (skin-06)

AFK Classic path complete. Next requires your design approval for Arcane Ledger mocks (9 player surfaces, iPad landscape) before skin-07.
