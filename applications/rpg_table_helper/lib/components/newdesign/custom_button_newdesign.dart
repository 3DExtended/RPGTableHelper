import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';

enum CustomButtonNewdesignVariant {
  Default,
  AccentButton,
  DarkButton,
  FlatButton,
}

class CustomButtonNewdesign extends StatelessWidget {
  final void Function()? onPressed;
  final String? label;
  final Widget? icon;
  final bool? isSubbutton;
  final CustomButtonNewdesignVariant? variant;
  const CustomButtonNewdesign({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.variant,
    this.isSubbutton,
  });

  @override
  Widget build(BuildContext context) {
    var variantToUse = variant ?? CustomButtonNewdesignVariant.Default;

    var useLightTextColor =
        variantToUse == CustomButtonNewdesignVariant.AccentButton ||
            variantToUse == CustomButtonNewdesignVariant.DarkButton;

    return CupertinoButton(
      onPressed: onPressed,
      minSize: 0,
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          color: variantToUse == CustomButtonNewdesignVariant.FlatButton
              ? Colors.transparent
              : (variantToUse == CustomButtonNewdesignVariant.AccentButton
                  ? accentColor
                  : (variantToUse == CustomButtonNewdesignVariant.DarkButton
                      ? darkColor
                      : bgColor)),
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: variantToUse == CustomButtonNewdesignVariant.FlatButton
              ? null
              : Border.all(
                  color:
                      variantToUse == CustomButtonNewdesignVariant.AccentButton
                          ? accentColor
                          : darkColor,
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
                        color: onPressed != null
                            ? (useLightTextColor ? Colors.white : darkTextColor)
                            : const Color.fromARGB(255, 135, 135, 135),
                        fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
