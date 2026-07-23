# SSE + REST realtime (replace SignalR) — work items

Parent PRD: [`docs/prd/sse-rest-realtime-replace-signalr.md`](../../docs/prd/sse-rest-realtime-replace-signalr.md)

> Local-only planning (no OpenGitBase repo yet). Forge discussion numbers TBD.

| ID | Title | Type | Status | Blocked by | Forge |
|----|--------|------|--------|------------|-------|
| sse-01 | SSE `/events` hub + Flutter EventsClient | AFK | done | — | local |
| sse-02 | Config revision store + REST PATCH/PUT/GET | AFK | done | — | local |
| sse-03 | SessionEnter + presence SSE + hydration | AFK | done | sse-01 | local |
| sse-04 | Config-changed SSE + Flutter ConfigSync | AFK | done | sse-01, sse-02, sse-03 | local |
| sse-05 | Join-request SSE + Flutter handlers | AFK | done | sse-01 | local |
| sse-06 | Session commands: rolls + grants | AFK | done | sse-01, sse-03, sse-04 | local |
| sse-07 | Notes ACL/content SSE + LoreSync | AFK | done | sse-01 | local |
| sse-08 | Delete SignalR + SSE/REST E2E | AFK | done | sse-04, sse-05, sse-06, sse-07 | local |
