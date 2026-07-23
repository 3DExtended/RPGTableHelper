# [slice] sse-04 — Config-changed SSE + Flutter ConfigSync

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

After successful config PATCH/PUT, emit session-scoped SSE `campagneConfigChanged` / `characterConfigChanged` with `{ id, revision }` only (no body). Recipients are users with active `SessionEnter` for that campagne.

Flutter ConfigSync: debounce local edits → one in-flight PATCH/PUT per entity → coalesce → on 409 GET/rebase/retry → on notify GET `?sinceRevision=` and apply patch or full into Riverpod stores. Remove dependency on hub invoke queue for config sync.

## Acceptance criteria

- [ ] Config write triggers SSE notify without embedding config JSON
- [ ] Only session participants receive config-changed events
- [ ] Flutter applies inbound patch/full correctly; 409 path rebases
- [ ] Debounce + single in-flight write; no hub invoke queue used for config
- [ ] Multi-client API/Flutter test: writer PATCH → peer notified → peer GET catch-up

## Blocked by

- sse-01
- sse-02
- sse-03

## User stories covered

- 14, 30 (wires 11–17 end-to-end at the table)
