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

## sse-08 complete — SignalR hard cut (SSE + REST only)

- **Backend deleted**: `RpgServerSignalRHub`, `RpgConfigSliceV3EnvelopeBuilder`, `RpgConfigSliceV3UpstreamEnvelope`, `AddSignalR().AddMessagePackProtocol()` + `MapHub<>` in `Startup`, and the `MessagePack` package ref. All SignalR API tests removed (`SignalRControllers/`, V3 envelope tests). `RpgConfigColdHotSlicer` kept (used by REST config store, not SignalR-only).
- **Flutter deleted**: `server_communication_service.dart` (hub client), `hub_invoke_queue.dart`, `hub_invoke_retry.dart`, `rpg_config_upstream_envelope.dart`, the `signalr_netcore` dependency, all `integration_test/signalr_*` + hub-only unit tests, and the `run_flutter_signalr_e2e.sh` / `run_flutter_multi_sim_e2e.sh` scripts.
- **Rewired**: `ServerMethodsService` no longer depends on the hub client; durable config writes route through the active `ConfigSyncSessionController` (debounced REST PATCH/PUT + 409 rebase), falling back to a direct REST PUT when no session controller is active. DM/player storage observers call the same path. `main.dart` ping/pong + hub-drain timers removed in favor of `EventsClient.ensureConnected()`.
- **Docs**: `PROJECT_OVERVIEW.md` communication section updated to SSE + REST.
- `dotnet test` — Api.Tests: 143 passed / 1 skipped (pre-existing, unrelated); DataLayer.Tests: 77 passed; BusinessLayer.Tests: 9 passed; Shared.Tests: 66 passed.
- `flutter test` (full app suite): **1204 passed**.
- **Known gap**: real-time DM view of a *player's* character edits (old `updateRpgCharacterConfigOnDmSide` hub relay) is not yet wired to an SSE listener on the DM side; player edits still persist via ConfigSync REST. Deferred to a follow-up.

## sse-08 follow-up: fix DM live player-character view (prod-readiness)

- **Bug**: `select_game_mode_screen.dart` `onCampagneSelected` set `connectedPlayers: null` and never mapped `SessionHydrationResult.allCharacters` into `ConnectionDetails.connectedPlayers`, so every DM view that reads `connectedPlayers` (character overview, fight sequence, grant items, campagne management) rendered nothing. On top of that, `ConfigSyncSessionController._onSseEvent` only ever applied `characterConfigChanged` for `id == _characterId` ("our own" character), which the DM never sets — so player edits never reached the DM's roster, and `participantOnline`/`participantOffline` presence SSE (sse-03) was ignored entirely by the config-sync layer.
- **Fix**:
  - New pure `mapCharactersToOpenPlayerConnections` (`lib/services/session/connected_players_mapper.dart`) parses each hydrated `PlayerCharacter`'s `rpgCharacterConfiguration` into an `OpenPlayerConnection` (falling back to a named base config on missing/malformed JSON), skipping characters without an id or player user id. `onCampagneSelected` now seeds `connectedPlayers` from `hydrationResponse.result!.allCharacters` via this mapper immediately after DM hydration.
  - `ConfigSyncSessionController` gained three optional DM-companion callbacks: `onRemoteCharacterConfig(characterId, config)` (fired on `characterConfigChanged` for any character other than `_characterId` — GETs the character via `getPlayerCharacterById` and forwards the parsed config), `onParticipantOnline(userId)` / `onParticipantOffline(userId)` (fired on presence SSE, scoped to the started campagne). The DM's own `startForCharacter` behavior (own-character catch-up) is untouched.
  - `select_game_mode_screen.dart` wires these into `_onRemoteCharacterConfigForDm` / `_onParticipantPresenceForDm`, which patch the matching `connectedPlayers` entry (by `playerCharacterId` / `userId`) in place — config + `lastPing` refresh on remote edit, `lastPing` set/cleared on presence. Player path (`onCharacterSelected`) is unchanged (`connectedPlayers` stays `null` there, as before).
  - No SignalR resurrected; still pure SSE + REST.
- Commit: see `git log -1`.
- `flutter test test/services/session/ test/services/config_sync/ test/screens/select_game_mode_screen_test.dart test/screens/pageviews/dm_page_screen_test.dart`: 61 passed.
- `flutter test` (full app suite): 1216 passed.

---
