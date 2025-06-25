import 'package:flutter/material.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class CustomDropdownMenu extends StatelessWidget {
  const CustomDropdownMenu({
    super.key,
    required this.selectedValueTemp,
    required this.setter,
    required this.items,
    required this.label,
    this.noBorder,
  });
  final String label;
  final bool? noBorder;
  final String? selectedValueTemp;
  final Null Function(String? newValue) setter;
  final List<DropdownMenuItem<String?>> items;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              fillColor: CustomThemeProvider.of(context).theme.darkColor,
              enabledBorder: noBorder == true
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                      color: CustomThemeProvider.of(context).theme.darkColor,
                    )),
            ),
      ),
      child: DropdownButtonFormField<String?>(
        iconEnabledColor: CustomThemeProvider.of(context).theme.darkColor,
        iconDisabledColor: const Color.fromARGB(255, 140, 133, 125),
        borderRadius: BorderRadius.circular(10),
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: CustomThemeProvider.of(context).theme.darkTextColor,
              fontSize: noBorder == true ? 24 : null,
              height: noBorder == true ? 1 : null,
            ),
        decoration: InputDecoration(
          labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: CustomThemeProvider.of(context).theme.darkTextColor),
          filled: true,
          fillColor: const Color.fromARGB(0, 0, 0, 0),
          labelText: label,
          border: noBorder == true
              ? InputBorder.none
              : OutlineInputBorder(
                  borderSide: BorderSide(
                  color: CustomThemeProvider.of(context).theme.darkColor,
                )),
        ),
        dropdownColor: CustomThemeProvider.of(context).theme.bgColor,
        value: selectedValueTemp,
        isDense: true,
        onChanged: setter,
        items: items,
      ),
    );
  }
}
