# Changelog

## v1 (unreleased)

The player API: a player's own app can take part at the table.

### Added

- Scopes for API keys: `campaigns:read`, `characters:read`, `characters:write`, `notes:read`,
  `notes:write`, `fights:play`, `events`. Chosen when creating a key in the app, together with an
  optional expiry date. A key without the scope an endpoint needs answers `403 insufficient_scope`.
- `GET me`: the key's owner and scopes.
- `GET campaigns/{id}/members`, `GET campaigns/{id}/config`.
- `POST campaigns/{id}/session/enter|leave`: sit down at the table to get its events.
- Character sheet: `GET|PATCH characters/{id}/sheet` (JSON Patch against a revision, validated) and
  `PUT characters/{id}/sheet/stats/{statUuid}` (one stat, e.g. hit points; companions and the active
  alternate form included).
- Notes: read documents and the blocks shared with you; create, change and delete your documents and
  text blocks with an explicit `visibleTo`.
- Initiative: `GET campaigns/{id}/fight`, `POST campaigns/{id}/fight/rolls`. Open requests are stored
  on the server, so a player who was away is still asked.
- Events for API keys: `initiativeRequested`, `initiativeSettled`, `fightEnded`. Each event reaches
  a key only with the matching scope; events of the app's internals are no longer sent to keys.
  `initiativeSettled` tells every app of a player that a roll is no longer needed (rolled in another
  app or by the DM, or removed by the DM), so all their prompts close.
- Rate limits per key: 120 requests and 30 writes per minute (`429` with `Retry-After`).
- One error shape for v1: `{ error, message, problems?, ... }`.
- Swagger document "External API" with the scope of every endpoint.

### Changed

- Keys created before scopes existed keep read access: `campaigns:read`, `characters:read`,
  `notes:read`.
- The old paths without `/v1` (`characters`, `campaigns`, `documents` reads) still work. They are
  not documented any more; use `/v1`.
- `characterConfigChanged` also reaches the player who made the change, so a change made in the
  Questkeeper app shows up in your app and the other way round.

### Fixed

- Reading someone else's note document returned all of its blocks, also those not shared with you.
  Now only the shared blocks are returned (also in the Questkeeper app).
