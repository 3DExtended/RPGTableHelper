# Character Screen Configuration

The DM should be able to configure the Character Screen.

First, they have to be asked which tabs a player CAN have
    For each tab we need the following information:
        - Name of Tab
        - Is tab optional

    We suggest the following tab structure to start:
        - Background
        - Stats
        - Features
        - Attacks
        - Spells
        - (Pets)

Then, we go through each tab and allow the configuration.
-> Background
    - A background consists out of multiple multiline text blocks with headline the user can enter, the DM should be able to specify a placerholder text
-> Stats
    - HP

- BLOCKS
  - multiline text blocks with headline and placeholder (e.g.:"Herkunft")
  - Integer Number with maxiumum Value and Name ("HP")
    Is this changed regularly?
  - Integer Number with Name ("AC")
    Is this changed regularly?

## Development

WILO:

For every `CharacterStatValueType` we need the following tests:

- 1. The dm configuration view
- 2. The player configuration view
- 3. The player view in the player characters page
  - There might be multiple options for each CharacterStatValueType how they are displayed and the user could change in between them. If so, we need a map to a list of all the options and in the tests we need multiple options.
