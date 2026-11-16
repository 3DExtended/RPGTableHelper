import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// The D&D template new campaigns start from.
void main() {
  final config = RpgConfigurationModel.getBaseConfiguration();
  final tabs = config.characterStatTabsDefinition!;
  final allStats = tabs.expand((t) => t.statsInTab).toList();

  /// Every value a player types in: plain stats by name, plus the detail
  /// values inside the character summary (Klasse, Volk).
  List<String> askedValueNames() => [
    for (final stat in allStats)
      if (stat.valueType ==
          CharacterStatValueType.characterNameWithLevelAndAdditionalDetails)
        ...((jsonDecode(stat.jsonSerializedAdditionalData!)["values"]
                as List<dynamic>)
            .map((v) => (v as Map<String, dynamic>)["label"] as String))
      else if (stat.valueType == CharacterStatValueType.singleLineText ||
          stat.valueType == CharacterStatValueType.multiLineText)
        stat.name,
  ];

  test('Klasse and Volk are asked only once (in the character summary)', () {
    final names = askedValueNames();
    expect(names.where((n) => n == 'Klasse'), hasLength(1));
    expect(names.where((n) => n == 'Volk'), hasLength(1));

    final background = tabs.firstWhere((t) => t.tabName == 'Background');
    expect(
      background.statsInTab.map((s) => s.name),
      isNot(anyOf(contains('Klasse'), contains('Volk'))),
    );

    final summary = allStats.singleWhere(
      (s) =>
          s.valueType ==
          CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
    );
    expect(summary.jsonSerializedAdditionalData, contains('"Klasse"'));
    expect(summary.jsonSerializedAdditionalData, contains('"Volk"'));
  });

  test('no typed-in text field is asked twice', () {
    final names = askedValueNames();
    final duplicates = names
        .where((n) => names.where((other) => other == n).length > 1)
        .toSet();
    // "Aussehen" exists twice on purpose: a text on Background and the
    // portrait image on Stats (the image is not part of this list).
    expect(duplicates, isEmpty);
  });

  test('stat uuids are unique', () {
    final uuids = allStats.map((s) => s.statUuid).toList();
    expect(uuids.toSet(), hasLength(uuids.length));
  });

  test('the template still round-trips through JSON', () {
    final decoded = RpgConfigurationModel.fromJson(
      jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>,
    );
    expect(
      decoded.characterStatTabsDefinition!.expand((t) => t.statsInTab),
      hasLength(allStats.length),
    );
  });
}
