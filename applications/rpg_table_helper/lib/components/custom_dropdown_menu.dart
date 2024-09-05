import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatelessWidget {
  const CustomDropdownMenu({
    super.key,
    required this.selectedValueTemp,
    required this.setter,
    required this.items,
    required this.label,
  });
  final String label;
  final String? selectedValueTemp;
  final Null Function(String? newValue) setter;
  final List<DropdownMenuItem<String?>> items;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<String?>(
        borderRadius: BorderRadius.circular(10),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(0, 0, 0, 0),
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: selectedValueTemp,
        isDense: true,
        onChanged: setter,
        items: items,
      ),
    );
  }
}
