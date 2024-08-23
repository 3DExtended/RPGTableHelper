import 'package:flutter/material.dart';

class FillRemainingSpace extends StatelessWidget {
  const FillRemainingSpace({
    super.key,
    required this.child,
  });

  final Container child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [child],
        ),
      ],
    );
  }
}
