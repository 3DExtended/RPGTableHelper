import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class CustomFaIcon extends StatelessWidget {
  const CustomFaIcon(
      {super.key, required this.icon, this.size, this.color, this.noPadding});

  final Color? color;
  final IconData icon;
  final double? size;
  final bool? noPadding;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          iconTheme: IconThemeData(
            color: color ?? CustomThemeProvider.of(context).theme.textColor,
            size: size ?? 16,
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(
              color: color ?? CustomThemeProvider.of(context).theme.textColor,
            ),
          ),
        ),
        child: Container(
            width: (size ?? 16) + (noPadding == true ? 0 : 8),
            height: (size ?? 16) + (noPadding == true ? 0 : 8),
            alignment: AlignmentDirectional.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: FaIcon(icon),
            )));
  }
}
