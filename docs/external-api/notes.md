# Notes

Notes work as in the Questkeeper app. A **document** (title, folder) holds **blocks**. Each block has
its own visibility: its author always reads it, plus the campaign members listed in `visibleTo`.

- You read your own documents completely, and in other documents the blocks shared with you.
- You change only what you wrote.
- Through the API you write **text blocks** (Markdown). Image blocks can be read and deleted.

Scopes: `notes:read` to read, `notes:write` to write.

## Who can read a block

Pick readers from the campaign members:

```http
GET /api/external/v1/campaigns/{campaignId}/members        (campaigns:read)
```

```json
[
  { "userId": "40c3...", "isDm": true,  "isYou": false, "characters": [] },
  { "userId": "b52e...", "isDm": false, "isYou": true,  "characters": [{ "id": "1834...", "name": "Aria" }] },
  { "userId": "ad18...", "isDm": false, "isYou": false, "characters": [{ "id": "f213...", "name": "Borin" }] }
]
```

`visibleTo` is **required** on every block you create or change:

| `visibleTo` | Who reads the block |
| --- | --- |
| `[]` | only you |
| `["40c3..."]` | you and the DM |
| `["40c3...", "ad18..."]` | you, the DM and Borin's player |

Only user ids of campaign members are accepted (`400 invalid_request` otherwise). Your own id is
ignored, you always read your blocks. There is no "everyone" shortcut; list the members.

## Reading

```http
GET /api/external/v1/campaigns/{campaignId}/documents
GET /api/external/v1/documents/{documentId}
```

```json
{
  "id": "14dc...",
  "campaignId": "2991...",
  "title": "Plans",
  "groupName": "Heist",
  "createdByUserId": "b52e...",
  "isOwn": true,
  "createdAt": "2026-11-01T18:02:11+00:00",
  "lastModifiedAt": "2026-11-01T18:05:40+00:00",
  "blocks": [
    {
      "id": "7a1e...",
      "type": "text",
      "markdownText": "Steal the **crown**.",
      "imageUrl": null,
      "createdByUserId": "b52e...",
      "isOwn": true,
      "visibleTo": ["40c3..."],
      "createdAt": "2026-11-01T18:03:00+00:00",
      "lastModifiedAt": "2026-11-01T18:03:00+00:00"
    }
  ]
}
```

Blocks come oldest first. `visibleTo` is only filled on your own blocks.

## Writing

```http
POST /api/external/v1/campaigns/{campaignId}/documents
{ "title": "Plans", "groupName": "Heist" }
→ 201, the document (empty)

POST /api/external/v1/documents/{documentId}/blocks
{ "markdownText": "Steal the **crown**.", "visibleTo": ["40c3..."] }
→ 201, the block

PUT /api/external/v1/blocks/{blockId}
{ "markdownText": "Steal the crown. Tonight.", "visibleTo": [] }
→ 200, the block — whoever is no longer in visibleTo cannot read it any more

PUT /api/external/v1/documents/{documentId}
{ "title": "Old plans", "groupName": "Archive" }
→ 200, the document

DELETE /api/external/v1/blocks/{blockId}        → 204
DELETE /api/external/v1/documents/{documentId}  → 204 (with all blocks)
```

`groupName` is the folder the app sorts the document into; documents with the same name are shown
together.

You can only add blocks to your own documents. Changing someone else's document or block answers
`403 forbidden` if you can read it, and `404` if you cannot.

## Staying in sync

When a block is shared with you, changed, unshared or deleted, you get

```text
event: noteAccessChanged
data: {"campagneId":"2991...","documentId":"14dc...","blockId":"7a1e...","changeKind":"granted"}
```

`changeKind` is `granted`, `updated` or `revoked`. Load the document again (on `revoked` it may be
gone for you: `404`). You do not get events for your own changes.
