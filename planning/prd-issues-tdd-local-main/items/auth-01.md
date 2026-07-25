## Summary

Password login (`POST /SignIn/login`) now mints an access + refresh token pair instead of returning a bare JWT string. A new `AuthSessions` table (`AuthSessionEntity` + `CreateAuthSessionQuery`/`CreateAuthSessionQueryHandler`, modeled directly on the existing `ApiKeyEntity`/`CreateApiKeyQueryHandler` hashed-secret pattern) stores one row per issued refresh token: `UserId`, a SHA-256 `TokenHash` (plaintext is never persisted, only returned once in the response), `ExpiresAt`, plus nullable `PreviousTokenHash`/`PreviousTokenExpiresAt`/`RevokedAt` columns reserved for `auth-02`'s rotation/grace window. `JwtOptions` gained `RefreshTokenNumberOfSecondsToExpire` (default 90 days / 7,776,000s) and the access-token default moved from ~200 minutes to 6 hours (21,600s) per the PRD. `SignInController.LoginWithUsernameAndPasswordAsync` now returns `AuthTokenPairDto { AccessToken, RefreshToken, ExpiresIn }` as JSON; each login call creates a new `AuthSession` row, so two logins for the same user produce two independent sessions (multi-device support). `RegisterController`'s two registration paths (username/password and API-key/SSO completion) no longer write the dead `UserCredential.RefreshToken` field — their response shape (bare JWT) is otherwise unchanged, per scope.

On the Flutter side, `flutter_secure_storage` was added and a new `ISecureRefreshTokenStorage`/`SecureRefreshTokenStorage`/`MockSecureRefreshTokenStorage` triplet (following the existing `IApiConnectorService` service pattern) persists the refresh token outside SharedPreferences. `AuthenticationService.loginWithUsernameAndPassword` parses the new JSON body (still received through the existing generated `Future<Response<String>> signInLoginPost` Chopper method — its `$JsonSerializableConverter` passes `Response<String>` bodies through untouched, so the raw JSON text arrives as-is with no swagger regen needed) via a new `persistTokenPair(rawJson)` method that stores the access token through the existing `setJwt` (prefs) and the refresh token through `ISecureRefreshTokenStorage` (secure storage).

## Linked Context

- PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`
- Work item: `auth-01` (`planning/longer-lived-auth/items/auth-01.md`)
- Handoff: `planning/prd-issues-tdd-local-main/items/auth-01-handoff.md`

## What was built

### Backend

- `AuthSessionEntity` (`libraries/RPGTableHelper.DataLayer/Entities/AuthSessionEntity.cs`) — `EntityBase<Guid>` with `UserId`, `TokenHash`, `ExpiresAt`, and nullable `PreviousTokenHash`/`PreviousTokenExpiresAt`/`RevokedAt` (unused by `auth-01`, reserved for `auth-02`).
- `RpgDbContext` — new `DbSet<AuthSessionEntity> AuthSessions`, unique index on `TokenHash`, non-unique index on `UserId`.
- `CreateAuthSessionQuery`/`CreateAuthSessionResponse` (`libraries/RPGTableHelper.DataLayer.Contracts/{Queries,Models}/AuthSessions/`) — takes `UserId` + caller-computed `ExpiresAt` (kept in `DataLayer.Contracts` so `JwtOptions`, which lives in `WebApi`, never has to be referenced from `DataLayer`).
- `CreateAuthSessionQueryHandler` — mints a 32-byte random secret (`RandomNumberGenerator.Fill`, base64 minus padding, same shape as `CreateApiKeyQueryHandler`), SHA-256-hashes it for storage, and returns the plaintext once in `CreateAuthSessionResponse.PlainRefreshToken`.
- Migration `AddAuthSessions` (`libraries/RPGTableHelper.DataLayer/Migrations/20260725221516_AddAuthSessions.cs`) via `dotnet ef migrations add`.
- `JwtOptions` — `NumberOfSecondsToExpire` default `12000` → `21600` (6h); new `RefreshTokenNumberOfSecondsToExpire` default `7776000` (90d).
- `AuthTokenPairDto` (`applications/RPGTableHelper.WebApi/Dtos/AuthTokenPairDto.cs`) — `{ AccessToken, RefreshToken, ExpiresIn }`.
- `SignInController` — constructor now also takes `JwtOptions`/`ISystemClock`; `LoginWithUsernameAndPasswordAsync` mints the JWT as before, then calls `CreateAuthSessionQuery` with `ExpiresAt = now + RefreshTokenNumberOfSecondsToExpire`, and returns the `AuthTokenPairDto`. Apple/Google/register flows are untouched (still bare JWT strings).
- `RegisterController` — removed the `ApiKeyGenerator.GenerateKey(32)` + `RefreshToken = refreshToken` dead-field write from both `RegisterAsync` and `RegisterWithApiKeyAsync`; response shape (bare JWT) unchanged.

### Flutter

- `pubspec.yaml` — added `flutter_secure_storage: ^10.3.1` (via `flutter pub add`).
- `services/auth/secure_refresh_token_storage.dart` (new) — `ISecureRefreshTokenStorage`/`SecureRefreshTokenStorage`/`MockSecureRefreshTokenStorage`, same `I<Name>`/`<Name>`/`Mock<Name>` shape as `IApiConnectorService`.
- `services/auth/authentication_service.dart` — `IAuthenticationService`/`AuthenticationService`/`MockAuthenticationService` take a new `secureRefreshTokenStorage` dependency; `loginWithUsernameAndPassword` now calls the extracted `persistTokenPair(rawJson)` (parses `{accessToken, refreshToken, expiresIn}`, calls `apiConnectorService.setJwt` + `secureRefreshTokenStorage.setRefreshToken`) instead of `setJwt(result.result!)` directly.
- `services/auth/api_connector_service.dart` — `MockApiConnectorService` gained a `lastSetJwt` field (set inside `setJwt`) so tests can assert what was persisted.
- `services/dependency_provider.dart` — registers `ISecureRefreshTokenStorage` and threads it into both the real and mock `IAuthenticationService` factories.

## Behavior implemented (maps to acceptance criteria)

- [x] New `AuthSession` persistence: user id, token hash, expiry, created/last-used (`CreationDate`/`LastModifiedAt` from `EntityBase`); rotation fields present but nullable/unused, ready for `auth-02`.
- [x] Password login returns JSON `{ accessToken, refreshToken, expiresIn }` instead of a bare JWT string.
- [x] Access JWT default lifetime 6h (`21600`); refresh 90d (`7776000`); both configurable via `JwtOptions`.
- [x] Refresh token stored hashed (SHA-256) server-side; plaintext never persisted, only returned once.
- [x] Flutter stores access JWT in prefs (`setJwt`, unchanged) and refresh token in secure storage (`ISecureRefreshTokenStorage`) after password login.
- [x] `UserCredential.RefreshToken` no longer written on the register paths touched here.
- [x] API tests: mint (`CreateAuthSessionQueryHandlerTests`), controller-level hash/expiry assertions, multi-session (two logins → two `AuthSession` rows). Flutter test: `persistTokenPair` storage happy path.

## Explicitly NOT done in this slice (by design)

- No `POST /refresh` endpoint (`auth-02`).
- No rotation/grace-window logic — the nullable `PreviousTokenHash`/`PreviousTokenExpiresAt`/`RevokedAt` columns exist but are not read or written yet.
- Apple/Google/register response shapes unchanged (still bare JWT strings) — only the dead `UserCredential.RefreshToken` write was removed from `RegisterController`.
- No cold-start `SessionRestorer`, no logout/revoke, no auto-refresh (`auth-03`/`auth-04`/`auth-05`).
- No swagger.json/generated-client regen — `signInLoginPost`'s `Response<String>` still compiles and works because `$JsonSerializableConverter` skips JSON-decoding when `ResultType == String`, so the raw response text (now a JSON object) passes through untouched for `authentication_service.dart` to parse manually.

## Dependency Graph

### Direct dependencies (blocked by)

- None (first item in the `longer-lived-auth` chain).

### Full chain

`auth-01` → `auth-02` → (`auth-03`, `auth-05`) → `auth-04`

## Status

- Branch: `main`
- Tests:
  - `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~SignInController"` → 10 passed, 1 skipped (pre-existing, unrelated to this change)
  - `dotnet test tests/RPGTableHelper.DataLayer.Tests --filter "FullyQualifiedName~AuthSession"` → 1 passed
  - `dotnet test tests/RPGTableHelper.DataLayer.Tests` (full project) → 78 passed
  - `dotnet test tests/RPGTableHelper.Api.Tests` (full project) → 138 passed, 9 failed (pre-existing SSE notification event-name assertion failures unrelated to auth, reproduced identically on `main` before this change — see Blockers below), 1 skipped
  - `flutter test test/services/auth/ test/services/dependency_provider_test.dart test/screens/login_screen_test.dart test/screens/register_screen_test.dart` → all passed
  - `flutter test` (full app suite) → 1223 passed
- Visual snapshots: none required (no UI/layout change)
- Commit(s): see handoff doc / progress log

## Blockers / notes for follow-up

- `ConfigChangedSseNotificationControllerTests`/`SessionCommandSseNotificationControllerTests` (9 tests) fail on a clean checkout of `main` (before any `auth-01` change) with the same SSE event-name assertion mismatches — confirmed pre-existing and unrelated to auth; not fixed here (out of scope for `auth-01`).
