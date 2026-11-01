# Initiative

When the DM starts a fight in Questkeeper, everyone whose character or companion takes part is asked
to roll initiative. The fight is stored on the server: a player who is away is asked when they come
back, until they rolled or the DM ends the fight (or nothing happens for 12 hours).

Scope: `fights:play`.

## The flow

1. The DM starts a fight. If your app has the [event stream](events.md) open, it gets

   ```text
   event: initiativeRequested
   data: {"fightId":"5b0e...","campagneId":"2991...","participants":[{"participantId":"91ac...","characterUuid":"0b7c...","playerCharacterId":"1834...","name":"Aria","kind":"Character"},{"participantId":"91ad...","characterUuid":"wolf-1","playerCharacterId":"1834...","name":"Fang","kind":"Companion"}]}
   ```

2. Your app was not connected? Ask on start and after every reconnect:

   ```http
   GET /api/external/v1/campaigns/{campaignId}/fight
   ```

   ```json
   {
     "fight": {
       "id": "5b0e...",
       "campagneId": "2991...",
       "startedAt": "2026-11-01T19:30:00+00:00",
       "isOpen": true,
       "isDmView": false,
       "revision": 3,
       "participants": [
         { "id": "91ac...", "kind": "Character", "characterUuid": "0b7c...", "playerCharacterId": "1834...", "name": "Aria", "roll": null, "isPending": true },
         { "id": "91ad...", "kind": "Companion", "characterUuid": "wolf-1", "playerCharacterId": "1834...", "name": "Fang", "roll": null, "isPending": true }
       ]
     }
   }
   ```

   `fight` is `null` if there is no open fight. You only see your own characters and companions.

3. Ask the player for their rolls (the total, modifiers included) and send them:

   ```http
   POST /api/external/v1/campaigns/{campaignId}/fight/rolls
   { "rolls": [ { "characterUuid": "0b7c...", "roll": 17 }, { "characterUuid": "wolf-1", "roll": 9 } ] }
   ```

   The answer is the fight as you see it, now with `isPending: false`. The DM sees the new order
   right away. You may send rolls one by one.

4. A roll is no longer needed because the player rolled somewhere else (in the Questkeeper app, or
   in a second tab of your app), the DM rolled for them, or the DM took the character out of the
   fight. Every stream of that player gets

   ```text
   event: initiativeSettled
   data: {"fightId":"5b0e...","campagneId":"2991...","participants":[{"participantId":"91ac...","characterUuid":"0b7c...","roll":17}]}
   ```

   Stop asking for these `characterUuid`s. `roll` is `null` when the DM removed the character. Your
   own roll comes back to you too; ignore what you no longer show.

5. The fight ends:

   ```text
   event: fightEnded
   data: {"fightId":"5b0e...","campagneId":"2991...","reason":"EndedByDm"}
   ```

   `reason` is `EndedByDm`, `ReplacedByNewFight` (a new fight started; you will get a new
   `initiativeRequested`) or `Expired`. Close your prompt if it is still open.

## Answers

| Status | `error` | Meaning |
| --- | --- | --- |
| 200 | – | Rolls saved. |
| 400 | `invalid_request` | A `characterUuid` is not in the fight, or a roll is outside -1000…1000. |
| 403 | `forbidden` | You rolled for someone else's character. Through the API everyone rolls only for their own, the DM included. |
| 409 | `no_open_fight` | There is no open fight (any more). |
| 409 | `fight_conflict` | You already rolled for this character (e.g. in the Questkeeper app). Reload the fight. |

The player may also roll in the Questkeeper app. Whatever arrives first counts; the other one gets
`fight_conflict`, and both apps get `initiativeSettled`, so the other prompt closes. Events missed
while disconnected are not sent later: after a reconnect, load the fight and close the prompts of
characters that are no longer pending.
