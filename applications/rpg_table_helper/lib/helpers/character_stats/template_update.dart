import 'dart:convert';

import 'package:quest_keeper/helpers/character_stats/stat_example.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:uuid/v7.dart';

/// What the template a campaign was set up with offers since: properties
/// that are new in the template, and properties of the campaign whose
/// template version reads differently (name, help text, list entries, ...).
///
/// Campaigns and templates share property uuids, so the values of the
/// characters stay where they are. Entries of lists are merged by uuid: the
/// template's first, then the campaign's own, so no choice of a character
/// loses its entry.
class TemplateUpdate {
  const TemplateUpdate({
    required this.template,
    required this.changes,
    this.tabChanges = const [],
  });

  final RpgConfigurationTemplateId template;
  final List<TemplateStatChange> changes;

  /// Tabs the template names differently (same uuid).
  final List<TemplateTabChange> tabChanges;

  /// Everything on offer: tab renames and property changes.
  int get count => tabChanges.length + changes.length;

  /// The ids [applyTemplateUpdate] takes, all of them.
  Set<String> get allIds => {
        for (final t in tabChanges) t.id,
        for (final c in changes) c.id,
      };

  /// Same changes, same signature: to remember an update the game master
  /// set aside, until the template changes again.
  String get signature => [
        for (final t in tabChanges) '${t.id}:${t.templateName}',
        for (final c in changes)
          '${c.id}:${_normalized(c.updated).hashCode}',
      ].join('|');
}

/// A tab of the campaign the template names differently.
class TemplateTabChange {
  const TemplateTabChange({
    required this.uuid,
    required this.currentName,
    required this.templateName,
  });

  final String uuid;
  final String currentName;
  final String templateName;

  String get id => 'tab:$uuid';
}

enum TemplateStatChangeKind { added, changed }

class TemplateStatChange {
  const TemplateStatChange({
    required this.kind,
    required this.current,
    required this.updated,
    required this.templateTabName,
    required this.templateTabUuid,
  });

  final TemplateStatChangeKind kind;

  /// What [applyTemplateUpdate] knows the change by.
  String get id => updated.statUuid;

  /// The campaign's property, null for an added one.
  final CharacterStatDefinition? current;

  /// The property as it will be: the template's, merged with the campaign's.
  final CharacterStatDefinition updated;

  /// Where the template has it; an added property goes into the campaign's
  /// tab with this uuid, or else of this name.
  final String templateTabName;
  final String templateTabUuid;

  bool get nameChanged => current != null && current!.name != updated.name;

  bool get helperTextChanged =>
      current != null && current!.helperText != updated.helperText;

  /// List entries the template adds (options, values, slots).
  int get newEntries => current == null
      ? 0
      : _entryUuids(updated).difference(_entryUuids(current!)).length;

  /// Entries both have read differently in the template (e.g. a spell's
  /// description).
  bool get entriesRevised {
    if (current == null) return false;
    final before = _entriesByUuid(current!);
    final after = _entriesByUuid(updated);
    return before.entries
        .any((e) => after.containsKey(e.key) && after[e.key] != e.value);
  }

  /// The example answer the character form shows reads differently.
  bool get exampleChanged =>
      current != null &&
      _additionalData(current!)[statExampleKey] !=
          _additionalData(updated)[statExampleKey];

  /// Anything else differs (how often it changes, further settings).
  bool get otherSettingsChanged =>
      current != null &&
      _withoutEntries(current!.copyWith(
            name: updated.name,
            helperText: updated.helperText,
          )) !=
          _withoutEntries(updated);
}

/// The template [config] was most likely set up with, judged by the
/// property uuids they share; null when it shares too few with any.
RpgConfigurationTemplateId? baseTemplateOf(RpgConfigurationModel config) {
  final own = StatNumbers.allStats(config).map((s) => s.statUuid).toSet();
  RpgConfigurationTemplateId? best;
  var bestShared = 0;
  for (final id in RpgConfigurationTemplates.ids) {
    if (id == RpgConfigurationTemplateId.empty) continue;
    final shared = StatNumbers.allStats(RpgConfigurationTemplates.build(id))
        .where((s) => own.contains(s.statUuid))
        .length;
    if (shared > bestShared) {
      best = id;
      bestShared = shared;
    }
  }
  // A property or two could come from the building blocks.
  return bestShared >= 3 ? best : null;
}

/// What the base template of [config] offers, or null when nothing (or no
/// base template).
TemplateUpdate? templateUpdateFor(RpgConfigurationModel config) {
  final id = baseTemplateOf(config);
  if (id == null) return null;

  final own = {
    for (final stat in StatNumbers.allStats(config)) stat.statUuid: stat,
  };
  final hasSummary = own.values.any((s) =>
      s.valueType ==
      CharacterStatValueType.characterNameWithLevelAndAdditionalDetails);

  final ownTabs = {
    for (final tab in config.characterStatTabsDefinition ??
        const <CharacterStatsTabDefinition>[])
      tab.uuid: tab,
  };
  final templateTabs = RpgConfigurationTemplates.build(id)
          .characterStatTabsDefinition ??
      const <CharacterStatsTabDefinition>[];
  final tabChanges = [
    for (final tab in templateTabs)
      if (ownTabs[tab.uuid] case final own?
          when own.tabName.trim() != tab.tabName.trim())
        TemplateTabChange(
          uuid: tab.uuid,
          currentName: own.tabName,
          templateName: tab.tabName,
        ),
  ];

  final changes = <TemplateStatChange>[];
  for (final tab in templateTabs) {
    for (final stat in tab.statsInTab) {
      final current = own[stat.statUuid];
      if (current == null) {
        if (hasSummary &&
            stat.valueType ==
                CharacterStatValueType
                    .characterNameWithLevelAndAdditionalDetails) {
          continue;
        }
        changes.add(TemplateStatChange(
          kind: TemplateStatChangeKind.added,
          current: null,
          updated: _withoutGroup(stat),
          templateTabName: tab.tabName,
          templateTabUuid: tab.uuid,
        ));
        continue;
      }
      // Another field type would not fit the characters' values.
      if (current.valueType != stat.valueType) continue;
      final updated = _merged(current, stat);
      if (_normalized(updated) == _normalized(current)) continue;
      changes.add(TemplateStatChange(
        kind: TemplateStatChangeKind.changed,
        current: current,
        updated: updated,
        templateTabName: tab.tabName,
        templateTabUuid: tab.uuid,
      ));
    }
  }
  return changes.isEmpty && tabChanges.isEmpty
      ? null
      : TemplateUpdate(template: id, changes: changes, tabChanges: tabChanges);
}

/// [config] with the [chosen] changes (by their ids) of [update]: tabs
/// renamed, changed properties in place, added ones at the end of the
/// template's tab (found by uuid, else by name), or of a new tab like it.
RpgConfigurationModel applyTemplateUpdate(
  RpgConfigurationModel config,
  TemplateUpdate update,
  Set<String> chosen,
) {
  final picked = update.changes.where((c) => chosen.contains(c.id));
  final renamed = {
    for (final t in update.tabChanges)
      if (chosen.contains(t.id)) t.uuid: t.templateName,
  };
  final changed = {
    for (final c in picked)
      if (c.kind == TemplateStatChangeKind.changed)
        c.updated.statUuid: c.updated,
  };
  final tabs = [
    for (final tab in config.characterStatTabsDefinition ??
        const <CharacterStatsTabDefinition>[])
      tab.copyWith(tabName: renamed[tab.uuid] ?? tab.tabName, statsInTab: [
        for (final stat in tab.statsInTab)
          if (changed[stat.statUuid] case final updated?)
            _withGroup(updated, stat.groupId)
          else
            stat,
      ]),
  ];

  for (final c in picked) {
    if (c.kind != TemplateStatChangeKind.added) continue;
    var index = tabs.indexWhere((t) => t.uuid == c.templateTabUuid);
    if (index < 0) {
      index = tabs.indexWhere((t) =>
          t.tabName.trim().toLowerCase() ==
          c.templateTabName.trim().toLowerCase());
    }
    if (index < 0) {
      tabs.add(CharacterStatsTabDefinition(
        uuid: tabs.any((t) => t.uuid == c.templateTabUuid)
            ? const UuidV7().generate()
            : c.templateTabUuid,
        tabName: c.templateTabName,
        isOptional: false,
        isDefaultTab: tabs.isEmpty,
        statsInTab: const [],
      ));
      index = tabs.length - 1;
    }
    final tab = tabs[index];
    // Its own row below what the tab has.
    final groups = tab.statsInTab.map((s) => s.groupId ?? 0);
    final group = groups.isEmpty ? 0 : groups.reduce((a, b) => a > b ? a : b) + 1;
    tabs[index] = tab.copyWith(
      statsInTab: [...tab.statsInTab, _withGroup(c.updated, group)],
    );
  }
  return config.copyWith(characterStatTabsDefinition: tabs);
}

/// The template's [template] property, with the campaign's settings it does
/// not set and the campaign's own list entries after its own.
CharacterStatDefinition _merged(
  CharacterStatDefinition current,
  CharacterStatDefinition template,
) {
  final own = _additionalData(current);
  final theirs = _additionalData(template);
  final merged = <String, dynamic>{...own, ...theirs};
  for (final key in theirs.keys) {
    final ownList = own[key];
    final theirList = theirs[key];
    if (ownList is List && theirList is List && _isEntryList(theirList)) {
      final known = {for (final e in theirList) (e as Map)['uuid']};
      merged[key] = [
        ...theirList,
        for (final e in ownList)
          if (e is Map && !known.contains(e['uuid'])) e,
      ];
    }
  }
  return CharacterStatDefinition.fromJson({
    ...template.toJson(),
    'groupId': current.groupId,
    'jsonSerializedAdditionalData': merged.isEmpty ? null : jsonEncode(merged),
  });
}

bool _isEntryList(List<dynamic> list) =>
    list.isNotEmpty && list.every((e) => e is Map && e['uuid'] is String);

Map<String, dynamic> _additionalData(CharacterStatDefinition stat) {
  final json = stat.jsonSerializedAdditionalData;
  if (json == null || json.trim().isEmpty) return {};
  try {
    final decoded = jsonDecode(json);
    return decoded is Map<String, dynamic> ? decoded : {};
  } catch (_) {
    return {};
  }
}

Set<String> _entryUuids(CharacterStatDefinition stat) =>
    _entriesByUuid(stat).keys.toSet();

/// Every list entry by uuid, as JSON to compare.
Map<String, String> _entriesByUuid(CharacterStatDefinition stat) => {
      for (final value in _additionalData(stat).values)
        if (value is List && _isEntryList(value))
          for (final e in value) (e as Map)['uuid'] as String: jsonEncode(e),
    };

/// For comparing: without the layout (group), with the additional data
/// decoded and list entries by uuid, so neither key nor entry order counts.
String _normalized(CharacterStatDefinition stat) => jsonEncode({
      ...stat.toJson(),
      'groupId': null,
      'jsonSerializedAdditionalData': {
        for (final MapEntry(:key, :value) in _additionalData(stat).entries)
          key: value is List && _isEntryList(value)
              ? (value.map((e) => jsonEncode(e)).toList()..sort())
              : value,
      },
    });

/// For comparing the other settings: without list entries and example.
String _withoutEntries(CharacterStatDefinition stat) {
  final data = _additionalData(stat)
    ..removeWhere((_, v) => v is List && _isEntryList(v))
    ..remove(statExampleKey);
  return jsonEncode({
    ...stat.toJson(),
    'groupId': null,
    'jsonSerializedAdditionalData': data,
  });
}

CharacterStatDefinition _withoutGroup(CharacterStatDefinition stat) =>
    _withGroup(stat, null);

CharacterStatDefinition _withGroup(CharacterStatDefinition stat, int? group) =>
    CharacterStatDefinition.fromJson({...stat.toJson(), 'groupId': group});
