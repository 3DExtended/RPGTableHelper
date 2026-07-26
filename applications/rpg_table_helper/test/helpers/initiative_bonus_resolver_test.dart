import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/initiative_bonus_resolver.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

void main() {
  group('RpgConfigurationModel initiative bonus fields', () {
    test('fromJson without initiative keys loads as None', () {
      final encoded = jsonEncode(
        RpgConfigurationModel.getBaseConfiguration().toJson(),
        toEncodable: (value) => (value as dynamic).toJson(),
      );
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      json.remove('initiativeBonusStatUuid');
      json.remove('initiativeBonusListEntryUuid');
      json.remove('initiativeBonusField');

      final loaded = RpgConfigurationModel.fromJson(json);

      expect(loaded.initiativeBonusStatUuid, isNull);
      expect(loaded.initiativeBonusListEntryUuid, isNull);
      expect(loaded.initiativeBonusField, isNull);
    });

    test('base preset prefills Fähigkeiten Geschicklichkeit otherValue', () {
      final base = RpgConfigurationModel.getBaseConfiguration();

      expect(base.initiativeBonusStatUuid,
          '44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3');
      expect(base.initiativeBonusListEntryUuid,
          'a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4');
      expect(base.initiativeBonusField, InitiativeBonusField.otherValue);
    });
  });

  group('formatInitiativeBonus', () {
    test('formats positive, negative, and zero', () {
      expect(formatInitiativeBonus(2), '(+2)');
      expect(formatInitiativeBonus(-1), '(-1)');
      expect(formatInitiativeBonus(0), '(0)');
    });
  });

  group('resolveInitiativeBonus', () {
    late RpgConfigurationModel rpgConfig;

    setUp(() {
      rpgConfig = RpgConfigurationModel.getBaseConfiguration();
    });

    RpgCharacterConfiguration characterWithSkills({
      required int dexOtherValue,
      int dexValue = 14,
      bool includeDexEntry = true,
    }) {
      final skillsStatUuid = '44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3';
      final dexUuid = 'a7aa4151-8c7c-41d4-91d2-2ff0a3d084a4';
      final values = <Map<String, dynamic>>[
        {
          'uuid': '76183b57-d6f3-4414-962c-837488ed0384',
          'value': 12,
          'otherValue': 1,
        },
        if (includeDexEntry)
          {
            'uuid': dexUuid,
            'value': dexValue,
            'otherValue': dexOtherValue,
          },
      ];

      return RpgCharacterConfiguration(
        uuid: 'char-1',
        characterName: 'Test',
        characterStats: [
          RpgCharacterStatValue(
            statUuid: skillsStatUuid,
            serializedValue: jsonEncode({'values': values}),
            hideFromCharacterScreen: false,
            hideLabelOfStat: false,
            variant: null,
          ),
        ],
        inventory: const [],
        moneyInBaseType: 0,
        tabConfigurations: null,
        companionCharacters: null,
        alternateForms: null,
        isAlternateFormActive: null,
        alternateForm: null,
        transformationComponents: null,
      );
    }

    test('resolves list entry otherValue with entry label', () {
      final character = characterWithSkills(dexOtherValue: 2);

      final hint = resolveInitiativeBonus(
        rpgConfig: rpgConfig,
        character: character,
      );

      expect(hint, isNotNull);
      expect(hint!.label, 'Geschicklichkeit');
      expect(hint.bonus, 2);
    });

    test('returns null when character has no matching list entry', () {
      final character = characterWithSkills(
        dexOtherValue: 2,
        includeDexEntry: false,
      );

      expect(
        resolveInitiativeBonus(rpgConfig: rpgConfig, character: character),
        isNull,
      );
    });

    test('returns null when initiative refs are unset', () {
      final cleared = RpgConfigurationModel.getBaseConfiguration()
          .copyWith
          .initiativeBonusStatUuid(null)
          .copyWith
          .initiativeBonusListEntryUuid(null)
          .copyWith
          .initiativeBonusField(null);

      expect(
        resolveInitiativeBonus(
          rpgConfig: cleared,
          character: characterWithSkills(dexOtherValue: 2),
        ),
        isNull,
      );
    });

    test('returns bonus 0 when otherValue is explicitly 0', () {
      final hint = resolveInitiativeBonus(
        rpgConfig: rpgConfig,
        character: characterWithSkills(dexOtherValue: 0),
      );

      expect(hint, isNotNull);
      expect(hint!.bonus, 0);
      expect(hint.label, 'Geschicklichkeit');
    });

    test('resolves plain int using value and stat name as label', () {
      const statUuid = 'plain-int-stat';
      final config = RpgConfigurationModel(
        rpgName: 't',
        allItems: const [],
        placesOfFindings: const [],
        currencyDefinition: CurrencyDefinition(currencyTypes: const []),
        itemCategories: const [],
        craftingRecipes: const [],
        characterStatTabsDefinition: [
          CharacterStatsTabDefinition(
            uuid: 'tab',
            tabName: 'Stats',
            isOptional: false,
            isDefaultTab: true,
            statsInTab: [
              CharacterStatDefinition(
                statUuid: statUuid,
                name: 'Initiative',
                helperText: '',
                groupId: null,
                valueType: CharacterStatValueType.int,
                editType: CharacterStatEditType.static,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
              ),
            ],
          ),
        ],
        initiativeBonusStatUuid: statUuid,
        initiativeBonusListEntryUuid: null,
        initiativeBonusField: InitiativeBonusField.value,
      );

      final character = RpgCharacterConfiguration(
        uuid: 'c',
        characterName: 'P',
        characterStats: [
          RpgCharacterStatValue(
            statUuid: statUuid,
            serializedValue: '{"value": 5}',
            hideFromCharacterScreen: false,
            hideLabelOfStat: false,
            variant: null,
          ),
        ],
        inventory: const [],
        moneyInBaseType: 0,
        tabConfigurations: null,
        companionCharacters: null,
        alternateForms: null,
        isAlternateFormActive: null,
        alternateForm: null,
        transformationComponents: null,
      );

      final hint =
          resolveInitiativeBonus(rpgConfig: config, character: character);

      expect(hint!.label, 'Initiative');
      expect(hint.bonus, 5);
    });

    test('resolves intWithMaxValue maxValue when field is maxValue', () {
      const statUuid = 'hp-stat';
      final config = RpgConfigurationModel(
        rpgName: 't',
        allItems: const [],
        placesOfFindings: const [],
        currencyDefinition: CurrencyDefinition(currencyTypes: const []),
        itemCategories: const [],
        craftingRecipes: const [],
        characterStatTabsDefinition: [
          CharacterStatsTabDefinition(
            uuid: 'tab',
            tabName: 'Stats',
            isOptional: false,
            isDefaultTab: true,
            statsInTab: [
              CharacterStatDefinition(
                statUuid: statUuid,
                name: 'HP',
                helperText: '',
                groupId: null,
                valueType: CharacterStatValueType.intWithMaxValue,
                editType: CharacterStatEditType.static,
                isOptionalForAlternateForms: false,
                isOptionalForCompanionCharacters: false,
              ),
            ],
          ),
        ],
        initiativeBonusStatUuid: statUuid,
        initiativeBonusListEntryUuid: null,
        initiativeBonusField: InitiativeBonusField.maxValue,
      );

      final character = RpgCharacterConfiguration(
        uuid: 'c',
        characterName: 'P',
        characterStats: [
          RpgCharacterStatValue(
            statUuid: statUuid,
            serializedValue: '{"value": 10, "maxValue": 17}',
            hideFromCharacterScreen: false,
            hideLabelOfStat: false,
            variant: null,
          ),
        ],
        inventory: const [],
        moneyInBaseType: 0,
        tabConfigurations: null,
        companionCharacters: null,
        alternateForms: null,
        isAlternateFormActive: null,
        alternateForm: null,
        transformationComponents: null,
      );

      final hint =
          resolveInitiativeBonus(rpgConfig: config, character: character);

      expect(hint!.bonus, 17);
      expect(hint.label, 'HP');
    });

    test('returns null when stat uuid is unknown (soft invalidate)', () {
      final broken = RpgConfigurationModel.getBaseConfiguration().copyWith(
        initiativeBonusStatUuid: 'missing-stat-uuid',
      );

      expect(
        resolveInitiativeBonus(
          rpgConfig: broken,
          character: characterWithSkills(dexOtherValue: 2),
        ),
        isNull,
      );
    });
  });
}
