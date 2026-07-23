# Execution plan — SSE + REST realtime

**PRD:** `docs/prd/sse-rest-realtime-replace-signalr.md`  
**Items:** `planning/sse-rest-realtime/`  
**Branch strategy:** **main** (all work items committed sequentially on default branch).

## Ordered work items

| Order | ID | Title | Blocked by | Status |
|------:|----|--------|------------|--------|
| 1 | sse-01 | SSE `/events` hub + Flutter EventsClient | — | pending |
| 2 | sse-02 | Config revision store + REST PATCH/PUT/GET | — | done |
| 3 | sse-03 | SessionEnter + presence SSE + hydration | sse-01 | pending |
| 4 | sse-04 | Config-changed SSE + Flutter ConfigSync | sse-01,02,03 | pending |
| 5 | sse-05 | Join-request SSE + Flutter handlers | sse-01 | pending |
| 6 | sse-06 | Session commands: rolls + grants | sse-01,03,04 | pending |
| 7 | sse-07 | Notes ACL/content SSE + LoreSync | sse-01 | pending |
| 8 | sse-08 | Delete SignalR + SSE/REST E2E | sse-04..07 | pending |

## Dependency graph

```
sse-01 ──┬──► sse-03 ──► sse-04 ──► sse-06 ──┐
         │              ▲                    │
         │              │                    ▼
         ├──► sse-05    sse-02              sse-08
         │                                   ▲
         └──► sse-07 ────────────────────────┘
```

## Verification notes (this repo)

- Backend: `dotnet test` (API / DataLayer / BusinessLayer as touched)
- Compose: `docker compose` for RPGTableHelper API (not OpenGitBase scripts)
- Flutter: `flutter test` for EventsClient / sync; integration tests where applicable
- Playwright visual gallery: N/A (Flutter app, not opengitbase-web)
