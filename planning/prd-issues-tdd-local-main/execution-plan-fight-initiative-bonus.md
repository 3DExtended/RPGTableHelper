# Execution plan — Fight / Initiative bonus config

Parent PRD: [`docs/prd/fight-initiative-bonus-config.md`](../../docs/prd/fight-initiative-bonus-config.md)  
Items: [`planning/fight-initiative-bonus/`](../fight-initiative-bonus/index.md)

Branch strategy: **main** (all work items committed sequentially on default branch).

Ready filter: `Status: ready` in slice metadata (local planning; not forge).

## Dependency graph

```
init-01
  └─> init-02
        └─> init-03
              └─> init-04
```

## Ordered execution

| Order | ID | Title | Status |
|-------|-----|--------|--------|
| 1 | init-01 | Config fields + field enum + base-preset prefill + resolve/format helper | done |
| 2 | init-02 | Initiative popup helper sentence (main / companion / form) | done |
| 3 | init-03 | Fight / Initiative wizard step (pickers, preview, None, broken→None wipe) | done |
| 4 | init-04 | Incomplete-Next confirm + Back keeps draft | pending |

## Verification notes (this repo)

- Flutter UI: golden updates via `applications/rpg_table_helper/updategoldens.sh` after all slices (user request).
- No OpenGitBase Playwright gallery; do not apply opengitbase-web visual skill here.
- Backend untouched for this PRD (config is Flutter JSON); compose E2E N/A unless API changes appear.
