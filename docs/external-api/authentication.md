# Authentication

## API keys

Every request carries the key in a header:

```http
X-Api-Key: sk-AbCd...
```

A player creates keys in the Questkeeper app (user settings → **API Keys**), names them, picks
permissions (scopes) and optionally an expiry date. The key belongs to that player: the API sees
what they see and acts as them. Revoking the key in the app stops it immediately.

Each person who uses your app creates their own key and enters it there. Do not share one key
between players.

### In the browser

The API allows cross-origin requests, including the `X-Api-Key` header, so a single-page app can
call it directly. Keep in mind:

- The key lives in the user's browser. Store it where your app keeps secrets (e.g. memory or
  `localStorage` behind your own login), never in source code or URLs.
- `EventSource` cannot send headers. Read the event stream with `fetch` instead; see
  [Events](events.md#reading-the-stream-in-a-browser).

## Scopes

| Scope | Allows | Shown in the app as |
| --- | --- | --- |
| `campaigns:read` | Your campaigns, their members and rule configuration | See your campaigns and fellow players |
| `characters:read` | Your characters and their sheets; sheet and item events | Read your character sheets |
| `characters:write` | Change your character sheets | Change your character sheets, e.g. hit points |
| `notes:read` | Notes you can see; note events | Read the notes you can see |
| `notes:write` | Create and change your own notes and their visibility | Write your own notes and choose who sees them |
| `fights:play` | See the open fight and roll initiative; fight events | Roll initiative when the DM starts a fight |
| `events` | The live event stream and being "at the table" | Receive live updates |

`GET me` needs no scope and tells you which scopes the key has:

```json
{
  "userId": "b52e1c38-0144-4ffb-b661-e7df86e925f2",
  "username": "carsten",
  "apiKey": { "prefix": "sk-trWO", "scopes": ["characters:read", "characters:write", "events"] }
}
```

`characters:write` does not include `characters:read`, and `notes:write` does not include
`notes:read`. Ask for both if you need both.

Keys created before scopes existed have `campaigns:read`, `characters:read` and `notes:read`.

## Rate limits

Per key:

- 120 requests per minute in total,
- 30 of them may change something (anything but `GET`).

Over the limit you get `429` with a `Retry-After` header (seconds) and

```json
{ "error": "rate_limited", "message": "Too many requests with this API key. Try again in 42 s.", "retryAfterSeconds": 42 }
```

React to events instead of polling, and send hit point changes when they settle (e.g. 500 ms after
the last click), not on every click.

## Errors

Errors of the v1 API share one JSON shape:

```json
{
  "error": "invalid_sheet",
  "message": "The patched sheet would not be valid any more; nothing was saved.",
  "problems": ["/characterStats[statUuid=hp-stat]/serializedValue: \"value\" and \"maxValue\" must be integers."]
}
```

| Status | `error` | Meaning |
| --- | --- | --- |
| 400 | `invalid_request` | The body or a parameter is invalid; `problems` says what. |
| 400 | `invalid_patch` | The JSON Patch is malformed or does not apply (e.g. a path that is not there). |
| 400 | `unsupported_block_type` | Only text blocks can be written. |
| 401 | – (empty body) | No key, or the key is unknown, revoked or expired. |
| 403 | `insufficient_scope` | The key lacks a scope; `requiredScopes` lists it. |
| 403 | `forbidden` | You may see it but not change it (someone else's note, someone else's character in a fight). |
| 404 | `not_found` | It does not exist, or it is not yours to see. |
| 409 | `revision_conflict` | The sheet changed since `fromRevision`; `currentRevision` says where it is now. |
| 409 | `no_open_fight` | The campaign has no open fight (any more). |
| 409 | `fight_conflict` | E.g. you already rolled for this character. |
| 422 | `invalid_sheet` | The change would break the sheet for Questkeeper; `problems` lists why. |
| 429 | `rate_limited` | See above. |
| 500 | `write_failed` | The server could not store the change. Try again later. |

The read endpoints that existed before v1 (`characters`, `campaigns`, `campaigns/{id}/characters`)
still answer errors with an empty body and the status code only.
