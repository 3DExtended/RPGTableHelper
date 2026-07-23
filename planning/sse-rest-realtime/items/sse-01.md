# [slice] sse-01 — SSE `/events` hub + Flutter EventsClient

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

Authenticated long-lived SSE endpoint (`GET /events`) that registers the user connection in an in-process hub. Flutter opens the stream with Bearer JWT, parses typed events (even if only a keepalive/hello initially), reconnects with backoff on drop, and refreshes the token on 401 before reconnecting. App resume re-establishes the stream.

Demoable: logged-in client stays connected and receives a server-sent hello/ping event; reconnect after kill recovers.

## Acceptance criteria

- [ ] Authenticated `GET /events` streams SSE to the caller; unauthenticated requests are rejected
- [ ] Server can push an event to a specific user id over their open stream(s)
- [ ] Flutter EventsClient connects after login, handles disconnect, refreshes JWT on auth failure, reconnects with backoff
- [ ] App resume path reopens the stream when the app was backgrounded
- [ ] API + Flutter unit/integration tests cover connect and reconnect happy path

## Blocked by

None — can start immediately

## User stories covered

- 1, 2, 3
