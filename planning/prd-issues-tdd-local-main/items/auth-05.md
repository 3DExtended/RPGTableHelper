# [slice] auth-05 — implementation record

## Summary

Logout on `SelectGameModeScreen` clears local tokens and revokes the device session via `POST /SignIn/logout`. Apple (fully registered) and register paths mint the same `AuthTokenPairDto` through `IAuthTokenPairIssuer`. `POST /SignIn/revoke-all` revokes every AuthSession for the authenticated user (API-only). EN/DE strings for logout and session-expired; SessionRestorer shows session-expired snackbar when refresh fails with a stored token.

## Linked Context

- PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`
- Work item: `auth-05`

## Dependency Graph

### Direct dependencies (blocked by)
- auth-01
- auth-02

### Full chain
`auth-01 -> auth-02 -> auth-05`

## Status

- Branch: `main`
- Tests: SignIn/Register API + AuthSession revoke handlers + Flutter session_revoker / session_restorer
- Visual snapshots: SelectGameMode goldens updated for logout control
- Local E2E: `./scripts/test-auth-refresh-e2e.sh` covers logout + revoke-all
