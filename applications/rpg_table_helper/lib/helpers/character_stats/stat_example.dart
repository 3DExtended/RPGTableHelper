import 'dart:convert';

import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// Field types with an example answer: the character form shows it in the
/// empty field ("z. B. …") so players see what kind of answer fits.
const statTypesWithExample = {
  CharacterStatValueType.singleLineText,
  CharacterStatValueType.multiLineText,
  CharacterStatValueType.singleImage,
};

/// Key of the example in the property's additional data. Older app versions
/// ignore it.
const statExampleKey = 'example';

/// The example answer of [stat], or null.
String? statExampleOf(CharacterStatDefinition stat) {
  if (!statTypesWithExample.contains(stat.valueType)) return null;
  final json = stat.jsonSerializedAdditionalData;
  if (json == null || json.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(json);
    if (decoded is! Map) return null;
    final example = decoded[statExampleKey];
    return example is String && example.trim().isNotEmpty
        ? example.trim()
        : null;
  } catch (_) {
    return null;
  }
}

/// Additional data holding [example] (none when empty).
String? statExampleAdditionalData(String example) =>
    example.trim().isEmpty ? null : jsonEncode({statExampleKey: example.trim()});
