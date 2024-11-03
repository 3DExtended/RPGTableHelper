import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.labelText,
      required this.textEditingController,
      required this.keyboardType,
      this.newDesign,
      this.password,
      this.placeholderText});

  final TextInputType keyboardType;
  final bool? newDesign;
  final String labelText;
  final TextEditingController textEditingController;
  final String? placeholderText;
  final bool? password;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        scrollPadding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        minLines: keyboardType == TextInputType.multiline
            ? 5
            : (password == true ? 1 : null),
        maxLines: keyboardType == TextInputType.multiline
            ? 5
            : (password == true ? 1 : null),
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.sentences,
        obscureText: password ?? false,
        enableSuggestions: true,
        scribbleEnabled: true,
        decoration: InputDecoration(
          helperText: placeholderText,
          labelText: labelText,
          alignLabelWithHint: true,
          enabledBorder: newDesign != true
              ? null
              : OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: darkColor),
                ),
          border: OutlineInputBorder(
            borderSide: newDesign != true
                ? BorderSide()
                : BorderSide(width: 1, color: darkColor),
          ),
          hintStyle: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: newDesign == true ? darkTextColor : textColor),
          labelStyle: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: newDesign == true ? darkTextColor : textColor),
          helperStyle: Theme.of(context)
              .textTheme
              .labelSmall!
              .copyWith(color: newDesign == true ? darkTextColor : textColor),
        ),
        style: Theme.of(context)
            .textTheme
            .labelLarge!
            .copyWith(color: newDesign == true ? darkTextColor : textColor),
        controller: textEditingController,
      ),
    );
  }
}
