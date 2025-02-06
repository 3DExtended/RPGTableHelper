import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/constants.dart';

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
            color: textColor,
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
            color: textColor,
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
