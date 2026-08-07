import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:themed/themed.dart';

/// Mock-sampled champagne gold for Ledger navbar title + active diamond.
const Color kLedgerNavbarAccent = Color(0xffE29259);

class Navbar extends StatelessWidget {
  const Navbar({
    super.key,
    required this.useTopSafePadding,
    required this.closeFunction,
    required this.titleWidget,
    required this.backInsteadOfCloseIcon,
    required this.menuOpen,
    this.subTitle,
    this.logoutFunction,
  });

  final bool useTopSafePadding;
  final bool backInsteadOfCloseIcon;
  final VoidCallback? closeFunction;
  final Widget titleWidget;
  final Widget? subTitle;
  final VoidCallback? menuOpen;
  final VoidCallback? logoutFunction;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final ledger = isArcaneLedgerActive(context);

    final Color backgroundColor;
    if (ledger) {
      backgroundColor = const Color(0xff15100C);
    } else if (CustomThemeProvider.of(context).brightnessNotifier.value ==
        Brightness.light) {
      backgroundColor = theme.darkColor;
    } else {
      backgroundColor = theme.bgColor.darker(0.4);
    }

    final textColor =
        CustomThemeProvider.of(context).brightnessNotifier.value ==
                Brightness.light
            ? theme.textColor
            : theme.darkTextColor;

    // Mock close/back: large thin cream strokes.
    final closeIcon = ledger
        ? CustomPaint(
            size: const Size(28, 28),
            painter: _LedgerNavbarXPainter(
              color: const Color(0xffEDE3D4),
            ),
          )
        : CustomFaIcon(
            size: 20,
            icon: backInsteadOfCloseIcon
                ? FontAwesomeIcons.chevronLeft
                : FontAwesomeIcons.xmark,
            color: textColor,
          );

    final backIcon = ledger
        ? CustomPaint(
            size: const Size(28, 28),
            painter: _LedgerNavbarChevronPainter(
              color: const Color(0xffEDE3D4),
            ),
          )
        : CustomFaIcon(
            size: 20,
            icon: FontAwesomeIcons.chevronLeft,
            color: textColor,
          );

    final barContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: ledger ? 10 : 0),
          child: Opacity(
            opacity: closeFunction == null ? 0 : 1,
            child: CustomButton(
              variant: CustomButtonVariant.FlatButton,
              onPressed: closeFunction,
              icon: backInsteadOfCloseIcon ? backIcon : closeIcon,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: ledger ? 0 : 9.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleWidget,
                if (subTitle != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: subTitle!,
                  ),
              ],
            ),
          ),
        ),
        Opacity(
          opacity: logoutFunction == null ? 0 : 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Tooltip(
              message: AppLocalizations.of(context)?.logout ?? '',
              child: CustomButton(
                variant: CustomButtonVariant.FlatButton,
                onPressed: logoutFunction,
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.rightFromBracket,
                  size: ledger ? 20 : 20,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: menuOpen == null ? 0 : 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 4),
            child: CustomButton(
              variant: CustomButtonVariant.FlatButton,
              onPressed: menuOpen,
              icon: CustomFaIcon(
                icon: FontAwesomeIcons.gears,
                size: ledger ? 18 : 20,
                color: ledger
                    ? const Color(0xffE8DCC8).withValues(alpha: 0.7)
                    : textColor,
              ),
            ),
          ),
        ),
      ],
    );

    Widget barBody;
    if (ledger) {
      final topPad =
          useTopSafePadding ? MediaQuery.of(context).padding.top : 0.0;
      barBody = SizedBox(
        height: topPad + 68,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // One leather plate covers safe-area + bar; cover = fill without stretch.
            Positioned.fill(
              child: Image.asset(
                ArcaneLedgerAssets.navbarLeather,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
            // Soft bottom vignette matching mock separation into parchment.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x33000000),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                if (topPad > 0) SizedBox(height: topPad),
                SizedBox(
                  height: 68,
                  width: double.infinity,
                  child: barContent,
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 1,
                color: const Color(0x88EDDBC0),
              ),
            ),
          ],
        ),
      );
    } else {
      barBody = Column(
        children: [
          if (useTopSafePadding)
            SizedBox(
              height: MediaQuery.of(context).padding.top,
              width: double.infinity,
              child: ColoredBox(color: backgroundColor),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: ColoredBox(
              color: backgroundColor,
              child: barContent,
            ),
          ),
        ],
      );
    }

    return barBody;
  }
}

Color ledgerNavbarAccent(BuildContext context) {
  if (isArcaneLedgerActive(context)) return kLedgerNavbarAccent;
  return CustomThemeProvider.of(context).theme.accentColor;
}

class _LedgerNavbarXPainter extends CustomPainter {
  final Color color;

  _LedgerNavbarXPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Mock close mark is a filled bone-weight cross, not a hairline stroke.
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const inset = 5.5;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerNavbarXPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LedgerNavbarChevronPainter extends CustomPainter {
  final Color color;

  _LedgerNavbarChevronPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.62, size.height * 0.22)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..lineTo(size.width * 0.62, size.height * 0.78);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LedgerNavbarChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
