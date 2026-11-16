import 'package:flutter/material.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// Title style the modals use in their [Navbar].
TextStyle appModalTitleStyle(BuildContext context) {
  final themeProvider = CustomThemeProvider.of(context);
  return Theme.of(context).textTheme.titleLarge!.copyWith(
    color: themeProvider.brightnessNotifier.value == Brightness.light
        ? themeProvider.theme.textColor
        : themeProvider.theme.darkTextColor,
    fontSize: 24,
  );
}

/// Body text style on the modal surface.
TextStyle appModalBodyStyle(BuildContext context, {double fontSize = 16}) {
  return Theme.of(context).textTheme.bodyMedium!.copyWith(
    color: CustomThemeProvider.of(context).theme.darkTextColor,
    fontSize: fontSize,
  );
}

/// The drop shadow of `CustomShadowWidget` as a plain box shadow.
///
/// `CustomShadowWidget` paints its child twice (a blurred copy below the real
/// one). For forms that doubles every text field, its focus and its state, so
/// the form modals use this instead. The skinned panels are rectangles, so the
/// result looks the same.
class ModalPanelShadow extends StatelessWidget {
  const ModalPanelShadow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x54000000),
            offset: Offset(-4, 4),
            blurRadius: 5,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A centered dialog in the look of the app's modals: skinned panel, title
/// bar, scrollable body and a row of actions at the bottom.
///
/// Show it with [showDialog]; it works under every sheet skin.
class AppStyleDialog extends StatelessWidget {
  const AppStyleDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
    this.onClose,
    this.maxWidth = 600,
  });

  final String title;
  final Widget child;

  /// Buttons at the bottom, laid out from the end.
  final List<Widget> actions;

  /// Shows the close icon in the title bar when set.
  final VoidCallback? onClose;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final horizontalInset = MediaQuery.sizeOf(context).width < 800
        ? 20.0
        : 80.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ModalPanelShadow(
          child: SkinnedModalPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Navbar(
                  backInsteadOfCloseIcon: false,
                  closeFunction: onClose,
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: child,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    modalFooterBottomPadding(context, classic: 20),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 10,
                    runSpacing: 10,
                    children: actions,
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
