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
  final List<DropdownMenuEntry<String?>> items;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String?>(
      expandedInsets: EdgeInsets.zero,
      label: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Colors.white),
      ),
      dropdownMenuEntries: items,
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
        /*
        int? search(List<DropdownMenuEntry<T>> entries, TextEditingController textEditingController) {
    final String searchText = textEditingController.value.text.toLowerCase();
    if (searchText.isEmpty) {
      return null;
    }
    if (currentHighlight != null && entries[currentHighlight!].label.toLowerCase().contains(searchText)) {
      return currentHighlight;
    }
    final int index = entries.indexWhere((DropdownMenuEntry<T> entry) => entry.label.toLowerCase().contains(searchText));

    return index != -1 ? index : null;
  },
         */
        if (searchText.isEmpty) {
          return null;
        }
        final int index = entries.indexWhere(
            (entry) => entry.label.toLowerCase().contains(searchText));
        return index != -1 ? index : null;
      },
    );
  }
}
