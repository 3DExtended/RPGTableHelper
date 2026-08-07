// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

enum CustomButtonVariant {
  Default,
  AccentButton,
  DarkButton,
  FlatButton,
}

class CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? label;
  final Widget? icon;
  final bool? isSubbutton;
  final double? width;
  final double? height;
  final double? boderRadiusOverride;
  final CustomButtonVariant? variant;
  const CustomButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.variant,
    this.isSubbutton,
    this.width,
    this.height,
    this.boderRadiusOverride,
  });

  Color _getBackgroundColor(
      CustomButtonVariant variant, bool isEnabled, BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    if (!isEnabled) {
      if (variant == CustomButtonVariant.FlatButton) {
        return Colors.transparent;
      }
      // Decorated skins: muted version of the enabled fill (readable on parchment/atlas).
      if (isDecoratedSheetSkinActive(context)) {
        if (variant == CustomButtonVariant.AccentButton) {
          if (isArcaneLedgerActive(context)) {
            return theme.darkColor.withValues(alpha: 0.35);
          }
          return theme.accentColor.withValues(alpha: 0.35);
        }
        if (variant == CustomButtonVariant.DarkButton) {
          return theme.darkColor.withValues(alpha: 0.35);
        }
        // Default: outlined on parchment/atlas (no cream/navy plate).
        return Colors.transparent;
      }
      return theme.middleBgColor;
    }

    switch (variant) {
      case CustomButtonVariant.FlatButton:
        return Colors.transparent;
      case CustomButtonVariant.AccentButton:
        // Arcane Ledger primary CTAs match inventory "+ Add": ink fill, not terracotta.
        if (isArcaneLedgerActive(context)) {
          return theme.darkColor;
        }
        return theme.accentColor;
      case CustomButtonVariant.DarkButton:
        return theme.darkColor;
      default:
        // Decorated: transparent outlined control (wizard chevrons, "+ …").
        if (isDecoratedSheetSkinActive(context)) {
          return Colors.transparent;
        }
        return theme.bgColor;
    }
  }

  Color _getBorderColor(
      CustomButtonVariant variant, bool isEnabled, BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    if (!isEnabled) {
      if (isDecoratedSheetSkinActive(context) &&
          variant != CustomButtonVariant.FlatButton) {
        if (variant == CustomButtonVariant.AccentButton &&
            isNightCartographerActive(context)) {
          return theme.accentColor.withValues(alpha: 0.4);
        }
        return theme.darkColor.withValues(alpha: 0.4);
      }
      return theme.middleBgColor;
    }
    if (variant == CustomButtonVariant.AccentButton) {
      if (isArcaneLedgerActive(context)) {
        return theme.darkColor;
      }
      return theme.accentColor;
    }
    return theme.darkColor;
  }

  Color _getLabelColor(
      CustomButtonVariant variant, bool isEnabled, BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    if (!isEnabled && variant != CustomButtonVariant.FlatButton) {
      if (isDecoratedSheetSkinActive(context)) {
        // Keep high-contrast label on the muted fill (cream on Arcane ink wash /
        // navy on Cartographer gold wash).
        if (variant == CustomButtonVariant.AccentButton &&
            isNightCartographerActive(context)) {
          return theme.bgColor.withValues(alpha: 0.85);
        }
        return theme.textColor.withValues(alpha: 0.9);
      }
      return theme.darkTextColor.withValues(alpha: 0.55);
    }

    final useLightTextColor = variant == CustomButtonVariant.AccentButton ||
        variant == CustomButtonVariant.DarkButton;
    final cartographerAccentLabel =
        variant == CustomButtonVariant.AccentButton &&
            isNightCartographerActive(context);
    // Champagne-gold accent on Night Cartographer needs dark navy label text.
    if (cartographerAccentLabel) {
      return theme.bgColor;
    }
    return useLightTextColor ? theme.textColor : theme.darkTextColor;
  }

  @override
  Widget build(BuildContext context) {
    var variantToUse = variant ?? CustomButtonVariant.Default;
    final isEnabled = onPressed != null;
    final decorated = isDecoratedSheetSkinActive(context);
    final labelColor = _getLabelColor(variantToUse, isEnabled, context);

    // Pill radius for decorated primary CTAs (matches inventory "+ Add").
    final radius = boderRadiusOverride ??
        (decorated &&
                variantToUse == CustomButtonVariant.AccentButton &&
                label != null
            ? 20.0
            : 5.0);

    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      minimumSize: Size(0, 0),
      child: Container(
        height: height,
        width: width,
        alignment: height != null || width != null ? Alignment.center : null,
        decoration: BoxDecoration(
          color: _getBackgroundColor(variantToUse, isEnabled, context),
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          border: variantToUse == CustomButtonVariant.FlatButton
              ? null
              : Border.all(
                  color: _getBorderColor(variantToUse, isEnabled, context),
                ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSubbutton == true ? 5 : 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) icon!,
              if (label != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    label!,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: labelColor,
                          fontSize: 16,
                          fontFamily: decorated ? 'Ruwudu' : null,
                          fontWeight:
                              decorated ? FontWeight.w500 : FontWeight.normal,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
