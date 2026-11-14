/// Which number of a stat value is meant.
///
/// - `value`: the main number (`{"value": 17}`, also of list entries)
/// - `otherValue`: the second, "calculated" number of
///   `intWithCalculatedValue` / `listOfIntWithCalculatedValues`
/// - `maxValue`: the maximum of `intWithMaxValue`
/// - `level`: the level of `characterNameWithLevelAndAdditionalDetails`
enum StatNumberField { value, otherValue, maxValue, level }

/// Points at one number of a character stat: the stat, for list stats the
/// entry inside it, and which of its numbers. Used by the DM's card choice
/// and by computed stats.
class StatNumberRef {
  final String statUuid;
  final String? entryUuid;
  final StatNumberField field;

  const StatNumberRef({
    required this.statUuid,
    this.entryUuid,
    this.field = StatNumberField.value,
  });

  /// Stable string form, used for storage and equality.
  String get key => "$statUuid|${entryUuid ?? ""}|${field.name}";

  static StatNumberRef? fromKey(String key) {
    var parts = key.split("|");
    if (parts.length != 3 || parts[0].isEmpty) return null;
    var field = StatNumberField.values
        .where((f) => f.name == parts[2])
        .firstOrNull;
    if (field == null) return null;
    return StatNumberRef(
      statUuid: parts[0],
      entryUuid: parts[1].isEmpty ? null : parts[1],
      field: field,
    );
  }

  @override
  bool operator ==(Object other) => other is StatNumberRef && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => "StatNumberRef($key)";
}
