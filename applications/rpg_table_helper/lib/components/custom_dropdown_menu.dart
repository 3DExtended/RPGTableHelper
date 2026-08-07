import 'package:flutter/material.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
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
        initialValue: selectedValueTemp,
        isDense: true,
        onChanged: setter,
        items: items,
      ),
    );
  }

  /// Double-rule ink field matching lore outlined controls under Ledger & Cartographer.
  Widget _buildDecorated(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final ink = theme.darkTextColor;
    final cartographer = isNightCartographerActive(context);
    final menuBg = cartographer ? theme.middleBgColor : theme.bgColor;
    final textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          color: ink,
          fontFamily: 'Ruwudu',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        );

    return CustomPaint(
      painter: _DecoratedFieldPlatePainter(ink: ink),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: menuBg,
            splashColor: ink.withValues(alpha: 0.12),
            highlightColor: ink.withValues(alpha: 0.08),
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: Colors.transparent,
                  onSurface: ink,
                ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String?>(
              icon: Icon(Icons.arrow_drop_down, color: ink, size: 28),
              iconEnabledColor: ink,
              iconDisabledColor: ink.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
              style: textStyle,
              decoration: InputDecoration(
                labelStyle: textStyle,
                floatingLabelStyle: textStyle,
                filled: false,
                isDense: true,
                labelText: label,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              ),
              dropdownColor: menuBg,
              initialValue: selectedValueTemp,
              isDense: true,
              onChanged: setter,
              items: items,
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-opacity double-rule plate (same language as lore outlined buttons).
class _DecoratedFieldPlatePainter extends CustomPainter {
  final Color ink;

  _DecoratedFieldPlatePainter({required this.ink});

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
  bool shouldRepaint(covariant _DecoratedFieldPlatePainter oldDelegate) =>
      oldDelegate.ink != ink;
}
