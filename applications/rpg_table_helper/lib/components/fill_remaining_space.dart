import 'package:flutter/material.dart';

class FillRemainingSpace extends StatelessWidget {
  const FillRemainingSpace({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [child],
          ),
        ),
      ],
    );
  }
}
