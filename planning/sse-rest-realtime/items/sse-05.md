# [slice] sse-05 — Join-request SSE + Flutter handlers

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: done

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

Keep join-code + one-time DM approval via existing REST join-request flow. On create, SSE `joinRequestCreated` (small payload) to the DM whenever their `/events` stream is up (membership-scoped, not session-gated). On accept/deny, SSE `joinRequestResolved` to the player. Fix/remove broken SignalR group notify if still present. Flutter shows/handles these events without requiring `SessionEnter`.

## Acceptance criteria

- [x] Creating a join request notifies the DM over SSE with request identity + player display info
- [x] Accept/deny notifies the player over SSE; accept still links character to campagne via REST
- [x] Events deliver without SessionEnter
- [x] Flutter DM and player UIs react to the events (list/snackbar/navigation as appropriate)
- [x] Tests cover create → DM event and handle → player event

## Blocked by

- sse-01

## User stories covered

- 4, 5, 6, 29

## Implementation notes

- `CampagneJoinRequestController` (`applications/RPGTableHelper.WebApi/Controllers/RpgControllers/CampagneJoinRequestController.cs`)
  no longer depends on `IHubContext<RpgServerSignalRHub>`. The two broken SignalR group notifies (create used a
  bogus `{requestId}_Dm` group nobody ever joined; handle broadcast to `Clients.All`) are removed and replaced
  with `ISseEventHub.SendToUserAsync` calls straight to the DM (`campagne.DmUserId`) on create and to the
  requesting player (`joinRequest.UserId`) on accept/deny.
- Payloads carry only identity + display info, no config bodies: `joinRequestCreated` -
  `{ requestId, campagneId, playerCharacterId, playerName, username }`; `joinRequestResolved` -
  `{ requestId, campagneId, type }` (`type` is `"Accept"` or `"Deny"`).
- Membership-scoped, not session-gated: recipients are resolved directly from the campagne/join-request rows
  (DM id, requester's user id), independent of `ISessionPresenceService`/`SessionEnter`. `ISseEventHub` already
  no-ops for users without an open `/events` connection, so no extra presence check is needed.
- API coverage: `tests/RPGTableHelper.Api.Tests/Controllers/RpgControllers/CampagneJoinRequestSseNotificationControllerTests.cs`
  drives create → DM event and handle (accept + deny) → player event end-to-end over real `/events` HTTP
  streams, with neither side calling `SessionEnter`.
- Flutter: new `JoinRequestNotificationController`
  (`applications/rpg_table_helper/lib/services/join_requests/join_request_notification_controller.dart`) wraps
  the shared `EventsClient` stream and exposes typed `JoinRequestCreatedEvent` / `JoinRequestResolvedEvent`
  callbacks, mirroring the `ConfigSyncSessionController` pattern from sse-04 but intentionally not session-scoped.
  It is started from `SelectGameModeScreen` (the app-shell landing screen after login, whose `State` stays alive
  underneath the DM/player table screens pushed on top of it), so requests are seen both before and during a
  table session. On `joinRequestCreated` the DM sees a snackbar and, if currently managing the matching campagne,
  the request is appended to `connectionDetailsProvider`'s `openPlayerRequests` list. On `joinRequestResolved`
  the player sees a snackbar and, if accepted, the character/campagne list is reloaded so they can enter.
  Unit tests: `test/services/join_requests/join_request_notification_controller_test.dart`.
