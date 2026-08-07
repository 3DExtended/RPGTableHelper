import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class CustomIntEditField extends StatefulWidget {
  final void Function(int newValue) onValueChange;
  final String label;
  final int startValue;
  final int? minValue;
  final int? maxValue;
  const CustomIntEditField({
    super.key,
    required this.onValueChange,
    required this.label,
    required this.startValue,
    this.minValue,
    this.maxValue,
  });

  @override
  State<CustomIntEditField> createState() => _CustomIntEditFieldState();
}

class _CustomIntEditFieldState extends State<CustomIntEditField> {
  int currentValue = 0;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    currentValue = widget.startValue;
    textEditingController.text = currentValue.toString();
    textEditingController.addListener(onTextEditControllerValueChange);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomIntEditField oldWidget) {
    Future.delayed(Duration.zero, () {
      if (currentValue != widget.startValue) {
        if (!mounted) return;
        setState(() {
          currentValue = widget.startValue;
          textEditingController.text = currentValue.toString();
        });
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    textEditingController.removeListener(onTextEditControllerValueChange);
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isDecoratedSheetSkinActive(context)) {
      return _buildLedger(context);
    }
    return _buildClassic(context);
  }

  Widget _buildLedger(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkTextColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _LedgerStepButton(
          ink: ink,
          icon: FontAwesomeIcons.minus,
          enabled:
              widget.minValue == null || currentValue > widget.minValue!,
          onPressed: () {
            setState(() {
              currentValue = widget.minValue == null
                  ? currentValue - 1
                  : max(widget.minValue!, currentValue - 1);
              textEditingController.text = currentValue.toString();
            });
            widget.onValueChange(currentValue);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CustomPaint(
            painter: _LedgerValueBoxPainter(ink: ink),
            child: SizedBox(
              width: 64,
              height: 36,
              child: Center(
                child: TextField(
                  controller: textEditingController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: ink,
                        fontSize: 18,
                        fontFamily: 'Ruwudu',
                        fontWeight: FontWeight.w600,
                      ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        ),
        _LedgerStepButton(
          ink: ink,
          icon: FontAwesomeIcons.plus,
          enabled:
              widget.maxValue == null || currentValue < widget.maxValue!,
          onPressed: () {
            setState(() {
              currentValue = widget.maxValue == null
                  ? currentValue + 1
                  : min(widget.maxValue!, currentValue + 1);
              textEditingController.text = currentValue.toString();
            });
            widget.onValueChange(currentValue);
          },
        ),
      ],
    );
  }

  Widget _buildClassic(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          isSubbutton: true,
          variant: CustomButtonVariant.DarkButton,
          onPressed: widget.minValue != null && currentValue <= widget.minValue!
              ? null
              : () {
                  setState(() {
                    currentValue = widget.minValue == null
                        ? currentValue - 1
                        : max(widget.minValue!, currentValue - 1);
                    textEditingController.text = currentValue.toString();
                  });

                  widget.onValueChange(currentValue);
                },
          icon: CustomFaIcon(
            icon: FontAwesomeIcons.minus,
            size: iconSizeInlineButtons,
            color: CustomThemeProvider.of(context).theme.textColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SizedBox(
            width: 100,
            child: CustomTextField(
              labelText: widget.label,
              textEditingController: textEditingController,
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        CustomButton(
          isSubbutton: true,
          variant: CustomButtonVariant.DarkButton,
          onPressed: widget.maxValue != null && currentValue >= widget.maxValue!
              ? null
              : () {
                  setState(() {
                    currentValue = widget.maxValue == null
                        ? currentValue + 1
                        : min(widget.maxValue!, currentValue + 1);

                    textEditingController.text = currentValue.toString();
                  });

                  widget.onValueChange(currentValue);
                },
          icon: CustomFaIcon(
            icon: FontAwesomeIcons.plus,
            size: iconSizeInlineButtons,
            color: CustomThemeProvider.of(context).theme.textColor,
          ),
        ),
      ],
    );
  }

  void onTextEditControllerValueChange() {
    var tempValue = int.tryParse(textEditingController.text);
    if (tempValue == null) return;

    if (widget.minValue != null) {
      tempValue = max(widget.minValue!, tempValue);
    }
    if (widget.maxValue != null) {
      tempValue = min(widget.maxValue!, tempValue);
    }

    setState(() {
      currentValue = tempValue!;
      widget.onValueChange(currentValue);
    });
  }
}

class _LedgerStepButton extends StatelessWidget {
  final Color ink;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _LedgerStepButton({
    required this.ink,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: enabled ? onPressed : null,
      minSize: 0,
      padding: EdgeInsets.zero,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: CustomPaint(
          painter: _LedgerValueBoxPainter(ink: ink),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Center(
              child: CustomFaIcon(
                icon: icon,
                size: 14,
                color: ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LedgerValueBoxPainter extends CustomPainter {
  final Color ink;

  _LedgerValueBoxPainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final inner = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final fill = Paint()
      ..color = const Color(0x66F8F0E4)
      ..style = PaintingStyle.fill;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(2),
    );
    canvas.drawRRect(r, fill);
    canvas.drawRRect(r, outer);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
        const Radius.circular(1.5),
      ),
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerValueBoxPainter oldDelegate) =>
      oldDelegate.ink != ink;
}
