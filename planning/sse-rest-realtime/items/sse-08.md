# [slice] sse-08 — Delete SignalR + SSE/REST E2E

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: done

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

Hard-cut removal of SignalR: hub, MessagePack hub wiring, Flutter hub client, invoke queue/drain, protocol v1/v2/v3 sync paths, cold/hot wire helpers used only for SignalR. Replace SignalR API tests and `integration_test/signalr_*` with SSE+REST multi-client flows covering session, config patch notify, join, rolls/grants, and notes ACL. Paired API + app; no shim.

## Acceptance criteria

- [x] No SignalR hub mapped; SignalR packages unused by app/API sync paths
- [x] Flutter has no hub connection/queue for table sync
- [x] Former SignalR tests removed or rewritten against SSE/REST
- [x] E2E (or strong integration) covers: login → events → join → session enter → config PATCH notify → peer catch-up; notes revoke; at least one roll or grant path
- [x] PROJECT_OVERVIEW / sync docs updated to SSE + REST

## Implementation notes

- **Backend deletions**: `RpgServerSignalRHub`, `RpgConfigSliceV3EnvelopeBuilder`,
  `RpgConfigSliceV3UpstreamEnvelope`, `AddSignalR().AddMessagePackProtocol()`
  + `MapHub<>` wiring in `Startup`, and the `MessagePack` package reference.
  `RpgConfigColdHotSlicer` was kept — it is used by the REST config store, not
  only by SignalR.
- **Flutter deletions**: `server_communication_service.dart` (hub client),
  `hub_invoke_queue.dart`, `hub_invoke_retry.dart`,
  `rpg_config_upstream_envelope.dart`, the `signalr_netcore` dependency, and all
  `integration_test/signalr_*` + hub-only unit tests.
- **Rewire**: `ServerMethodsService` no longer depends on the hub client; durable
  config writes route through the active `ConfigSyncSessionController`
  (debounced REST PATCH/PUT + 409 rebase) and fall back to a direct REST PUT
  when no session controller is active. The DM/player storage observers call the
  same `sendUpdatedRpgConfig` / `sendUpdatedRpgCharacterConfig` path. Presence
  and inbound edits are SSE-driven; the `main.dart` ping/pong + hub-drain timers
  were removed in favor of `EventsClient.ensureConnected()`.
- **Coverage**: SSE/REST flows are covered by API integration tests
  (`ConfigChangedSseNotificationControllerTests`,
  `SessionCommandSseNotificationControllerTests`,
  `CampagneJoinRequestSseNotificationControllerTests`,
  `NotesSseNotificationControllerTests`) plus Flutter unit/widget tests
  (`config_sync_*`, `session_entry_coordinator`, `events_client`,
  `server_methods_service_config_write_test`,
  `server_methods_service_session_commands_test`).
- **Known gap**: real-time DM viewing of a *player's* character edits (previously
  the `updateRpgCharacterConfigOnDmSide` hub relay) is not yet wired to an SSE
  listener on the DM side. Player edits still persist via ConfigSync REST; only
  the DM's live view of them is deferred to a follow-up.

## Blocked by

- sse-04
- sse-05
- sse-06
- sse-07

## User stories covered

- 26, 27, 31
