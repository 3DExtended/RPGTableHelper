import 'package:flutter/material.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class CustomDropdownMenuWithSearch extends StatelessWidget {
  const CustomDropdownMenuWithSearch({
    super.key,
    required this.selectedValueTemp,
    required this.setter,
    required this.items,
    required this.label,
    this.noBorder,
  });
  final String label;
  final String? selectedValueTemp;
  final Null Function(String? newValue) setter;
  final List<DropdownMenuEntry<String?>> items;
  final bool? noBorder;

  InputBorder _getBorder(BuildContext context) {
    if (noBorder == true) {
      return InputBorder.none;
    }

    return OutlineInputBorder(
      borderSide:
          BorderSide(color: CustomThemeProvider.of(context).theme.darkColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              fillColor: CustomThemeProvider.of(context).theme.darkColor,
              enabledBorder: _getBorder(context),
            ),
      ),
      child: DropdownMenu<String?>(
        trailingIcon: Icon(
          Icons.arrow_drop_down,
          color: CustomThemeProvider.of(context).theme.darkColor,
        ),
        selectedTrailingIcon: Icon(
          Icons.arrow_drop_up,
          color: CustomThemeProvider.of(context).theme.darkColor,
        ),
        textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: CustomThemeProvider.of(context).theme.darkTextColor),
        expandedInsets: EdgeInsets.zero,
        label: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: CustomThemeProvider.of(context).theme.darkTextColor),
        ),
        dropdownMenuEntries: items,
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: CustomThemeProvider.of(context).theme.darkTextColor),
              filled: true,
              iconColor: CustomThemeProvider.of(context).theme.darkTextColor,
              fillColor: const Color.fromARGB(0, 0, 0, 0),
              border: _getBorder(context),
            ),
        initialSelection: selectedValueTemp,
        enableFilter: true,
        menuStyle: const MenuStyle(
          alignment: Alignment.bottomLeft,
          maximumSize: WidgetStatePropertyAll(
            Size.fromHeight(350),
          ),
        ),
        requestFocusOnTap: true,
        onSelected: setter,
        searchCallback: (entries, searchText) {
          if (searchText.isEmpty) {
            return null;
          }
          final int index = entries.indexWhere((entry) =>
              entry.label.toLowerCase().contains(searchText.toLowerCase()));
          return index != -1 ? index : null;
        },
      ),
    );
  }
}
