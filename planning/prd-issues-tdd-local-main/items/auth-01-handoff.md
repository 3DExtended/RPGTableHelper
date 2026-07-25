# [handoff] auth-01 — Token pair on password login + AuthSession + Flutter secure store

## PRD

`docs/prd/longer-lived-auth-refresh-tokens.md`

## Work item

`planning/longer-lived-auth/items/auth-01.md`

## Branch

`main`

## Acceptance criteria

- AuthSession persistence (user id, token hash, expiry, created/last-used)
- Password login returns `{ accessToken, refreshToken, expiresIn }`
- Access ~6h, refresh ~90d configurable
- Refresh hashed server-side
- Flutter: JWT prefs + refresh secure storage
- Stop writing UserCredential.RefreshToken on touched paths
- Tests: API + Flutter

## Dependencies

None
