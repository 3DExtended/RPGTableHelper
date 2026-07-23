# [slice] sse-04 — handoff

## Branch
`main`

## PRD
`docs/prd/sse-rest-realtime-replace-signalr.md`

## Work item
`planning/sse-rest-realtime/items/sse-04.md`

## Acceptance criteria
- Config write triggers SSE notify without embedding config JSON
- Only session participants receive config-changed events
- Flutter applies inbound patch/full correctly; 409 path rebases
- Debounce + single in-flight write; no hub invoke queue used for config
- Multi-client API/Flutter test: writer PATCH → peer notified → peer GET catch-up

## What's live now

- `ISessionPresenceService.GetOnlineParticipants(campagneId)` — returns the online user ids for a campagne's table session.
- `CampagneController`/`PlayerCharacterController` PATCH and PUT config endpoints now emit `campagneConfigChanged`/`characterConfigChanged` SSE (`{ id, revision }`, no body) to every other online session participant right after a successful write; no-op if nobody else is online (or, for characters, if the character has no campagne).
- Flutter `ConfigSyncCoordinator` (`lib/services/config_sync/config_sync_coordinator.dart`) — per-entity debounce (500 ms) + coalesce + single-in-flight PUT, 409 → GET/rebase/retry (up to 5 attempts per flush), and `onRemoteChanged(revision)` → catch-up `GET ?sinceRevision=` applying patch or full doc.
- Flutter `ConfigSyncSessionController` (`lib/services/config_sync/config_sync_session_controller.dart`) — owns a campagne + character coordinator pair, wires them to `IRpgEntityService` and the shared `EventsClient`, and routes inbound `*ConfigChanged` SSE events by `id` to the right coordinator; patch application decodes the caller's current doc (via a Riverpod read callback), applies the JSON Patch, and pushes the result back in via the matching apply callback.
- `select_game_mode_screen.dart` starts a `ConfigSyncSessionController` right after REST hydration (both DM and player paths), seeding the coordinator(s) with the current revision fetched via the new `getCampagneRpgConfigSnapshot`/`getCharacterRpgConfigSnapshot` calls, and stops it in the existing "returned from game screen" callback alongside `stopConnection()`/`leave(...)`.

## Explicitly NOT done in this slice (by design)

- The editor UI (wizards, campagne/character edit screens) still writes config through the SignalR hub invoke queue — `ConfigSyncCoordinator.notifyLocalEdit` is not yet called from any UI edit flow, only the SSE-notify → catch-up (read) path is live end-to-end. Per the task instructions, the write-path switch is deferred to `sse-08` (SignalR removal); this slice makes the new path available and functioning, ready to become primary.
- SignalR itself is untouched.
- No join-request SSE (`sse-05`) or session-command (`sse-06`) work.

## Key files for the next engineer

- `applications/RPGTableHelper.WebApi/Services/Presence/{ISessionPresenceService,SessionPresenceService}.cs` (`GetOnlineParticipants`)
- `applications/RPGTableHelper.WebApi/Controllers/RpgControllers/{Campagne,PlayerCharacter}Controller.cs` (`Notify*ConfigChangedAsync` helpers)
- Tests: `tests/RPGTableHelper.Api.Tests/Services/Presence/SessionPresenceServiceTests.cs`, `tests/RPGTableHelper.Api.Tests/Controllers/RpgControllers/ConfigChangedSseNotificationControllerTests.cs`
- Flutter: `applications/rpg_table_helper/lib/services/config_sync/{config_sync_models,config_sync_coordinator,config_sync_session_controller}.dart`, `applications/rpg_table_helper/lib/services/rpg_entity_service.dart` (`save*RpgConfig`/`get*RpgConfigSnapshot`), `applications/rpg_table_helper/lib/screens/select_game_mode_screen.dart`
- Flutter tests: `applications/rpg_table_helper/test/services/config_sync/{config_sync_coordinator_test,config_sync_session_controller_test}.dart`

## Dependencies
Blocked by `sse-01` (SSE hub), `sse-02` (config revision REST), `sse-03` (`SessionEnter`/presence) — all complete.

## Full chain
`sse-01` → `sse-03` → `sse-04` → feeds into `sse-06` (session commands, blocked by `sse-01, sse-03, sse-04`) and `sse-08` (SignalR removal, blocked by `sse-04..07`).
