import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

// JSON helpers for the stat types checkboxTrack, textList and singleSelect,
// and for the "show level" switch of the character summary. The formats are
// documented next to CharacterStatValueType. Every reader is lenient: broken
// or missing data yields an empty value instead of an exception, so a sheet
// never fails to render because of one stat.

Map<String, dynamic> _decodeMap(String? raw) {
  if (raw == null || raw.trim().isEmpty) return {};
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : {};
  } catch (_) {
    return {};
  }
}

// --- checkboxTrack ----------------------------------------------------------

/// Configuration of a [CharacterStatValueType.checkboxTrack] stat:
/// `{"boxCount": 3, "labels": ["1", "2", "3"]}`.
class CheckboxTrackConfig {
  static const int minBoxes = 1;
  static const int maxBoxes = 20;
  static const int defaultBoxCount = 3;

  /// Number of boxes, always within [minBoxes]..[maxBoxes].
  final int boxCount;

  /// One label per box (empty for an unlabelled box); length is [boxCount].
  final List<String> labels;

  const CheckboxTrackConfig._(this.boxCount, this.labels);

  factory CheckboxTrackConfig({
    required int boxCount,
    List<String> labels = const [],
  }) {
    final count = boxCount.clamp(minBoxes, maxBoxes);
    return CheckboxTrackConfig._(
      count,
      List.generate(count, (i) => i < labels.length ? labels[i].trim() : ''),
    );
  }

  factory CheckboxTrackConfig.fromAdditionalData(String? raw) {
    final json = _decodeMap(raw);
    final count = json['boxCount'];
    final labels = json['labels'];
    return CheckboxTrackConfig(
      boxCount: count is num ? count.toInt() : defaultBoxCount,
      labels: labels is List
          ? labels.map((e) => e?.toString() ?? '').toList()
          : const [],
    );
  }

  factory CheckboxTrackConfig.of(CharacterStatDefinition stat) =>
      CheckboxTrackConfig.fromAdditionalData(stat.jsonSerializedAdditionalData);

  bool get hasLabels => labels.any((l) => l.isNotEmpty);

  /// `labels` is left out when no box has one.
  String toAdditionalData() =>
      jsonEncode({'boxCount': boxCount, if (hasLabels) 'labels': labels});
}

/// Ticked boxes of a checkbox track value `{"checked": [0, 2]}`.
Set<int> checkedBoxesOf(String? serializedValue) {
  final checked = _decodeMap(serializedValue)['checked'];
  if (checked is! List) return {};
  return checked.whereType<num>().map((e) => e.toInt()).toSet();
}

/// `{"checked": [...]}` with the indices sorted.
String serializeCheckedBoxes(Iterable<int> checked) =>
    jsonEncode({'checked': (checked.toSet().toList()..sort())});

/// Ticks box [index] when it is free, frees it when it is ticked. Indices
/// outside the current box count (left from a longer track) are dropped.
String toggleCheckboxTrackBox({
  required String? serializedValue,
  required int index,
  required int boxCount,
}) {
  final checked = checkedBoxesOf(serializedValue)
      .where((i) => i >= 0 && i < boxCount)
      .toSet();
  if (!checked.remove(index)) checked.add(index);
  return serializeCheckedBoxes(checked);
}

// --- textList ---------------------------------------------------------------

/// A fixed, labelled slot of a text list (e.g. "Hauptaspekt").
class TextListSlot {
  final String uuid;
  final String label;

  const TextListSlot({required this.uuid, required this.label});

  Map<String, dynamic> toJson() => {'uuid': uuid, 'label': label};
}

/// Configuration of a [CharacterStatValueType.textList] stat:
/// `{"slots": [{"uuid": "...", "label": "..."}], "allowCustomEntries": true}`.
class TextListConfig {
  final List<TextListSlot> slots;

  /// Whether the player may add and delete own entries below the slots.
  final bool allowCustomEntries;

  const TextListConfig({required this.slots, required this.allowCustomEntries});

  factory TextListConfig.fromAdditionalData(String? raw) {
    final json = _decodeMap(raw);
    final slots = json['slots'];
    final allowCustom = json['allowCustomEntries'];
    return TextListConfig(
      slots: slots is List
          ? slots
                .whereType<Map<String, dynamic>>()
                .where((s) => s['uuid'] is String)
                .map(
                  (s) => TextListSlot(
                    uuid: s['uuid'] as String,
                    label: s['label']?.toString() ?? '',
                  ),
                )
                .toList()
          : const [],
      // Without slots a list the player cannot add to would stay empty.
      allowCustomEntries: allowCustom is bool ? allowCustom : true,
    );
  }

  factory TextListConfig.of(CharacterStatDefinition stat) =>
      TextListConfig.fromAdditionalData(stat.jsonSerializedAdditionalData);

  String toAdditionalData() => jsonEncode({
    'slots': slots.map((s) => s.toJson()).toList(),
    'allowCustomEntries': allowCustomEntries,
  });
}

/// One stored entry of a text list value.
class TextListEntry {
  final String uuid;
  final String value;

  const TextListEntry({required this.uuid, required this.value});

  Map<String, dynamic> toJson() => {'uuid': uuid, 'value': value};
}

/// Entries of a text list value `{"values": [{"uuid": "...", "value": "..."}]}`.
List<TextListEntry> textListEntriesOf(String? serializedValue) {
  final values = _decodeMap(serializedValue)['values'];
  if (values is! List) return [];
  return values
      .whereType<Map<String, dynamic>>()
      .where((e) => e['uuid'] is String)
      .map(
        (e) => TextListEntry(
          uuid: e['uuid'] as String,
          value: e['value']?.toString() ?? '',
        ),
      )
      .toList();
}

String serializeTextListEntries(Iterable<TextListEntry> entries) =>
    jsonEncode({'values': entries.map((e) => e.toJson()).toList()});

/// A row of a text list as shown: a slot (with its label) or an own entry.
class TextListRow {
  final String uuid;

  /// The slot label; null for one of the player's own entries.
  final String? slotLabel;
  final String value;

  const TextListRow({
    required this.uuid,
    required this.slotLabel,
    required this.value,
  });

  bool get isSlot => slotLabel != null;
}

/// The slots in configured order (empty value when not filled in), then the
/// player's own entries in stored order. Own entries are only listed while
/// the configuration allows them.
List<TextListRow> textListRowsOf(
  TextListConfig config,
  List<TextListEntry> entries,
) {
  final slotUuids = config.slots.map((s) => s.uuid).toSet();
  return [
    for (final slot in config.slots)
      TextListRow(
        uuid: slot.uuid,
        slotLabel: slot.label,
        value:
            entries.firstWhereOrNull((e) => e.uuid == slot.uuid)?.value ?? '',
      ),
    if (config.allowCustomEntries)
      for (final entry in entries.where((e) => !slotUuids.contains(e.uuid)))
        TextListRow(uuid: entry.uuid, slotLabel: null, value: entry.value),
  ];
}

/// [serializedValue] with the entry [uuid] set to [value] (added at the end
/// when it does not exist yet).
String setTextListEntry({
  required String? serializedValue,
  required String uuid,
  required String value,
}) {
  final entries = textListEntriesOf(serializedValue);
  final index = entries.indexWhere((e) => e.uuid == uuid);
  final updated = TextListEntry(uuid: uuid, value: value);
  if (index == -1) {
    entries.add(updated);
  } else {
    entries[index] = updated;
  }
  return serializeTextListEntries(entries);
}

/// [serializedValue] without the entry [uuid].
String removeTextListEntry({
  required String? serializedValue,
  required String uuid,
}) => serializeTextListEntries(
  textListEntriesOf(serializedValue).where((e) => e.uuid != uuid),
);

// --- singleSelect -----------------------------------------------------------

/// An option of a single (or multi) select, stored as
/// `{"uuid": "...", "label": "...", "description": "...", "summary": "..."}`.
class SelectOption {
  final String uuid;
  final String label;
  final String description;
  final String? summary;

  const SelectOption({
    required this.uuid,
    required this.label,
    required this.description,
    this.summary,
  });
}

/// Options of a [CharacterStatValueType.singleSelect] stat
/// (`{"options": [...]}`, the multiselect format).
List<SelectOption> selectOptionsOf(CharacterStatDefinition stat) {
  final options = _decodeMap(stat.jsonSerializedAdditionalData)['options'];
  if (options is! List) return [];
  return options
      .whereType<Map<String, dynamic>>()
      .where((o) => o['uuid'] is String)
      .map(
        (o) => SelectOption(
          uuid: o['uuid'] as String,
          label: o['label']?.toString() ?? '',
          description: o['description']?.toString() ?? '',
          summary: o['summary'] is String ? o['summary'] as String : null,
        ),
      )
      .toList();
}

/// The selected option uuid of a single select value `{"value": "..."}`.
String? selectedOptionUuidOf(String? serializedValue) {
  final value = _decodeMap(serializedValue)['value'];
  return value is String && value.isNotEmpty ? value : null;
}

String serializeSingleSelect(String? optionUuid) =>
    jsonEncode({'value': optionUuid});

// --- characterNameWithLevelAndAdditionalDetails -----------------------------

/// Whether the character summary shows (and asks for) the level. Stored as
/// `"showLevel": false` next to `"values"`; absent means true, so campaigns
/// from before the switch keep their level.
bool characterSummaryShowsLevel(CharacterStatDefinition stat) {
  if (stat.valueType !=
      CharacterStatValueType.characterNameWithLevelAndAdditionalDetails) {
    return true;
  }
  return _decodeMap(stat.jsonSerializedAdditionalData)['showLevel'] != false;
}
