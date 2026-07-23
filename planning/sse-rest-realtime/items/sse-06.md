# [slice] sse-06 — Session commands: rolls + grants

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: done

## Parent

PRD: `docs/prd/sse-rest-realtime-replace-signalr.md`

## What to build

Replace SignalR fight/roll relays with REST commands that fan out over SSE with **inline** small payloads (`playersAreAskedForRolls`, `dmReceivedFightSequenceAnswer`). Grant items mutate character config through the revisioned PATCH/PUT path (sse-02/04), then peers learn via `characterConfigChanged` (optional tiny toast event). Session-scoped recipients only. No ping/pong.

## Acceptance criteria

- [x] Ask-rolls and roll-result REST endpoints emit SSE with fight-sequence payload to session participants
- [x] Grant-items updates character config via revision store and notifies via config-changed (and optional toast event)
- [x] Flutter DM/player fight and grant flows use REST + SSE instead of hub invokes
- [x] Tests cover roll round-trip and grant → character revision bump → peer notify

## Blocked by

- sse-01
- sse-03
- sse-04

## User stories covered

- 18, 19

## Implementation notes

- New `SessionCommandController`
  (`applications/RPGTableHelper.WebApi/Controllers/RpgControllers/SessionCommandController.cs`) with three
  endpoints, all session-scoped via `ISessionPresenceService` (no ping/pong, no persisted ephemeral state):
  - `POST SessionCommand/askplayersforrolls/{campagneid}` (DM only) fans out an inline `FightSequenceDto`
    (`{ fightUuid, sequence: [{ characterId, characterName, roll }] }`) as `playersAreAskedForRolls` to every
    other online participant in the campagne's table session.
  - `POST SessionCommand/sendfightsequencerollstodm/{playercharacterid}` (character owner only) sends the same
    inline payload as `dmReceivedFightSequenceAnswer` straight to the DM, if the DM currently has an active
    session for that campagne.
  - `POST SessionCommand/grantitems/{playercharacterid}` (DM only) additively merges `GrantItemsRequestDto`
    grants into the character's `inventory` JSON via the new `CharacterInventoryPatcher` helper, reusing the
    same revisioned write path as sse-02/sse-04 (`PlayerCharacterUpdateQuery` + `IConfigRevisionHistoryStore` +
    `ConfigFileBackupWriter`). Notifies peers with the standard `characterConfigChanged` (`{ id, revision }`)
    and additionally sends a small `itemsGranted` toast (`{ playerCharacterId, items }`) straight to the granted
    player if they are online in session, so the client can show "you received X" without a GET round-trip.
- API coverage:
  `tests/RPGTableHelper.Api.Tests/Controllers/RpgControllers/SessionCommandSseNotificationControllerTests.cs`
  drives all three endpoints end-to-end over real `/events` HTTP streams (authorization checks, SSE payload
  delivery, inventory-merge/revision-bump semantics).
- Flutter: `IRpgEntityService` gained REST client methods (`askPlayersForRolls`, `sendFightSequenceRollsToDm`,
  `grantItemsToCharacter`) in `rpg_entity_service.dart`, following the existing raw-`http` pattern used by
  `updateCampagneRpgConfiguration`/`_postSessionAction`. New
  `SessionCommandNotificationController`
  (`applications/rpg_table_helper/lib/services/session_commands/session_command_notification_controller.dart`)
  wraps the shared `EventsClient` stream (mirroring `JoinRequestNotificationController`/
  `ConfigSyncSessionController`) and exposes typed `FightSequenceNotification` / `ItemsGrantedNotification`
  callbacks for `playersAreAskedForRolls`, `dmReceivedFightSequenceAnswer`, and `itemsGranted`.
  `ServerMethodsService.askPlayersForRolls` / `sendFightSequenceRollsToDm` / `sendGrantedItemsToPlayers` now call
  the new REST methods instead of SignalR hub invokes (one REST call per granted character for
  `sendGrantedItemsToPlayers`), while the SignalR hub methods/registrations are left untouched for now (removal
  is sse-08). `SelectGameModeScreen` starts/stops a `SessionCommandNotificationController` per session-entry
  (DM and player), wiring its callbacks to the *existing*, already-tested `ServerMethodsService.
  playersAreAskedForRolls` / `dmReceivedFightSequenceAnswer` / `grantPlayerItems` handlers (by re-serializing
  the parsed SSE event back into the same JSON shape those methods already decode) - so the roll-modal and
  grant-toast UX is unchanged regardless of whether the notify arrived via SignalR or SSE.
  Unit tests: `test/services/session_commands/session_command_notification_controller_test.dart` and
  `test/services/session_commands/server_methods_service_session_commands_test.dart`.
