import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/property_purposes.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// What the game master picked in [showPropertyPurposePicker]: a purpose, or
/// the full list of field types ([purpose] null).
class PropertyPurposeSelection {
  const PropertyPurposeSelection(this.purpose);

  final PropertyPurpose? purpose;
}

/// A new property: first "What do you want to track?", then the property
/// editor with the field type the purpose stands for. Null when cancelled.
Future<CharacterStatDefinition?> showNewPropertyEditor({
  required BuildContext context,
  List<StatWithTab> availableStats = const [],
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  final selection = await showPropertyPurposePicker(
    context: context,
    overrideNavigatorKey: overrideNavigatorKey,
  );
  if (selection == null || !context.mounted) return null;

  return showGetDmConfigurationModal(
    context: context,
    availableStats: availableStats,
    purpose: selection.purpose,
    overrideNavigatorKey: overrideNavigatorKey,
  );
}

Future<PropertyPurposeSelection?> showPropertyPurposePicker({
  required BuildContext context,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) {
  return customShowCupertinoModalBottomSheet<PropertyPurposeSelection>(
    isDismissible: true,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    context: context,
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    overrideNavigatorKey: overrideNavigatorKey,
    builder: (context) => PropertyPurposePicker(
      navigatorKey: overrideNavigatorKey ?? navigatorKey,
    ),
  );
}

class PropertyPurposePicker extends StatelessWidget {
  const PropertyPurposePicker({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  static ValueKey<String> keyFor(PropertyPurpose? purpose) =>
      ValueKey('propertyPurpose-${purpose?.name ?? 'advanced'}');

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;

    void pick(PropertyPurpose? purpose) =>
        navigatorKey.currentState!.pop(PropertyPurposeSelection(purpose));

    return ModalContentWrapper<PropertyPurposeSelection>(
      isFullscreen: true,
      hideSaveButton: true,
      title: s.newPropertyBtnLabel,
      navigatorKey: navigatorKey,
      onCancel: () async {},
      onSave: null,
      child: LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 2 : 1;
        const spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        Widget card(PropertyPurpose? purpose, FaIconData icon, String title,
                String description) =>
            SizedBox(
              width: cardWidth,
              child: _PurposeCard(
                key: keyFor(purpose),
                icon: icon,
                title: title,
                description: description,
                onTap: () => pick(purpose),
              ),
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.propertyPurposePickerQuestion,
              style: textTheme.titleMedium!.copyWith(
                color: theme.darkTextColor,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.propertyPurposePickerHint,
              style: textTheme.bodyMedium!.copyWith(
                color: theme.darkTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final info in PropertyPurposeInfo.all)
                  card(info.purpose, info.icon, info.title(s),
                      info.description(s)),
                card(null, FontAwesomeIcons.sliders,
                    s.propertyPurposeAdvancedTitle,
                    s.propertyPurposeAdvancedDescription),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _PurposeCard extends StatelessWidget {
  const _PurposeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final FaIconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(8);

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: theme.darkTextColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: CustomFaIcon(
                    icon: icon,
                    size: 20,
                    color: theme.accentColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall!.copyWith(
                          color: theme.darkTextColor,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: textTheme.bodySmall!.copyWith(
                          color: theme.darkTextColor.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
