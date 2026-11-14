/// Which number of a stat value a card shows.
///
/// `value` is the main number (`{"value": 17}`), `otherValue` is the second,
/// "calculated" number of `intWithCalculatedValue` and
/// `listOfIntWithCalculatedValues` (`{"value": 16, "otherValue": 3}`).
enum DmCardStatField { value, otherValue }

/// Points at one number of a character stat: the stat, for list stats the
/// entry inside it, and which of its numbers.
class DmCardStatRef {
  final String statUuid;
  final String? entryUuid;
  final DmCardStatField field;

  const DmCardStatRef({
    required this.statUuid,
    this.entryUuid,
    this.field = DmCardStatField.value,
  });

  /// Stable string form, used for storage and equality.
  String get key => "$statUuid|${entryUuid ?? ""}|${field.name}";

  static DmCardStatRef? fromKey(String key) {
    var parts = key.split("|");
    if (parts.length != 3 || parts[0].isEmpty) return null;
    var field = DmCardStatField.values
        .where((f) => f.name == parts[2])
        .firstOrNull;
    if (field == null) return null;
    return DmCardStatRef(
      statUuid: parts[0],
      entryUuid: parts[1].isEmpty ? null : parts[1],
      field: field,
    );
  }

  @override
  bool operator ==(Object other) => other is DmCardStatRef && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => "DmCardStatRef($key)";
}

/// The DM's local choices for the character cards on the DM overview:
/// which cards are hidden and which stats a card shows.
///
/// Stored per campaign on the DM's device only (see
/// [IDmCharacterCardSettingsStore]); players never see it.
class DmCharacterCardSettings {
  /// Uuids of hidden characters. A player character is hidden by its own
  /// uuid (also while its alternate form is active), a companion by the
  /// companion's uuid. Kept across offline/online and app restarts.
  final Set<String> hiddenCharacterUuids;

  /// `false`: the card picks its stats automatically (first value with a
  /// maximum as bar, the first numbers of the default tab).
  /// `true`: [barStatUuid] and [numberStats] decide.
  final bool useCustomStats;

  /// The `intWithMaxValue` stat drawn as bar; `null` shows no bar.
  final String? barStatUuid;

  /// The numbers listed on the card, in this order.
  final List<DmCardStatRef> numberStats;

  /// A card has room for this many numbers.
  static const maxNumberStats = 8;

  const DmCharacterCardSettings({
    this.hiddenCharacterUuids = const {},
    this.useCustomStats = false,
    this.barStatUuid,
    this.numberStats = const [],
  });

  static const empty = DmCharacterCardSettings();

  DmCharacterCardSettings copyWith({
    Set<String>? hiddenCharacterUuids,
    bool? useCustomStats,
    String? Function()? barStatUuid,
    List<DmCardStatRef>? numberStats,
  }) {
    return DmCharacterCardSettings(
      hiddenCharacterUuids: hiddenCharacterUuids ?? this.hiddenCharacterUuids,
      useCustomStats: useCustomStats ?? this.useCustomStats,
      barStatUuid: barStatUuid != null ? barStatUuid() : this.barStatUuid,
      numberStats: numberStats ?? this.numberStats,
    );
  }

  bool isHidden(String characterUuid) =>
      hiddenCharacterUuids.contains(characterUuid);

  DmCharacterCardSettings withHidden(String characterUuid, bool hidden) {
    var updated = {...hiddenCharacterUuids};
    if (hidden) {
      updated.add(characterUuid);
    } else {
      updated.remove(characterUuid);
    }
    return copyWith(hiddenCharacterUuids: updated);
  }

  Map<String, dynamic> toJson() => {
    "hiddenCharacterUuids": hiddenCharacterUuids.toList()..sort(),
    "useCustomStats": useCustomStats,
    "barStatUuid": barStatUuid,
    "numberStats": numberStats.map((e) => e.key).toList(),
  };

  /// Lenient: unknown or broken parts fall back to the defaults, so a damaged
  /// entry never blocks the DM screen.
  factory DmCharacterCardSettings.fromJson(Map<String, dynamic> json) {
    var hidden = json["hiddenCharacterUuids"];
    var numbers = json["numberStats"];
    return DmCharacterCardSettings(
      hiddenCharacterUuids: hidden is List
          ? hidden.whereType<String>().toSet()
          : const <String>{},
      useCustomStats: json["useCustomStats"] == true,
      barStatUuid: json["barStatUuid"] is String
          ? json["barStatUuid"] as String
          : null,
      numberStats: numbers is List
          ? numbers
                .whereType<String>()
                .map(DmCardStatRef.fromKey)
                .whereType<DmCardStatRef>()
                .take(maxNumberStats)
                .toList()
          : const [],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DmCharacterCardSettings &&
      other.useCustomStats == useCustomStats &&
      other.barStatUuid == barStatUuid &&
      other.hiddenCharacterUuids.length == hiddenCharacterUuids.length &&
      other.hiddenCharacterUuids.containsAll(hiddenCharacterUuids) &&
      other.numberStats.length == numberStats.length &&
      Iterable.generate(numberStats.length)
          .every((i) => other.numberStats[i] == numberStats[i]);

  @override
  int get hashCode => Object.hash(
    useCustomStats,
    barStatUuid,
    Object.hashAllUnordered(hiddenCharacterUuids),
    Object.hashAll(numberStats),
  );
}
