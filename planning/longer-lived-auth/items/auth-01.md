# [slice] auth-01 — Token pair on password login + AuthSession store + Flutter secure refresh storage

## Metadata

- Forge: local
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`

## What to build

Introduce server-side refresh sessions and change password login to return a JSON token pair. Persist hashed refresh tokens in a new AuthSession (or equivalent) table. Extend JwtOptions for access (~6h) and refresh (~90d) lifetimes. Flutter parses the new login response, keeps the access JWT in SharedPreferences, and stores the refresh token in FlutterSecureStorage.

Demoable: username/password login yields `{ accessToken, refreshToken, expiresIn }`; client persists both; a second device login creates a separate AuthSession row (multi-session).

## Acceptance criteria

- [ ] New AuthSession persistence: user id, token hash, expiry, created/last-used (rotation fields may land in auth-02)
- [ ] Password login returns JSON `{ accessToken, refreshToken, expiresIn }` instead of a bare JWT string
- [ ] Access JWT default lifetime ~6h; refresh ~90d; both configurable via options
- [ ] Refresh token stored hashed server-side; plaintext never persisted
- [ ] Flutter stores access JWT in prefs and refresh token in secure storage after password login
- [ ] Stop writing unused `UserCredential.RefreshToken` on register/login paths touched here (or clearly deprecate)
- [ ] API + Flutter tests cover mint + client storage happy path

## Blocked by

None

## User stories covered

- 7, 11, 15, 16
