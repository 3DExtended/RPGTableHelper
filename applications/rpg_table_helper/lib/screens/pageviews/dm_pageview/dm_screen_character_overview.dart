import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/render_characters_as_cards.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/custom_iterator_extensions.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class DmScreenCharacterOverview extends ConsumerStatefulWidget {
  const DmScreenCharacterOverview({
    super.key,
  });

  @override
  ConsumerState<DmScreenCharacterOverview> createState() =>
      _DmScreenCharacterOverviewState();
}

class _DmScreenCharacterOverviewState
    extends ConsumerState<DmScreenCharacterOverview> {
  @override
  Widget build(BuildContext context) {
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;

    return Container(
        color: CustomThemeProvider.of(context).theme.bgColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: connectionDetails == null || rpgConfig == null
                ? CustomLoadingSpinner()
                : Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    runSpacing: 20,
                    spacing: 20,
                    children: getPlayerCharacterCards(
                        context, connectionDetails, rpgConfig),
                  ),
          ),
        ));
  }

  List<Widget> getPlayerCharacterCards(BuildContext context,
      ConnectionDetails connectionDetails, RpgConfigurationModel rpgConfig) {
    List<
        ({
          RpgCharacterConfigurationBase characterToRender,
          bool isAlternateForm,
          bool isCompanion,
        })> charactersToRender = [];

    if (connectionDetails.connectedPlayers != null) {
      for (var connectedPlayer in (connectionDetails.connectedPlayers!)) {
        var charConfig = connectedPlayer.configuration;

        if (charConfig.isAlternateFormActive != true ||
            charConfig.alternateForm == null) {
          charactersToRender.add((
            characterToRender: charConfig,
            isAlternateForm: false,
            isCompanion: false
          ));
        } else {
          charactersToRender.add((
            characterToRender: charConfig.alternateForm!,
            isAlternateForm: true,
            isCompanion: false
          ));
        }

        if (charConfig.companionCharacters != null &&
            charConfig.companionCharacters!.isNotEmpty) {
          charactersToRender.addAll(charConfig.companionCharacters!.map((c) => (
                characterToRender: c,
                isAlternateForm: false,
                isCompanion: true
              )));
        }
      }
    }

    if (charactersToRender.isEmpty) {
      return [
        SizedBox(
          height: 50,
        ),
        Center(
          child: Text(
            S.of(context).noPlayersOnline,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontWeight: FontWeight.bold),
          ),
        )
      ];
    } else {
      // sort charactersToRender by ordering in initiative tracker
      var initiativeTracker = connectionDetails.fightSequence?.sequence;

      if (initiativeTracker != null) {
        charactersToRender = charactersToRender
            .sortBy((d) => initiativeTracker
                .firstWhere((element) => element.$1 == d.characterToRender.uuid,
                    orElse: () => (null, '', 0))
                .$3 as num)
            .toList();
      }
    }

    return RenderCharactersAsCards.renderCharactersAsCharacterCard(
        context, charactersToRender, rpgConfig);
  }
}
