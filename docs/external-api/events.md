# Events

Questkeeper pushes what happens at the table over one Server-Sent Events stream. Keep it open while
your app runs; load data with the REST endpoints when an event says something changed.

```http
GET /events
X-Api-Key: <key>
Accept: text/event-stream
```

The stream is outside `/api/external/v1` and needs the `events` scope. Each event also needs the
scope of the data it is about (table below); events your key may not read are not sent.

## Format

```text
event: hello
data: {"userId":"b52e1c38-..."}

: keepalive

event: characterConfigChanged
data: {"id":"18341370-...","revision":8}
```

- `hello` arrives first, on every connection.
- `: keepalive` comment lines come every 15 seconds. Use them to notice a dead connection
  (nothing for 45 seconds → reconnect).
- `data` is always one line of JSON.
- Payloads use the app's spelling `campagneId` (with "g-n-e").

## Sitting at the table

Some events only go to the people **at the table**, like in the app when it shows a campaign. Sit down
after the stream is open, and stand up when your app closes:

```http
POST /api/external/v1/campaigns/{campaignId}/session/enter    → 200 { "onlineUserIds": ["40c3...", "b52e..."] }
POST /api/external/v1/campaigns/{campaignId}/session/leave    → 204
```

Enter after the stream is open: events only reach an open stream. When **all** your streams are
closed for 20 seconds, you leave the table by yourself; a quick reconnect keeps your seat, but call
`enter` again anyway.

Presence is per **user**, not per device: if you use your app and the Questkeeper app at the same
time, `leave` from one of them makes you leave in both. Prefer to simply close the stream.

## Catalog

| Event | Scope | Who gets it | `data` |
| --- | --- | --- | --- |
| `hello` | `events` | you, on connect | `{ userId }` |
| `participantOnline`, `participantOffline` | `events` | at the table | `{ campagneId, userId }` |
| `characterConfigChanged` | `characters:read` | at the table | `{ id, revision }` — `id` is the character id |
| `itemsGranted` | `characters:read` | you, at the table | `{ playerCharacterId, items: [{ itemUuid, amount }] }` |
| `campagneConfigChanged` | `campaigns:read` | at the table | `{ id, revision }` — `id` is the campaign id |
| `noteAccessChanged` | `notes:read` | you, always | `{ campagneId, documentId, blockId, changeKind }` |
| `initiativeRequested` | `fights:play` | you, always | `{ fightId, campagneId, participants: [{ participantId, characterUuid, playerCharacterId, name, kind }] }` |
| `initiativeSettled` | `fights:play` | you, always | `{ fightId, campagneId, participants: [{ participantId, characterUuid, roll }] }` |
| `fightEnded` | `fights:play` | you, always | `{ fightId, campagneId, reason }` |

What to do:

- **`characterConfigChanged`** — if `id` is your character and `revision` is newer than yours, load
  the sheet again ([Character sheet](character-sheet.md)). Fires for every character at the table,
  also after your own writes and when you change your character in the Questkeeper app.
- **`itemsGranted`** — the DM gave you items. They are already in the sheet; show a message.
- **`campagneConfigChanged`** — reload `campaigns/{id}/config` if you show stat names.
- **`noteAccessChanged`** — reload the document ([Notes](notes.md)).
- **`initiativeRequested`**, **`initiativeSettled`**, **`fightEnded`** — see [Initiative](initiative.md).

Other events the Questkeeper app uses are not sent to API keys. New events may be added; ignore the
ones you do not know.

## Reading the stream in a browser

`EventSource` cannot send the `X-Api-Key` header. Read the stream with `fetch` instead:

```js
async function readEvents(baseUrl, apiKey, onEvent, signal) {
  const response = await fetch(`${baseUrl}/events`, {
    headers: { "X-Api-Key": apiKey, Accept: "text/event-stream" },
    signal,
  });
  if (!response.ok) throw new Error(`events: ${response.status}`);

  const reader = response.body.pipeThrough(new TextDecoderStream()).getReader();
  let buffer = "";
  for (;;) {
    const { value, done } = await reader.read();
    if (done) return; // closed by the server: reconnect
    buffer += value;
    let end;
    while ((end = buffer.indexOf("\n\n")) >= 0) {
      const chunk = buffer.slice(0, end);
      buffer = buffer.slice(end + 2);
      let type = "message", data = "";
      for (const line of chunk.split("\n")) {
        if (line.startsWith("event: ")) type = line.slice(7);
        else if (line.startsWith("data: ")) data += line.slice(6);
      }
      if (data) onEvent(type, JSON.parse(data));
    }
  }
}
```

[examples/player-client.mjs](examples/player-client.mjs) adds reconnects and a keepalive watchdog.

## Reconnecting without missing anything

Events are not stored; what happens while you are disconnected is not sent later. After every
(re)connect:

1. wait for `hello`,
2. `session/enter` again,
3. load what you show: the sheet (compare `revision`), the fight (`GET campaigns/{id}/fight` —
   open initiative requests are stored), changed notes.

Reconnect with a growing delay (1 s, 2 s, 5 s, … 30 s). A `401` means the key was revoked or has
expired: stop and ask the user for a new one.
