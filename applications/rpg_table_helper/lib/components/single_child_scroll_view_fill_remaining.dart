import 'package:flutter/widgets.dart';

class SingleChildScrollViewFillRemaining extends StatelessWidget {
  const SingleChildScrollViewFillRemaining({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}
