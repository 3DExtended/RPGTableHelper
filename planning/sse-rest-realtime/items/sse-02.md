# [slice] sse-02 — Config revision store + REST PATCH/PUT/GET

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

Single-document config storage for campagne and character: one JSON body + one monotonic `Revision`, plus a history table of the last ~10 full snapshots. Migrate away from cold/hot wire/storage as the sync model. REST:

- `PATCH` with JSON Patch + `fromRevision` (409 on mismatch)
- `PUT` full document + optional `fromRevision` (failsafe)
- `GET ?sinceRevision=N` → `{ kind: "patch" | "full", revision, ... }`

On every successful persist, write the existing filesystem backup under `configbackups/`. No SSE required in this slice (curl/API tests prove behavior).

## Acceptance criteria

- [ ] Migration lands single revision + history for campagne and character; existing data remains loadable
- [ ] PATCH applies when `fromRevision` matches; bumps revision; stores history snapshot; writes file backup
- [ ] PATCH/PUT with stale `fromRevision` returns 409
- [ ] GET without sinceRevision (or unsatisfiable since) returns full; GET with recent since returns patch when computable
- [ ] History older than window forces full on GET
- [ ] API tests cover patch success, 409, full failsafe, history window, backups outside E2E skip rules

## Blocked by

None — can start immediately

## User stories covered

- 11, 12, 13, 15, 16, 17, 25
