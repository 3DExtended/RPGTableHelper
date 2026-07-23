## Summary

Single-document config storage (one JSON body + one monotonic `Revision`) for `Campagne` and `PlayerCharacter`, backed by a ~10-snapshot history table. New REST surface: `PATCH` (JSON Patch + `fromRevision`, 409 on stale), `PUT` (full doc + optional `fromRevision` failsafe), `GET ?sinceRevision=N` (returns `patch` when a history snapshot covers the gap, else `full`). File backups under `configbackups/` on every successful persist, skipped in E2E hosts via the existing pattern from `RpgServerSignalRHub`. Cold/hot columns and the SignalR sync path are left in place (removal is sse-08); this slice only adds the new revisioned REST wire and storage.

## Linked Context

- PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`
- Work item: `sse-02` (`planning/sse-rest-realtime/items/sse-02.md`)

## What was built

### Data layer

- `CampagneRpgConfigHistoryEntity` / `PlayerCharacterRpgConfigHistoryEntity` — history snapshots (`{ParentId}`, `Revision`, `ConfigJson`, `CreatedAt`), unique index on `(ParentId, Revision)`, cascade delete from parent.
- `RpgDbContext` — new `DbSet`s + model configuration for both history tables.
- Migration `20260723081418_AddConfigRevisionHistoryTables` — additive only; no changes to existing columns, so pre-migration campagne/character data stays loadable as-is. Verified with a dedicated migration test that seeds data on the prior migration and asserts it survives the new one.
- Reused the existing `RpgConfigurationMergedRevision` (Campagne) and `RpgCharacterConfigurationRevision` (PlayerCharacter) columns as the single monotonic revision — no schema churn needed there.

### Services (`applications/RPGTableHelper.WebApi/Services/ConfigRevisions/`)

- `ConfigDocumentPatcher` — `TryApply` (RFC 6902 JSON Patch via `JsonPatch.Net`, operating on `System.Text.Json.Nodes.JsonNode` to avoid friction with the app's global Newtonsoft config) and `TryBuildTopLevelPatch` (diff two JSON documents into a minimal `replace`/`add`/`remove` patch over top-level properties, used for GET `sinceRevision`).
- `IConfigRevisionHistoryStore` / `ConfigRevisionHistoryStore` — records a snapshot per successful write and trims to the most recent 10 per parent; look up a snapshot by exact revision for GET.
- `ConfigFileBackupWriter` — extracted/reused version of the existing hub backup logic; skips filesystem writes when `IHostEnvironment.EnvironmentName` is an E2E host.

### DTOs (`applications/RPGTableHelper.WebApi/Dtos/RpgEntities/`)

- `ConfigPatchRequestDto` (`FromRevision`, `Patch` as raw JSON string), `ConfigWriteResultDto` (`Revision`), `ConfigSnapshotResponseDto` (`Kind`, `Revision`, `FromRevision?`, `FullConfig?`, `Patch?`).
- Added optional `FromRevision` to `CampagneUpdateRpgConfigDto` / `PlayerCharacterUpdateRpgConfigDto` for the PUT failsafe check.

### Controllers

- `CampagneController` — extended `UpdateCampagneRpgConfigAsync` (PUT) with the optional `fromRevision` conflict check + history/backup; added `PatchCampagneRpgConfigAsync` (PATCH) and `GetCampagneRpgConfigAsync` (GET `?sinceRevision=`).
- `PlayerCharacterController` — same three changes for `PlayerCharacterEntity` / `RpgCharacterConfiguration`.
- Both controllers gained `IConfigRevisionHistoryStore`, `IHostEnvironment`, and `ILogger` via constructor DI; registered in `Startup.cs`.

## Behavior implemented (maps to acceptance criteria)

- [x] Migration lands single revision + history for campagne and character; existing data remains loadable (migration test seeds on prior migration, asserts post-migration).
- [x] PATCH applies when `fromRevision` matches current revision; bumps revision; stores history snapshot; writes file backup.
- [x] PATCH/PUT with stale `fromRevision` returns `409 Conflict`.
- [x] GET without `sinceRevision` (or with an unsatisfiable one) returns `kind: "full"`; GET with a `sinceRevision` covered by history returns `kind: "patch"`.
- [x] History older than the ~10-snapshot window forces `kind: "full"` on GET.
- [x] API tests cover patch success, 409, GET full/patch/window-exceeded, and backup skip-in-E2E.

## Dependency Graph

### Direct dependencies (blocked by)

- None

### Full chain

`sse-02`

## Status

- Branch: `main`
- Tests:
  - `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~ConfigRevision|FullyQualifiedName~ConfigFileBackupWriter|FullyQualifiedName~ConfigDocumentPatcher"` → 20 passed
  - `dotnet test tests/RPGTableHelper.DataLayer.Tests --filter "FullyQualifiedName~ConfigRevisionHistoryMigrationTests"` → 1 passed
  - `dotnet test RPGTableHelper.sln` (full solution, SignalR e2e excluded from this pass since it needs a live compose stack) → all green (Api.Tests 114 passed/1 skipped, DataLayer.Tests 74 passed, BusinessLayer.Tests 9 passed, Shared.Tests 66 passed, plus the vendored Prodot.Patterns.Cqrs suites)
- Visual snapshots: none (backend-only slice, no Flutter/UI changes)
- Commit(s): `6c9a907c`
