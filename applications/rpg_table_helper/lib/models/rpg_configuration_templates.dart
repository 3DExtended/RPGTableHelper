import 'dart:convert';

import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// The templates a game master picks from when a new campaign is set up.
enum RpgConfigurationTemplateId { empty, fantasySrd, narrative }

/// Ready-made campaign configurations. The property names and helper texts
/// are German, like the Fantasy 5E (SRD) template.
///
/// Every template is built fresh with fixed uuids, so the same template
/// always gives the same configuration: that is how the setup assistant
/// tells whether the game master changed something since picking it.
class RpgConfigurationTemplates {
  /// In the order the setup assistant shows them.
  static const ids = [
    RpgConfigurationTemplateId.empty,
    RpgConfigurationTemplateId.fantasySrd,
    RpgConfigurationTemplateId.narrative,
  ];

  /// What a new campaign starts with before a template is picked.
  static const defaultId = RpgConfigurationTemplateId.fantasySrd;

  static RpgConfigurationModel build(RpgConfigurationTemplateId id) =>
      switch (id) {
        RpgConfigurationTemplateId.empty => empty(),
        RpgConfigurationTemplateId.fantasySrd => fantasySrd(),
        RpgConfigurationTemplateId.narrative => narrative(),
      };

  /// [id] for the campaign [current]: everything from the template, the
  /// campaign's name and sheet skin kept.
  static RpgConfigurationModel applyTo(
    RpgConfigurationTemplateId id,
    RpgConfigurationModel current,
  ) => build(id)
      .copyWith(rpgName: current.rpgName, defaultSkinId: current.defaultSkinId);

  /// [config] as JSON without the parts a template does not set (name and
  /// sheet skin), to compare configurations.
  static String comparableJson(RpgConfigurationModel config) =>
      jsonEncode(config.copyWith(rpgName: '', defaultSkinId: null));

  /// The template [config] equals (name and sheet skin aside), or null when
  /// it matches none, e.g. because the game master changed something.
  static RpgConfigurationTemplateId? matchingTemplateOf(
    RpgConfigurationModel config,
  ) {
    final json = comparableJson(config);
    for (final id in ids) {
      if (comparableJson(build(id)) == json) return id;
    }
    return null;
  }

  /// "Fantasy 5E (SRD)": the configuration new campaigns got before the
  /// template choice, the SRD template without its items and recipes.
  static RpgConfigurationModel fantasySrd() =>
      RpgConfigurationModel.getBaseConfiguration().copyWith(
        allItems: [],
        // The template's recipes use its items; without them they are empty.
        craftingRecipes: [],
      );

  /// "Leer": one sheet tab with the character's name, level and a free
  /// description, one currency, nothing else.
  static RpgConfigurationModel empty() => RpgConfigurationModel(
    rpgName: "Leer",
    // The app shows amounts in the first currency, so one is needed.
    currencyDefinition: _coinsOnly(),
    placesOfFindings: [],
    itemCategories: [],
    allItems: [],
    craftingRecipes: [],
    characterStatTabsDefinition: [
      CharacterStatsTabDefinition(
        uuid: "b9e60f17-4618-4c69-935a-15b69d34d94e",
        tabName: "Charakter",
        isOptional: false,
        isDefaultTab: true,
        statsInTab: [
          _stat(
            uuid: "a6b3031a-e9c1-42a9-adff-ef5bc9fc4c8e",
            name: "Grundwerte",
            type: CharacterStatValueType
                .characterNameWithLevelAndAdditionalDetails,
            additionalData: jsonEncode({"values": []}),
          ),
          _stat(
            uuid: "667aaa95-fee5-4237-81b1-42b79f99a60b",
            name: "Beschreibung",
            helperText:
                "Wer ist dein Charakter? Wie sieht er aus, woher kommt er, "
                "was treibt ihn an?",
            type: CharacterStatValueType.multiLineText,
            additionalData: _example(
              "Mira, 34, Schmugglerin aus dem Hafenviertel. Trägt immer den "
              "Ring ihrer Mutter und will die Schulden der Familie tilgen.",
            ),
          ),
        ],
      ),
    ],
  );

  /// "Erzählerisch (Aspekte & Stress)": short sentences describe the
  /// character, a row of boxes takes hits, lasting consequences follow.
  /// All texts are written for this app; no level, no items.
  static RpgConfigurationModel narrative() => RpgConfigurationModel(
    rpgName: "Erzählerisch (Aspekte & Stress)",
    currencyDefinition: _coinsOnly(),
    placesOfFindings: [],
    itemCategories: [],
    allItems: [],
    craftingRecipes: [],
    characterStatTabsDefinition: [
      CharacterStatsTabDefinition(
        uuid: "3027ce8d-4628-469e-97e9-7aa99bae990b",
        tabName: "Charakter",
        isOptional: false,
        isDefaultTab: true,
        statsInTab: [
          _stat(
            uuid: "629c983f-3f13-4150-9442-b0e86d6ce54e",
            name: "Grundwerte",
            type: CharacterStatValueType
                .characterNameWithLevelAndAdditionalDetails,
            additionalData: jsonEncode({"values": [], "showLevel": false}),
          ),
          _stat(
            uuid: "ae8ebe43-6fe4-4acc-aaaa-225888916c61",
            name: "Porträt",
            helperText: "Erstelle ein Bild von deinem Charakter.",
            type: CharacterStatValueType.singleImage,
            additionalData: _example(
              "Junge Frau mit wildem Lockenkopf und abgewetzter Lederjacke, "
              "lacht verschmitzt.",
            ),
          ),
          _stat(
            uuid: "7ecd3603-7c86-4717-bd99-bb6974355b13",
            name: "Aspekte",
            helperText:
                "Kurze Sätze, die deinen Charakter ausmachen. Der Hauptaspekt "
                "sagt, wer er ist, das Dilemma, was ihm immer wieder Ärger "
                "macht. Weitere Aspekte kannst du selbst ergänzen.",
            type: CharacterStatValueType.textList,
            additionalData: const TextListConfig(
              slots: [
                TextListSlot(
                  uuid: "3050573c-5409-48fb-ac5d-4ba4f19ad679",
                  label: "Hauptaspekt",
                ),
                TextListSlot(
                  uuid: "8b60b1b8-6609-4875-babf-13e76fa586be",
                  label: "Dilemma",
                ),
              ],
              allowCustomEntries: true,
            ).toAdditionalData(),
          ),
          _stat(
            uuid: "63eb8d94-d582-4460-a703-25597bc4d2d7",
            name: "Erzählpunkte",
            helperText:
                "Damit setzt du Aspekte ein oder nimmst Einfluss auf die "
                "Geschichte.",
            type: CharacterStatValueType.int,
          ),
          _stat(
            uuid: "de0ea003-373d-4ca8-b4ef-f45814ce62b2",
            name: "Erholung",
            helperText:
                "So viele Erzählpunkte hast du zu Beginn jeder Sitzung "
                "mindestens.",
            type: CharacterStatValueType.int,
          ),
          _stat(
            uuid: "5f7c6bed-5a71-4614-8556-1d65d426930a",
            name: "Stress",
            helperText:
                "Kreuze ein Kästchen an, wenn dein Charakter einen Treffer "
                "wegsteckt. Nach der Szene werden alle wieder frei.",
            type: CharacterStatValueType.checkboxTrack,
            editType: CharacterStatEditType.oneTap,
            additionalData: CheckboxTrackConfig(boxCount: 3).toAdditionalData(),
          ),
          _stat(
            uuid: "0ad9d2ec-60bd-4426-86ce-142cc5a5a29b",
            name: "Konsequenzen",
            helperText:
                "Folgen eines Treffers, die länger bleiben. Die Zahl sagt, "
                "wie viel vom Treffer die Konsequenz abfängt.",
            type: CharacterStatValueType.textList,
            additionalData: const TextListConfig(
              slots: [
                TextListSlot(
                  uuid: "7201cd7d-e3b2-41e4-ae31-d03793a84aac",
                  label: "Leicht (2)",
                ),
                TextListSlot(
                  uuid: "119ce829-d842-41e4-b60f-e20c06512476",
                  label: "Mittel (4)",
                ),
                TextListSlot(
                  uuid: "1eb3fbe2-85e8-4ee1-b969-1cc4033a27e8",
                  label: "Schwer (6)",
                ),
              ],
              allowCustomEntries: false,
            ).toAdditionalData(),
          ),
        ],
      ),
      CharacterStatsTabDefinition(
        uuid: "14d41dba-f329-4faa-9e9f-1bb45d2131f4",
        tabName: "Fertigkeiten",
        isOptional: false,
        isDefaultTab: false,
        statsInTab: [
          _stat(
            uuid: "87aa9951-499a-45d7-bc27-35a44f667066",
            name: "Fertigkeiten",
            helperText:
                "Trag bei jedem Wert ein, welche Fertigkeiten dein Charakter "
                "so gut kann, z. B. „Klettern, Feilschen“. Bei einer Probe "
                "zählt der Wert zum Wurf dazu.",
            type: CharacterStatValueType.textList,
            additionalData: const TextListConfig(
              slots: [
                TextListSlot(
                  uuid: "231c98a6-cd4d-4ddf-9179-2488e12dbb1b",
                  label: "+4",
                ),
                TextListSlot(
                  uuid: "324aa3c4-9fb7-40dd-8d25-63e0c7deb318",
                  label: "+3",
                ),
                TextListSlot(
                  uuid: "8191a508-15c8-4fc8-a14c-11cba7a599ba",
                  label: "+2",
                ),
                TextListSlot(
                  uuid: "87261fde-72a7-41fa-b31d-b9c78fe87a84",
                  label: "+1",
                ),
              ],
              allowCustomEntries: false,
            ).toAdditionalData(),
          ),
          _stat(
            uuid: "0896462e-2a2c-4905-b763-0e91e8c33ad6",
            name: "Stunts",
            helperText:
                "Besondere Kniffe deines Charakters. Beschreib jeden in einem "
                "Satz: was er kann und wann das gilt.",
            type: CharacterStatValueType.textList,
            additionalData: const TextListConfig(
              slots: [],
              allowCustomEntries: true,
            ).toAdditionalData(),
          ),
        ],
      ),
    ],
  );

  /// Values the "So sieht es der Spieler" preview shows for properties of
  /// the templates where the generic sample (e.g. 17 for every number) would
  /// not fit, by property uuid. Properties the game master added keep the
  /// generic sample.
  static Map<String, String> sampleValues() => {
    // Erzählerisch: Aspekte, Erzählpunkte, Erholung, Stress, Konsequenzen
    "7ecd3603-7c86-4717-bd99-bb6974355b13": jsonEncode({
      "values": [
        {
          "uuid": "3050573c-5409-48fb-ac5d-4ba4f19ad679",
          "value": "Ehemalige Schmugglerin mit Gewissen",
        },
        {
          "uuid": "8b60b1b8-6609-4875-babf-13e76fa586be",
          "value": "Alte Schulden bei der Hafengilde",
        },
      ],
    }),
    "63eb8d94-d582-4460-a703-25597bc4d2d7": '{"value": 3}',
    "de0ea003-373d-4ca8-b4ef-f45814ce62b2": '{"value": 3}',
    "5f7c6bed-5a71-4614-8556-1d65d426930a": '{"checked": [0]}',
    "0ad9d2ec-60bd-4426-86ce-142cc5a5a29b": jsonEncode({
      "values": [
        {
          "uuid": "7201cd7d-e3b2-41e4-ae31-d03793a84aac",
          "value": "Verstauchter Knöchel",
        },
      ],
    }),
    // Erzählerisch: Fertigkeiten, Stunts
    "87aa9951-499a-45d7-bc27-35a44f667066": jsonEncode({
      "values": [
        {"uuid": "231c98a6-cd4d-4ddf-9179-2488e12dbb1b", "value": "Heimlichkeit"},
        {
          "uuid": "324aa3c4-9fb7-40dd-8d25-63e0c7deb318",
          "value": "Feilschen, Klettern",
        },
        {
          "uuid": "8191a508-15c8-4fc8-a14c-11cba7a599ba",
          "value": "Wahrnehmung, Kontakte",
        },
        {
          "uuid": "87261fde-72a7-41fa-b31d-b9c78fe87a84",
          "value": "Fechten, Wissen, Schwimmen",
        },
      ],
    }),
    "0896462e-2a2c-4905-b763-0e91e8c33ad6": jsonEncode({
      "values": [
        {
          "uuid": "d877f7e6-861f-4f26-ade1-4fb4bf121a91",
          "value": "Schattenläuferin: +2 auf Heimlichkeit, wenn es dunkel ist.",
        },
      ],
    }),
  };

  static CurrencyDefinition _coinsOnly() => CurrencyDefinition(
    currencyTypes: [
      CurrencyType(name: "Münzen", multipleOfPreviousValue: null),
    ],
  );

  /// Additional data with the example answer the character form shows.
  static String _example(String text) => jsonEncode({"example": text});

  static CharacterStatDefinition _stat({
    required String uuid,
    required String name,
    required CharacterStatValueType type,
    String helperText = "",
    CharacterStatEditType editType = CharacterStatEditType.static,
    String? additionalData,
  }) => CharacterStatDefinition(
    statUuid: uuid,
    name: name,
    helperText: helperText,
    groupId: null,
    valueType: type,
    editType: editType,
    isOptionalForAlternateForms: false,
    isOptionalForCompanionCharacters: false,
    jsonSerializedAdditionalData: additionalData,
  );
}
