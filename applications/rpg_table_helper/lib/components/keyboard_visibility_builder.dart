import 'package:flutter/widgets.dart';

/// Rebuilds whenever the software keyboard opens or closes.
///
/// Reads the raw view insets on purpose: inside a [Scaffold] body the
/// keyboard inset is removed from [MediaQuery], so widgets there can neither
/// see the keyboard nor get rebuilt when it appears.
class KeyboardVisibilityBuilder extends StatefulWidget {
  const KeyboardVisibilityBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, bool isKeyboardVisible) builder;

  @override
  State<KeyboardVisibilityBuilder> createState() =>
      _KeyboardVisibilityBuilderState();
}

class _KeyboardVisibilityBuilderState extends State<KeyboardVisibilityBuilder>
    with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isKeyboardVisible = _readKeyboardVisible();
  }

  @override
  void didChangeMetrics() {
    final visible = _readKeyboardVisible();
    if (visible != _isKeyboardVisible && mounted) {
      setState(() => _isKeyboardVisible = visible);
    }
  }

  bool _readKeyboardVisible() => View.of(context).viewInsets.bottom > 0;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _isKeyboardVisible);
}
