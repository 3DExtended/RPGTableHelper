# [slice] sse-03 — SessionEnter + presence SSE + hydration

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

Separate **session presence** from membership. Already-accepted DM/player calls REST `SessionEnter` (campagne and/or character id). Server marks them online for that campagne, emits small SSE `participantOnline` / `participantOffline` to other session participants. Presence tracks SSE liveness with a short grace period on disconnect/reconnect (no ping/pong).

On enter, client **pulls** hydration over REST: DM gets campagne config + all characters in campagne; player gets campagne config + own character. No “request status from players” push.

## Acceptance criteria

- [ ] `SessionEnter` / leave (or implicit leave on SSE drop after grace) updates online set
- [ ] Online/offline SSE delivered only to users currently in that campagne session
- [ ] Brief reconnect within grace does not flicker offline
- [ ] Flutter session start performs REST hydration as specified (DM vs player)
- [ ] No ping/pong protocol remains required for presence in this path
- [ ] API + Flutter tests for enter, grace reconnect, and hydration calls

## Blocked by

- sse-01

## User stories covered

- 7, 8, 9, 10, 20, 28
