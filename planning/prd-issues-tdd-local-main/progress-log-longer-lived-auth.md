# Progress log — Longer-lived auth

## 2026-07-26 — Run start

- Branch: `main`
- PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`
- Items: `planning/longer-lived-auth/`
- User confirmed plan; implementing auth-01 → auth-02 → auth-03 → auth-05 → auth-04 on main with TDD + compose verification where applicable

## 2026-07-26 — auth-01 done

- Backend: `AuthSessionEntity` + `CreateAuthSessionQuery`/`CreateAuthSessionQueryHandler` (SHA-256 hashed refresh tokens, modeled on `ApiKeyEntity`); `AddAuthSessions` EF migration; `JwtOptions.RefreshTokenNumberOfSecondsToExpire` (90d) + access default bumped to 21600s (6h); `SignInController.LoginWithUsernameAndPasswordAsync` now returns `AuthTokenPairDto { AccessToken, RefreshToken, ExpiresIn }` and creates an `AuthSession` row per login (multi-session verified); `RegisterController` stopped writing the dead `UserCredential.RefreshToken` field on both register paths.
- Flutter: added `flutter_secure_storage`; new `ISecureRefreshTokenStorage`/`SecureRefreshTokenStorage`/`MockSecureRefreshTokenStorage`; `AuthenticationService.persistTokenPair` parses the new JSON login response and stores the access JWT via the existing `setJwt` (prefs) and the refresh token via secure storage; no swagger regen needed (`Response<String>` passes the raw JSON body through untouched).
- Tests: `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~SignInController"` (10 passed, 1 pre-existing skip), `dotnet test tests/RPGTableHelper.DataLayer.Tests` (78 passed), `flutter test` (1223 passed). Full `Api.Tests` run has 9 pre-existing SSE notification test failures unrelated to auth (reproduced identically on a clean `main` checkout before this change) — not fixed here, out of scope.
- Status: `auth-01` marked `done` in `planning/longer-lived-auth/index.md` and the execution plan. Next up: `auth-02` (refresh rotation/grace/reuse-revoke).

## 2026-07-26 — auth-02 done

- Backend: `JwtOptions.RefreshTokenGracePeriodSeconds` (default 60s); `RefreshAuthSessionQuery`/`RefreshAuthSessionQueryHandler` (current-hash rotate, previous-hash-within-grace rotate again, previous-hash-after-grace revoke that session only, unknown/expired/revoked → 401 no side effects); `SignInController.RefreshAsync` (`POST /SignIn/refresh`) wired to it, loads the user by id to mint a fresh JWT, returns `AuthTokenPairDto`.
- Flutter: new `ITokenRefresher`/`TokenRefresher`/`MockTokenRefresher` (`services/auth/token_refresher.dart`) — reads the stored refresh token, POSTs it via an injectable HTTP caller (no swagger regen needed, same rationale as `auth-01`), persists the new pair via `setJwt` + `setRefreshToken` on success; wired into `dependency_provider.dart`.
- Tests: `dotnet test tests/RPGTableHelper.DataLayer.Tests --filter "FullyQualifiedName~RefreshAuthSessionQueryHandlerTests"` (7 passed), `dotnet test tests/RPGTableHelper.DataLayer.Tests` full (85 passed), `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~SignInControllerTests"` (16 passed, 1 pre-existing skip), `flutter test test/services/auth/` (6 passed). Full `Api.Tests` run still has the same 9 pre-existing SSE notification failures (reconfirmed via `git stash` against `main` before this change) — unrelated, not fixed here.
- Status: `auth-02` marked `done` in `planning/longer-lived-auth/index.md` and the execution plan. Next up: `auth-03` (cold-start `SessionRestorer`) then `auth-05`, then `auth-04`.

## 2026-07-26 — auth-03 done

- Flutter: new `ISessionRestorer`/`SessionRestorer`/`MockSessionRestorer` (`services/auth/session_restorer.dart`) — no stored refresh token → `needsLogin` with zero network calls; stored token → delegates to `ITokenRefresher.refresh()`, mapping success to `restored` and any failure (expired/revoked/unreachable) to `needsLogin`. New `SessionRestorerScreen` (`screens/preauthorized/session_restorer_screen.dart`) shows a brief spinner, calls `ISessionRestorer.restore()` post-frame, and `pushReplacementNamed`s to `SelectGameModeScreen` or `LoginScreen`. `main.dart`'s `initialRoute` now defaults to `SessionRestorerScreen.route` instead of `LoginScreen.route`; `dependency_provider.dart` registers `ISessionRestorer`.
- Tests: `flutter test test/services/auth/session_restorer_test.dart` (5 passed), `flutter test test/screens/preauthorized/session_restorer_screen_test.dart` (4 passed), `flutter test` full app suite (1237 passed).
- Status: `auth-03` marked `done` in `planning/longer-lived-auth/index.md` and the execution plan. Next up: `auth-05` (logout + revoke; Apple/register token pairs; EN/DE), then `auth-04` (proactive refresh timer + 401 retry + SSE `refreshJwt`, needs `auth-03`).
