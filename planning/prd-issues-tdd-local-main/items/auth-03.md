## Summary

Cold start now runs through a new `SessionRestorerScreen` gate before the user ever sees `LoginScreen` or `SelectGameModeScreen`. `MyApp`'s `initialRoute` (and `onGenerateRoute` in `main.dart`) moved from `LoginScreen.route` to `SessionRestorerScreen.route`. The screen shows a brief `CircularProgressIndicator` and, in a post-frame callback, asks a new `ISessionRestorer` service to decide the destination: if there is no refresh token in secure storage (e.g. an upgrade from an older JWT-only install), it returns `needsLogin` without ever calling the network; if a refresh token is present, it delegates to the existing `ITokenRefresher.refresh()` (from `auth-02`) and returns `restored` only on a genuine `200` — any failure (expired/revoked token, unreachable API, malformed response) also collapses to `needsLogin`. The screen then does a single `Navigator.pushReplacementNamed` to either `SelectGameModeScreen.route` or `LoginScreen.route`. This keeps the "never enter the app on a cached access JWT alone" rule enforced in one small, fully unit-testable class (`SessionRestorer`) rather than scattered across the widget, matching the `TokenRefresher`/`AuthenticationService` split already in the codebase.

`ISessionRestorer`/`SessionRestorer`/`MockSessionRestorer` follow the same `I<Name>`/`<Name>`/`Mock<Name>` shape as the other auth services and are registered in `dependency_provider.dart` alongside `ITokenRefresher`. `SessionRestorerScreen` reads it via `DependencyProvider.getIt!.get<ISessionRestorer>()` (the same direct-`GetIt` pattern `main.dart` already uses for `EventsClient` in `_recoverSseSession`) rather than `DependencyProvider.of(context)`, which keeps the screen trivially testable without needing the full `DependencyProvider` `InheritedWidget`/`ProviderScope` wiring — tests just swap `DependencyProvider.getIt` for a fresh `GetIt` instance with a mock or real `SessionRestorer` registered, then assert on stub routes reached via `Navigator`.

## Linked Context

- PRD: `docs/prd/longer-lived-auth-refresh-tokens.md`
- Work item: `auth-03` (`planning/longer-lived-auth/items/auth-03.md`)
- Depends on: `auth-02` (`planning/prd-issues-tdd-local-main/items/auth-02.md`)

## What was built

### Flutter

- `services/auth/session_restorer.dart` (new) — `ISessionRestorer`/`SessionRestorer`/`MockSessionRestorer` and the `SessionRestoreResult { restored, needsLogin }` enum. `SessionRestorer.restore()`: no stored refresh token → `needsLogin` (no `ITokenRefresher` call at all); stored token + `tokenRefresher.refresh()` succeeds → `restored`; stored token + refresh fails for any reason → `needsLogin`.
- `screens/preauthorized/session_restorer_screen.dart` (new) — `SessionRestorerScreen` (`route = 'session-restorer'`), a `StatefulWidget` showing a `CircularProgressIndicator` while it calls `ISessionRestorer.restore()` in `initState`'s post-frame callback, then `pushReplacementNamed`s to `SelectGameModeScreen.route` or `LoginScreen.route` based on the result. Guards against calling `Navigator` after unmount (`if (!mounted) return`).
- `services/dependency_provider.dart` — registers `ISessionRestorer` (real `SessionRestorer` wired to `ISecureRefreshTokenStorage` + `ITokenRefresher`; `MockSessionRestorer` in mocked mode).
- `main.dart` — `AppRoutingShell`'s `MaterialApp.initialRoute` now defaults to `SessionRestorerScreen.route` (was `LoginScreen.route`); `onGenerateRoute` gained the corresponding case. `MyApp(initialRoute: ...)`'s override parameter is untouched, so any future test/tooling that pins a specific starting route still works.

## Behavior implemented (maps to acceptance criteria)

- [x] Cold start with a valid refresh token → loading → `SelectGameMode` (`SessionRestorerScreen` is the only route the user transiently sees before the replacement navigation; there is no `LoginScreen` frame in between).
- [x] Missing refresh token → `LoginScreen`, even if an old JWT still sits in prefs (`SessionRestorer` never inspects the JWT/prefs — only the refresh token presence gates the network call).
- [x] Failed refresh (expired/revoked token or unreachable API) → `LoginScreen`; no offline entry on the cached access JWT alone, since `SessionRestorer` only ever returns `restored` on `ITokenRefresher.refresh() == true`.
- [x] Optional session-expired messaging path left as a stub for `auth-05`: `SessionRestoreResult.needsLogin` is a single outcome for both "no token" and "refresh failed", which is where `auth-05`'s localized copy can branch if it wants to distinguish them later (not required by this slice's acceptance criteria).
- [x] Flutter tests cover success (`restored` → SelectGameMode), missing refresh (`needsLogin` → Login), and refresh-failure (`needsLogin` via a real `SessionRestorer` + failing `MockTokenRefresher` → Login) routing, plus the underlying `SessionRestorer` logic in isolation.

## Explicitly NOT done in this slice (by design)

- No distinct UI/copy for "no refresh token" vs. "refresh failed" (both map to `needsLogin` / `LoginScreen`); localized session-expired messaging is `auth-05`.
- No logout UI, no automatic 401 interceptor, no proactive refresh timer, no SSE `refreshJwt` wiring — all `auth-04`.
- No Apple/Google/register token-pair parity — `auth-05`.
- No swagger/generated-client changes — this slice only consumes the already-existing `ITokenRefresher`/`ISecureRefreshTokenStorage` from `auth-01`/`auth-02`.

## Dependency Graph

### Direct dependencies (blocked by)

- `auth-02` (done)

### Full chain

`auth-01` → `auth-02` → (`auth-03`, `auth-05`) → `auth-04`

## Status

- Branch: `main`
- Tests:
  - `flutter test test/services/auth/session_restorer_test.dart` → 5 passed
  - `flutter test test/screens/preauthorized/session_restorer_screen_test.dart` → 4 passed
  - `flutter test test/services/auth/ test/screens/preauthorized/` → 15 passed
  - `flutter test` (full app suite) → 1237 passed
  - `flutter analyze` on touched files → 0 new issues (2 pre-existing, unrelated infos in `main.dart`: `unnecessary_import`, `avoid_print`)
- Visual snapshots: none required (`SessionRestorerScreen` is a transient loading gate, not a designed/localized screen; no golden test added)
- Commit(s): `5c689dc6` — `feat(auth): restore session on cold start via refresh token`

## Blockers / notes for follow-up

- None. `SessionRestoreResult` intentionally collapses "no refresh token" and "refresh failed" into one `needsLogin` outcome; if `auth-05` wants a session-expired message only for the latter, it will need to either inspect `ISecureRefreshTokenStorage` itself first or extend the enum — flagged here so it isn't a surprise.
