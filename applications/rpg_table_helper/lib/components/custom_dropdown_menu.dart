import 'package:flutter/material.dart';
import 'package:rpg_table_helper/constants.dart';

class CustomDropdownMenu extends StatelessWidget {
  const CustomDropdownMenu({
    super.key,
    required this.selectedValueTemp,
    required this.setter,
    required this.items,
    required this.label,
    this.newDesign,
    this.noBorder,
  });
  final String label;
  final bool? newDesign;
  final bool? noBorder;
  final String? selectedValueTemp;
  final Null Function(String? newValue) setter;
  final List<DropdownMenuItem<String?>> items;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              fillColor: newDesign == true ? darkColor : null,
              enabledBorder: noBorder == true
                  ? InputBorder.none
                  : const OutlineInputBorder(
                      borderSide: BorderSide(
                      color: Color(0xff938f99),
                    )),
            ),
      ),
      child: DropdownButtonFormField<String?>(
        borderRadius: BorderRadius.circular(10),
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: newDesign == true ? darkTextColor : textColor,
              fontSize: noBorder == true ? 24 : null,
              height: noBorder == true ? 1 : null,
            ),
        decoration: InputDecoration(
          labelStyle: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: newDesign == true ? darkTextColor : textColor),
          filled: true,
          fillColor: const Color.fromARGB(0, 0, 0, 0),
          labelText: label,
          border:
              noBorder == true ? InputBorder.none : const OutlineInputBorder(),
        ),
        dropdownColor: newDesign == true ? bgColor : null,
        value: selectedValueTemp,
        isDense: true,
        onChanged: setter,
        items: items,
      ),
    );
  }
}
