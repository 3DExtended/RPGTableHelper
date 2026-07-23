## Summary

After a successful campagne or player-character config PATCH/PUT, the writer's connected session participants (via `ISessionPresenceService`) receive a session-scoped SSE `campagneConfigChanged`/`characterConfigChanged` notify carrying only `{ id, revision }` — never the config body. On Flutter, `ConfigSyncCoordinator` gives each entity debounced/coalesced local edits with a single in-flight PUT, 409-triggered GET/rebase/retry, and `ConfigSyncSessionController` wires two coordinators (campagne + character) to `IRpgEntityService` and the shared `EventsClient`, applying inbound SSE notifies via a `GET ?sinceRevision=` catch-up (patch or full document) into the Riverpod config stores. `select_game_mode_screen.dart` starts/stops these coordinators around table session entry/leave so both DM and player clients catch up on config edits made by other participants in near-real time, while the existing SignalR hub invoke queue remains the write path used by the editor UI until `sse-08`.

## Linked Context

- PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`
- Work item: `sse-04` (`planning/sse-rest-realtime/items/sse-04.md`)

## What was built

### Backend

- `ISessionPresenceService.GetOnlineParticipants(Guid campagneId)` — new query returning the user ids currently marked online for a campagne's table session (used to scope config-changed notifies); implemented in `SessionPresenceService` from the existing in-memory per-campagne participant map.
- `CampagneController` — injects `ISseEventHub`/`ISessionPresenceService`; after a successful `UpdateCampagneRpgConfigAsync` (PUT) or `PatchCampagneRpgConfigAsync` (PATCH), calls a new `NotifyCampagneConfigChangedAsync(campagneId, revision, ct)` helper that sends `campagneConfigChanged` with `{ id, revision }` (via `JsonSerializer.Serialize`, no config body) to every online session participant except the writer themself; no-ops if there are no other online participants.
- `PlayerCharacterController` — same shape: injects `ISseEventHub`/`ISessionPresenceService`, calls `NotifyCharacterConfigChangedAsync(playerCharacterId, campagneId, revision, ct)` after a successful character config PUT/PATCH, sending `characterConfigChanged` to the owning campagne's other online session participants; no-ops if the character has no campagne assigned or nobody else is online.

### Flutter

- `services/config_sync/config_sync_models.dart` — `ConfigWriteResult` (`{ revision }`) and `ConfigSnapshot` (`{ kind, revision, fromRevision?, fullConfig?, patch? }`) mirroring the API's `sse-02` DTOs, with `isFull`/`isPatch` helpers.
- `services/config_sync/config_sync_coordinator.dart` — `ConfigSyncCoordinator`: framework-agnostic (`write`/`read`/`applyFull`/`applyPatch` callbacks, no `IRpgEntityService`/Riverpod dependency) driver for a single entity's config sync: `notifyLocalEdit` debounces (default 500 ms) and coalesces to the latest desired document; `_flush` guarantees a single in-flight write, retries up to `maxConflictRetriesPerFlush` times on `409` by re-fetching/rebasing via `_catchUp` before resubmitting the same desired edit; `onRemoteChanged(remoteRevision)` triggers a catch-up GET (skipped if a write is in flight or the revision is already known); `hydrate()`/`seed()` establish the baseline revision; `flushNow()`/`dispose()` support tests and teardown.
- `services/config_sync/config_sync_session_controller.dart` — `ConfigSyncSessionController`: owns one `ConfigSyncCoordinator` per entity kind (campagne, character), wires `write`/`read` to `IRpgEntityService.save*RpgConfig`/`get*RpgConfigSnapshot`, and `applyFull`/`applyPatch` to caller-supplied Riverpod callbacks (`applyCampagneConfig`/`readCampagneConfig`, `applyCharacterConfig`/`readCharacterConfig`); subscribes once to the shared `EventsClient.events` stream and routes `campagneConfigChanged`/`characterConfigChanged` notifies (matched by `id`) to `onRemoteChanged` on the corresponding coordinator; patch application reads the current doc from the Riverpod callback, applies the RFC 6902 patch via `JsonPatch.apply`, and re-decodes into the typed model.
- `services/rpg_entity_service.dart` — new `IRpgEntityService` methods `saveCampagneRpgConfig`/`getCampagneRpgConfigSnapshot`/`saveCharacterRpgConfig`/`getCharacterRpgConfigSnapshot`, implemented with raw `http.put`/`http.get` + JWT bearer (same pattern as the existing `sse-02`/`sse-03` REST fallbacks, since the revision fields aren't exposed on the generated Swagger models); `MockRpgEntityService` gets matching override-based fakes for tests.
- `screens/select_game_mode_screen.dart` — `onCampagneSelected` (DM) and `onCharacterSelected` (player) build a `ConfigSyncSessionController` after REST hydration, fetch the current revision via `getCampagneRpgConfigSnapshot`/`getCharacterRpgConfigSnapshot`, and `startForCampagne`/`startForCharacter`; the session-leave callback (already present from `sse-03`) now also calls `configSyncSessionController.stop()` alongside `serverCommunicationService.stopConnection()` and `sessionEntryCoordinator.leave(...)`.

## Behavior implemented (maps to acceptance criteria)

- [x] Config write triggers SSE notify without embedding config JSON (`{ id, revision }` only — verified by `dataLine.Should().NotContain("rpgName")` in the new controller tests).
- [x] Only session participants receive config-changed events (`GetOnlineParticipants` scoping, writer excluded).
- [x] Flutter applies inbound patch/full correctly; 409 path rebases (`ConfigSyncCoordinator` unit tests cover both `onRemoteChanged` branches and the 409 retry/rebase loop).
- [x] Debounce + single in-flight write (`notifyLocalEdit`/`_flush` tests); hub invoke queue is intentionally left as the UI's write path for now — see "explicitly not done" below.
- [x] Multi-client API test: writer PATCH → peer notified → peer GET catch-up (`ConfigChangedSseNotificationControllerTests`, 5 tests covering campagne PATCH/PUT and character PATCH/PUT plus the "no other participants → no notify" case).

## Explicitly NOT done in this slice (by design)

- The SignalR hub invoke queue is still what the editor UI (wizards, character/campagne edit screens) calls to persist edits — `ConfigSyncCoordinator.notifyLocalEdit`/write path isn't yet called from any UI edit flow. Only the *read* side (SSE notify → `GET ?sinceRevision=` catch-up → Riverpod) is wired end-to-end from app start. Switching the UI's write path to `ConfigSyncCoordinator` is left for `sse-08` (SignalR removal), per the task's explicit instruction to leave the hub path in place until then.
- SignalR itself is untouched.
- No changes to join-request SSE (`sse-05`) or session commands (`sse-06`).

## Dependency Graph

### Direct dependencies (blocked by)

- `sse-01` (SSE hub — `ISseEventHub`, `GET /events`, Flutter `EventsClient`)
- `sse-02` (Config revision store + REST PATCH/PUT/GET)
- `sse-03` (`SessionEnter`/leave + `ISessionPresenceService` + REST hydration)

### Full chain

`sse-01` → `sse-03` → `sse-04` → feeds into `sse-06` (session commands) and `sse-08` (SignalR removal)

## Status

- Branch: `main`
- Tests:
  - `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~SessionPresenceServiceTests|FullyQualifiedName~ConfigChangedSseNotificationControllerTests"` → 11 passed
  - `dotnet test RPGTableHelper.sln` (full solution) → Api.Tests 165 passed / 1 skipped (pre-existing, unrelated), DataLayer.Tests 74 passed, BusinessLayer.Tests 9 passed, Shared.Tests 66 passed, Prodot.* 78 passed
  - `flutter test test/services/config_sync/` → 14 passed (`ConfigSyncCoordinator` + `ConfigSyncSessionController`)
  - `flutter test` (full app suite) → 1216 passed
- Visual snapshots: none required (no UI layout change)
- Commit(s): see handoff doc
