# Execution plan — Longer-lived auth (access + refresh tokens)

**PRD:** `docs/prd/longer-lived-auth-refresh-tokens.md`  
**Items:** `planning/longer-lived-auth/` (`--items-path planning/longer-lived-auth/index.md`)  
**Log dir:** `planning/prd-issues-tdd-local-main/`  
**Branch strategy:** **main** (all work items committed sequentially on default branch).  
**Ready filter:** Status `ready` (not yet complete).

## Ordered work items

| Order | ID | Title | Blocked by | Status |
|------:|----|--------|------------|--------|
| 1 | auth-01 | Token pair on password login + AuthSession store + Flutter secure refresh storage | — | done |
| 2 | auth-02 | Refresh API (rotate, grace, reuse-revoke) + Flutter TokenRefresher call path | auth-01 | pending |
| 3 | auth-03 | Cold-start SessionRestorer (skip login / fail → login; no offline bypass) | auth-02 | pending |
| 4 | auth-05 | Logout on SelectGameMode + revoke; Apple/register token pairs; revoke-all API; EN/DE | auth-01, auth-02 | pending |
| 5 | auth-04 | Auto-refresh: proactive timer + Chopper 401 + SSE `refreshJwt` single-flight | auth-02, auth-03 | pending |

Note: After auth-02, **auth-03** then **auth-05** (auth-05 does not need auth-03). **auth-04** last (needs auth-03).

## Dependency graph

```
auth-01 ──► auth-02 ──┬──► auth-03 ──► auth-04
                      │
                      └──► auth-05
```

## Verification notes (this repo)

- Backend: `dotnet test` (API / DataLayer / BusinessLayer as touched)
- Compose: `docker compose` for RPGTableHelper API on port 7777 (not OpenGitBase scripts)
- Flutter: `flutter test` for auth services / session restore
- Playwright visual gallery: N/A (Flutter app, not opengitbase-web); widget tests where UI changes (logout, cold start)
