# [slice] init-02 — Initiative popup helper sentence

## Metadata

- Forge: local (TBD)
- Type: AFK
- Status: ready

## Parent

PRD: `docs/prd/fight-initiative-bonus-config.md`

## What to build

Wire the resolve helper into the initiative ask flow. When a player (main character, companion, or alternate form) is prompted, resolve against **that** entity’s stats and show a localized helper sentence in the existing modal when a bonus is present; hide the line when resolve returns null. Players still type and submit the final integer; no prefill, no auto-roll, no SSE/DTO changes.

With the base-preset prefill from init-01, new campaigns show the DEX/Geschicklichkeit hint without any wizard work yet.

Demoable: ask for initiative with a character that has the marked mod → modal shows `Add {label} {formatted} to your roll`; companion without that stat → no hint; Send still returns an int.

## Acceptance criteria

- [ ] Modal shows localized helper sentence when resolve succeeds
- [ ] Modal omits the hint when resolve is null; Send still works
- [ ] Main character, companion, and alternate-form prompts each resolve against their own stats
- [ ] Roll field is not prefilled; submitted value remains a manual `int?`
- [ ] No fight-sequence DTO / SSE payload changes
- [ ] EN + DE strings for the sentence template
- [ ] Widget/service tests cover hint present, hint absent, and submit path

## Blocked by

- init-01

## User stories covered

- 1, 3, 4, 5, 6, 7, 21 (sentence), 23
