import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_keeper/components/app_style_dialog.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Frame for small form modals (shown with
/// `customShowCupertinoModalBottomSheet`): title bar, body and a footer with
/// "Abbrechen" and a primary button.
///
/// Unlike `ModalContentWrapper`, it does not close itself on the primary
/// button, so the form can validate and show errors inline first.
class FormModalFrame extends StatelessWidget {
  const FormModalFrame({
    super.key,
    required this.title,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onCancel,
    this.isBusy = false,
    this.primaryButtonKey,
    this.cancelLabel,
  });

  final String title;
  final Widget child;

  /// `null` hides the primary button (e.g. for a sheet that only informs).
  final String? primaryLabel;

  /// Defaults to "Abbrechen".
  final String? cancelLabel;

  /// `null` disables the primary button.
  final VoidCallback? onPrimary;
  final VoidCallback onCancel;

  /// Shows a progress indicator instead of the primary button.
  final bool isBusy;
  final Key? primaryButtonKey;

  @override
  Widget build(BuildContext context) {
    final modalPadding = MediaQuery.sizeOf(context).width < 800 ? 20.0 : 80.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.fromLTRB(modalPadding, 20, modalPadding, 20),
        child: Center(
          child: ModalPanelShadow(
            child: SkinnedModalPanel(
              child: ConstrainedBox(
                constraints: skinnedModalContentConstraints(
                  context,
                  maxWidth: 800,
                  classicFooterPadding: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Navbar(
                      backInsteadOfCloseIcon: false,
                      closeFunction: isBusy ? null : onCancel,
                      menuOpen: null,
                      useTopSafePadding: false,
                      titleWidget: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: appModalTitleStyle(context),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: child,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        30,
                        10,
                        30,
                        modalFooterBottomPadding(context, classic: 20),
                      ),
                      child: Row(
                        children: [
                          CustomButton(
                            label: cancelLabel ?? S.of(context).cancel,
                            onPressed: isBusy ? null : onCancel,
                          ),
                          const Spacer(),
                          if (isBusy)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CustomThemeProvider.of(context)
                                      .theme
                                      .accentColor,
                                ),
                              ),
                            )
                          else if (primaryLabel != null)
                            CustomButton(
                              key: primaryButtonKey,
                              variant: CustomButtonVariant.AccentButton,
                              label: primaryLabel,
                              onPressed: onPrimary,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text field in the look of `CustomTextField`, plus inline error text,
/// input formatters and an explicit text style.
class FormModalTextField extends StatelessWidget {
  const FormModalTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.keyboardType,
    this.errorText,
    this.hintText,
    this.helperText,
    this.inputFormatters,
    this.autofocus = false,
    this.style,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final String? errorText;
  final String? hintText;
  final String? helperText;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final TextStyle? style;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final labelStyle = Theme.of(context).textTheme.labelLarge!
        .copyWith(fontFamily: 'Ruwudu', color: theme.darkTextColor);
    final border = OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: theme.darkColor),
    );
    final errorColor =
        CustomThemeProvider.of(context).brightnessNotifier.value ==
            Brightness.light
        ? theme.darkRed
        : theme.lightRed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        autofocus: autofocus,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        scrollPadding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        style: style ?? labelStyle,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          errorMaxLines: 3,
          alignLabelWithHint: true,
          enabledBorder: border,
          border: border,
          focusedBorder: border,
          disabledBorder: border.copyWith(
            borderSide: BorderSide(
              width: 1,
              color: theme.darkColor.withValues(alpha: 0.4),
            ),
          ),
          errorBorder: border.copyWith(
            borderSide: BorderSide(width: 1, color: errorColor),
          ),
          focusedErrorBorder: border.copyWith(
            borderSide: BorderSide(width: 2, color: errorColor),
          ),
          labelStyle: labelStyle,
          hintStyle: labelStyle.copyWith(
            color: theme.darkTextColor.withValues(alpha: 0.5),
          ),
          helperStyle: Theme.of(context).textTheme.labelSmall!
              .copyWith(fontFamily: 'Ruwudu', color: theme.darkTextColor),
          errorStyle: Theme.of(context).textTheme.labelMedium!
              .copyWith(fontFamily: 'Ruwudu', color: errorColor, fontSize: 14),
        ),
      ),
    );
  }
}
