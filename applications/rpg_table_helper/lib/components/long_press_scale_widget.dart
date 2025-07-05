import 'package:flutter/widgets.dart';

class LongPressScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onLongPress;

  const LongPressScaleWidget({
    super.key,
    required this.child,
    required this.onLongPress,
  });

  @override
  _LongPressScaleWidgetState createState() => _LongPressScaleWidgetState();
}

class _LongPressScaleWidgetState extends State<LongPressScaleWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressCancel: () {
        setState(() => _pressed = false);
      },
      onLongPress: () {
        Future.delayed(Duration(milliseconds: 150), () {
          widget.onLongPress();
          setState(() => _pressed = false);
        });
      },
      onLongPressStart: (_) => setState(() => _pressed = true),
      onLongPressEnd: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
