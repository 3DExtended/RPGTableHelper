import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/character_stats/template_update.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';

CharacterStatDefinition _named(RpgConfigurationModel config, String name) =>
    StatNumbers.allStats(config).firstWhere((s) => s.name == name);

Map<String, dynamic> _data(CharacterStatDefinition stat) =>
    jsonDecode(stat.jsonSerializedAdditionalData!) as Map<String, dynamic>;

CharacterStatDefinition _withData(
  CharacterStatDefinition stat,
  Map<String, dynamic> data,
) => stat.copyWith(jsonSerializedAdditionalData: jsonEncode(data));

const _ownSpell = {
  'uuid': 'own-cantrip',
  'label': 'Funkenregen',
  'description': 'Eigener Zaubertrick der Spielleitung.',
};

/// A campaign set up before the template got its current texts: "HP" and
/// "Skills" under their old names, an old help text, a skill the template
/// added since is missing, the portrait is missing, a cantrip of its own and
/// a property of its own ("Klasse").
RpgConfigurationModel _oldCampaign() {
  final template = RpgConfigurationTemplates.fantasySrd();
  CharacterStatDefinition old(CharacterStatDefinition stat) {
    switch (stat.name) {
      case 'TP':
        return stat.copyWith(name: 'HP', helperText: 'Wie viel HP?');
      case 'Attribute':
        return stat.copyWith(name: 'Skills');
      case 'Fertigkeiten':
        final data = _data(stat);
        return _withData(stat, {
          ...data,
          'options': (data['options'] as List).take(17).toList(),
        });
      case 'Zaubertricks':
        final data = _data(stat);
        final options = [...data['options'] as List];
        // Its own entry in the middle: the order must not count.
        options.insert(2, _ownSpell);
        return _withData(stat, {...data, 'options': options});
      default:
        return stat;
    }
  }

  return template.copyWith(
    rpgName: 'Alte Runde',
    characterStatTabsDefinition: [
      for (final tab in template.characterStatTabsDefinition!)
        tab.copyWith(statsInTab: [
          for (final stat in tab.statsInTab)
            if (stat.name != 'Porträt') old(stat),
          if (tab.tabName == 'Hintergrund')
            CharacterStatDefinition(
              statUuid: 'own-class',
              name: 'Klasse',
              helperText: '',
              groupId: 5,
              valueType: CharacterStatValueType.singleLineText,
              editType: CharacterStatEditType.static,
              isOptionalForAlternateForms: false,
              isOptionalForCompanionCharacters: false,
            ),
        ]),
    ],
  );
}

void main() {
  group('base template', () {
    test('the template that shares the most properties', () {
      expect(baseTemplateOf(_oldCampaign()),
          RpgConfigurationTemplateId.fantasySrd);
      expect(baseTemplateOf(RpgConfigurationTemplates.narrative()),
          RpgConfigurationTemplateId.narrative);
    });

    test('none for "Leer" or a few building blocks', () {
      expect(baseTemplateOf(RpgConfigurationTemplates.empty()), isNull);

      final srd = StatNumbers.allStats(RpgConfigurationTemplates.fantasySrd());
      final twoBlocks = RpgConfigurationTemplates.empty().copyWith(
        characterStatTabsDefinition: [
          RpgConfigurationTemplates.empty()
              .characterStatTabsDefinition!
              .single
              .copyWith(statsInTab: [srd[2], srd[3]]),
        ],
      );
      expect(baseTemplateOf(twoBlocks), isNull);
      expect(templateUpdateFor(twoBlocks), isNull);
    });
  });

  test('nothing to update for a campaign as the template has it', () {
    for (final id in RpgConfigurationTemplates.ids) {
      expect(templateUpdateFor(RpgConfigurationTemplates.build(id)), isNull,
          reason: '$id');
    }
    // Own properties and another layout do not count.
    final template = RpgConfigurationTemplates.fantasySrd();
    final regrouped = template.copyWith(characterStatTabsDefinition: [
      for (final tab in template.characterStatTabsDefinition!)
        tab.copyWith(statsInTab: [
          for (final stat in tab.statsInTab) stat.copyWith(groupId: 7),
        ]),
    ]);
    expect(templateUpdateFor(regrouped), isNull);
  });

  group('an old campaign', () {
    final update = templateUpdateFor(_oldCampaign())!;
    TemplateStatChange change(String templateName) =>
        update.changes.singleWhere((c) => c.updated.name == templateName);

    test('gets what changed in the template', () {
      expect(update.template, RpgConfigurationTemplateId.fantasySrd);
      expect(update.changes.map((c) => c.updated.name), [
        'Porträt',
        'Attribute',
        'TP',
        'Fertigkeiten',
      ]);
    });

    test('says what changes', () {
      final hp = change('TP');
      expect(hp.kind, TemplateStatChangeKind.changed);
      expect(hp.current!.name, 'HP');
      expect(hp.nameChanged, isTrue);
      expect(hp.helperTextChanged, isTrue);
      expect(hp.newEntries, 0);
      expect(hp.otherSettingsChanged, isFalse);

      final skills = change('Fertigkeiten');
      expect(skills.nameChanged, isFalse);
      expect(skills.newEntries, 1);
      expect(skills.entriesRevised, isFalse);

      final portrait = change('Porträt');
      expect(portrait.kind, TemplateStatChangeKind.added);
      expect(portrait.current, isNull);
      expect(portrait.templateTabName, 'Werte');
    });

    test('keeps entries of its own', () {
      expect(
        update.changes.where((c) => c.updated.name == 'Zaubertricks'),
        isEmpty,
        reason: 'only its own entry differs',
      );
    });

    test('applies only what was chosen, values keep their uuids', () {
      final old = _oldCampaign();
      final hp = change('TP');
      final portrait = change('Porträt');
      final next = applyTemplateUpdate(
        old,
        update,
        {hp.updated.statUuid, portrait.updated.statUuid},
      );

      expect(_named(next, 'TP').statUuid, hp.current!.statUuid);
      expect(_named(next, 'TP').groupId, hp.current!.groupId);
      expect(_named(next, 'Skills').statUuid, isNotEmpty,
          reason: 'not chosen');
      expect(_named(next, 'Klasse').groupId, 5, reason: 'its own, untouched');

      final werte = next.characterStatTabsDefinition!
          .singleWhere((t) => t.tabName == 'Werte');
      expect(werte.statsInTab.last.statUuid, portrait.updated.statUuid);
      final groups = werte.statsInTab.map((s) => s.groupId ?? 0).toList();
      expect(werte.statsInTab.last.groupId,
          groups.take(groups.length - 1).reduce((a, b) => a > b ? a : b) + 1,
          reason: 'a row of its own');

      expect(next.rpgName, 'Alte Runde');
      expect(StatNumbers.allStats(next), hasLength(
          StatNumbers.allStats(old).length + 1));
      expect(templateUpdateFor(next)!.changes.map((c) => c.updated.name),
          ['Attribute', 'Fertigkeiten']);
    });

    test('merges list entries: the template\'s, then its own', () {
      final stat = RpgConfigurationTemplates.fantasySrd();
      final cantrips = _named(stat, 'Zaubertricks');
      final campaign = _oldCampaign();
      // The template's entry got a new description.
      final revised = _withData(_named(campaign, 'Zaubertricks'), {
        ..._data(_named(campaign, 'Zaubertricks')),
        'options': [
          for (final option in _data(_named(campaign, 'Zaubertricks'))['options']
              as List)
            option['uuid'] == (_data(cantrips)['options'] as List).first['uuid']
                ? {...option as Map, 'description': 'Alter Text'}
                : option,
        ],
      });
      final config = campaign.copyWith(characterStatTabsDefinition: [
        for (final tab in campaign.characterStatTabsDefinition!)
          tab.copyWith(statsInTab: [
            for (final s in tab.statsInTab)
              s.statUuid == revised.statUuid ? revised : s,
          ]),
      ]);

      final update = templateUpdateFor(config)!;
      final change =
          update.changes.singleWhere((c) => c.updated.name == 'Zaubertricks');
      expect(change.entriesRevised, isTrue);
      expect(change.newEntries, 0);

      final merged = _named(
        applyTemplateUpdate(config, update, {change.updated.statUuid}),
        'Zaubertricks',
      );
      final options = _data(merged)['options'] as List;
      expect(options.map((o) => o['uuid']), [
        ...(_data(cantrips)['options'] as List).map((o) => o['uuid']),
        'own-cantrip',
      ]);
      expect(options.first['description'],
          (_data(cantrips)['options'] as List).first['description']);
    });

    test('an added property without its tab gets the tab', () {
      final old = _oldCampaign();
      final noValuesTab = old.copyWith(characterStatTabsDefinition: [
        for (final tab in old.characterStatTabsDefinition!)
          if (tab.tabName != 'Werte') tab,
      ]);
      final update = templateUpdateFor(noValuesTab)!;
      final next = applyTemplateUpdate(noValuesTab, update, {
        for (final c in update.changes) c.updated.statUuid,
      });
      final werte = next.characterStatTabsDefinition!.last;
      expect(werte.tabName, 'Werte');
      expect(werte.isDefaultTab, isFalse);
      expect(werte.statsInTab.map((s) => s.name), contains('TP'));
      expect(templateUpdateFor(next), isNull);
    });

    test('another field type is left alone', () {
      final old = _oldCampaign();
      final hp = _named(old, 'HP');
      final asText = old.copyWith(characterStatTabsDefinition: [
        for (final tab in old.characterStatTabsDefinition!)
          tab.copyWith(statsInTab: [
            for (final s in tab.statsInTab)
              s.statUuid == hp.statUuid
                  ? s.copyWith(valueType: CharacterStatValueType.singleLineText)
                  : s,
          ]),
      ]);
      expect(
        templateUpdateFor(asText)!.changes.map((c) => c.updated.statUuid),
        isNot(contains(hp.statUuid)),
      );
    });

    test('the signature follows the changes', () {
      final again = templateUpdateFor(_oldCampaign())!;
      expect(again.signature, update.signature);
      final next = applyTemplateUpdate(_oldCampaign(), update,
          {change('TP').updated.statUuid});
      expect(templateUpdateFor(next)!.signature, isNot(update.signature));
    });
  });
}
