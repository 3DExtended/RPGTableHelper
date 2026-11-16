import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

const confirmDeleteDialogCancelKey = ValueKey('confirmDeleteDialogCancel');
const confirmDeleteDialogConfirmKey = ValueKey('confirmDeleteDialogConfirm');

/// Asks before something is deleted. Uses the skinned modal panel so the
/// dialog matches the active character sheet skin.
///
/// Resolves to true only when the user confirms; cancel and tapping outside
/// resolve to false.
Future<bool> showConfirmDeleteDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final theme = CustomThemeProvider.of(ctx).theme;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SkinnedModalPanel(
          child: ConstrainedBox(
            constraints: skinnedModalContentConstraints(ctx, maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(ctx).textTheme.titleLarge!
                        .copyWith(color: theme.darkTextColor, fontSize: 22),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    message,
                    style: Theme.of(ctx).textTheme.bodyMedium!
                        .copyWith(color: theme.darkTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      CustomButton(
                        key: confirmDeleteDialogCancelKey,
                        variant: CustomButtonVariant.FlatButton,
                        label: S.of(ctx).cancel,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                      CustomButton(
                        key: confirmDeleteDialogConfirmKey,
                        variant: CustomButtonVariant.AccentButton,
                        label: confirmLabel ?? S.of(ctx).confirmDeleteBtnLabel,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  return result == true;
}
