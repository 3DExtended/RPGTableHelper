import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/character_sheet_skin_picker.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// First RPG configuration wizard step: campaign default sheet skin.
class RpgConfigurationWizardStep0CharacterSheetSkin extends WizardStepBase {
  const RpgConfigurationWizardStep0CharacterSheetSkin({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    required super.setWizardTitle,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep0CharacterSheetSkin> createState() =>
      _RpgConfigurationWizardStep0CharacterSheetSkinState();
}

class _RpgConfigurationWizardStep0CharacterSheetSkinState
    extends ConsumerState<RpgConfigurationWizardStep0CharacterSheetSkin> {
  String? _selectedSkinId;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.setWizardTitle(S.of(context).characterSheetAppearanceTitle);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!_loaded) {
        final initial =
            data.defaultSkinId ?? CharacterSheetSkinIds.classicDark;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _loaded = true;
            _selectedSkinId = initial;
          });
          _persistAndApply(initial);
        });
      }
    });

    final helper = '''
## ${S.of(context).characterSheetAppearanceTitle}

Pick the default look for character sheets in this campaign.
Players can override this later for their own characters.
''';

    return TwoPartWizardStepBody(
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepHelperText: helper,
      onPreviousBtnPressed: widget.onPreviousBtnPressed,
      onNextBtnPressed: _selectedSkinId == null
          ? null
          : () {
              _persistAndApply(_selectedSkinId!);
              widget.onNextBtnPressed();
            },
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: [
        CharacterSheetSkinPicker(
          selectedSkinId: _selectedSkinId,
          campaignDefaultSkinId: _selectedSkinId,
          onSelected: (id) {
            if (id == null) return;
            setState(() => _selectedSkinId = id);
            _persistAndApply(id);
          },
        ),
      ],
    );
  }

  void _persistAndApply(String skinId) {
    final current = ref.read(rpgConfigurationProvider).requireValue;
    if (current.defaultSkinId != skinId) {
      ref.read(rpgConfigurationProvider.notifier).updateConfiguration(
            current.copyWith(defaultSkinId: skinId),
          );
    }
    CustomThemeProvider.of(context).setActiveSkinId(skinId);
  }
}
