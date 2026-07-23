# [slice] sse-07 — Notes ACL/content SSE + LoreSync

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

On note/block permission changes, content updates, and create/delete, compute who gained, lost, or still shares access. Emit membership-scoped SSE (ids + change kind only; no note bodies) to those users’ `/events` streams—even without SessionEnter. Flutter LoreSync: on `revoked` drop document/block from local lore immediately; on granted/updated refetch `GET /Notes/getdocuments/{campagneId}`. Private blocks with empty `permittedUsers` notify nobody until shared.

## Acceptance criteria

- [ ] Permission diff notifies gained and lost users with correct change kinds
- [ ] Content/create/delete notifies remaining sharees (and revoke-style on delete)
- [ ] SSE payloads contain no note bodies
- [ ] Flutter revoke removes locally without waiting on GET; grant/update refetches filtered list
- [ ] Tests cover grant, revoke, content edit, and delete notification targeting

## Blocked by

- sse-01

## User stories covered

- 21, 22, 23, 24, 29
