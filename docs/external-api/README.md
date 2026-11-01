# Questkeeper Player API

The player API lets your own app take part in a Questkeeper table as a player: read and change your
character sheet (so the DM sees your hit points change), read and write notes with the visibility
you choose, and roll initiative when the DM starts a fight. It is the same table the Questkeeper app
shows; changes go both ways, live.

- Base URL: `https://questkeeper-prod.peter-esser.de/api/external/v1`
- Reference (every endpoint, request and response):
  `https://questkeeper-prod.peter-esser.de/swagger` (document "External API",
  raw: `/swagger/external/swagger.json`)
- Auth: an API key in the `X-Api-Key` header. Each player creates their own.

## Quick start

1. In the Questkeeper app open your user settings, choose **API Keys** and create a key. Tick the
   permissions your app needs (see [Authentication](authentication.md)). The key is shown once;
   store it like a password.
2. Check it:

   ```bash
   curl -H "X-Api-Key: $KEY" https://questkeeper-prod.peter-esser.de/api/external/v1/me
   ```

3. Find your campaign and character:

   ```bash
   curl -H "X-Api-Key: $KEY" .../api/external/v1/campaigns
   curl -H "X-Api-Key: $KEY" .../api/external/v1/characters
   ```

   These two lists are older than v1 and return the stored records as they are: ids are objects
   (`"id": { "value": "2991..." }`, `"campagneId": { "value": "..." }`). Every v1 endpoint uses plain
   ids.

4. Open the event stream, sit down at the table, and react to what happens
   (see [Events](events.md)).

A complete browser client is in [examples/player-client.mjs](examples/player-client.mjs).

## What a player client usually does

| Goal | Calls | Guide |
| --- | --- | --- |
| Show and edit the sheet | `GET characters/{id}/sheet`, `PATCH characters/{id}/sheet`, `GET campaigns/{id}/config` | [Character sheet](character-sheet.md) |
| Sync hit points | `PUT characters/{id}/sheet/stats/{statUuid}` | [Character sheet](character-sheet.md#changing-one-stat) |
| Notes | `GET/POST campaigns/{id}/documents`, `POST documents/{id}/blocks`, `PUT blocks/{id}` | [Notes](notes.md) |
| Initiative | events `initiativeRequested`, `initiativeSettled`, `GET campaigns/{id}/fight`, `POST campaigns/{id}/fight/rolls` | [Initiative](initiative.md) |
| Live updates | `GET /events`, `POST campaigns/{id}/session/enter` | [Events](events.md) |

## Endpoints

All paths are relative to `/api/external/v1`.

| Method | Path | Scope |
| --- | --- | --- |
| GET | `me` | – |
| GET | `campaigns`, `campaigns/{id}` | `campaigns:read` |
| GET | `campaigns/{id}/members` | `campaigns:read` |
| GET | `campaigns/{id}/config` | `campaigns:read` |
| GET | `campaigns/{id}/characters` (DM only) | `campaigns:read` |
| POST | `campaigns/{id}/session/enter`, `campaigns/{id}/session/leave` | `events` |
| GET | `characters`, `characters/{id}` | `characters:read` |
| GET | `characters/{id}/sheet` | `characters:read` |
| PATCH | `characters/{id}/sheet` | `characters:write` |
| PUT | `characters/{id}/sheet/stats/{statUuid}` | `characters:write` |
| GET | `campaigns/{id}/documents`, `documents/{id}` | `notes:read` |
| POST | `campaigns/{id}/documents` | `notes:write` |
| PUT, DELETE | `documents/{id}` | `notes:write` |
| POST | `documents/{id}/blocks` | `notes:write` |
| PUT, DELETE | `blocks/{id}` | `notes:write` |
| GET | `campaigns/{id}/fight` | `fights:play` |
| POST | `campaigns/{id}/fight/rolls` | `fights:play` |
| GET | `/events` (outside `/api/external/v1`) | `events` |

## Ground rules

- **You act as yourself.** A key can do what its owner could do as a player, limited by its
  scopes: your own characters, your own notes, rolls for your own characters. Even a DM's key only
  gets the player view.
- **Things you cannot see are "not found".** A campaign you are not part of, someone else's
  character or a note not shared with you answers `404`. (The read endpoints from before v1,
  `characters/{id}` and `campaigns/{id}`, answer `403` instead.)
- **Writes are checked.** Sheet changes go against a revision and are validated; notes need an
  explicit visibility. Nothing is shared or overwritten by accident.
- **Errors** have one shape: `{ "error": "<code>", "message": "...", ... }`. Branch on `error`. See
  [Authentication → Errors](authentication.md#errors).

## More

- [Authentication, scopes, rate limits, errors](authentication.md)
- [Character sheet](character-sheet.md)
- [Notes](notes.md)
- [Initiative](initiative.md)
- [Events](events.md)
- [Changelog](CHANGELOG.md)
