# Notes

Notes work as in the Questkeeper app. A **document** (title, folder) holds **blocks**. Each block has
its own visibility: its author always reads it, plus the campaign members listed in `visibleTo`.

- You read your own documents completely, and in other documents the blocks shared with you.
- You change only what you wrote.
- A block is **text** (Markdown) or an **image** with an optional caption.

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

An image block carries an image and optionally a caption. Upload it as `multipart/form-data`:

```bash
curl -X POST "$BASE/api/external/v1/documents/$DOCUMENT_ID/image-blocks" \
  -H "X-Api-Key: $KEY" \
  -F "image=@vault.png;type=image/png" \
  -F "markdownText=The vault" \
  -F 'visibleTo=["40c3..."]'
```

The answer is `201` with the block; `imageUrl` holds the full link to the image.

- `image`: PNG or JPEG, at most 10 MB. The file's content is checked, not just its name.
- `visibleTo`: required, here as a **JSON array in a form field**. `[]` keeps the block private.
- `markdownText`: optional.

Afterwards you can change the caption and who reads the block. The image itself stays; to swap it,
delete the block and create a new one.

```http
PUT /api/external/v1/image-blocks/{blockId}
{ "markdownText": "The empty vault", "visibleTo": [] }
→ 200, the block
```

`PUT blocks/{id}` is for text blocks only, `PUT image-blocks/{id}` for image blocks only; the wrong
one answers `400 unsupported_block_type`. `DELETE blocks/{id}` deletes both.

> **`visibleTo` guards the block, not the image file.** Anyone with the `imageUrl` can load the image
> without logging in, and someone who has seen the link keeps it after you take them out of
> `visibleTo`. Do not upload images that must stay secret from people who had access once.

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
