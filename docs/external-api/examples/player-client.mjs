/**
 * Questkeeper player client: a dependency-free ES module for browsers and Node 18+.
 *
 *   import { QuestkeeperPlayer } from "./player-client.mjs";
 *   const qk = new QuestkeeperPlayer({ baseUrl: "https://questkeeper-prod.peter-esser.de", apiKey });
 *
 * A complete flow (hit points, notes, initiative) is at the end of this file.
 */

const V1 = "/api/external/v1";

/** An error answer of the API. Branch on `code`, e.g. "revision_conflict" or "insufficient_scope". */
export class ApiError extends Error {
  constructor(status, body) {
    super(body?.message ?? `HTTP ${status}`);
    this.name = "ApiError";
    this.status = status;
    this.code = body?.error ?? null;
    this.body = body;
  }
}

/** All stat definitions of a campaign config (`(await qk.config(id)).config`), across its tabs. */
export function statDefinitions(config) {
  return (config.characterStatTabsDefinition ?? []).flatMap((tab) => tab.statsInTab ?? []);
}

export class QuestkeeperPlayer {
  #baseUrl;
  #apiKey;
  #pendingStats = new Map();

  constructor({ baseUrl, apiKey }) {
    this.#baseUrl = baseUrl.replace(/\/+$/, "");
    this.#apiKey = apiKey;
  }

  /** Sends one request; waits and retries (twice) when the rate limit answers 429. */
  async request(method, path, body) {
    for (let attempt = 0; ; attempt++) {
      const response = await fetch(this.#baseUrl + path, {
        method,
        headers: {
          "X-Api-Key": this.#apiKey,
          ...(body === undefined ? {} : { "Content-Type": "application/json" }),
        },
        body: body === undefined ? undefined : JSON.stringify(body),
      });
      if (response.status === 429 && attempt < 2) {
        await sleep((Number(response.headers.get("Retry-After")) || 5) * 1000);
        continue;
      }
      const text = await response.text();
      const json = text ? parseJson(text) : null;
      if (!response.ok) throw new ApiError(response.status, json);
      return json;
    }
  }

  // --- who and where -------------------------------------------------------------------------

  me() {
    return this.request("GET", `${V1}/me`);
  }

  /** Your campaigns. (This list is older than v1 and nests ids as { value }; flattened here.) */
  async campaigns() {
    const list = await this.request("GET", `${V1}/campaigns`);
    return list.map((c) => ({ id: c.id.value, name: c.campagneName, dmUserId: c.dmUserId.value }));
  }

  /** Your characters, with the campaign they play in. (Older than v1, see campaigns().) */
  async characters() {
    const list = await this.request("GET", `${V1}/characters`);
    return list.map((c) => ({ id: c.id.value, name: c.characterName, campaignId: c.campagneId?.value ?? null }));
  }

  members(campaignId) {
    return this.request("GET", `${V1}/campaigns/${campaignId}/members`);
  }

  config(campaignId) {
    return this.request("GET", `${V1}/campaigns/${campaignId}/config`);
  }

  enterTable(campaignId) {
    return this.request("POST", `${V1}/campaigns/${campaignId}/session/enter`);
  }

  leaveTable(campaignId) {
    return this.request("POST", `${V1}/campaigns/${campaignId}/session/leave`);
  }

  // --- character sheet -----------------------------------------------------------------------

  /** `{ characterId, campaignId, name, revision, sheet }` */
  sheet(characterId) {
    return this.request("GET", `${V1}/characters/${characterId}/sheet`);
  }

  patchSheet(characterId, fromRevision, patch) {
    return this.request("PATCH", `${V1}/characters/${characterId}/sheet`, { fromRevision, patch });
  }

  /**
   * Loads the sheet, lets `change(sheet)` return JSON Patch operations, and saves them. If the sheet
   * changed in between (someone else wrote), it starts over with the new version, up to three times.
   */
  async changeSheet(characterId, change) {
    for (let attempt = 0; ; attempt++) {
      const { revision, sheet } = await this.sheet(characterId);
      const patch = change(sheet);
      if (patch.length === 0) return { revision };
      try {
        return await this.patchSheet(characterId, revision, patch);
      } catch (error) {
        if (error.code !== "revision_conflict" || attempt >= 2) throw error;
      }
    }
  }

  /** Sets one stat to `value`, the decoded serializedValue, e.g. `{ value: 7, maxValue: 20 }`. */
  setStat(characterId, statUuid, value, { companionUuid, fromRevision } = {}) {
    const query = companionUuid ? `?companionUuid=${encodeURIComponent(companionUuid)}` : "";
    return this.request(
      "PUT",
      `${V1}/characters/${characterId}/sheet/stats/${encodeURIComponent(statUuid)}${query}`,
      { value, fromRevision },
    );
  }

  /**
   * Like setStat, but waits until the value stopped changing for `delayMs`, e.g. while the player taps
   * "-" five times. Only the last value is sent; every caller gets its result.
   */
  setStatSoon(characterId, statUuid, value, { companionUuid, delayMs = 600 } = {}) {
    const key = `${characterId}/${companionUuid ?? ""}/${statUuid}`;
    const entry = this.#pendingStats.get(key) ?? { waiting: [] };
    clearTimeout(entry.timer);
    this.#pendingStats.set(key, entry);
    return new Promise((resolve, reject) => {
      entry.waiting.push({ resolve, reject });
      entry.timer = setTimeout(() => {
        this.#pendingStats.delete(key);
        this.setStat(characterId, statUuid, value, { companionUuid }).then(
          (result) => entry.waiting.forEach((w) => w.resolve(result)),
          (error) => entry.waiting.forEach((w) => w.reject(error)),
        );
      }, delayMs);
    });
  }

  // --- notes ---------------------------------------------------------------------------------

  documents(campaignId) {
    return this.request("GET", `${V1}/campaigns/${campaignId}/documents`);
  }

  document(documentId) {
    return this.request("GET", `${V1}/documents/${documentId}`);
  }

  createDocument(campaignId, { title, groupName }) {
    return this.request("POST", `${V1}/campaigns/${campaignId}/documents`, { title, groupName });
  }

  updateDocument(documentId, { title, groupName }) {
    return this.request("PUT", `${V1}/documents/${documentId}`, { title, groupName });
  }

  deleteDocument(documentId) {
    return this.request("DELETE", `${V1}/documents/${documentId}`);
  }

  /** `visibleTo`: user ids of campaign members who may read the block besides you; `[]` = only you. */
  addTextBlock(documentId, markdownText, visibleTo) {
    return this.request("POST", `${V1}/documents/${documentId}/blocks`, { markdownText, visibleTo });
  }

  updateTextBlock(blockId, markdownText, visibleTo) {
    return this.request("PUT", `${V1}/blocks/${blockId}`, { markdownText, visibleTo });
  }

  deleteBlock(blockId) {
    return this.request("DELETE", `${V1}/blocks/${blockId}`);
  }

  // --- initiative ----------------------------------------------------------------------------

  /** The open fight with your participants (`isPending` while you still have to roll), or null. */
  async fight(campaignId) {
    return (await this.request("GET", `${V1}/campaigns/${campaignId}/fight`)).fight;
  }

  /** `rolls`: `[{ characterUuid, roll }]`, the totals the player rolled. */
  roll(campaignId, rolls) {
    return this.request("POST", `${V1}/campaigns/${campaignId}/fight/rolls`, { rolls });
  }

  // --- events --------------------------------------------------------------------------------

  /**
   * Keeps the event stream open until `signal` aborts. After every (re)connect it sits down at
   * `campaignId`'s table and calls `onConnected`, where you reload what you show: events are not
   * replayed. Reconnects with a growing delay; stops for good on 401/403 (key revoked, expired or
   * without the `events` scope). Errors, also those thrown by your callbacks, go to `onError`.
   */
  async listen({ campaignId, onEvent, onConnected = () => {}, onError = () => {}, signal }) {
    let delay = 1000;
    while (!signal?.aborted) {
      try {
        await this.#readStream(async (type, data) => {
          try {
            if (type === "hello") {
              delay = 1000;
              if (campaignId) await this.enterTable(campaignId);
              await onConnected();
            } else {
              await onEvent(type, data);
            }
          } catch (error) {
            onError(error);
          }
        }, signal);
      } catch (error) {
        if (signal?.aborted) return;
        onError(error);
        if (error instanceof ApiError && (error.status === 401 || error.status === 403)) return;
      }
      await sleep(delay, signal);
      delay = Math.min(delay * 2, 30000);
    }
  }

  async #readStream(handle, outerSignal) {
    const controller = new AbortController();
    const abort = () => controller.abort();
    outerSignal?.addEventListener("abort", abort, { once: true });
    let watchdog;
    // The server sends a keepalive every 15 s; three missing means the connection is dead.
    const resetWatchdog = () => {
      clearTimeout(watchdog);
      watchdog = setTimeout(abort, 45000);
    };
    try {
      resetWatchdog();
      const response = await fetch(`${this.#baseUrl}/events`, {
        headers: { "X-Api-Key": this.#apiKey, Accept: "text/event-stream" },
        signal: controller.signal,
      });
      if (!response.ok) throw new ApiError(response.status, parseJson(await response.text()));

      const reader = response.body.pipeThrough(new TextDecoderStream()).getReader();
      let buffer = "";
      for (;;) {
        const { value, done } = await reader.read();
        if (done) return;
        resetWatchdog();
        buffer += value;
        let end;
        while ((end = buffer.indexOf("\n\n")) >= 0) {
          const chunk = buffer.slice(0, end);
          buffer = buffer.slice(end + 2);
          let type = "message";
          let data = "";
          for (const line of chunk.split("\n")) {
            if (line.startsWith("event: ")) type = line.slice(7);
            else if (line.startsWith("data: ")) data += line.slice(6);
          }
          if (data) await handle(type, JSON.parse(data));
        }
      }
    } finally {
      clearTimeout(watchdog);
      outerSignal?.removeEventListener("abort", abort);
      controller.abort();
    }
  }
}

function parseJson(text) {
  try {
    return JSON.parse(text);
  } catch {
    return { message: text };
  }
}

function sleep(ms, signal) {
  return new Promise((resolve) => {
    const timer = setTimeout(resolve, ms);
    signal?.addEventListener("abort", () => (clearTimeout(timer), resolve()), { once: true });
  });
}

/* --- Example: a player's web app ------------------------------------------------------------

const qk = new QuestkeeperPlayer({ baseUrl: "https://questkeeper-prod.peter-esser.de", apiKey });

const [character] = await qk.characters();
const campaignId = character.campaignId;
const hp = statDefinitions((await qk.config(campaignId)).config).find((s) => s.valueType === "intWithMaxValue");
let { revision, sheet } = await qk.sheet(character.id);

const stop = new AbortController(); // stop.abort() when the page closes
qk.listen({
  campaignId,
  signal: stop.signal,
  onConnected: async () => {
    // Catch up on what happened while we were away.
    ({ revision, sheet } = await qk.sheet(character.id));
    const fight = await qk.fight(campaignId);
    const pending = fight?.participants.filter((p) => p.isPending) ?? [];
    if (pending.length > 0) showInitiativeDialog(pending);
  },
  onEvent: async (type, data) => {
    if (type === "characterConfigChanged" && data.id === character.id && data.revision > revision) {
      ({ revision, sheet } = await qk.sheet(character.id)); // e.g. the DM changed our hit points
    }
    if (type === "initiativeRequested") showInitiativeDialog(data.participants);
    if (type === "fightEnded") closeInitiativeDialog();
  },
  onError: (error) => console.warn("Questkeeper:", error),
});

// The player taps "-" on their hit points (sent once they stop tapping):
({ revision } = await qk.setStatSoon(character.id, hp.statUuid, { value: 11, maxValue: 20 }));

// A note only the DM can read:
const dm = (await qk.members(campaignId)).find((m) => m.isDm);
const doc = await qk.createDocument(campaignId, { title: "Secrets", groupName: character.name });
await qk.addTextBlock(doc.id, "I pocketed the **crown**.", [dm.userId]);

// The player rolled 17 for their character and 9 for their wolf:
await qk.roll(campaignId, [
  { characterUuid: sheet.uuid, roll: 17 },
  { characterUuid: sheet.companionCharacters[0].uuid, roll: 9 },
]);

// Rename the character, safe against concurrent changes:
await qk.changeSheet(character.id, () => [{ op: "replace", path: "/characterName", value: "Aria the Bold" }]);

------------------------------------------------------------------------------------------------ */
