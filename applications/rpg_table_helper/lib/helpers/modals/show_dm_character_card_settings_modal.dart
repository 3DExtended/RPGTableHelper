import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/dm_card_stats.dart';
import 'package:quest_keeper/helpers/character_stats/stat_number_labels.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/dm_character_card_settings.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// A card the DM can hide or show.
typedef DmCardEntry = ({String uuid, String name, bool isCompanion});

/// Lets the DM pick which online characters get a card and which stats the
/// cards show. Returns the new settings, or `null` on cancel.
Future<DmCharacterCardSettings?> showDmCharacterCardSettingsModal(
  BuildContext context, {
  required List<DmCardEntry> cards,
  required RpgConfigurationModel rpgConfig,
  required DmCharacterCardSettings currentSettings,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  return await customShowCupertinoModalBottomSheet<DmCharacterCardSettings>(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    enableDrag: true,
    context: context,
    overrideNavigatorKey: overrideNavigatorKey,
    builder: (context) => DmCharacterCardSettingsModalContent(
      cards: cards,
      rpgConfig: rpgConfig,
      currentSettings: currentSettings,
      overrideNavigatorKey: overrideNavigatorKey,
    ),
  );
}

class DmCharacterCardSettingsModalContent extends StatefulWidget {
  const DmCharacterCardSettingsModalContent({
    super.key,
    required this.cards,
    required this.rpgConfig,
    required this.currentSettings,
    this.overrideNavigatorKey,
  });

  final List<DmCardEntry> cards;
  final RpgConfigurationModel rpgConfig;
  final DmCharacterCardSettings currentSettings;
  final GlobalKey<NavigatorState>? overrideNavigatorKey;

  @override
  State<DmCharacterCardSettingsModalContent> createState() =>
      _DmCharacterCardSettingsModalContentState();
}

class _DmCharacterCardSettingsModalContentState
    extends State<DmCharacterCardSettingsModalContent> {
  late DmCharacterCardSettings settings = widget.currentSettings;

  void _toggleCustomStats(bool useCustom) {
    setState(() {
      if (useCustom &&
          settings.barStatUuid == null &&
          settings.numberStats.isEmpty) {
        // Start from what the cards show today, so the DM only adds or
        // removes.
        var automatic = DmCardStats.automaticSelection(
          widget.rpgConfig,
          isAlternateForm: false,
          isCompanion: false,
        );
        var numbers = automatic.numberStats.isNotEmpty
            ? automatic.numberStats
            : automatic.fallbackNumberStats;
        settings = settings.copyWith(
          useCustomStats: true,
          barStatUuid: () => automatic.barStatUuid,
          numberStats: numbers,
        );
      } else {
        settings = settings.copyWith(useCustomStats: useCustom);
      }
    });
  }

  void _toggleNumber(List<DmCardStatOption> options, StatNumberRef ref) {
    setState(() {
      var selected = settings.numberStats.toSet();
      if (!selected.remove(ref)) {
        if (selected.length >= DmCharacterCardSettings.maxNumberStats) return;
        selected.add(ref);
      }
      // Keep the order of the campaign's stats.
      settings = settings.copyWith(
        numberStats: options
            .map((o) => o.ref)
            .where(selected.contains)
            .toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var textColor = CustomThemeProvider.of(context).theme.darkTextColor;
    var headingStyle = Theme.of(context).textTheme.titleMedium!
        .copyWith(color: textColor, fontWeight: FontWeight.bold);
    var hintStyle = Theme.of(context).textTheme.bodyMedium!
        .copyWith(color: textColor);

    var numberOptions = DmCardStats.numberOptions(
      widget.rpgConfig,
      statNumberLabelsOf(context),
    );
    var barOptions = DmCardStats.barOptions(widget.rpgConfig);

    return ModalContentWrapper<DmCharacterCardSettings>(
      isFullscreen: true,
      title: S.of(context).customizeCards,
      navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
      onCancel: () async {},
      onSave: () async => settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.of(context).visibleCards, style: headingStyle),
          const SizedBox(height: 4),
          Text(S.of(context).visibleCardsHint, style: hintStyle),
          const SizedBox(height: 8),
          if (widget.cards.isEmpty)
            Text(S.of(context).noPlayersOnline, style: hintStyle),
          ...widget.cards.map(
            (card) => DmSettingsCheckTile(
              key: ValueKey("dmCardVisible_${card.uuid}"),
              label: card.isCompanion
                  ? "${card.name} (${S.of(context).companion})"
                  : card.name,
              isSet: !settings.isHidden(card.uuid),
              onChanged: () => setState(() {
                settings = settings.withHidden(
                  card.uuid,
                  !settings.isHidden(card.uuid),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Text(S.of(context).cardStatsSection, style: headingStyle),
          const SizedBox(height: 8),
          DmSettingsCheckTile(
            key: const ValueKey("dmCardUseCustomStats"),
            label: S.of(context).chooseCardStatsYourself,
            isSet: settings.useCustomStats,
            onChanged: () => _toggleCustomStats(!settings.useCustomStats),
          ),
          if (!settings.useCustomStats)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                S.of(context).automaticCardStatsHint,
                style: hintStyle,
              ),
            ),
          if (settings.useCustomStats) ...[
            const SizedBox(height: 16),
            Text(S.of(context).cardBar, style: headingStyle),
            DmSettingsCheckTile(
              key: const ValueKey("dmCardBar_none"),
              label: S.of(context).noBar,
              isSet: settings.barStatUuid == null,
              onChanged: () => setState(() {
                settings = settings.copyWith(barStatUuid: () => null);
              }),
            ),
            ...barOptions.map(
              (stat) => DmSettingsCheckTile(
                key: ValueKey("dmCardBar_${stat.statUuid}"),
                label: stat.name,
                isSet: settings.barStatUuid == stat.statUuid,
                onChanged: () => setState(() {
                  settings = settings.copyWith(
                    barStatUuid: () => stat.statUuid,
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${S.of(context).cardNumbers} (${settings.numberStats.length}/${DmCharacterCardSettings.maxNumberStats})",
              style: headingStyle,
            ),
            if (numberOptions.isEmpty)
              Text(S.of(context).noCardStatsAvailable, style: hintStyle),
            ..._buildNumberOptions(numberOptions, hintStyle),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<Widget> _buildNumberOptions(
    List<DmCardStatOption> options,
    TextStyle groupStyle,
  ) {
    var result = <Widget>[];
    String? currentGroup;
    var isFull =
        settings.numberStats.length >= DmCharacterCardSettings.maxNumberStats;
    for (var option in options) {
      if (option.groupLabel != currentGroup) {
        currentGroup = option.groupLabel;
        result.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 4),
            child: Text(
              option.groupLabel,
              style: groupStyle.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        );
      }
      var isSet = settings.numberStats.contains(option.ref);
      result.add(
        DmSettingsCheckTile(
          key: ValueKey("dmCardNumber_${option.ref.key}"),
          label: option.label,
          isSet: isSet,
          onChanged: !isSet && isFull
              ? null
              : () => _toggleNumber(options, option.ref),
        ),
      );
    }
    return result;
  }
}

/// A square checkbox with a label that wraps on narrow screens.
class DmSettingsCheckTile extends StatelessWidget {
  const DmSettingsCheckTile({
    super.key,
    required this.label,
    required this.isSet,
    required this.onChanged,
  });

  final String label;
  final bool isSet;

  /// `null` disables the tile.
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    var theme = CustomThemeProvider.of(context).theme;
    var isDisabled = onChanged == null;
    return InkWell(
      onTap: onChanged,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1,
          child: Row(
            children: [
              CustomButton(
                isSubbutton: true,
                onPressed: onChanged,
                icon: Container(
                  width: 20,
                  height: 20,
                  color: isSet ? theme.darkColor : Colors.transparent,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium!
                      .copyWith(color: theme.darkTextColor, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
