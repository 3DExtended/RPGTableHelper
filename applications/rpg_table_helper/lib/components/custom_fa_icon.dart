import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomFaIcon extends StatelessWidget {
  const CustomFaIcon({
    super.key,
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 16,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        child: Container(
            width: 24,
            height: 24,
            alignment: AlignmentDirectional.center,
            child: FaIcon(icon)));
  }
}
