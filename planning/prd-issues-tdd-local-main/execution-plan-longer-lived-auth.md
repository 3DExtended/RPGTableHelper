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
| 2 | auth-02 | Refresh API (rotate, grace, reuse-revoke) + Flutter TokenRefresher call path | auth-01 | done |
| 3 | auth-03 | Cold-start SessionRestorer (skip login / fail → login; no offline bypass) | auth-02 | done |
| 4 | auth-05 | Logout on SelectGameMode + revoke; Apple/register token pairs; revoke-all API; EN/DE | auth-01, auth-02 | done |
| 5 | auth-04 | Auto-refresh: proactive timer + Chopper 401 + SSE `refreshJwt` single-flight | auth-02, auth-03 | done |

## Dependency graph

```
auth-01 ──► auth-02 ──┬──► auth-03 ──► auth-04
                      │
                      └──► auth-05
```

## Verification notes (this repo)

- Backend: `dotnet test` (API / DataLayer AuthSession + SignIn/Register)
- Local API E2E: `ASPNETCORE_ENVIRONMENT=LocalSignalRE2E` + `./scripts/test-auth-refresh-e2e.sh http://127.0.0.1:5012`
- Flutter: `flutter test test/services/auth/`
- Playwright visual gallery: N/A (Flutter); SelectGameMode goldens updated for logout
