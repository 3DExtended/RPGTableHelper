import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomFaIcon extends StatelessWidget {
  const CustomFaIcon({super.key, required this.icon, this.size, this.color});

  final Color? color;
  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          iconTheme: IconThemeData(
            color: color ?? Colors.white,
            size: size ?? 16,
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(
              color: color ?? Colors.white,
            ),
          ),
        ),
        child: Container(
            width: (size ?? 16) + 8,
            height: (size ?? 16) + 8,
            alignment: AlignmentDirectional.center,
            child: FaIcon(icon)));
  }
}
