# [slice] auth-05 — Logout on SelectGameMode + revoke; Apple/register token pairs; revoke-all API; EN/DE

## Metadata

- Forge: local
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`

## What to build

Add logout on `SelectGameModeScreen` that clears local tokens and revokes this session’s refresh token on the server. Extend Apple (fully registered) and register flows to return the same token pair shape; keep Apple incomplete-registration redirect/`apiKey` unchanged. Expose revoke-all-sessions API without UI. Localize logout and session-expired strings (EN/DE).

Demoable: logout returns to login and cold start no longer restores; Apple/register leave the user with refresh storage like password login; revoke-all invalidates every AuthSession for the user via API.

## Acceptance criteria

- [ ] Logout control on `SelectGameModeScreen` clears prefs JWT + secure refresh and calls revoke for this session
- [ ] After logout, cold start does not restore the session
- [ ] Apple fully-registered login and username/password register return `{ accessToken, refreshToken, expiresIn }` and Flutter stores them
- [ ] Apple incomplete-registration path unchanged in spirit
- [ ] Revoke-all endpoint invalidates all refresh sessions for the authenticated (or otherwise authorized) user; no UI required
- [ ] Logout and session-expired user-facing strings localized EN + DE
- [ ] API + Flutter tests cover logout revoke, Apple/register pair issuance, and revoke-all

## Blocked by

- auth-01
- auth-02

## User stories covered

- 8, 9, 10, 12, 18, 20
