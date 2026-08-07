import 'package:flutter/material.dart';
import 'package:quest_keeper/components/character_sheet_skin_picker.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
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

  Widget dialogShell({
    required BuildContext ctx,
    required Widget body,
    required List<Widget> actions,
  }) {
    final theme = CustomThemeProvider.of(ctx).theme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SkinnedModalPanel(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.of(ctx).characterSheetAppearanceTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.titleLarge!.copyWith(
                        color: theme.darkTextColor,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 16),
                body,
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  if (immediateApply) {
    return showDialog<Object?>(
      context: context,
      builder: (ctx) {
        return dialogShell(
          ctx: ctx,
          body: CharacterSheetSkinPicker(
            selectedSkinId: draft,
            campaignDefaultSkinId: campaignDefaultSkinId,
            showUseCampaignDefault: true,
            onSelected: (id) {
              Navigator.of(ctx).pop(AppearanceModalSelection(id));
            },
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
          return dialogShell(
            ctx: ctx,
            body: CharacterSheetSkinPicker(
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
