import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_stats/narrative_stat_types.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// JSON formats of the stat types checkboxTrack, textList and singleSelect,
/// the "show level" switch, and how unknown (future) types load.
void main() {
  CharacterStatDefinition stat(
    CharacterStatValueType type, {
    String? additionalData,
  }) => CharacterStatDefinition(
    statUuid: "stat-${type.name}",
    name: type.name,
    groupId: null,
    helperText: "help",
    valueType: type,
    editType: CharacterStatEditType.oneTap,
    isOptionalForAlternateForms: false,
    isOptionalForCompanionCharacters: false,
    jsonSerializedAdditionalData: additionalData,
  );

  /// Encodes like the app (jsonEncode of the whole configuration) and back.
  CharacterStatDefinition roundTrip(CharacterStatDefinition definition) =>
      CharacterStatDefinition.fromJson(
        jsonDecode(jsonEncode(definition.toJson())) as Map<String, dynamic>,
      );

  group('checkboxTrack', () {
    test('definition and value survive a JSON round trip', () {
      final config = CheckboxTrackConfig(
        boxCount: 4,
        labels: const ["1", "2", "3", "Leicht"],
      );
      final definition = stat(
        CharacterStatValueType.checkboxTrack,
        additionalData: config.toAdditionalData(),
      );

      final loaded = roundTrip(definition);
      expect(loaded.valueType, CharacterStatValueType.checkboxTrack);
      expect(definition.toJson()['valueType'], 'checkboxTrack');
      expect(jsonDecode(loaded.jsonSerializedAdditionalData!), {
        "boxCount": 4,
        "labels": ["1", "2", "3", "Leicht"],
      });
      final loadedConfig = CheckboxTrackConfig.of(loaded);
      expect(loadedConfig.boxCount, 4);
      expect(loadedConfig.labels, ["1", "2", "3", "Leicht"]);

      final value = serializeCheckedBoxes({2, 0});
      expect(jsonDecode(value), {
        "checked": [0, 2],
      });
      expect(checkedBoxesOf(value), {0, 2});
    });

    test('box count is kept within 1-20, labels are optional', () {
      expect(CheckboxTrackConfig(boxCount: 0).boxCount, 1);
      expect(CheckboxTrackConfig(boxCount: 99).boxCount, 20);
      final unlabelled = CheckboxTrackConfig(boxCount: 3);
      expect(unlabelled.labels, ["", "", ""]);
      expect(jsonDecode(unlabelled.toAdditionalData()), {"boxCount": 3});
      expect(
        CheckboxTrackConfig.fromAdditionalData(null).boxCount,
        CheckboxTrackConfig.defaultBoxCount,
      );
    });

    test('toggling ticks and frees a box and drops boxes past the end', () {
      var value = toggleCheckboxTrackBox(
        serializedValue: null,
        index: 1,
        boxCount: 3,
      );
      expect(checkedBoxesOf(value), {1});
      value = toggleCheckboxTrackBox(
        serializedValue: value,
        index: 1,
        boxCount: 3,
      );
      expect(checkedBoxesOf(value), isEmpty);

      // The DM shortened the track from 5 to 3 boxes.
      value = toggleCheckboxTrackBox(
        serializedValue: '{"checked": [0, 4]}',
        index: 2,
        boxCount: 3,
      );
      expect(checkedBoxesOf(value), {0, 2});
    });
  });

  group('textList', () {
    const config = TextListConfig(
      slots: [
        TextListSlot(uuid: "slot-concept", label: "Hauptaspekt"),
        TextListSlot(uuid: "slot-trouble", label: "Dilemma"),
      ],
      allowCustomEntries: true,
    );

    test('definition and value survive a JSON round trip', () {
      final loaded = roundTrip(
        stat(
          CharacterStatValueType.textList,
          additionalData: config.toAdditionalData(),
        ),
      );
      expect(loaded.valueType, CharacterStatValueType.textList);
      expect(jsonDecode(loaded.jsonSerializedAdditionalData!), {
        "slots": [
          {"uuid": "slot-concept", "label": "Hauptaspekt"},
          {"uuid": "slot-trouble", "label": "Dilemma"},
        ],
        "allowCustomEntries": true,
      });
      final loadedConfig = TextListConfig.of(loaded);
      expect(loadedConfig.slots.map((s) => s.label), [
        "Hauptaspekt",
        "Dilemma",
      ]);
      expect(loadedConfig.allowCustomEntries, isTrue);

      final value = serializeTextListEntries(const [
        TextListEntry(uuid: "slot-concept", value: "Fahrende Ritterin"),
        TextListEntry(uuid: "own-1", value: "Schuldet der Gilde Geld"),
      ]);
      expect(jsonDecode(value), {
        "values": [
          {"uuid": "slot-concept", "value": "Fahrende Ritterin"},
          {"uuid": "own-1", "value": "Schuldet der Gilde Geld"},
        ],
      });
      expect(textListEntriesOf(value).map((e) => e.uuid), [
        "slot-concept",
        "own-1",
      ]);
    });

    test('rows list the slots first, then own entries if allowed', () {
      final entries = textListEntriesOf(
        '{"values": [{"uuid": "own-1", "value": "Eigener"}, '
        '{"uuid": "slot-trouble", "value": "Jähzornig"}]}',
      );
      final rows = textListRowsOf(config, entries);
      expect(rows.map((r) => r.uuid), [
        "slot-concept",
        "slot-trouble",
        "own-1",
      ]);
      expect(rows[0].value, "");
      expect(rows[1].value, "Jähzornig");
      expect(rows[2].isSlot, isFalse);

      final noOwn = textListRowsOf(
        const TextListConfig(slots: [], allowCustomEntries: false),
        entries,
      );
      expect(noOwn, isEmpty);
    });

    test('entries can be set, added and removed', () {
      var value = setTextListEntry(
        serializedValue: null,
        uuid: "slot-concept",
        value: "A",
      );
      value = setTextListEntry(serializedValue: value, uuid: "own", value: "B");
      value = setTextListEntry(
        serializedValue: value,
        uuid: "slot-concept",
        value: "A2",
      );
      expect(textListEntriesOf(value).map((e) => "${e.uuid}=${e.value}"), [
        "slot-concept=A2",
        "own=B",
      ]);
      value = removeTextListEntry(serializedValue: value, uuid: "own");
      expect(textListEntriesOf(value).map((e) => e.uuid), ["slot-concept"]);
    });
  });

  group('singleSelect', () {
    const additionalData =
        '{"options": [{"uuid": "o1", "label": "Adel", "description": "Von Stand"}, '
        '{"uuid": "o2", "label": "Gosse", "description": "", "summary": "Kurz"}]}';

    test('definition and value survive a JSON round trip', () {
      final loaded = roundTrip(
        stat(
          CharacterStatValueType.singleSelect,
          additionalData: additionalData,
        ),
      );
      expect(loaded.valueType, CharacterStatValueType.singleSelect);
      expect(loaded.jsonSerializedAdditionalData, additionalData);
      final options = selectOptionsOf(loaded);
      expect(options.map((o) => o.label), ["Adel", "Gosse"]);
      expect(options[1].summary, "Kurz");

      final value = serializeSingleSelect("o2");
      expect(jsonDecode(value), {"value": "o2"});
      expect(selectedOptionUuidOf(value), "o2");
      expect(jsonDecode(serializeSingleSelect(null)), {"value": null});
      expect(selectedOptionUuidOf(serializeSingleSelect(null)), isNull);
    });
  });

  group('show level', () {
    CharacterStatDefinition summary(String? additionalData) => stat(
      CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
      additionalData: additionalData,
    );

    test('is on unless the configuration says "showLevel": false', () {
      expect(characterSummaryShowsLevel(summary(null)), isTrue);
      expect(
        characterSummaryShowsLevel(summary('{"values": []}')),
        isTrue,
        reason: 'campaigns from before the switch keep their level',
      );
      expect(
        characterSummaryShowsLevel(
          summary('{"values": [], "showLevel": true}'),
        ),
        isTrue,
      );
      expect(
        characterSummaryShowsLevel(
          summary('{"values": [], "showLevel": false}'),
        ),
        isFalse,
      );
    });
  });

  group('unknown types from a newer app version', () {
    Map<String, dynamic> definitionJson(String valueType) => {
      "name": "Neues Ding",
      "statUuid": "future-stat",
      "helperText": "",
      "groupId": null,
      "valueType": valueType,
      "editType": "static",
      "isOptionalForAlternateForms": false,
      "isOptionalForCompanionCharacters": false,
      "jsonSerializedAdditionalData": '{"some": "config"}',
    };

    test('load as unsupported and keep their type name when saved', () {
      final loaded = CharacterStatDefinition.fromJson(definitionJson("hexMap"));
      expect(loaded.valueType, CharacterStatValueType.unsupported);
      expect(loaded.unsupportedValueTypeName, "hexMap");

      final saved = loaded.toJson();
      expect(saved["valueType"], "hexMap");
      expect(saved["jsonSerializedAdditionalData"], '{"some": "config"}');
      expect(saved.containsKey("unsupportedValueTypeName"), isFalse);
    });

    test('do not break loading the whole configuration', () {
      final base = RpgConfigurationModel.getBaseConfiguration();
      final json =
          jsonDecode(jsonEncode(base.toJson())) as Map<String, dynamic>;
      final tabs = json["characterStatTabsDefinition"] as List<dynamic>;
      (tabs.first["statsInTab"] as List<dynamic>).add(definitionJson("hexMap"));

      final loaded = RpgConfigurationModel.fromJson(json);
      final stats = loaded.characterStatTabsDefinition!.first.statsInTab;
      expect(stats.last.valueType, CharacterStatValueType.unsupported);

      // Saving again writes the original type back.
      final again = jsonDecode(jsonEncode(loaded.toJson()));
      expect(
        (again["characterStatTabsDefinition"][0]["statsInTab"] as List)
            .last["valueType"],
        "hexMap",
      );
    });

    test('known types are unchanged', () {
      final definition = stat(CharacterStatValueType.intWithMaxValue);
      expect(definition.toJson()["valueType"], "intWithMaxValue");
      expect(roundTrip(definition).unsupportedValueTypeName, isNull);
    });
  });
}
