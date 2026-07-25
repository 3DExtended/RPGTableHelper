# [slice] auth-03 — Cold-start SessionRestorer (skip login / fail → login; no offline bypass)

## Metadata

- Forge: local
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`

## What to build

On app launch, if a refresh token exists in secure storage, show brief loading, call refresh (via TokenRefresher), and navigate to `SelectGameMode` on success. If no refresh token (upgrade from JWT-only installs) or refresh fails / no network, stay on or return to `LoginScreen` with optional session-expired messaging. Do not enter the app on a cached access JWT alone when refresh cannot succeed.

Demoable: kill and relaunch the app while refresh is valid → land on SelectGameMode without credentials; revoke or delete refresh → login screen.

## Acceptance criteria

- [ ] Cold start with valid refresh → loading → `SelectGameMode` (no LoginScreen flash as the destination)
- [ ] Missing refresh token → `LoginScreen` even if an old JWT remains in prefs
- [ ] Failed refresh or unreachable API on launch → remain on login / retry (no offline entry on access JWT alone)
- [ ] Optional localized session-expired message path prepared (copy may finalize in auth-05)
- [ ] Flutter tests cover success, missing refresh, and refresh-failure routing

## Blocked by

- auth-02

## User stories covered

- 1, 2, 5, 6, 17
