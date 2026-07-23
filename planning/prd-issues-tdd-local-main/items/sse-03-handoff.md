# [slice] sse-03 — handoff

## Branch
`main`

## PRD
`docs/prd/sse-rest-realtime-replace-signalr.md`

## Work item
`planning/sse-rest-realtime/items/sse-03.md`

## Acceptance criteria
- `SessionEnter`/leave (or implicit leave on SSE drop after grace) updates online set
- Online/offline SSE delivered only to users currently in that campagne session
- Brief reconnect within grace does not flicker offline
- Flutter session start performs REST hydration as specified (DM vs player)
- No ping/pong protocol remains required for presence in this path
- API + Flutter tests for enter, grace reconnect, and hydration calls

## What's live now

- `POST /Session/enter/{campagneid}` — 401 unless the caller is the campagne's DM or an already-accepted player (checked via `CampagneIsUserInCampagneQuery`); marks the caller online for that campagne's session and broadcasts `participantOnline` (payload includes `userId` + `campagneId`) to the other participants currently online for that campagne via SSE.
- `POST /Session/leave/{campagneid}` — marks the caller offline and broadcasts `participantOffline` to the remaining online participants.
- `GET /events` (unchanged endpoint) now also feeds `ISessionPresenceService.OnSseConnectedAsync`/`OnSseDisconnectedAsync`. Losing the last SSE connection for a user starts a grace-period timer (20s in normal hosts, 150ms when `IHostEnvironment.EnvironmentName` is `E2ETest`); if the user reconnects before the timer fires, no offline transition/broadcast happens. If the timer fires with no reconnect, the user is marked offline and `participantOffline` is broadcast — this is the "implicit leave on SSE drop" path from the acceptance criteria, layered on top of the explicit `leave` call.
- Flutter: `IRpgEntityService.enterSession`/`leaveSession` (raw REST, JWT bearer) and `getPlayerCharacterById` (Chopper). `SessionEntryCoordinator.enterAsDm`/`enterAsPlayer` call `enterSession` then hydrate over REST (DM: `getCampagneById` + `getPlayerCharactersForCampagne`; player: `getCampagneById` + `getPlayerCharacterById`); `select_game_mode_screen.dart` calls this before starting the SignalR connection/navigating, and calls `.leave(...)` from the "returned from game screen" callback.

## Explicitly NOT done in this slice (by design)

- SignalR is untouched and still runs alongside this — `RegisterGame`/`JoinGame` still happen right after the new REST enter+hydrate step. Removing SignalR is `sse-08`.
- No config-changed SSE (`sse-04`) and no join-request SSE (`sse-05`) — presence is the only SSE surface added here.
- No ping/pong protocol was added or is required; liveness is derived purely from the SSE connection's open/close lifecycle plus the grace-period timer.
- The DM's "all characters" hydration result is fetched but not yet threaded into a shared provider/cache — `DmScreenCampagneManagement` still does its own lazy `getPlayerCharactersForCampagne` fetch when that tab is opened. Wiring the hydrated list through to avoid the duplicate fetch is a possible follow-up, not required by the acceptance criteria.

## Key files for the next engineer

- `applications/RPGTableHelper.WebApi/Services/Presence/{ISessionPresenceService,SessionPresenceService}.cs`
- `applications/RPGTableHelper.WebApi/Controllers/RpgControllers/SessionController.cs`
- `applications/RPGTableHelper.WebApi/Controllers/EventsController.cs` (presence hook-in) and `Services/Sse/{ISseEventHub,SseEventHub}.cs` (`HasConnection`)
- `applications/RPGTableHelper.WebApi/Startup.cs` (DI registration + grace period)
- Tests: `tests/RPGTableHelper.Api.Tests/Services/Presence/SessionPresenceServiceTests.cs`, `tests/RPGTableHelper.Api.Tests/Controllers/RpgControllers/SessionControllerTests.cs`
- Flutter: `applications/rpg_table_helper/lib/services/session/session_entry_coordinator.dart`, `applications/rpg_table_helper/lib/services/rpg_entity_service.dart` (`enterSession`/`leaveSession`/`getPlayerCharacterById`), `applications/rpg_table_helper/lib/screens/select_game_mode_screen.dart`
- Flutter tests: `applications/rpg_table_helper/test/services/session/session_entry_coordinator_test.dart`

## Dependencies
Blocked by `sse-01` (SSE hub + `GET /events` + Flutter `EventsClient`) — already complete.

## Full chain
`sse-01` → `sse-03` — feeds into `sse-04` (config-changed SSE, blocked by `sse-01, sse-02, sse-03`) and `sse-06` (session commands, blocked by `sse-01, sse-03, sse-04`).
