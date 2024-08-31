import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/styled_box.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? label;
  final Widget? icon;
  const CustomButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      minSize: 0,
      padding: const EdgeInsets.all(0),
      child: StyledBox(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: label != null
              ? Text(
                  label!,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: onPressed != null
                          ? Colors.white
                          : const Color.fromARGB(255, 135, 135, 135),
                      fontSize: 16),
                )
              : icon!,
        ),
      ),
    );
  }
}
