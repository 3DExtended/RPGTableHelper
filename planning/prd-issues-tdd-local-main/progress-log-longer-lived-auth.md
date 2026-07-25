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
