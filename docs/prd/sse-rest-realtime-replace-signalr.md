# [PRD] Replace SignalR with SSE + REST realtime

> Local draft (no OpenGitBase repo yet). Canonical forge discussion TBD after repo exists.

## Problem Statement

Table sync today depends on SignalR (`/Chat`) with three protocol versions (full blobs, cold/hot slices, JSON Patch envelopes), a flaky client invoke queue, and REST as an unreliable fallback that does not notify peers. Large campagne/character JSON rides the realtime channel, reconnect/group choreography is fragile, and presence is a separate ping/pong loop. Document (lore) permission and content changes have no push at all—players keep stale views until manual refresh.

As a DM or player at the table, I need reliable, simple sync: small notifications when something changed, fetch real data over REST, partial updates by default, and a clear full-document escape hatch when revisions diverge—without maintaining a second realtime stack.

## Solution

Remove SignalR entirely. Use one authenticated Server-Sent Events stream per user for notifications (and small ephemeral session payloads). Persist and fetch durable state via REST. Campagne and character configs use a single JSON document + monotonic revision, JSON Patch writes by default, full PUT/GET as failsafe, and a short server-side revision history so peers can catch up with patches. Session membership (join-code + one-time DM approval) is separate from session presence (sit down tonight). Notes emit SSE when access or content changes so lore UIs update live.

Ship as a hard cut: API and Flutter app upgrade together.

## User Stories

1. As a **player**, I want to open one long-lived events connection after login, so that I receive realtime signals without managing SignalR groups.
2. As a **DM**, I want the same events connection, so that join requests, table signals, and note changes reach me without a separate hub.
3. As a **user**, I want the events stream to reconnect with a refreshed JWT after errors or token expiry, so that sleep/background does not permanently break sync.
4. As a **player**, I want to enter a join code and request to join a campagne once, so that the DM can approve my character into the campaign.
5. As a **DM**, I want an SSE notify when someone requests to join, so that I can accept or deny without polling.
6. As a **player**, I want an SSE notify when my join request is resolved, so that I know I am a campaign member.
7. As an **already-accepted player**, I want to enter a table session without another DM approval, so that reconnecting tonight is fast.
8. As a **DM**, I want SSE when a participant comes online or goes offline at the table, so that I see who is present without ping/pong.
9. As a **DM starting a session**, I want to pull campagne config and all character configs over REST, so that I have current state without asking players to re-upload.
10. As a **player starting a session**, I want to pull campagne config and my character over REST, so that I am in sync before play.
11. As a **DM**, I want campagne config edits to PATCH by default, so that large catalogs are not resent on every small change.
12. As a **player**, I want character config edits to PATCH by default, so that inventory tweaks stay light on the wire.
13. As a **client**, I want PUT full config when I have no baseline or am out of sync, so that I can recover without stuck state.
14. As a **peer at the table**, I want an SSE notify (id + revision only) when config changes, so that I can GET a patch or full document myself.
15. As a **client**, I want `GET config?sinceRevision=N` to return a patch when possible or full when history is missing, so that catch-up stays efficient with a failsafe.
16. As a **client**, I want `409` on revision mismatch, so that I rebase and retry instead of silently overwriting.
17. As a **user with one device**, I want conflicts to be rare, so that 409 is a safety net not a common UX.
18. As a **DM**, I want fight/roll commands to POST over REST and fan out inline on SSE, so that latency stays low for small session signals.
19. As a **DM**, I want granting items to update character config via the normal revisioned write path, so that inventory never diverges from the stored document.
20. As a **player**, I want presence derived from my events connection and session enter (with grace on brief reconnect), so that I do not maintain a heartbeat protocol.
21. As a **note owner**, I want changing block permissions to notify users who gained or lost access, so that their lore view updates without refresh.
22. As a **shared reader**, I want content edits, creates, and deletes of notes/blocks I can see to notify me, so that lore stays live.
23. As a **user who lost access**, I want the client to drop that document from local lore immediately, so that revoked content disappears at once.
24. As a **user who gained access or saw an update**, I want the client to refetch the filtered document list, so that ACL filtering stays correct.
25. As an **operator**, I want timestamped filesystem backups on every successful config persist, so that recovery options remain beyond SQLite history.
26. As a **developer**, I want cold/hot wire protocols and the SignalR hub gone, so that there is one sync model to reason about.
27. As a **developer**, I want paired API + app deploy with no SignalR shim, so that dual stacks do not linger.
28. As a **player not at the table**, I want not to receive fight/roll/config session spam, so that background noise stays low—while still receiving join and note-access events when my events stream is up.
29. As a **DM**, I want join-request and note-access events even when I have not entered a table session, so that I can manage membership and lore from the app shell.
30. As a **client**, I want a single in-flight write per entity with debounce and coalesce, so that the old critical invoke queue is unnecessary.
31. As a **tester**, I want SSE/REST integration coverage replacing SignalR hub tests, so that regressions in sync and presence are caught.

## Implementation Decisions

### Modules (deep seams)

| Module | Responsibility |
|--------|----------------|
| **SseEventHub** (API) | Per-user long-lived SSE connections; auth; subscribe/unsubscribe; fan-out to user ids; reconnect-safe connection registry (in-process) |
| **SessionPresenceService** | `SessionEnter` / leave; map user↔campagne online set; grace on SSE drop; emit `participantOnline` / `participantOffline` |
| **ConfigRevisionStore** | Single JSON + `Revision` per campagne/character; last ~10 full snapshots; compute patch(N→current) or full; apply JSON Patch with `fromRevision`; 409 on mismatch; trigger file backup on success |
| **ConfigHttpApi** | `PATCH` / `PUT` / `GET ?sinceRevision=` for campagne and character configs; after write → SSE notify (session-scoped recipients) |
| **JoinRequestApi** | Existing join-code create + DM handle; after mutate → SSE to DM / player (membership-scoped) |
| **SessionCommandApi** | REST ask-rolls, roll-result, grant-items; grants go through ConfigRevisionStore; SSE inline for ephemeral payloads |
| **NoteChangeNotifier** | Diff permitted users + structural/content changes; SSE to gained/lost/remaining sharees (membership-scoped) |
| **Flutter EventsClient** | Open `/events`, parse typed events, reconnect/backoff, resume + SessionEnter |
| **Flutter ConfigSync** | Debounce → one in-flight PATCH/PUT; 409 rebase; apply GET patch/full into Riverpod stores |
| **Flutter LoreSync** | On note SSE: revoke → drop local; else refetch document list |
| **SignalR removal** | Delete hub, MessagePack hub wiring, client hub services, invoke queue/retry-as-hub, protocol v1/v2/v3 paths, cold/hot slicer as wire protocol |

### Transport

- `GET /events` (SSE), `Authorization: Bearer`.
- One stream per authenticated user.
- No multi-instance fanout (Redis) in this PRD—single API process.

### Event routing

| Event class | Recipients |
|-------------|------------|
| Config changed, rolls, grants, presence | Users with active `SessionEnter` for that campagne |
| Join request created / resolved | DM (and player on resolve) whenever `/events` connected |
| Note access / content / structure | Affected campagne members with `/events` up (not session-gated) |

### Config contract

- Drop cold/hot **protocol** and migrate storage to one document + one revision + history table (retain/migrate useful data from existing columns).
- Writes: JSON Patch + `fromRevision` (default); full PUT + optional `fromRevision` (failsafe).
- Reads: `GET ?sinceRevision=N` → `{ kind: "patch" | "full", revision, ... }`.
- SSE payload: `{ type, entityId, revision }` only—no config body.
- File backups under `configbackups/` on every successful persist (unchanged intent).

### Session vs membership

- **Membership:** join code → join request → DM approve once → character linked to campagne.
- **Presence:** `SessionEnter` for already-accepted members; SSE connection + grace = online; no ping/pong.
- **Hydration:** pull REST on enter (DM: campagne + all characters; player: campagne + own character). No `requestStatusFromPlayers`.

### Notes

- Keep block-level `PermittedUsers`.
- SSE on permission diff, content update, create/delete document/block.
- Payload: ids + change kind (`granted` / `revoked` / `updated` / …); no bodies.
- Client: revoke → remove locally; else refetch `GET /Notes/getdocuments/{campagneId}`.
- Private new blocks (`permittedUsers: []`) notify nobody until shared.

### Client write path

- Debounce locally; at most one in-flight write per entity; coalesce to latest desired state; retry with backoff; on 409 GET/rebase/retry.
- Delete hub invoke queue, drain loops, and SignalR-specific critical coalesce.

### Compatibility

- Hard cut. No SignalR shim. Paired API + Flutter release.

## Testing Decisions

External behavior only; prefer lowest layer that proves the behavior.

| Area | Prior art / approach |
|------|----------------------|
| Config PATCH/PUT/GET + revision/409/history | Extend/replace API tests under `tests/RPGTableHelper.Api.Tests` (former SignalR config tests become HTTP) |
| SSE fan-out + auth + routing (session vs membership) | API integration tests with test SSE client / `HttpClient` stream read |
| Join request + SessionEnter presence + grace | API integration tests |
| Session commands (rolls inline SSE; grants via config revision) | API integration tests |
| Note permission/content SSE targeting | API tests around Notes controllers + notifier |
| Flutter EventsClient reconnect / config sync / lore revoke-or-refetch | Unit/widget tests replacing `hub_invoke_*` and SignalR service tests |
| Multi-client E2E at table | Replace `integration_test/signalr_*` with SSE+REST flows (join, session enter, config patch notify, note ACL) |
| Migration cold/hot → single doc + history | Data-layer / migration tests; assert existing campaigns still load |

Do not require SignalR MessagePack or hub protocol tests after removal.

## Out of Scope

- Changing RPG config JSON game-schema shape (items, stats tabs, etc.)
- Redesigning note ACL to document-level (stays block-level)
- Fixing by-id note GET returning unfiltered blocks to partial sharees (known gap; list endpoint remains client path)
- Multi-instance SSE (Redis / sticky backplane)
- Supporting old SignalR clients or protocol v1/v2/v3 shims
- Unrelated notes soft-delete list hygiene (unless touched incidentally)

## Further Notes

- Agreed in design grill (2026-07-23): complete SignalR kill; SSE notify + REST data; JSON Patch + revision history (~10); 409 rebase; one user `/events` stream; presence = SSE + SessionEnter; keep disk config backups; notes live SSE for ACL and content.
- When an OpenGitBase repo exists for this project, publish this body as a Discussion titled `[PRD] Replace SignalR with SSE + REST realtime` and sync via `ogb docs pull`.
- Suggested follow-up: `/to-issues-local` (or forge slices) into tracer bullets: SSE hub → config revision API → session/join/presence → Flutter client cutover → notes notifier → delete SignalR → E2E.
