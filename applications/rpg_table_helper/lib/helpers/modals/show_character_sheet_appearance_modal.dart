import 'package:flutter/material.dart';
import 'package:quest_keeper/components/character_sheet_skin_picker.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Dismissed without saving (Cancel or barrier).
class AppearanceModalCancelled {
  const AppearanceModalCancelled();
}

/// Explicit picker result. [skinId] null means "use campaign default".
class AppearanceModalSelection {
  final String? skinId;
  const AppearanceModalSelection(this.skinId);
}

/// Opens Appearance picker.
///
/// Immediate mode: returns [AppearanceModalSelection] as soon as a tile is
/// tapped. Save/Cancel mode: live-previews on the sheet; Save returns
/// [AppearanceModalSelection], Cancel restores theme and returns
/// [AppearanceModalCancelled].
Future<Object?> showCharacterSheetAppearanceModal({
  required BuildContext context,
  required String? currentSkinId,
  required String? campaignDefaultSkinId,
  required bool immediateApply,
}) async {
  var draft = currentSkinId;
  final theme = CustomThemeProvider.of(context).theme;

  if (immediateApply) {
    return showDialog<Object?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.bgColor,
          title: Text(
            S.of(ctx).characterSheetAppearanceTitle,
            style: TextStyle(color: theme.darkTextColor),
          ),
          content: SizedBox(
            width: 520,
            child: CharacterSheetSkinPicker(
              selectedSkinId: draft,
              campaignDefaultSkinId: campaignDefaultSkinId,
              showUseCampaignDefault: true,
              onSelected: (id) {
                Navigator.of(ctx).pop(AppearanceModalSelection(id));
              },
            ),
          ),
          actions: [
            CustomButton(
              variant: CustomButtonVariant.FlatButton,
              onPressed: () =>
                  Navigator.of(ctx).pop(const AppearanceModalCancelled()),
              label: S.of(ctx).cancel,
            ),
          ],
        );
      },
    );
  }

  return showDialog<Object?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            backgroundColor: theme.bgColor,
            title: Text(
              S.of(ctx).characterSheetAppearanceTitle,
              style: TextStyle(color: theme.darkTextColor),
            ),
            content: SizedBox(
              width: 520,
              child: CharacterSheetSkinPicker(
                selectedSkinId: draft,
                campaignDefaultSkinId: campaignDefaultSkinId,
                showUseCampaignDefault: true,
                onSelected: (id) {
                  setLocal(() => draft = id);
                  final preview = resolveCharacterSheetSkin(
                    characterSkinId: id,
                    campaignDefaultSkinId: campaignDefaultSkinId,
                  ).renderSkinId;
                  CustomThemeProvider.of(context).setActiveSkinId(preview);
                },
              ),
            ),
            actions: [
              CustomButton(
                variant: CustomButtonVariant.FlatButton,
                onPressed: () {
                  final restore = resolveCharacterSheetSkin(
                    characterSkinId: currentSkinId,
                    campaignDefaultSkinId: campaignDefaultSkinId,
                  ).renderSkinId;
                  CustomThemeProvider.of(context).setActiveSkinId(restore);
                  Navigator.of(ctx).pop(const AppearanceModalCancelled());
                },
                label: S.of(ctx).cancel,
              ),
              CustomButton(
                variant: CustomButtonVariant.AccentButton,
                onPressed: () =>
                    Navigator.of(ctx).pop(AppearanceModalSelection(draft)),
                label: S.of(ctx).save,
              ),
            ],
          );
        },
      );
    },
  );
}
