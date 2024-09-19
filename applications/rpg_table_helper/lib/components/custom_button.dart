import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/styled_box.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? label;
  final Widget? icon;
  final bool? isSubbutton;
  const CustomButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.isSubbutton,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      minSize: 0,
      padding: const EdgeInsets.all(0),
      child: StyledBox(
        borderRadius: isSubbutton == true ? 5 : null,
        borderThickness: isSubbutton == true ? 0 : null,
        overrideInnerDecoration: isSubbutton == true
            ? BoxDecoration(
                color: const Color(0xff434752),
                borderRadius: BorderRadius.circular(5),
              )
            : null,
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
                            ? Colors.white
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
