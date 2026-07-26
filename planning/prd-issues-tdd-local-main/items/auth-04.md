# [slice] auth-04 — implementation record

## Summary

Wired ongoing session refresh: single-flight `TokenRefresher`, absolute access-token expiry store, `SessionRefreshCoordinator` (proactive ~5 min before expiry + app resume), Chopper `JwtRefreshAuthenticator` on 401, and `EventsClient.refreshJwt` via the coordinator. Hard refresh failure clears tokens and navigates to `LoginScreen`.

## Linked Context

- PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`
- Work item: `auth-04`

## Dependency Graph

### Direct dependencies (blocked by)
- auth-02
- auth-03

### Full chain
`auth-01 -> auth-02 -> auth-03 -> auth-04`

## Status

- Branch: `main`
- Tests: `flutter test test/services/auth/` (45 passed) including single-flight, authenticator, coordinator
- Visual snapshots: none (no new visual surface beyond auth-05 logout)
- Local E2E: refresh rotation + grace against running LocalSignalRE2E API
