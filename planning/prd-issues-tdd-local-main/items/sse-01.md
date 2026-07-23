## Summary

Authenticated SSE `GET /events` with in-process `ISseEventHub` fan-out; Flutter `EventsClient` + parser with reconnect/JWT refresh; wired on authorized entry and app resume.

## Linked Context

- PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`
- Work item: `sse-01`

## Dependency Graph

### Direct dependencies (blocked by)

- None

### Full chain

`sse-01`

## Status

- Branch: `main`
- Tests: `dotnet test --filter EventsControllerTests` (3 passed); `flutter test test/services/sse/events_client_test.dart` (5 passed)
- Visual snapshots: none
- Commit(s): pending
