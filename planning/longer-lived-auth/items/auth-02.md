# [slice] auth-02 — Refresh API (rotate, grace, reuse-revoke) + Flutter TokenRefresher call path

## Metadata

- Forge: local
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`

## What to build

Add `POST` refresh that accepts a refresh token and returns a new token pair. Implement rotation with ~60s grace (current + previous hash). After grace, reuse of an old refresh token rejects and revokes that session chain only. Flutter TokenRefresher can call refresh, update stored tokens, and expose a single entry point for later auto-refresh wiring.

Demoable: refresh succeeds and rotates; a twin refresh within grace still works; post-grace reuse of the old token fails and kills that session.

## Acceptance criteria

- [ ] Refresh endpoint issues new access + refresh pair and rotates server session
- [ ] Previous refresh token accepted only during ~60s grace window
- [ ] Post-grace reuse of rotated token rejects and revokes that session chain (not all user sessions)
- [ ] Expired / unknown refresh tokens are rejected without side effects beyond failure
- [ ] Flutter TokenRefresher can refresh and update prefs + secure storage
- [ ] API tests cover rotate, grace, reuse-revoke, expiry; Flutter tests cover successful refresh persistence

## Blocked by

- auth-01

## User stories covered

- 13, 15, 19
