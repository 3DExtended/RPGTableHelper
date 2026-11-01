# Character sheet

A character's sheet is one JSON document, exactly as the Questkeeper app stores it. Your app reads
the whole document and changes it with JSON Patch; every change creates a new **revision**.

Only your own characters are available (`characters:read` to read, `characters:write` to change).

## Reading

```http
GET /api/external/v1/characters/{characterId}/sheet
```

```json
{
  "characterId": "18341370-70ff-4b4a-bf00-2bd0733f2701",
  "campaignId": "2991450b-4e6a-43bf-ab35-924fdffe4061",
  "name": "Aria",
  "revision": 7,
  "sheet": {
    "uuid": "0b7c...",
    "characterName": "Aria",
    "characterStats": [
      { "statUuid": "hp-stat", "serializedValue": "{\"value\":12,\"maxValue\":20}" },
      { "statUuid": "bio-stat", "serializedValue": "{\"value\":\"Grew up in the harbour.\"}" }
    ],
    "inventory": [{ "itemUuid": "c3f1...", "amount": 2 }],
    "moneyInBaseType": 1250,
    "companionCharacters": [{ "uuid": "wolf-1", "characterName": "Fang", "characterStats": [] }],
    "alternateForms": [],
    "isAlternateFormActive": false,
    "alternateForm": null
  }
}
```

The sheet has no field names like "hit points". It holds **stat values**, each pointing to a stat
the campaign defines (`statUuid`). To show a sheet, combine it with the campaign configuration.

| Field | Meaning |
| --- | --- |
| `uuid` | The character's id inside Questkeeper (fights and companions refer to it). Never change it. |
| `characterName` | Name shown at the table. |
| `characterStats` | Stat values: `statUuid` plus `serializedValue`, a **string** that holds JSON. |
| `inventory` | Items as `{ itemUuid, amount }`; the items are defined in the campaign configuration (`allItems`). |
| `moneyInBaseType` | Money in the smallest currency unit of the campaign. |
| `companionCharacters` | Companions (animals, familiars...). Each has its own `uuid`, `characterName` and `characterStats`. |
| `alternateForms` | Forms the character can transform into. |
| `isAlternateFormActive`, `alternateForm` | While transformed, `alternateForm` is the active form, and the table sees **its** stats. |

Other fields may exist; keep what you do not understand.

### The campaign configuration

```http
GET /api/external/v1/campaigns/{campaignId}/config        (campaigns:read)
```

`config.characterStatTabsDefinition[].statsInTab[]` defines every stat:

```json
{ "statUuid": "hp-stat", "name": "Hit points", "helperText": "", "valueType": "intWithMaxValue", "editType": "oneTap", "jsonSerializedAdditionalData": null }
```

- `valueType` says what `serializedValue` holds (table below).
- `editType`: `oneTap` stats change during play (hit points, spell slots); `static` ones rarely.
- `jsonSerializedAdditionalData` describes options and groups for some types (string holding JSON).

| `valueType` | `serializedValue` (decoded) |
| --- | --- |
| `singleLineText`, `multiLineText` | `{ "value": "text" }` |
| `int` | `{ "value": 17 }` |
| `intWithMaxValue` | `{ "value": 12, "maxValue": 17 }` — hit points are usually this |
| `intWithCalculatedValue` | `{ "value": 12, "otherValue": 2 }` |
| `multiselect` | `{ "values": ["<option uuid>", ...] }`, options in `jsonSerializedAdditionalData.options` |
| `singleImage` | `{ "imageUrl": "https://...", "value": "caption" }` |
| `listOfIntWithCalculatedValues` | `{ "values": [{ "uuid": "<group uuid>", "value": 12, "otherValue": 2 }] }` |
| `listOfIntsWithIcons` | `{ "values": [{ "uuid": "<group uuid>", "value": 12 }] }` |
| `characterNameWithLevelAndAdditionalDetails` | `{ "level": 3, "values": [{ "uuid": "<group uuid>", "value": "Dwarf" }] }` |
| `companionSelector` | `{ "values": [{ "uuid": "<companion uuid>" }] }` |
| `transformIntoAlternateFormBtn` | no value (a button in the app) |

## Changing one stat

The easiest way to sync a life tracker:

```http
PUT /api/external/v1/characters/{characterId}/sheet/stats/{statUuid}
Content-Type: application/json

{ "value": { "value": 7, "maxValue": 20 } }
```

```json
{ "revision": 8 }
```

- Send the **decoded** value; the server writes it into `serializedValue`.
- `?companionUuid=wolf-1` sets the stat of that companion instead.
- While the character is transformed, the active form's stat is set: that is what the table sees.
- Without `fromRevision` the stat is overwritten whatever else changed — fine for your own hit points.
  Send `"fromRevision": 7` if you only want to write on top of the version you have.
- `404` if the sheet has no value for that stat yet (add it with PATCH), `422` if the value does not
  fit the stat's type.

## Changing anything: JSON Patch

```http
PATCH /api/external/v1/characters/{characterId}/sheet
Content-Type: application/json

{
  "fromRevision": 7,
  "patch": [
    { "op": "test", "path": "/characterStats/0/statUuid", "value": "hp-stat" },
    { "op": "replace", "path": "/characterStats/0/serializedValue", "value": "{\"value\":7,\"maxValue\":20}" },
    { "op": "replace", "path": "/moneyInBaseType", "value": 1300 }
  ]
}
```

- `patch` is an [RFC 6902](https://www.rfc-editor.org/rfc/rfc6902) operation list: `add`, `remove`,
  `replace`, `move`, `copy`, `test`. All or nothing.
- Stats are addressed by **index**. Put a `test` on the `statUuid` before a `replace`, so the patch
  fails instead of hitting another stat if the list changed.
- `replace` needs the field to exist. `add` creates a field or overwrites it, and
  `/characterStats/-` appends a stat value.
- `serializedValue` is a string: encode the value object yourself (`JSON.stringify`).

Answers:

| Status | `error` | What to do |
| --- | --- | --- |
| 200 | – | `{ "revision": 8 }` — the new revision. |
| 409 | `revision_conflict` | Someone (the DM, the app) changed the sheet. Load it again, re-apply your change, send it with the new revision. `currentRevision` tells you where it is. |
| 400 | `invalid_patch` | The patch does not apply, e.g. a `test` failed or a path is missing. |
| 422 | `invalid_sheet` | The result would break the character in Questkeeper. Nothing was saved; `problems` lists why. |

What is checked (only problems your change introduces count):

- `uuid` stays the same and non-empty; `characterName` is a string; `characterStats` and `inventory`
  are lists (the app cannot open a sheet without them, so do not remove them).
- Every stat value has a `statUuid` and a `serializedValue` that is a JSON object.
- If the campaign defines stats: the `statUuid` exists and the value fits its `valueType`.
- The same for companions, alternate forms and the active form; each of them needs a `uuid` and a
  `characterName`.
- `inventory` entries are `{ itemUuid, amount }`; `moneyInBaseType` is an integer.

## Staying in sync

Every saved change is announced to everyone at the table (see [Events](events.md#sitting-at-the-table)),
your own Questkeeper app included:

```text
event: characterConfigChanged
data: {"id":"18341370-...","revision":8}
```

When you receive it for your character with a revision newer than yours, load the sheet again.
Other players' characters cause the same event; you cannot load their sheets.
