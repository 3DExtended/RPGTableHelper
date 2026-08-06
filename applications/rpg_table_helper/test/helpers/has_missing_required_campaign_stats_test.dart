import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_stats/has_missing_required_campaign_stats.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

RpgCharacterConfiguration _characterWithAllCampaignStats(
  RpgConfigurationModel rpg,
) {
  final defs = rpg.characterStatTabsDefinition
          ?.expand((t) => t.statsInTab)
          .toList() ??
      const <CharacterStatDefinition>[];
  return RpgCharacterConfiguration.getBaseConfiguration(rpg).copyWith(
    characterStats: defs
        .map(
          (d) => RpgCharacterStatValue(
            hideFromCharacterScreen: false,
            hideLabelOfStat: false,
            variant: null,
            statUuid: d.statUuid,
            serializedValue: '{}',
          ),
        )
        .toList(),
  );
}

void main() {
  group('hasMissingRequiredCampaignStats', () {
    test('false when all campaign stats present and name set', () {
      final rpg = RpgConfigurationModel.getBaseConfiguration();
      final char = _characterWithAllCampaignStats(rpg);
      expect(
        hasMissingRequiredCampaignStats(rpgConfig: rpg, character: char),
        isFalse,
      );
    });

    test('true when character name empty', () {
      final rpg = RpgConfigurationModel.getBaseConfiguration();
      final char =
          _characterWithAllCampaignStats(rpg).copyWith(characterName: '   ');
      expect(
        hasMissingRequiredCampaignStats(rpgConfig: rpg, character: char),
        isTrue,
      );
    });

    test('true when a campaign stat uuid is missing from character', () {
      final rpg = RpgConfigurationModel.getBaseConfiguration();
      final char = RpgCharacterConfiguration.getBaseConfiguration(rpg)
          .copyWith(characterStats: []);
      expect(
        hasMissingRequiredCampaignStats(rpgConfig: rpg, character: char),
        isTrue,
      );
    });

    test('true for default factory character (default tab only)', () {
      final rpg = RpgConfigurationModel.getBaseConfiguration();
      final char = RpgCharacterConfiguration.getBaseConfiguration(rpg);
      expect(
        hasMissingRequiredCampaignStats(rpgConfig: rpg, character: char),
        isTrue,
      );
    });
  });
}
