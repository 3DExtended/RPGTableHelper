import 'package:flutter/material.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/components/pick_tile.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/prepared_characters.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/prepared_character.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// The prepared character of [config] the player takes over, null when
/// cancelled.
Future<PreparedCharacter?> showPreparedCharacterPicker({
  required BuildContext context,
  required RpgConfigurationModel config,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) {
  return customShowCupertinoModalBottomSheet<PreparedCharacter>(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    context: context,
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    overrideNavigatorKey: overrideNavigatorKey,
    builder: (context) => PreparedCharacterPicker(
      navigatorKey: overrideNavigatorKey ?? navigatorKey,
      config: config,
    ),
  );
}

class PreparedCharacterPicker extends StatefulWidget {
  const PreparedCharacterPicker({
    super.key,
    required this.navigatorKey,
    required this.config,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final RpgConfigurationModel config;

  static ValueKey<String> keyFor(String uuid) =>
      ValueKey('preparedCharacterPick-$uuid');

  @override
  State<PreparedCharacterPicker> createState() =>
      _PreparedCharacterPickerState();
}

class _PreparedCharacterPickerState extends State<PreparedCharacterPicker> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final prepared = widget.config.preparedCharacters ?? const [];
    final chosen = prepared.where((p) => p.uuid == _selected).firstOrNull;

    return ModalContentWrapper<PreparedCharacter>(
      isFullscreen: true,
      title: s.preparedCharactersPickerTitle,
      saveButtonLabel: s.preparedCharactersTake,
      navigatorKey: widget.navigatorKey,
      onCancel: () async {},
      onSave: chosen == null ? null : () async => chosen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.preparedCharactersPickerHint,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: theme.darkTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          for (final character in prepared)
            PickTile(
              key: PreparedCharacterPicker.keyFor(character.uuid),
              title: character.characterName.trim().isEmpty
                  ? s.preparedCharacterUnnamed
                  : character.characterName,
              subtitle:
                  preparedCharacterSummary(s, widget.config, character),
              isSelected: _selected == character.uuid,
              disabledReason: null,
              onTap: () => setState(() => _selected = character.uuid),
            ),
        ],
      ),
    );
  }
}
