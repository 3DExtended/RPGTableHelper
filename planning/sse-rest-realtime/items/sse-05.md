# [slice] sse-05 — Join-request SSE + Flutter handlers

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

Keep join-code + one-time DM approval via existing REST join-request flow. On create, SSE `joinRequestCreated` (small payload) to the DM whenever their `/events` stream is up (membership-scoped, not session-gated). On accept/deny, SSE `joinRequestResolved` to the player. Fix/remove broken SignalR group notify if still present. Flutter shows/handles these events without requiring `SessionEnter`.

## Acceptance criteria

- [ ] Creating a join request notifies the DM over SSE with request identity + player display info
- [ ] Accept/deny notifies the player over SSE; accept still links character to campagne via REST
- [ ] Events deliver without SessionEnter
- [ ] Flutter DM and player UIs react to the events (list/snackbar/navigation as appropriate)
- [ ] Tests cover create → DM event and handle → player event

## Blocked by

- sse-01

## User stories covered

- 4, 5, 6, 29
