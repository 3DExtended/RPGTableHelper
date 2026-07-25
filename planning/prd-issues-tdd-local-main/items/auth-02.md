## Summary

`POST /SignIn/refresh` exchanges a presented plaintext refresh token for a new access + refresh token pair, rotating the underlying `AuthSession` row. A new `RefreshAuthSessionQuery`/`RefreshAuthSessionQueryHandler` (`libraries/RPGTableHelper.DataLayer.Contracts`/`libraries/RPGTableHelper.DataLayer`) hashes the presented token and looks it up first against the session's current `TokenHash`, then against `PreviousTokenHash`. A match on the current hash (not expired, not revoked) rotates: the current hash moves to `PreviousTokenHash`, `PreviousTokenExpiresAt` is set to `now + RefreshTokenGracePeriodSeconds` (new `JwtOptions` field, default 60s), a fresh opaque token is minted and hashed into `TokenHash`, `ExpiresAt` is extended, and any stale `RevokedAt` is cleared. A match on `PreviousTokenHash` while `PreviousTokenExpiresAt >= now` is treated identically (a twin refresh from a flaky client still succeeds and rotates again). A match on `PreviousTokenHash` *after* grace revokes that session (`RevokedAt = now`) and returns unauthorized — theft/reuse protection scoped to that one session chain, never touching the user's other sessions. Unknown, expired-current, or already-revoked tokens return unauthorized with no side effects. `SignInController.RefreshAsync` calls the query, loads the user by id (`UserQuery`) to mint a new access JWT (same pattern as the Apple/Google login paths), and returns `AuthTokenPairDto`.

On the Flutter side, a new `ITokenRefresher`/`TokenRefresher`/`MockTokenRefresher` service (`services/auth/token_refresher.dart`) reads the refresh token from `ISecureRefreshTokenStorage`, POSTs it to `SignIn/refresh` via injectable `RefreshHttpCaller` (defaulting to a plain `package:http` call — the swagger-generated client was intentionally left untouched since this endpoint isn't in `swagger.json` yet, mirroring `auth-01`'s "no swagger regen needed" note), and on a `200` persists the new pair directly through `IApiConnectorService.setJwt` + `ISecureRefreshTokenStorage.setRefreshToken` (the same two calls `AuthenticationService.persistTokenPair` makes). `refresh()` is the single entry point later auto-refresh wiring (`auth-04`'s proactive timer / 401 retry) will call. Registered in `dependency_provider.dart` alongside the other auth services.

## Linked Context

- PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`
- Work item: `auth-02` (`planning/longer-lived-auth/items/auth-02.md`)
- Depends on: `auth-01` (`planning/prd-issues-tdd-local-main/items/auth-01.md`)

## What was built

### Backend

- `JwtOptions.RefreshTokenGracePeriodSeconds` (`applications/RPGTableHelper.WebApi/Options/JwtOptions.cs`) — new field, default `60`.
- `RefreshAuthSessionQuery`/`RefreshAuthSessionResponse` (`libraries/RPGTableHelper.DataLayer.Contracts/{Queries,Models}/AuthSessions/`) — takes the plaintext token plus caller-computed `NewRefreshTokenLifetimeSeconds`/`GracePeriodSeconds` (same "keep `JwtOptions` out of `DataLayer`" pattern as `auth-01`'s `CreateAuthSessionQuery`).
- `RefreshAuthSessionQueryHandler` (`libraries/RPGTableHelper.DataLayer/QueryHandlers/AuthSessions/`) — current-hash / previous-hash-within-grace / previous-hash-after-grace / unknown branches described above; reuses the same SHA-256 hash + 32-byte random token minting as `CreateAuthSessionQueryHandler`.
- `RefreshTokenRequestDto` (`applications/RPGTableHelper.WebApi/Dtos/RefreshTokenRequestDto.cs`) — `{ RefreshToken }`.
- `SignInController.RefreshAsync` — new `[HttpPost("refresh")]` action under the existing `SignInController` (kept alongside `login` for cohesion, per slice guidance); runs `RefreshAuthSessionQuery`, loads the user by id, mints a new JWT, returns `AuthTokenPairDto`, or `401` on any failure.

### Flutter

- `services/auth/token_refresher.dart` (new) — `ITokenRefresher`/`TokenRefresher`/`MockTokenRefresher`, same `I<Name>`/`<Name>`/`Mock<Name>` shape as the other auth services; `TokenRefresher.refresh()` returns `false` (no side effects) when there's no stored refresh token, the HTTP call throws, or the server responds non-200; persists and returns `true` only on a well-formed `200` body.
- `services/dependency_provider.dart` — registers `ITokenRefresher` (real `TokenRefresher` wired to `IApiConnectorService` + `ISecureRefreshTokenStorage`; `MockTokenRefresher` in mocked mode).

## Behavior implemented (maps to acceptance criteria)

- [x] Refresh endpoint issues a new access + refresh pair and rotates the server session.
- [x] Previous refresh token accepted only during the ~60s grace window (`PreviousTokenExpiresAt`).
- [x] Post-grace reuse of a rotated token rejects (`401`) and revokes that session chain only — other sessions for the same user are untouched.
- [x] Expired / unknown refresh tokens are rejected with no side effects beyond the failure response.
- [x] Flutter `TokenRefresher` can refresh and update prefs (`setJwt`) + secure storage (`setRefreshToken`).
- [x] API tests cover rotate, grace (twin refresh), reuse-revoke, expiry, unknown token, and multi-session isolation; Flutter tests cover successful refresh persistence, no-token no-op, 401, and network-failure paths.

## Explicitly NOT done in this slice (by design)

- No cold-start `SessionRestorer` wiring (`auth-03`).
- No logout/revoke-all endpoint, no Apple/Google/register token-pair parity (`auth-05`).
- No proactive refresh timer, no Chopper 401 retry interceptor, no SSE `refreshJwt` wiring (`auth-04`) — `TokenRefresher.refresh()` exists as the entry point those slices will call.
- No swagger.json/generated-client regen for `/SignIn/refresh` — `TokenRefresher` talks to it via a plain injectable HTTP call instead of the generated Chopper client, so no hand-editing of generated `swagger.swagger.dart`/`.chopper.dart` was needed.

## Dependency Graph

### Direct dependencies (blocked by)

- `auth-01` (done)

### Full chain

`auth-01` → `auth-02` → (`auth-03`, `auth-05`) → `auth-04`

## Status

- Branch: `main`
- Tests:
  - `dotnet test tests/RPGTableHelper.DataLayer.Tests --filter "FullyQualifiedName~RefreshAuthSessionQueryHandlerTests"` → 7 passed
  - `dotnet test tests/RPGTableHelper.DataLayer.Tests` (full project) → 85 passed
  - `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~SignInControllerTests"` → 16 passed, 1 skipped (pre-existing, unrelated)
  - `dotnet test tests/RPGTableHelper.Api.Tests` (full project) → 144 passed, 9 failed (pre-existing SSE notification event-name assertion failures, reproduced identically by stashing this change and running against `main` before it — see Blockers), 1 skipped
  - `flutter test test/services/auth/` → 6 passed
- Visual snapshots: none required (no UI/layout change)
- Commit(s): see progress log

## Blockers / notes for follow-up

- Same 9 pre-existing `ConfigChangedSseNotificationControllerTests`/`SessionCommandSseNotificationControllerTests` failures noted in `auth-01`'s record reproduce unchanged on `main` before this slice's diff (confirmed via `git stash`); unrelated to auth, not fixed here.
