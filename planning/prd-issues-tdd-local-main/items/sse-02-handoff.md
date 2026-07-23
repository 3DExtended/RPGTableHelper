# [slice] sse-02 — handoff

## Branch
`main`

## PRD
`docs/prd/sse-rest-realtime-replace-signalr.md`

## Work item
`planning/sse-rest-realtime/items/sse-02.md`

## Acceptance criteria
- Migration lands single revision + history for campagne and character; existing data remains loadable
- PATCH applies when `fromRevision` matches; bumps revision; stores history snapshot; writes file backup
- PATCH/PUT with stale `fromRevision` returns 409
- GET without sinceRevision (or unsatisfiable since) returns full; GET with recent since returns patch when computable
- History older than window forces full on GET
- API tests cover patch success, 409, full failsafe, history window, backups outside E2E skip rules

## What's live now

- `PATCH /Campagne/patchcampagneconfig/{campagneid}` and `PATCH /PlayerCharacter/patchcharacterconfig/{playercharacterid}` — JSON Patch (RFC 6902) body + `FromRevision`; 409 on stale revision; 400 on invalid patch.
- `GET /Campagne/getcampagneconfig/{campagneid}?sinceRevision=N` and `GET /PlayerCharacter/getplayercharacterconfig/{playercharacterid}?sinceRevision=N` — returns `{ kind: "patch", revision, fromRevision, patch }` when a history snapshot for `sinceRevision` exists, else `{ kind: "full", revision, fullConfig }`.
- Existing `PUT .../updatecampagneconfig/{id}` and `PUT .../updateplayercharacterconfig/{id}` now accept an optional `FromRevision` and return 409 if provided and stale (opt-in — omit the field to keep old unconditional-overwrite behavior).
- Every successful PATCH/PUT records a history snapshot (trimmed to the last 10 per parent) and writes a file backup under `configbackups/` (skipped when `IHostEnvironment.EnvironmentName` is an E2E host, matching the existing hub pattern).
- Cold/hot config columns and the SignalR sync hub are untouched and still function — this slice adds the new REST wire alongside them, it does not replace or remove anything yet.

## Explicitly NOT done in this slice (by design)

- No SSE "config changed" notification on write (that's sse-04).
- SignalR hub/cold-hot sync model has not been removed (that's sse-08).
- Flutter client has not been updated to call the new endpoints — this slice is server/API only, proven via `dotnet test` API tests.

## Key files for the next engineer

- `applications/RPGTableHelper.WebApi/Services/ConfigRevisions/` — `ConfigDocumentPatcher`, `IConfigRevisionHistoryStore`/`ConfigRevisionHistoryStore`, `ConfigFileBackupWriter`.
- `applications/RPGTableHelper.WebApi/Controllers/RpgControllers/CampagneController.cs` and `PlayerCharacterController.cs` — PATCH/PUT/GET endpoints.
- `applications/RPGTableHelper.WebApi/Dtos/RpgEntities/Config{PatchRequest,WriteResult,SnapshotResponse}Dto.cs`.
- `libraries/RPGTableHelper.DataLayer/Entities/RpgEntities/{Campagne,PlayerCharacter}RpgConfigHistoryEntity.cs` + migration `20260723081418_AddConfigRevisionHistoryTables`.
- Tests: `tests/RPGTableHelper.Api.Tests/Controllers/RpgControllers/{Campagne,PlayerCharacter}ConfigRevisionControllerTests.cs`, `tests/RPGTableHelper.Api.Tests/Services/ConfigRevisions/*`, `tests/RPGTableHelper.DataLayer.Tests/Migrations/ConfigRevisionHistoryMigrationTests.cs`.

## Dependencies
None (sse-02 was unblocked from the start)

## Full chain
`sse-02` — feeds into `sse-04` (config-changed SSE + Flutter ConfigSync), which is blocked by `sse-01, sse-02, sse-03`.
