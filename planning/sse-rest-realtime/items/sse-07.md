# [slice] sse-07 — Notes ACL/content SSE + LoreSync

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: done

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

On note/block permission changes, content updates, and create/delete, compute who gained, lost, or still shares access. Emit membership-scoped SSE (ids + change kind only; no note bodies) to those users’ `/events` streams—even without SessionEnter. Flutter LoreSync: on `revoked` drop document/block from local lore immediately; on granted/updated refetch `GET /Notes/getdocuments/{campagneId}`. Private blocks with empty `permittedUsers` notify nobody until shared.

## Acceptance criteria

- [x] Permission diff notifies gained and lost users with correct change kinds
- [x] Content/create/delete notifies remaining sharees (and revoke-style on delete)
- [x] SSE payloads contain no note bodies
- [x] Flutter revoke removes locally without waiting on GET; grant/update refetches filtered list
- [x] Tests cover grant, revoke, content edit, and delete notification targeting

## Blocked by

- sse-01

## User stories covered

- 21, 22, 23, 24, 29

## Implementation notes

- New `INoteAccessChangeNotifier` / `NoteAccessChangeNotifier`
  (`applications/RPGTableHelper.WebApi/Services/Sse/`) computes, per note document/block mutation, which users
  gained (`granted`), lost (`revoked`), or kept (`updated`) access, and fans out a membership-scoped
  `noteAccessChanged` SSE event (`{ campagneId, documentId, blockId (nullable), changeKind }`, ids only - never
  note bodies) to each affected user's `/events` stream via the existing `ISseEventHub.SendToUsersAsync`, the
  same mechanism used by sse-05/sse-06. Delivery is independent of `SessionEnter`/table-session presence, per
  spec. The acting user is always excluded from their own notify.
  - `NotifyBlockCreatedAsync`: notifies the new block's `permittedUsers` (excluding the creator) as `granted`.
    A private block (`permittedUsers` empty) notifies nobody.
  - `NotifyBlockUpdatedAsync`: diffs `previousBlock.PermittedUsers` vs `updatedBlock.PermittedUsers` into
    gained/lost/remaining sets and sends `granted`/`revoked`/`updated` to each respectively - so a content-only
    edit (no ACL change) still reaches existing sharees as `updated`.
  - `NotifyBlockDeletedAsync`: notifies the deleted block's sharees as `revoked`.
  - `NotifyDocumentUpdatedAsync` / `NotifyDocumentDeletedAsync`: notify the union of `permittedUsers` across
    all of the document's blocks (document-level change, so `blockId` is omitted/`null`) as `updated` /
    `revoked` respectively - e.g. a document delete revokes every block sharee in one pass, and a title-only
    edit still reaches sharees as `updated` even though no block content changed.
  - Registered as a transient service in `Startup.cs` and wired into every mutating `NotesController` endpoint
    (`createtextblock`, `createimageblock`, `updatetextblock`, `updateimageblock`, `updatenote`, `deleteblock`,
    `deletedocument`).
- Fixed a pre-existing persistence bug found while wiring this up: `NoteBlockCreateQueryHandler` never actually
  saved `PermittedUsers` on block creation (the base create handler doesn't know about the many-to-many
  `PermittedUsersToNotesBlockEntity` join table). Added an `AfterCreationAsync` override that persists the join
  rows after the block row is created, so a block created with sharees already set is actually shared from the
  start (previously the first `granted` notify would have gone out with zero real recipients).
- Also fixed `NoteBlockQueryHandler` to `Include(x => x.PermittedUsers)` - it previously loaded blocks without
  their sharees, which would have made every downstream diff computation over-report `revoked` (empty
  `PermittedUsers` vs the real list) for update/delete flows re-querying a fresh block.
- API coverage: `tests/RPGTableHelper.Api.Tests/Services/Sse/NoteAccessChangeNotifierTests.cs` (unit,
  NSubstitute over `ISseEventHub`) covers grant/revoke/update diffing, private-block silence, and actor
  exclusion in isolation; `tests/RPGTableHelper.Api.Tests/Controllers/RpgControllers/
  NotesSseNotificationControllerTests.cs` drives the real `NotesController` endpoints end-to-end over live
  `/events` HTTP streams (create/update/delete block, update/delete document) to assert the right recipients
  see the right `changeKind`s without a `SessionEnter`; `tests/RPGTableHelper.DataLayer.Tests/QueryHandlers/
  RpgEntities/NoteDocuments/{NoteBlockCreateQueryHandlerTests,NoteBlockQueryHandlerTests}.cs` cover the two
  persistence/include fixes above.
- Flutter: new `NoteAccessNotificationController`
  (`applications/rpg_table_helper/lib/services/notes/note_access_notification_controller.dart`) wraps the
  shared `EventsClient` stream (mirroring `JoinRequestNotificationController`/
  `SessionCommandNotificationController`) and exposes a typed `NoteAccessChangedEvent` callback
  (`campagneId`, `documentId`, `blockId?`, `changeKind` as a `NoteAccessChangeKind` enum). `LoreScreen` starts
  it once loaded (independent of table-session state, matching the "even without SessionEnter" requirement)
  and reacts by change kind, scoped to the currently-open campagne:
  - `revoked`: drops the block (if `blockId` set) or the whole document (if `blockId` is null, e.g. document
    delete) from local lore state immediately via `setState`, with no network round-trip.
  - `granted` / `updated`: re-runs the existing `GET /Notes/getdocuments/{campagneId}` load
    (`_reloadAllPages()`) to pick up newly-shared or changed content, since the payload intentionally carries
    no note body to render inline.
  Unit tests: `test/services/notes/note_access_notification_controller_test.dart`.
