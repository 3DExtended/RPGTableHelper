import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/prepared_characters.dart';
import 'package:quest_keeper/helpers/character_stats/show_character_stats_form.dart';
import 'package:quest_keeper/helpers/modals/show_confirm_delete_dialog.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/prepared_character.dart';
import 'package:quest_keeper/screens/wizards/player_sheet_preview_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// "Vorbereitete Charaktere" on the game master's campaign page: characters
/// a joining player can take over. Kept in the campaign's configuration.
class PreparedCharactersSection extends ConsumerWidget {
  const PreparedCharactersSection({super.key, this.overrideNavigatorKey});

  final GlobalKey<NavigatorState>? overrideNavigatorKey;

  static const addKey = ValueKey('preparedCharactersAdd');

  static ValueKey<String> cardKeyFor(String uuid) =>
      ValueKey('preparedCharacter-$uuid');

  static ValueKey<String> deleteKeyFor(String uuid) =>
      ValueKey('preparedCharacterDelete-$uuid');

  static ValueKey<String> previewKeyFor(String uuid) =>
      ValueKey('preparedCharacterPreview-$uuid');

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    PreparedCharacter prepared,
  ) async {
    final config = ref.read(rpgConfigurationProvider).value;
    if (config == null) return;
    var current = prepared;
    await showCharacterStatsForm(
      context: context,
      pages: preparedCharacterPages(config),
      mode: CharacterStatsFormMode.prepare,
      characterName: prepared.characterName,
      initialValues: {
        for (final value in prepared.characterStats) value.statUuid: value,
      },
      characterToRenderStatFor: null,
      isEditingAlternateForm: false,
      overrideNavigatorKey: overrideNavigatorKey,
      // Page by page into the campaign; a new one appears with its first
      // stored page, so cancelling right away leaves nothing behind.
      onPersist: (stats, name) {
        current = withPreparedValues(current, stats, name);
        final latest = ref.read(rpgConfigurationProvider).value;
        if (latest == null) return;
        ref
            .read(rpgConfigurationProvider.notifier)
            .updateConfiguration(withPreparedCharacter(latest, current));
      },
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    PreparedCharacter prepared,
  ) async {
    final s = S.of(context);
    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: s.preparedCharacterDeleteTitle,
      message: s.preparedCharacterDeleteMessage(_nameOf(s, prepared)),
    );
    if (!confirmed) return;
    final latest = ref.read(rpgConfigurationProvider).value;
    if (latest == null) return;
    ref
        .read(rpgConfigurationProvider.notifier)
        .updateConfiguration(withoutPreparedCharacter(latest, prepared.uuid));
  }

  static String _nameOf(S s, PreparedCharacter prepared) =>
      prepared.characterName.trim().isEmpty
          ? s.preparedCharacterUnnamed
          : prepared.characterName.trim();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;
    final config = ref.watch(rpgConfigurationProvider).value;
    if (config == null) return const SizedBox.shrink();
    final prepared = config.preparedCharacters ?? const [];
    final isLight = CustomThemeProvider.of(context).brightnessNotifier.value ==
        Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              s.preparedCharactersTitle,
              style: textTheme.labelMedium!.copyWith(
                color: theme.darkTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomButton(
              key: addKey,
              isSubbutton: true,
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.plus,
                size: 14,
                color: theme.darkColor,
              ),
              label: s.preparedCharactersAdd,
              onPressed: () => _edit(context, ref, newPreparedCharacter()),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          s.preparedCharactersHint,
          style: textTheme.bodyMedium!.copyWith(
            color: theme.darkTextColor,
            fontSize: 16,
          ),
        ),
        if (prepared.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final character in prepared)
                SizedBox(
                  width: 350,
                  child: Material(
                    color: isLight ? theme.middleBgColor : theme.bgColor,
                    borderRadius: BorderRadius.circular(5),
                    child: InkWell(
                      key: cardKeyFor(character.uuid),
                      borderRadius: BorderRadius.circular(5),
                      onTap: () => _edit(context, ref, character),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nameOf(s, character),
                                    style: textTheme.labelMedium!.copyWith(
                                      fontSize: 20,
                                      color: theme.darkColor,
                                    ),
                                  ),
                                  if (preparedCharacterSummary(
                                          s, config, character)
                                      case final line when line.isNotEmpty)
                                    Text(
                                      line,
                                      style: textTheme.labelMedium!.copyWith(
                                        fontSize: 15,
                                        color: theme.darkColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Semantics(
                              label: s.preparedCharacterPreview,
                              button: true,
                              child: CustomButton(
                                key: previewKeyFor(character.uuid),
                                isSubbutton: true,
                                variant: CustomButtonVariant.FlatButton,
                                icon: CustomFaIcon(
                                  icon: FontAwesomeIcons.eye,
                                  size: 16,
                                  color: theme.darkColor,
                                ),
                                onPressed: () => PlayerSheetPreviewScreen.open(
                                  config,
                                  character: preparedCharacterAsCharacter(
                                    config,
                                    character,
                                  ),
                                ),
                              ),
                            ),
                            Semantics(
                              label: s.confirmDeleteBtnLabel,
                              button: true,
                              child: CustomButton(
                                key: deleteKeyFor(character.uuid),
                                isSubbutton: true,
                                variant: CustomButtonVariant.FlatButton,
                                icon: CustomFaIcon(
                                  icon: FontAwesomeIcons.trashCan,
                                  size: 16,
                                  color: theme.darkColor,
                                ),
                                onPressed: () =>
                                    _delete(context, ref, character),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
