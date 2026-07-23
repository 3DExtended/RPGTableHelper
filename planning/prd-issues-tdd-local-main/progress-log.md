# Progress log — SSE + REST realtime

## 2026-07-23 — Run start

- Branch: `main`
- Scope: sse-01 … sse-08 until prod-ready
- User confirmed local-only planning; implement on main with TDD + compose verification

## sse-01 complete

- Commit: `d99da33c`
- API EventsControllerTests: 3 passed
- Flutter events_client_test: 5 passed

## sse-02 complete

- Config revision store + REST PATCH/PUT/GET (Campagne + PlayerCharacter)
- Commit: `6c9a907c`
- `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~ConfigRevision|FullyQualifiedName~ConfigFileBackupWriter|FullyQualifiedName~ConfigDocumentPatcher"`: 20 passed
- `dotnet test tests/RPGTableHelper.DataLayer.Tests --filter "FullyQualifiedName~ConfigRevisionHistoryMigrationTests"`: 1 passed
- `dotnet test RPGTableHelper.sln`: full solution green (Api.Tests 114 passed/1 skipped, DataLayer.Tests 74 passed, BusinessLayer.Tests 9 passed, Shared.Tests 66 passed)

## sse-03 complete

- Table session presence (separate from campagne membership): REST `POST /Session/enter/{campagneid}` / `leave/{campagneid}`, in-process `ISessionPresenceService` online set per campagne, `participantOnline`/`participantOffline` SSE broadcast to other session participants only, grace period on SSE disconnect (20s prod / 150ms E2ETest) so brief reconnects don't flicker offline. Flutter `SessionEntryCoordinator` performs REST hydration right after `SessionEnter` (DM: campagne config + all characters; player: campagne config + own character), wired into `select_game_mode_screen.dart`. SignalR untouched.
- Commits: `983ae376` (backend), `acc0dfe4` (Flutter)
- `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~SessionController|FullyQualifiedName~SessionPresenceService|FullyQualifiedName~EventsController"`: 11 passed
- `dotnet test tests/RPGTableHelper.Api.Tests`: 158 passed / 1 skipped (pre-existing, unrelated)
- `dotnet test tests/RPGTableHelper.DataLayer.Tests`: 74 passed
- `flutter test test/services/session/session_entry_coordinator_test.dart`: 5 passed
- `flutter test` (full app suite): 1202 passed

## sse-04 complete

- Config-changed SSE: `CampagneController`/`PlayerCharacterController` PATCH/PUT now emit session-scoped `campagneConfigChanged`/`characterConfigChanged` (`{ id, revision }` only, no body) to other online session participants (`ISessionPresenceService.GetOnlineParticipants`, new). Flutter `ConfigSyncCoordinator` (debounce/coalesce, single-in-flight PUT, 409 GET/rebase/retry, SSE-notify → `GET ?sinceRevision=` catch-up) + `ConfigSyncSessionController` (wires coordinators to `IRpgEntityService` + shared `EventsClient`, applies patch/full into Riverpod). `select_game_mode_screen.dart` starts/stops the controller around session enter/leave. Hub invoke queue remains the UI's write path until `sse-08`, per task instructions.
- Commits: `a957807e` (backend), `085ce1de` (Flutter)
- `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~SessionPresenceServiceTests|FullyQualifiedName~ConfigChangedSseNotificationControllerTests"`: 11 passed
- `dotnet test RPGTableHelper.sln`: full solution green (Api.Tests 165 passed/1 skipped pre-existing unrelated, DataLayer.Tests 74 passed, BusinessLayer.Tests 9 passed, Shared.Tests 66 passed)
- `flutter test test/services/config_sync/`: 14 passed
- `flutter test` (full app suite): 1216 passed

---
