import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/player_stats_configuration_visuals.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

Future<RpgCharacterStatValue?> showGetPlayerConfigurationModal({
  required BuildContext context,
  required CharacterStatDefinition statConfiguration,
  required String characterName,
  required RpgCharacterConfiguration? characterToRenderStatFor,
  RpgCharacterStatValue? characterValue,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
  bool hideVariantSelection = false,
  bool hideAdditionalSetting = false,
  required bool isEditingAlternateForm,
}) async {
  return await customShowCupertinoModalBottomSheet<RpgCharacterStatValue>(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: false,
      context: context,
      backgroundColor: const Color.fromARGB(158, 49, 49, 49),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        return ShowGetPlayerConfigurationModalContent(
          statConfiguration: statConfiguration,
          characterValue: characterValue,
          overrideNavigatorKey: overrideNavigatorKey,
          characterName: characterName,
          characterToRenderStatFor: characterToRenderStatFor,
          hideVariantSelection: hideVariantSelection,
          hideAdditionalSetting: hideAdditionalSetting,
          isEditingAlternateForm: isEditingAlternateForm,
        );
      });
}

class ShowGetPlayerConfigurationModalContent extends ConsumerStatefulWidget {
  const ShowGetPlayerConfigurationModalContent({
    super.key,
    required this.statConfiguration,
    required this.characterName,
    required this.characterToRenderStatFor,
    required this.isEditingAlternateForm,
    this.characterValue,
    this.overrideNavigatorKey,
    this.hideVariantSelection = false,
    this.hideAdditionalSetting = false,
  });

  final bool isEditingAlternateForm;
  final GlobalKey<NavigatorState>? overrideNavigatorKey;
  final bool hideVariantSelection;
  final bool hideAdditionalSetting;
  final String characterName;
  final RpgCharacterConfiguration? characterToRenderStatFor;
  final CharacterStatDefinition statConfiguration;
  final RpgCharacterStatValue? characterValue;

  @override
  ConsumerState<ShowGetPlayerConfigurationModalContent> createState() =>
      _ShowGetPlayerConfigurationModalContentState();
}

class _ShowGetPlayerConfigurationModalContentState
    extends ConsumerState<ShowGetPlayerConfigurationModalContent> {
  RpgCharacterStatValue? newestStatValue;

  @override
  void initState() {
    newestStatValue = widget.characterValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContentWrapper<RpgCharacterStatValue>(
      isFullscreen: true,
      title: S.of(context).configureProperties +
          (widget.characterName.isEmpty
              ? ""
              : S.of(context).configurePropertiesForCharacterNameSuffix(
                  widget.characterName)),
      navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
      onCancel: () async {},
      onSave: () {
        return Future.value(newestStatValue);
      },
      child: Column(
        children: [
          if (widget.isEditingAlternateForm == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.exclamation,
                          color: darkTextColor,
                          size: 24,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          S.of(context).warning,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: darkTextColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).youAreEditingAnAlternateFormWarningText,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: darkTextColor,
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          PlayerStatsConfigurationVisuals(
            statConfiguration: widget.statConfiguration,
            characterValue: widget.characterValue,
            characterName: widget.characterName,
            characterToRenderStatFor: widget.characterToRenderStatFor,
            hideVariantSelection: widget.hideVariantSelection,
            hideAdditionalSetting: widget.hideAdditionalSetting,
            onNewStatValue: (newStatValue) {
              newestStatValue = newStatValue;
            },
          ),
        ],
      ),
    );
  }
}
