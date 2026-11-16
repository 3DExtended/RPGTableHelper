import 'dart:convert';

import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/stat_number_ref.dart';

export 'package:quest_keeper/models/stat_number_ref.dart';

/// How a building block turns its source number into a summand.
enum ComputedTermMode {
  /// The number as it is.
  value,

  /// The 5E SRD ability modifier: ⌊(x − 10) / 2⌋.
  modifier,
}

/// A block counts only when the character picked [optionUuid] in the
/// multiselect stat [statUuid]; picked twice (if allowed) counts twice,
/// e.g. expertise.
class ComputedTermCondition {
  final String statUuid;
  final String optionUuid;

  const ComputedTermCondition({
    required this.statUuid,
    required this.optionUuid,
  });

  Map<String, dynamic> toJson() => {
    "statUuid": statUuid,
    "optionUuid": optionUuid,
  };

  static ComputedTermCondition? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    var statUuid = json["statUuid"];
    var optionUuid = json["optionUuid"];
    if (statUuid is! String || optionUuid is! String) return null;
    return ComputedTermCondition(statUuid: statUuid, optionUuid: optionUuid);
  }

  @override
  bool operator ==(Object other) =>
      other is ComputedTermCondition &&
      other.statUuid == statUuid &&
      other.optionUuid == optionUuid;

  @override
  int get hashCode => Object.hash(statUuid, optionUuid);
}

/// One building block: `factor × mode(source)`, optionally only under a
/// [condition].
class ComputedStatTerm {
  final StatNumberRef source;
  final ComputedTermMode mode;
  final int factor;
  final ComputedTermCondition? condition;

  const ComputedStatTerm({
    required this.source,
    this.mode = ComputedTermMode.value,
    this.factor = 1,
    this.condition,
  });

  ComputedStatTerm copyWith({
    StatNumberRef? source,
    ComputedTermMode? mode,
    int? factor,
    ComputedTermCondition? Function()? condition,
  }) => ComputedStatTerm(
    source: source ?? this.source,
    mode: mode ?? this.mode,
    factor: factor ?? this.factor,
    condition: condition != null ? condition() : this.condition,
  );

  Map<String, dynamic> toJson() => {
    "source": source.key,
    "mode": mode.name,
    "factor": factor,
    if (condition != null) "condition": condition!.toJson(),
  };

  static ComputedStatTerm? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    var source = json["source"] is String
        ? StatNumberRef.fromKey(json["source"] as String)
        : null;
    if (source == null) return null;
    var mode =
        ComputedTermMode.values
            .where((m) => m.name == json["mode"])
            .firstOrNull ??
        ComputedTermMode.value;
    var factor = json["factor"] is int ? json["factor"] as int : 1;
    return ComputedStatTerm(
      source: source,
      mode: mode,
      factor: factor,
      condition: ComputedTermCondition.fromJson(json["condition"]),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ComputedStatTerm &&
      other.source == source &&
      other.mode == mode &&
      other.factor == factor &&
      other.condition == condition;

  @override
  int get hashCode => Object.hash(source, mode, factor, condition);
}

/// A computed property: `base + Σ terms`, e.g. passive Perception =
/// 10 + modifier(Wisdom) + proficiency bonus (if trained in Perception).
///
/// Stored inside an `int` stat's `jsonSerializedAdditionalData` under
/// [jsonKey], so app versions without this feature still read the stat as
/// a plain number (the value the player's app last wrote) instead of
/// failing on an unknown stat type.
class ComputedStatFormula {
  static const jsonKey = "computed";

  final int base;
  final List<ComputedStatTerm> terms;

  const ComputedStatFormula({this.base = 0, this.terms = const []});

  ComputedStatFormula copyWith({int? base, List<ComputedStatTerm>? terms}) =>
      ComputedStatFormula(base: base ?? this.base, terms: terms ?? this.terms);

  Map<String, dynamic> toJson() => {
    "base": base,
    "terms": terms.map((t) => t.toJson()).toList(),
  };

  static ComputedStatFormula? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    var terms = json["terms"];
    return ComputedStatFormula(
      base: json["base"] is int ? json["base"] as int : 0,
      terms: terms is List
          ? terms
                .map(ComputedStatTerm.fromJson)
                .whereType<ComputedStatTerm>()
                .toList()
          : const [],
    );
  }

  /// The formula of [stat], or `null` if it is not a computed stat.
  static ComputedStatFormula? of(CharacterStatDefinition stat) {
    if (stat.valueType != CharacterStatValueType.int) return null;
    var raw = stat.jsonSerializedAdditionalData;
    if (raw == null || raw.isEmpty) return null;
    try {
      var decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return fromJson(decoded[jsonKey]);
    } catch (_) {
      return null;
    }
  }

  /// `jsonSerializedAdditionalData` for an `int` stat with this formula.
  String toAdditionalData() => jsonEncode({jsonKey: toJson()});

  @override
  bool operator ==(Object other) =>
      other is ComputedStatFormula &&
      other.base == base &&
      other.terms.length == terms.length &&
      Iterable.generate(terms.length).every((i) => other.terms[i] == terms[i]);

  @override
  int get hashCode => Object.hash(base, Object.hashAll(terms));
}
