import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/constants.dart';

class CustomIntEditField extends StatefulWidget {
  final void Function(int newValue) onValueChange;
  final String label;
  final int startValue;
  final int minValue;
  final int maxValue;
  const CustomIntEditField({
    super.key,
    required this.onValueChange,
    required this.label,
    required this.startValue,
    this.minValue = -999,
    this.maxValue = 999,
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
  void dispose() {
    textEditingController.removeListener(onTextEditControllerValueChange);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButtonNewdesign(
          isSubbutton: true,
          variant: CustomButtonNewdesignVariant.DarkButton,
          onPressed: () {
            setState(() {
              currentValue = max(widget.minValue, currentValue - 1);
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
              newDesign: true,
            ),
          ),
        ),
        CustomButtonNewdesign(
          isSubbutton: true,
          variant: CustomButtonNewdesignVariant.DarkButton,
          onPressed: () {
            setState(() {
              currentValue = min(widget.maxValue, currentValue + 1);

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

    tempValue = min(widget.maxValue, max(widget.minValue, tempValue));

    setState(() {
      currentValue = tempValue!;
      widget.onValueChange(currentValue);
    });
  }
}
