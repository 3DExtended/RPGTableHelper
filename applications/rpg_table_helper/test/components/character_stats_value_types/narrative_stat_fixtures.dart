import 'dart:convert';

import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// Stats of a narrative template (stress track, aspects, origin) shared by the
/// sheet, form and DM tests of the checkboxTrack / textList / singleSelect
/// types.

CharacterStatDefinition narrativeStat({
  required String uuid,
  required String name,
  required CharacterStatValueType type,
  String? additionalData,
  CharacterStatEditType editType = CharacterStatEditType.oneTap,
}) => CharacterStatDefinition(
  statUuid: uuid,
  name: name,
  groupId: null,
  helperText: "",
  valueType: type,
  editType: editType,
  isOptionalForAlternateForms: false,
  isOptionalForCompanionCharacters: false,
  jsonSerializedAdditionalData: additionalData,
);

final stressTrack = narrativeStat(
  uuid: "stat-stress",
  name: "Stress",
  type: CharacterStatValueType.checkboxTrack,
  additionalData: CheckboxTrackConfig(
    boxCount: 4,
    labels: const ["1", "2", "3", "Ausgeschaltet"],
  ).toAdditionalData(),
);

final aspects = narrativeStat(
  uuid: "stat-aspects",
  name: "Aspekte",
  type: CharacterStatValueType.textList,
  editType: CharacterStatEditType.static,
  additionalData: const TextListConfig(
    slots: [
      TextListSlot(uuid: "slot-concept", label: "Hauptaspekt"),
      TextListSlot(uuid: "slot-trouble", label: "Dilemma"),
    ],
    allowCustomEntries: true,
  ).toAdditionalData(),
);

final origin = narrativeStat(
  uuid: "stat-origin",
  name: "Herkunft",
  type: CharacterStatValueType.singleSelect,
  editType: CharacterStatEditType.static,
  additionalData: jsonEncode({
    "options": [
      {
        "uuid": "opt-noble",
        "label": "Adel",
        "description": "Aus gutem Hause, mit Pflichten gegenüber der Familie.",
      },
      {
        "uuid": "opt-street",
        "label": "Gosse",
        "description": "Auf der Straße aufgewachsen, kennt jede Abkürzung.",
      },
    ],
  }),
);

CharacterStatDefinition characterSummary({required bool showLevel}) =>
    narrativeStat(
      uuid: "stat-summary",
      name: "Zusammenfassung",
      type: CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
      editType: CharacterStatEditType.static,
      additionalData: jsonEncode({
        "values": [
          {"uuid": "detail-role", "label": "Rolle"},
          {"uuid": "detail-folk", "label": "Volk"},
        ],
        if (!showLevel) "showLevel": false,
      }),
    );

/// A stat type of a newer app version this version does not know.
final futureStat = CharacterStatDefinition.fromJson({
  "name": "Hexkarte",
  "statUuid": "stat-future",
  "helperText": "",
  "groupId": null,
  "valueType": "hexMap",
  "editType": "static",
  "isOptionalForAlternateForms": false,
  "isOptionalForCompanionCharacters": false,
  "jsonSerializedAdditionalData": '{"size": 7}',
});

const storyTabUuid = "tab-story";

RpgConfigurationModel configWithStoryTab(List<CharacterStatDefinition> stats) =>
    RpgConfigurationModel.getBaseConfiguration().copyWith(
      characterStatTabsDefinition: [
        CharacterStatsTabDefinition(
          uuid: storyTabUuid,
          tabName: "Erzählung",
          isOptional: false,
          isDefaultTab: true,
          statsInTab: stats,
        ),
      ],
    );

RpgCharacterStatValue statValue(
  String statUuid,
  String serializedValue, {
  int variant = 0,
}) => RpgCharacterStatValue(
  statUuid: statUuid,
  serializedValue: serializedValue,
  variant: variant,
  hideFromCharacterScreen: false,
  hideLabelOfStat: false,
);

/// `{"level": 13, ...}` so a shown level is easy to find on the sheet.
const summaryLevel = 13;

RpgCharacterStatValue summaryValue({int variant = 0}) => statValue(
  "stat-summary",
  jsonEncode({
    "level": summaryLevel,
    "values": [
      {"uuid": "detail-role", "value": "Fahrende Ritterin"},
      {"uuid": "detail-folk", "value": "Mensch"},
    ],
  }),
  variant: variant,
);

RpgCharacterConfiguration characterWith(List<RpgCharacterStatValue> stats) =>
    RpgCharacterConfiguration.getBaseConfiguration(null)
        .copyWith(characterName: "Mira Dornwald", characterStats: stats);
