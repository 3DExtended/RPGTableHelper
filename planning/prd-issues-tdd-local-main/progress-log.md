# Progress log — SSE + REST realtime

## 2026-07-23 — Run start

- Branch: `main`
- Scope: sse-01 … sse-08 until prod-ready
- User confirmed local-only planning; implement on main with TDD + compose verification

## sse-01 complete

- Commit: `d99da33c`
- API EventsControllerTests: 3 passed
- Flutter events_client_test: 5 passed

## sse-02 complete

- Config revision store + REST PATCH/PUT/GET (Campagne + PlayerCharacter)
- Commit: `6c9a907c`
- `dotnet test tests/RPGTableHelper.Api.Tests --filter "FullyQualifiedName~ConfigRevision|FullyQualifiedName~ConfigFileBackupWriter|FullyQualifiedName~ConfigDocumentPatcher"`: 20 passed
- `dotnet test tests/RPGTableHelper.DataLayer.Tests --filter "FullyQualifiedName~ConfigRevisionHistoryMigrationTests"`: 1 passed
- `dotnet test RPGTableHelper.sln`: full solution green (Api.Tests 114 passed/1 skipped, DataLayer.Tests 74 passed, BusinessLayer.Tests 9 passed, Shared.Tests 66 passed)

---
