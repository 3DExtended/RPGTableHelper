import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.labelText,
      required this.textEditingController,
      required this.keyboardType,
      this.password,
      this.placeholderText});

  final TextInputType keyboardType;
  final String labelText;
  final TextEditingController textEditingController;
  final String? placeholderText;
  final bool? password;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contraints) {
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
            suffixIcon: contraints.maxWidth > 350 &&
                    keyboardType != TextInputType.multiline
                ? CustomButton(
                    isSubbutton: true,
                    variant: CustomButtonVariant.FlatButton,
                    icon: CustomFaIcon(
                        color: darkColor,
                        size: 16,
                        icon: FontAwesomeIcons.xmark),
                    onPressed: () {
                      textEditingController.clear();
                    },
                  )
                : null,
            helperText: placeholderText,
            labelText: labelText,
            alignLabelWithHint: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: darkColor),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: darkColor),
            ),
            hintStyle: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: darkTextColor),
            labelStyle: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: darkTextColor),
            helperStyle: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: darkTextColor),
          ),
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: darkTextColor),
          controller: textEditingController,
        ),
      );
    });
  }
}
