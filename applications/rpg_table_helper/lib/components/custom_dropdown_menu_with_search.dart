import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';

class CustomDropdownMenuWithSearch extends StatelessWidget {
  const CustomDropdownMenuWithSearch({
    super.key,
    required this.selectedValueTemp,
    required this.setter,
    required this.items,
    required this.label,
    required this.newDesign,
    this.noBorder,
  });
  final String label;
  final bool newDesign;
  final String? selectedValueTemp;
  final Null Function(String? newValue) setter;
  final List<DropdownMenuEntry<String?>> items;
  final bool? noBorder;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              fillColor: newDesign == true ? darkColor : null,
              enabledBorder: noBorder == true
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                      color: newDesign == true ? darkColor : Color(0xff938f99),
                    )),
            ),
      ),
      child: DropdownMenu<String?>(
        trailingIcon: Icon(
          Icons.arrow_drop_down,
          color: newDesign ? darkColor : textColor,
        ),
        selectedTrailingIcon: Icon(
          Icons.arrow_drop_up,
          color: newDesign ? darkColor : textColor,
        ),
        textStyle: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: newDesign ? darkTextColor : textColor),
        expandedInsets: EdgeInsets.zero,
        label: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: newDesign ? darkTextColor : textColor),
        ),
        dropdownMenuEntries: items,
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: newDesign == true ? darkTextColor : textColor),
              filled: true,
              iconColor: darkTextColor,
              fillColor: const Color.fromARGB(0, 0, 0, 0),
              border: noBorder == true
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(
                      color: newDesign == true ? darkColor : Color(0xff938f99),
                    )),
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
          final int index = entries.indexWhere(
              (entry) => entry.label.toLowerCase().contains(searchText));
          return index != -1 ? index : null;
        },
      ),
    );
  }
}
