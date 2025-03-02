// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/constants.dart';

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

  Color _getBackgroundColor(CustomButtonVariant variant, bool isEnabled) {
    if (!isEnabled) {
      return variant == CustomButtonVariant.FlatButton
          ? Colors.transparent
          : middleBgColor;
    }

    switch (variant) {
      case CustomButtonVariant.FlatButton:
        return Colors.transparent;
      case CustomButtonVariant.AccentButton:
        return accentColor;
      case CustomButtonVariant.DarkButton:
        return darkColor;
      default:
        return bgColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    var variantToUse = variant ?? CustomButtonVariant.Default;

    var useLightTextColor = variantToUse == CustomButtonVariant.AccentButton ||
        variantToUse == CustomButtonVariant.DarkButton;

    return CupertinoButton(
      onPressed: onPressed,
      minSize: 0,
      padding: EdgeInsets.zero,
      child: Container(
        height: height,
        width: width,
        alignment: height != null || width != null ? Alignment.center : null,
        decoration: BoxDecoration(
          color: _getBackgroundColor(variantToUse, onPressed != null),
          borderRadius:
              BorderRadius.all(Radius.circular(boderRadiusOverride ?? 5)),
          border: variantToUse == CustomButtonVariant.FlatButton
              ? null
              : Border.all(
                  color: onPressed == null
                      ? middleBgColor
                      : (variantToUse == CustomButtonVariant.AccentButton
                          ? accentColor
                          : darkColor),
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
                          color: (useLightTextColor
                              ? Colors.white
                              : darkTextColor),
                          fontSize: 16,
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
