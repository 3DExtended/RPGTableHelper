# [PRD] Longer-lived auth via access + refresh tokens

> Local draft (no forge publish). Commit on `main` only.

## Problem Statement

Users must sign in every time they launch the app. The API issues a single JWT (~3.3 hours today), the Flutter client always opens on `LoginScreen`, and there is no refresh endpoint. Mid-session expiry also breaks REST and SSE with no recovery path other than a full re-login. As a DM or player, I want to open the app and continue where I left off for weeks, without typing credentials (or Apple) on every cold start.

## Solution

Issue a short-lived **access JWT** (~6 hours) plus a long-lived **opaque refresh token** (~90 days). Store the refresh token in secure storage; keep the access JWT in SharedPreferences. On launch (and when needed mid-session), refresh in the background. Logout revokes this device’s refresh session. Users who upgrade from the old JWT-only client sign in once, then stay signed in.

## User Stories

1. As a **returning user**, I want the app to restore my session on launch without showing the login form, so that I can start playing immediately.
2. As a **user launching offline or with the API down**, I want to stay on login / retry until auth succeeds, so that I never enter the app half-authenticated.
3. As a **user whose access JWT is about to expire**, I want the client to refresh ~5 minutes early, so that API and SSE calls do not fail mid-session.
4. As a **user whose access JWT already expired**, I want a 401 on REST or SSE to trigger a single refresh and retry, so that brief expiry races do not force a re-login.
5. As a **user with a valid refresh token**, I want cold start to show a brief loading state then land on `SelectGameMode`, so that login is skipped when the session is still good.
6. As a **user whose refresh token expired or was revoked**, I want to see `LoginScreen` (with an optional session-expired message), so that I know I must sign in again.
7. As a **user signing in with username/password**, I want to receive access + refresh tokens, so that subsequent launches stay signed in.
8. As a **user signing in with Apple** (fully registered), I want the same token pair, so that Apple users get the same stay-signed-in experience.
9. As a **new user completing register**, I want the same token pair, so that I am not bounced to login after registration.
10. As a **user mid Apple registration** (username still needed), I want the existing redirect/apiKey path unchanged, so that incomplete SSO setup is not broken.
11. As a **user on two devices**, I want each device to keep its own refresh session, so that signing in on a phone does not kick my tablet.
12. As a **user logging out from Select Game Mode**, I want local tokens cleared and this session’s refresh token revoked on the server, so that that device cannot silently restore.
13. As a **user whose stolen old refresh token is reused after rotation**, I want that session chain revoked, so that theft of a rotated token cannot keep impersonating me on that session.
14. As a **developer**, I want refresh to be single-flight on the client, so that parallel API/SSE 401s do not stampede the refresh endpoint.
15. As a **developer**, I want refresh tokens stored hashed server-side with rotation and a short grace window, so that plaintext long-lived secrets are not sitting in the DB and twin refreshes do not flake.
16. As an **operator**, I want configurable access and refresh lifetimes (defaults 6h / 90d), so that production can tune without a code change.
17. As a **user upgrading from an older app build**, I want one intentional re-login when no refresh token exists locally, so that migration stays simple.
18. As a **developer**, I want a revoke-all-sessions API ready without UI, so that “sign out everywhere” can be wired later.
19. As a **tester**, I want API and client tests for mint, refresh, rotate, grace, reuse-revoke, logout, and cold-start restore failure, so that auth regressions are caught.
20. As a **localized user**, I want logout and session-expired copy in English and German, so that auth UX matches the rest of the app.

## Implementation Decisions

### Modules (deep seams)

| Module | Responsibility |
|--------|----------------|
| **AuthSessionStore** (API / DataLayer) | Persist refresh sessions: user id, token hash, expiry, current + previous hash for grace, created/last-used; CRUD + revoke one / revoke all |
| **TokenPairIssuer** (API) | Mint access JWT (~6h) + opaque refresh token (~90d); hash refresh before store; return `{ accessToken, refreshToken, expiresIn }` |
| **RefreshTokenApi** | `POST` refresh (body: refresh token) → new pair with rotation + ~60s grace; reject + revoke session chain on post-grace reuse |
| **Logout / RevokeApi** | Logout: revoke current session (authenticated or refresh-presented); revoke-all for user (API-only UI later) |
| **SignIn / Register response shape** | Password login, Apple (registered), and register all return the JSON token pair; Apple incomplete registration stays special-cased |
| **JwtOptions** | Access lifetime default 21600s (6h); add refresh lifetime (90 days) and grace seconds (~60) |
| **Flutter SecureRefreshStore** | Refresh token in `FlutterSecureStorage`; access JWT remains in SharedPreferences |
| **Flutter SessionRestorer** | Cold start: if refresh present → refresh → navigate to `SelectGameMode`; else `LoginScreen`; no offline bypass on cached JWT alone |
| **Flutter TokenRefresher** | Single-flight refresh; proactive timer (~5 min before `expiresIn`); on app resume; Chopper 401 retry; wire SSE `refreshJwt` |
| **Flutter Logout** | Control on `SelectGameModeScreen`: clear local tokens, call revoke, go to `LoginScreen` |

### Token model

- **Access**: HMAC JWT as today (claims unchanged in spirit: username, `identityproviderid` = user id, etc.), lifetime ~6h.
- **Refresh**: opaque random secret (not a JWT). Server stores only a hash (password-style). Client stores plaintext in secure storage.
- **Response**: `{ accessToken, refreshToken, expiresIn }` (seconds until access expiry).
- **Multi-session**: one DB row per refresh session; no device name/id metadata in v1.

### Rotation and theft

- Every successful refresh issues a new refresh token and invalidates the previous after a **~60s grace** (accept current or previous hash during grace).
- Presentation of a rotated token **after** grace → reject and revoke **that session chain** (not all user sessions).

### Client refresh policy

- Proactive: refresh ~5 minutes before `expiresIn` (use response field; do not require JWT parse).
- Reactive: on REST/SSE 401, single-flight refresh then retry once.
- Concurrent callers wait on the in-flight refresh and share the result.
- Mid-session refresh failure → clear tokens, navigate to `LoginScreen` (optional short message).

### Cold start / upgrade

- No refresh token in secure storage → `LoginScreen` (even if an old JWT sits in prefs).
- No soft “upgrade JWT → refresh” endpoint.
- No network / failed refresh on launch → remain on login / retry (do not enter app on cached access JWT alone).

### Schema

- New `AuthSession` (or equivalent) table; stop writing unused `UserCredential.RefreshToken` (cleanup/deprecation acceptable in same or follow-up migration).
- Do not conflate with Apple’s `SignInProviderRefreshToken` on pending SSO registration rows.

### Out-of-scope APIs still prepared

- `revoke all sessions for user` endpoint exists; no “Sign out everywhere” UI in this slice.

## Testing Decisions

External behavior only:

| Area | Prove |
|------|--------|
| **API auth tests** | Login/register/Apple registered return token pair; refresh rotates; grace accepts previous briefly; post-grace reuse revokes session; logout/revoke-one; revoke-all; expired refresh rejected |
| **JWT options** | Default access ~6h; refresh ~90d configurable |
| **Flutter unit/widget** | Secure store round-trip; SessionRestorer routes (success / missing refresh / refresh fail); TokenRefresher single-flight; 401 path invokes refresh once; logout clears local state |
| **Prior art** | `SignInController` / register flows; `JWTTokenGenerator`; `api_connector_service` JWT prefs; SSE `refreshJwt` hook; `SessionPresenceService` tests as pattern for service tests |

No requirement for full device E2E in this PRD; integration-style API tests + Flutter service tests are the bar.

## Out of Scope

- Google Sign-In client implementation (server stub may still return the new pair later; Flutter remains unimplemented).
- “Sign out everywhere” UI.
- Soft migration endpoint that mints refresh from an existing Bearer JWT.
- Device names, stable device IDs, or per-device management UI.
- Changing Apple incomplete-registration redirect/`apiKey` flow.
- Multi-instance refresh-token coordination beyond single API process / SQLite.
- Refresh-token cookies / HttpOnly browser flows.

## Further Notes

- Ship API + Flutter together: old clients expecting a bare JWT string body will break against the new JSON shape.
- Existing dead `UserCredential.RefreshToken` random string at register is scaffolding only—replace with AuthSession rows.
- Localization: logout + session-expired strings in EN/DE.
- Aligns with SSE PRD story about reconnecting with a refreshed JWT—this PRD supplies the missing refresh mechanism that hook was waiting for.
