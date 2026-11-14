import 'package:quest_keeper/models/stat_number_ref.dart';

export 'package:quest_keeper/models/stat_number_ref.dart';

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
  final List<StatNumberRef> numberStats;

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
    List<StatNumberRef>? numberStats,
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
                .map(StatNumberRef.fromKey)
                .whereType<StatNumberRef>()
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
