import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_stats/render_characters_as_cards.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/custom_iterator_extensions.dart';
import 'package:quest_keeper/helpers/modals/show_dm_character_card_settings_modal.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dm_character_card_settings_store.dart';

/// A card on the overview: what to draw and the uuid that hides it.
typedef _OverviewCard = ({
  RpgCharacterConfigurationBase characterToRender,
  bool isAlternateForm,
  bool isCompanion,
  String hideUuid,
});

class DmScreenCharacterOverview extends ConsumerStatefulWidget {
  const DmScreenCharacterOverview({super.key});

  @override
  ConsumerState<DmScreenCharacterOverview> createState() =>
      _DmScreenCharacterOverviewState();
}

class _DmScreenCharacterOverviewState
    extends ConsumerState<DmScreenCharacterOverview> {
  @override
  Widget build(BuildContext context) {
    var connectionDetails = ref.watch(connectionDetailsProvider).value;
    var rpgConfig = ref.watch(rpgConfigurationProvider).value;
    var campagneKey = connectionDetails?.campagneId ?? "";
    var cardSettings = ref.watch(dmCharacterCardSettingsProvider(campagneKey));

    return Container(
      color: characterSheetSurfaceColor(context),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: connectionDetails == null || rpgConfig == null
              ? CustomLoadingSpinner()
              : _buildContent(
                  context,
                  connectionDetails,
                  rpgConfig,
                  cardSettings,
                  campagneKey,
                ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ConnectionDetails connectionDetails,
    RpgConfigurationModel rpgConfig,
    DmCharacterCardSettings cardSettings,
    String campagneKey,
  ) {
    var onlineCards = getOnlineCards(connectionDetails);
    var visibleCards = onlineCards
        .where((c) => !cardSettings.isHidden(c.hideUuid))
        .toList();
    var hiddenCount = onlineCards.length - visibleCards.length;
    var textStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
      color: CustomThemeProvider.of(context).theme.darkTextColor,
      fontWeight: FontWeight.bold,
    );

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            if (hiddenCount > 0)
              Text(
                "${S.of(context).hiddenCards}: $hiddenCount",
                key: const ValueKey("dmHiddenCardsCount"),
                style: textStyle,
              ),
            CustomButton(
              key: const ValueKey("dmCustomizeCardsButton"),
              variant: CustomButtonVariant.AccentButton,
              label: S.of(context).customizeCards,
              onPressed: () => _openCardSettings(
                onlineCards,
                rpgConfig,
                cardSettings,
                campagneKey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          runSpacing: 20,
          spacing: 20,
          children: visibleCards.isEmpty
              ? [
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      onlineCards.isEmpty
                          ? S.of(context).noPlayersOnline
                          : S.of(context).allCardsHidden,
                      style: textStyle,
                    ),
                  ),
                ]
              : RenderCharactersAsCards.renderCharactersAsCharacterCard(
                  context,
                  visibleCards
                      .map(
                        (c) => (
                          characterToRender: c.characterToRender,
                          isAlternateForm: c.isAlternateForm,
                          isCompanion: c.isCompanion,
                        ),
                      )
                      .toList(),
                  rpgConfig,
                  settings: cardSettings,
                ),
        ),
      ],
    );
  }

  Future<void> _openCardSettings(
    List<_OverviewCard> onlineCards,
    RpgConfigurationModel rpgConfig,
    DmCharacterCardSettings cardSettings,
    String campagneKey,
  ) async {
    var result = await showDmCharacterCardSettingsModal(
      context,
      cards: onlineCards
          .map(
            (c) => (
              uuid: c.hideUuid,
              name: c.characterToRender.characterName.trim().isEmpty
                  ? S.of(context).characterNameDefault
                  : c.characterToRender.characterName,
              isCompanion: c.isCompanion,
            ),
          )
          .toList(),
      rpgConfig: rpgConfig,
      currentSettings: cardSettings,
    );
    if (result == null || !mounted) return;
    await ref
        .read(dmCharacterCardSettingsProvider(campagneKey).notifier)
        .update(result);
  }

  /// Every card of the characters online right now (player character or its
  /// active alternate form, plus companions), in initiative order.
  List<_OverviewCard> getOnlineCards(ConnectionDetails connectionDetails) {
    List<_OverviewCard> cards = [];

    for (var connectedPlayer in (connectionDetails.connectedPlayers ?? [])) {
      // Presence: roster membership is not online. Only lastPing marks session presence.
      if (connectedPlayer.lastPing == null) {
        continue;
      }
      var charConfig = connectedPlayer.configuration;

      if (charConfig.isAlternateFormActive != true ||
          charConfig.alternateForm == null) {
        cards.add((
          characterToRender: charConfig,
          isAlternateForm: false,
          isCompanion: false,
          hideUuid: charConfig.uuid,
        ));
      } else {
        // The alternate form hides and shows with its character.
        cards.add((
          characterToRender: charConfig.alternateForm!,
          isAlternateForm: true,
          isCompanion: false,
          hideUuid: charConfig.uuid,
        ));
      }

      for (var companion in charConfig.companionCharacters ?? []) {
        cards.add((
          characterToRender: companion,
          isAlternateForm: false,
          isCompanion: true,
          hideUuid: companion.uuid,
        ));
      }
    }

    // sort by ordering in initiative tracker
    var initiativeTracker = connectionDetails.fightSequence?.sequence;
    if (initiativeTracker != null && cards.isNotEmpty) {
      cards = cards
          .sortBy(
            (d) =>
                initiativeTracker
                        .firstWhere(
                          (element) => element.$1 == d.characterToRender.uuid,
                          orElse: () => (null, '', 0),
                        )
                        .$3
                    as num,
          )
          .toList();
    }
    return cards;
  }
}
