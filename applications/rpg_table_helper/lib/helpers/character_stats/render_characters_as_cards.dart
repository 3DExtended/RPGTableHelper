import 'package:flutter/widgets.dart';
import 'package:quest_keeper/components/custom_character_card.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/dm_card_stats.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

class RenderCharactersAsCards {
  /// One card per entry. [settings] decides which stats a card shows; without
  /// it (or in its automatic mode) the card picks them from the default tab.
  static List<Widget> renderCharactersAsCharacterCard(
    BuildContext context,
    List<
      ({
        RpgCharacterConfigurationBase characterToRender,
        bool isAlternateForm,
        bool isCompanion,
      })
    >
    charactersToRender,
    RpgConfigurationModel rpgConfig, {
    DmCharacterCardSettings settings = DmCharacterCardSettings.empty,
  }) {
    List<Widget> result = [];
    var calculatedSuffix = S.of(context).calculatedValueShort;

    for (var tuple in charactersToRender) {
      var characterName = tuple.characterToRender.characterName.trim().isEmpty
          ? S.of(context).characterNameDefault
          : tuple.characterToRender.characterName;
      var characterImage = tuple.characterToRender.getImageUrlWithoutBasePath(
        rpgConfig,
      );

      var selection = DmCardStats.selectionFor(
        rpgConfig,
        settings,
        isAlternateForm: tuple.isAlternateForm,
        isCompanion: tuple.isCompanion,
      );

      result.add(
        CustomCharacterCard(
          characterName: characterName,
          characterSingleNumberStats: DmCardStats.numbersFor(
            rpgConfig,
            selection,
            tuple.characterToRender,
            calculatedSuffix,
          ),
          imageUrl: characterImage,
          isGreyscale: false,
          isLoading: false,
          characterStatWithMaxValueForBarVisuals: DmCardStats.barFor(
            rpgConfig,
            selection,
            tuple.characterToRender,
          ),
        ),
      );
    }

    return result;
  }
}
