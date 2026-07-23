# [slice] sse-08 — Delete SignalR + SSE/REST E2E

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

Hard-cut removal of SignalR: hub, MessagePack hub wiring, Flutter hub client, invoke queue/drain, protocol v1/v2/v3 sync paths, cold/hot wire helpers used only for SignalR. Replace SignalR API tests and `integration_test/signalr_*` with SSE+REST multi-client flows covering session, config patch notify, join, rolls/grants, and notes ACL. Paired API + app; no shim.

## Acceptance criteria

- [ ] No SignalR hub mapped; SignalR packages unused by app/API sync paths
- [ ] Flutter has no hub connection/queue for table sync
- [ ] Former SignalR tests removed or rewritten against SSE/REST
- [ ] E2E (or strong integration) covers: login → events → join → session enter → config PATCH notify → peer catch-up; notes revoke; at least one roll or grant path
- [ ] PROJECT_OVERVIEW / sync docs updated to SSE + REST

## Blocked by

- sse-04
- sse-05
- sse-06
- sse-07

## User stories covered

- 26, 27, 31
