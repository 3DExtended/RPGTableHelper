# Longer-lived auth (access + refresh tokens) — work items

Parent PRD: [`docs/prd/longer-lived-auth-refresh-tokens.md`](../../docs/prd/longer-lived-auth-refresh-tokens.md)

> Local-only planning (no forge publish). Forge discussion numbers N/A.

| ID | Title | Type | Status | Blocked by | Forge |
|----|--------|------|--------|------------|-------|
| auth-01 | Token pair on password login + AuthSession store + Flutter secure refresh storage | AFK | ready | — | local |
| auth-02 | Refresh API (rotate, grace, reuse-revoke) + Flutter TokenRefresher call path | AFK | ready | auth-01 | local |
| auth-03 | Cold-start SessionRestorer (skip login / fail → login; no offline bypass) | AFK | ready | auth-02 | local |
| auth-04 | Auto-refresh: proactive timer + Chopper 401 + SSE `refreshJwt` single-flight | AFK | ready | auth-02, auth-03 | local |
| auth-05 | Logout on SelectGameMode + revoke; Apple/register token pairs; revoke-all API; EN/DE | AFK | ready | auth-01, auth-02 | local |
