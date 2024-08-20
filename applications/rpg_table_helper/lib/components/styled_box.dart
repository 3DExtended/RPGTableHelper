import 'package:flutter/material.dart';

class StyledBox extends StatelessWidget {
  final Widget child;

  const StyledBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: child,
    );
  }
}
