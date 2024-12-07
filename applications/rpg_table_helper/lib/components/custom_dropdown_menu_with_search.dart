import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';

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

  InputBorder _getBorder() {
    if (noBorder == true) {
      return InputBorder.none;
    }

    return OutlineInputBorder(
      borderSide: BorderSide(color: darkColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              fillColor: darkColor,
              enabledBorder: _getBorder(),
            ),
      ),
      child: DropdownMenu<String?>(
        trailingIcon: Icon(
          Icons.arrow_drop_down,
          color: darkColor,
        ),
        selectedTrailingIcon: Icon(
          Icons.arrow_drop_up,
          color: darkColor,
        ),
        textStyle: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: darkTextColor),
        expandedInsets: EdgeInsets.zero,
        label: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: darkTextColor),
        ),
        dropdownMenuEntries: items,
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              labelStyle: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: darkTextColor),
              filled: true,
              iconColor: darkTextColor,
              fillColor: const Color.fromARGB(0, 0, 0, 0),
              border: _getBorder(),
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
