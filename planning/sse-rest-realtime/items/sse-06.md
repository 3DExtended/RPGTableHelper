# [slice] sse-06 — Session commands: rolls + grants

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

Replace SignalR fight/roll relays with REST commands that fan out over SSE with **inline** small payloads (`playersAreAskedForRolls`, `dmReceivedFightSequenceAnswer`). Grant items mutate character config through the revisioned PATCH/PUT path (sse-02/04), then peers learn via `characterConfigChanged` (optional tiny toast event). Session-scoped recipients only. No ping/pong.

## Acceptance criteria

- [ ] Ask-rolls and roll-result REST endpoints emit SSE with fight-sequence payload to session participants
- [ ] Grant-items updates character config via revision store and notifies via config-changed (and optional toast event)
- [ ] Flutter DM/player fight and grant flows use REST + SSE instead of hub invokes
- [ ] Tests cover roll round-trip and grant → character revision bump → peer notify

## Blocked by

- sse-01
- sse-03
- sse-04

## User stories covered

- 18, 19
