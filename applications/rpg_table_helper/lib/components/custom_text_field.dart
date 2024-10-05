import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.labelText,
    required this.textEditingController,
    required this.keyboardType,
  });

  final TextInputType keyboardType;
  final String labelText;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        minLines: keyboardType == TextInputType.multiline ? 5 : null,
        maxLines: keyboardType == TextInputType.multiline ? 5 : null,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.sentences,
        enableSuggestions: true,
        scribbleEnabled: true,
        decoration: InputDecoration(
          labelText: labelText, // TODO localize
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
          hintStyle: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Colors.white),
          labelStyle: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Colors.white),
        ),
        style: Theme.of(context)
            .textTheme
            .labelLarge!
            .copyWith(color: Colors.white),
        controller: textEditingController,
      ),
    );
  }
}
