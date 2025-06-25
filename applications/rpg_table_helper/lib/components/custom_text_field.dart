import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.labelText,
      required this.textEditingController,
      required this.keyboardType,
      this.password,
      this.placeholderText,
      this.disableMaxLineLimit});
  final bool? disableMaxLineLimit;
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
              ? (disableMaxLineLimit == true ? null : 5)
              : (password == true ? 1 : null),
          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.sentences,
          obscureText: password ?? false,
          enableSuggestions: true,
          scrollPhysics: disableMaxLineLimit == true
              ? NeverScrollableScrollPhysics()
              : null,
          scribbleEnabled: true,
          decoration: InputDecoration(
            suffixIcon: contraints.maxWidth > 350 &&
                    keyboardType != TextInputType.multiline
                ? CustomButton(
                    isSubbutton: true,
                    variant: CustomButtonVariant.FlatButton,
                    icon: CustomFaIcon(
                        color: CustomThemeProvider.of(context).theme.darkColor,
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
              borderSide: BorderSide(
                  width: 1,
                  color: CustomThemeProvider.of(context).theme.darkColor),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1,
                  color: CustomThemeProvider.of(context).theme.darkColor),
            ),
            hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontFamily: "Ruwudu",
                color: CustomThemeProvider.of(context).theme.darkTextColor),
            labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontFamily: "Ruwudu",
                color: CustomThemeProvider.of(context).theme.darkTextColor),
            helperStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontFamily: "Ruwudu",
                color: CustomThemeProvider.of(context).theme.darkTextColor),
          ),
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontFamily: "Ruwudu",
              color: CustomThemeProvider.of(context).theme.darkTextColor),
          controller: textEditingController,
        ),
      );
    });
  }
}
