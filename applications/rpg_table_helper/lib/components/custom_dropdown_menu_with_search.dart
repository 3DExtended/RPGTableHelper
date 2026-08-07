import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
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
    if (isDecoratedSheetSkinActive(context) && noBorder != true) {
      return _buildDecorated(context);
    }
    return _buildClassic(context);
  }

  Widget _buildClassic(BuildContext context) {
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

  Widget _buildDecorated(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final ink = theme.darkTextColor;
    final cartographer = isNightCartographerActive(context);
    final menuBg = cartographer ? theme.middleBgColor : theme.bgColor;
    final textStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: ink,
          fontFamily: 'Ruwudu',
          fontWeight: FontWeight.w500,
        );

    return CustomPaint(
      painter: _DecoratedSearchFieldPlatePainter(ink: ink),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 2, 2, 2),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: menuBg,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: Colors.transparent,
                  onSurface: ink,
                ),
            inputDecorationTheme:
                Theme.of(context).inputDecorationTheme.copyWith(
                      fillColor: Colors.transparent,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
          ),
          child: DropdownMenu<String?>(
            trailingIcon: Icon(Icons.arrow_drop_down, color: ink),
            selectedTrailingIcon: Icon(Icons.arrow_drop_up, color: ink),
            textStyle: textStyle,
            expandedInsets: EdgeInsets.zero,
            label: Text(label, style: textStyle),
            dropdownMenuEntries: items,
            inputDecorationTheme:
                Theme.of(context).inputDecorationTheme.copyWith(
                      labelStyle: textStyle,
                      filled: false,
                      iconColor: ink,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
            initialSelection: selectedValueTemp,
            enableFilter: true,
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(menuBg),
              alignment: Alignment.bottomLeft,
              maximumSize: const WidgetStatePropertyAll(
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
        ),
      ),
    );
  }
}

class _DecoratedSearchFieldPlatePainter extends CustomPainter {
  final Color ink;

  _DecoratedSearchFieldPlatePainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(2),
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.5, 3.5, size.width - 7, size.height - 7),
      const Radius.circular(1),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawRRect(
      inner,
      Paint()
        ..color = ink.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
  }

  @override
  bool shouldRepaint(covariant _DecoratedSearchFieldPlatePainter oldDelegate) =>
      oldDelegate.ink != ink;
}
