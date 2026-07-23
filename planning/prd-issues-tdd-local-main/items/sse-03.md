## Summary

Table session presence, separate from campagne membership: already-accepted DM/players call REST `SessionEnter`/`leave` (`POST /Session/enter/{campagneid}`, `POST /Session/leave/{campagneid}`), the server tracks an in-process online set per campagne and broadcasts small `participantOnline`/`participantOffline` SSE events to the *other* participants currently in that campagne's session. Presence combines the explicit enter/leave call with SSE liveness (`GET /events` connect/disconnect), using a short grace period on disconnect so a brief reconnect (app backgrounding, network blip) does not flicker a participant offline. No ping/pong protocol is needed. On the Flutter side, session start now performs REST hydration right after `SessionEnter`: DM pulls campagne config + all characters in the campagne, player pulls campagne config + their own character.

## Linked Context

- PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`
- Work item: `sse-03` (`planning/sse-rest-realtime/items/sse-03.md`)

## What was built

### Backend

- `ISessionPresenceService` / `SessionPresenceService` (`applications/RPGTableHelper.WebApi/Services/Presence/`) — in-memory online set keyed by campagne id; `EnterAsync`/`LeaveAsync` broadcast `participantOnline`/`participantOffline` via `ISseEventHub.SendToUsersAsync` to the other online participants only; `OnSseConnectedAsync`/`OnSseDisconnectedAsync` track SSE liveness with a constructor-injected grace period (`Timer`-based, cancels pending offline transition on reconnect).
- `ISseEventHub.HasConnection(Guid userId)` — new query used to decide whether a disconnect is a "last connection dropped" event.
- `SessionController` (`applications/RPGTableHelper.WebApi/Controllers/RpgControllers/SessionController.cs`) — `POST enter/{campagneid}` (401 unless the caller is the campagne's DM or an accepted player, via `CampagneIsUserInCampagneQuery`) and `POST leave/{campagneid}`.
- `EventsController` — now calls `OnSseConnectedAsync` right after SSE registration and `OnSseDisconnectedAsync` once the connection is disposed and no other connection remains for that user (`finally` block around the existing keep-alive loop).
- `Startup.cs` — registers `ISessionPresenceService` as a singleton; grace period is `150ms` when `IHostEnvironment.IsEnvironment("E2ETest")`, else `20s`.

### Flutter

- `IRpgEntityService` / `RpgEntityService` — new `enterSession`/`leaveSession` (raw `http.post` to `Session/enter|leave/{id}`, same JWT + REST pattern as the existing `updateCampagneRpgConfiguration` REST fallback) and `getPlayerCharacterById` (thin Chopper wrapper around the existing `playerCharacterGetplayercharacterPlayercharacteridGet`, no swagger regen needed).
- `SessionEntryCoordinator` (`lib/services/session/session_entry_coordinator.dart`) — `enterAsDm`/`enterAsPlayer` call `enterSession` then hydrate (DM: campagne + all characters via `getPlayerCharactersForCampagne`; player: campagne + own character via `getPlayerCharacterById`), short-circuiting with the propagated error if `enterSession` itself fails; `leave` calls `leaveSession`.
- `select_game_mode_screen.dart` — `onCampagneSelected`/`onCharacterSelected` now enter the session and hydrate via the coordinator before starting the SignalR connection and navigating; `leave` is called from the pop callback alongside the existing `stopConnection()`.

## Behavior implemented (maps to acceptance criteria)

- [x] `SessionEnter`/`leave` updates the online set (`SessionController` → `SessionPresenceService`).
- [x] Online/offline SSE delivered only to users currently in that campagne's session (`SendToUsersAsync` targets the remaining/other online participant ids, not a broadcast).
- [x] Brief reconnect within grace does not flicker offline (`SessionPresenceServiceTests` — reconnect within grace vs. no-reconnect-past-grace).
- [x] Flutter session start performs REST hydration as specified (DM vs player) via `SessionEntryCoordinator`.
- [x] No ping/pong protocol required for presence in this path (grace period is purely `OnSseConnectedAsync`/`OnSseDisconnectedAsync` + a timer).
- [x] API + Flutter tests cover enter, grace reconnect, and hydration calls.

## Dependency Graph

### Direct dependencies (blocked by)

- `sse-01` (SSE hub — `ISseEventHub`, `GET /events`, Flutter `EventsClient`)

### Full chain

`sse-01` → `sse-03`

## Status

- Branch: `main`
- Tests:
  - `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~SessionController|FullyQualifiedName~SessionPresenceService|FullyQualifiedName~EventsController"` → 11 passed
  - `dotnet test tests/RPGTableHelper.Api.Tests` (full project) → 158 passed / 1 skipped (pre-existing, unrelated)
  - `dotnet test tests/RPGTableHelper.DataLayer.Tests` → 74 passed
  - `flutter test test/services/session/session_entry_coordinator_test.dart` → 5 passed
  - `flutter test` (full app suite) → 1202 passed
- Visual snapshots: none required (no UI layout change, existing `select_game_mode_screen` golden test still passes unchanged)
- Commit(s): `983ae376` (backend presence), `acc0dfe4` (Flutter SessionEnter/leave + hydration)
