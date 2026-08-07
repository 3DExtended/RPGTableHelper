import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_int_edit_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:themed/themed.dart';

enum MoneyChangeMode {
  addMoney,
  spendMoney,
}

class PlayerScreenCharacterMoney extends ConsumerStatefulWidget {
  final RpgConfigurationModel rpgConfig;
  final RpgCharacterConfiguration charToRender;
  const PlayerScreenCharacterMoney({
    super.key,
    required this.rpgConfig,
    required this.charToRender,
  });

  @override
  ConsumerState<PlayerScreenCharacterMoney> createState() =>
      _PlayerScreenCharacterMoneyState();
}

class _PlayerScreenCharacterMoneyState
    extends ConsumerState<PlayerScreenCharacterMoney> {
  var _selectedMoneyChangeMode = MoneyChangeMode.addMoney;
  List<({String label, int currentValue, int? multiplier})> _currencyValues =
      [];

  RpgCharacterConfiguration? charToRender;

  @override
  void initState() {
    _currencyValues = widget.rpgConfig.currencyDefinition.currencyTypes
        .map((e) => (
              label: e.name,
              currentValue: 0,
              multiplier: e.multipleOfPreviousValue
            ))
        .toList()
        .reversed
        .toList();
    charToRender = widget.charToRender;

    super.initState();
  }

  Color _metalTintFor(String label) {
    switch (label) {
      case 'Platin':
        return const Color(0xff8E969C);
      case 'Gold':
        return const Color(0xffC9A227);
      case 'Silber':
        return const Color(0xff9AA3A8);
      default:
        return const Color(0xffA86B3C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final ledger = isDecoratedSheetSkinActive(context);
    final ink = theme.darkTextColor;

    return SingleChildScrollView(
      child: Container(
        color: characterSheetSurfaceColor(context),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (ledger)
              Image.asset(
                ArcaneLedgerAssets.moneyBagHero,
                width: 96,
                height: 96,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              )
            else
              CustomFaIcon(
                icon: FontAwesomeIcons.sackDollar,
                size: 48,
                color: theme.darkColor,
              ),
            const SizedBox(height: 10),
            Text(
              charToRender == null
                  ? S.of(context).noMoneyDefaultText
                  : buildTextForCurrencyComparison(
                      widget.rpgConfig, charToRender!.moneyInBaseType ?? 0),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: ink,
                    fontSize: ledger ? 26 : 24,
                    fontFamily: ledger ? 'Ruwudu' : null,
                    fontWeight: ledger ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            Text(
              S.of(context).currentBalance,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: ink,
                    fontSize: 15,
                    fontStyle: ledger ? FontStyle.italic : FontStyle.normal,
                    fontFamily: ledger ? 'Ruwudu' : null,
                  ),
            ),
            SizedBox(height: ledger ? 16 : 20),
            if (!ledger) const HorizontalLine(),
            if (!ledger) const SizedBox(height: 20),
            if (ledger)
              CustomPaint(
                painter: _LedgerInkSegmentBorderPainter(ink: ink),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: _buildSegmentedControl(context, ledger: true),
                ),
              )
            else
              _buildSegmentedControl(context, ledger: false),
            SizedBox(height: ledger ? 28 : 20),
            if (ledger)
              _buildLedgerDenominationRow(context)
            else
              _buildClassicDenominationWrap(context),
            SizedBox(height: ledger ? 24 : 30),
            if (ledger) ...[
              CustomPaint(
                painter: _LedgerStarRulePainter(ink: ink),
                child: const SizedBox(width: double.infinity, height: 18),
              ),
              const SizedBox(height: 8),
              Text(
                charToRender == null
                    ? S.of(context).noMoneyDefaultText
                    : buildTextForCurrencyComparisonAfterAdjustment(
                        widget.rpgConfig, charToRender!),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: ink,
                      fontSize: 24,
                      fontFamily: 'Ruwudu',
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                S.of(context).newBalance,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: ink,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Ruwudu',
                    ),
              ),
              const SizedBox(height: 8),
              CustomPaint(
                painter: _LedgerStarRulePainter(ink: ink),
                child: const SizedBox(width: double.infinity, height: 18),
              ),
              const SizedBox(height: 20),
              _LedgerChamferedButton(
                label: _selectedMoneyChangeMode == MoneyChangeMode.addMoney
                    ? S.of(context).addBalance
                    : S.of(context).reduceBalance,
                enabled: getCurrentlyTypedBasePrice() != 0 &&
                    getNewCalculatedBasePrice(
                            widget.rpgConfig, charToRender) >=
                        0,
                onPressed: _onConfirmPressed,
              ),
            ] else ...[
              Text(
                charToRender == null
                    ? S.of(context).noMoneyDefaultText
                    : buildTextForCurrencyComparisonAfterAdjustment(
                        widget.rpgConfig, charToRender!),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: theme.darkTextColor, fontSize: 24),
              ),
              Text(
                S.of(context).newBalance,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: theme.darkTextColor, fontSize: 16),
              ),
              const SizedBox(height: 40),
              CustomButton(
                onPressed: getCurrentlyTypedBasePrice() == 0 ||
                        getNewCalculatedBasePrice(
                                widget.rpgConfig, charToRender) <
                            0
                    ? null
                    : _onConfirmPressed,
                variant: CustomButtonVariant.AccentButton,
                label: _selectedMoneyChangeMode == MoneyChangeMode.addMoney
                    ? S.of(context).addBalance
                    : S.of(context).reduceBalance,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context, {required bool ledger}) {
    final theme = CustomThemeProvider.of(context).theme;
    final cartographer = isNightCartographerActive(context);
    // Cartographer: cream thumb + navy label (gold fill reads as muddy mustard).
    // Ledger / classic: dark thumb + light label.
    final thumbColor =
        cartographer ? theme.darkTextColor : theme.darkColor;
    final selectedLabelColor =
        cartographer ? theme.bgColor : theme.textColor;
    final unselectedLabelColor = theme.darkTextColor;

    return CupertinoSlidingSegmentedControl<MoneyChangeMode>(
      backgroundColor: ledger
          ? Colors.transparent
          : (CustomThemeProvider.of(context).brightnessNotifier.value ==
                  Brightness.light
              ? theme.middleBgColor
              : theme.middleBgColor.darker(0.4)),
      thumbColor: thumbColor,
      groupValue: _selectedMoneyChangeMode,
      onValueChanged: (MoneyChangeMode? value) {
        if (value != null) {
          setState(() {
            _selectedMoneyChangeMode = value;
          });
        }
      },
      children: <MoneyChangeMode, Widget>{
        MoneyChangeMode.addMoney: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            S.of(context).addBalance,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 16,
                  fontFamily: ledger ? 'Ruwudu' : null,
                  color: _selectedMoneyChangeMode == MoneyChangeMode.addMoney
                      ? selectedLabelColor
                      : unselectedLabelColor,
                ),
          ),
        ),
        MoneyChangeMode.spendMoney: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            S.of(context).reduceBalance,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 16,
                  fontFamily: ledger ? 'Ruwudu' : null,
                  color: _selectedMoneyChangeMode == MoneyChangeMode.spendMoney
                      ? selectedLabelColor
                      : unselectedLabelColor,
                ),
          ),
        ),
      },
    );
  }

  Widget _buildClassicDenominationWrap(BuildContext context) {
    return Wrap(
      runAlignment: WrapAlignment.center,
      alignment: WrapAlignment.center,
      children: _currencyValues
          .asMap()
          .entries
          .map((cv) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomFaIcon(
                      icon: FontAwesomeIcons.sackDollar,
                      size: 40,
                      color: _metalTintFor(cv.value.label),
                    ),
                    const SizedBox(height: 15),
                    CustomIntEditField(
                      minValue: 0,
                      maxValue: 9999,
                      onValueChange: (newValue) {
                        setState(() {
                          _currencyValues[cv.key] = (
                            label: _currencyValues[cv.key].label,
                            multiplier: _currencyValues[cv.key].multiplier,
                            currentValue: newValue,
                          );
                        });
                      },
                      label: cv.value.label,
                      startValue: cv.value.currentValue,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildLedgerDenominationRow(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkTextColor;
    final children = <Widget>[];
    for (var i = 0; i < _currencyValues.length; i++) {
      if (i > 0) {
        children.add(
          CustomPaint(
            painter: _LedgerColumnDividerPainter(ink: ink),
            child: const SizedBox(width: 20, height: 190),
          ),
        );
      }
      final cv = _currencyValues[i];
      final index = i;
      children.add(
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                ArcaneLedgerAssets.moneyBagForLabel(cv.label),
                width: 78,
                height: 78,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 10),
              Text(
                cv.label,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: ink,
                      fontSize: 15,
                      fontFamily: 'Ruwudu',
                    ),
              ),
              const SizedBox(height: 10),
              CustomIntEditField(
                minValue: 0,
                maxValue: 9999,
                onValueChange: (newValue) {
                  setState(() {
                    _currencyValues[index] = (
                      label: _currencyValues[index].label,
                      multiplier: _currencyValues[index].multiplier,
                      currentValue: newValue,
                    );
                  });
                },
                label: '',
                startValue: cv.currentValue,
              ),
            ],
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  void _onConfirmPressed() {
    var newestConfig =
        ref.read(rpgCharacterConfigurationProvider).requireValue;

    var updatedChar = newestConfig.copyWith(
        moneyInBaseType:
            getNewCalculatedBasePrice(widget.rpgConfig, newestConfig));
    ref
        .read(rpgCharacterConfigurationProvider.notifier)
        .updateConfiguration(updatedChar);

    setState(() {
      charToRender = updatedChar;

      for (int i = 0; i < _currencyValues.length; i++) {
        _currencyValues[i] = (
          label: _currencyValues[i].label,
          multiplier: _currencyValues[i].multiplier,
          currentValue: 0,
        );
      }
    });
  }

  String buildTextForCurrencyComparison(
      RpgConfigurationModel rpgConfig, int moneyToVisualize) {
    var currentPlayerMoney = moneyToVisualize;

    var valueSplitInCurrency = CurrencyDefinition.valueOfItemForDefinition(
        rpgConfig.currencyDefinition, currentPlayerMoney);

    var result = "";

    var reversedCurrencyNames =
        rpgConfig.currencyDefinition.currencyTypes.reversed.toList();
    for (var i = 0; i < valueSplitInCurrency.length; i++) {
      var value = valueSplitInCurrency[i];
      if (value != 0) {
        var nameOfCurrencyValue = reversedCurrencyNames[i].name;
        result += " $value $nameOfCurrencyValue";
      }
    }

    if (result.isEmpty) {
      return "0 ${rpgConfig.currencyDefinition.currencyTypes.first.name}";
    }

    return result.trim();
  }

  String buildTextForCurrencyComparisonAfterAdjustment(
      RpgConfigurationModel rpgConfig, RpgCharacterConfiguration charToRender) {
    var updatedMoneyValue = getNewCalculatedBasePrice(rpgConfig, charToRender);

    if (_selectedMoneyChangeMode == MoneyChangeMode.addMoney) {
      return buildTextForCurrencyComparison(rpgConfig, updatedMoneyValue);
    } else {
      var updatedMoney = updatedMoneyValue;

      if (updatedMoney < 0) {
        return S.of(context).notEnoughBalance;
      }
      return buildTextForCurrencyComparison(rpgConfig, max(0, updatedMoney));
    }
  }

  int getNewCalculatedBasePrice(RpgConfigurationModel rpgConfig,
      RpgCharacterConfiguration? charToRender) {
    var currentlyTypedInBasePrice = getCurrentlyTypedBasePrice();

    if (_selectedMoneyChangeMode == MoneyChangeMode.addMoney) {
      return currentlyTypedInBasePrice + (charToRender?.moneyInBaseType ?? 0);
    } else {
      var updatedMoney =
          (charToRender?.moneyInBaseType ?? 0) - currentlyTypedInBasePrice;

      return updatedMoney;
    }
  }

  int getCurrentlyTypedBasePrice() {
    var result = 0;
    var currentMultiplier = 1;
    for (var i = (_currencyValues.length - 1); i >= 0; i--) {
      var tuple = _currencyValues[i];
      if (tuple.multiplier != null) {
        currentMultiplier *= tuple.multiplier!;
      }
      result += tuple.currentValue * currentMultiplier;
    }

    return result;
  }
}

class _LedgerInkSegmentBorderPainter extends CustomPainter {
  final Color ink;

  _LedgerInkSegmentBorderPainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final inner = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(6),
    );
    canvas.drawRRect(r, outer);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
        const Radius.circular(4),
      ),
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerInkSegmentBorderPainter oldDelegate) =>
      oldDelegate.ink != ink;
}

class _LedgerColumnDividerPainter extends CustomPainter {
  final Color ink;

  _LedgerColumnDividerPainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(x, 8), Offset(x, size.height - 8), paint);
    final star = Paint()
      ..color = ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final c = Offset(x, size.height / 2);
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -pi / 2 + i * pi / 4;
      final radius = i.isEven ? 4.0 : 1.6;
      final p = Offset(c.dx + cos(angle) * radius, c.dy + sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, star);
  }

  @override
  bool shouldRepaint(covariant _LedgerColumnDividerPainter oldDelegate) =>
      oldDelegate.ink != ink;
}

class _LedgerStarRulePainter extends CustomPainter {
  final Color ink;

  _LedgerStarRulePainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    final midY = size.height / 2;
    canvas.drawLine(Offset(24, midY), Offset(size.width / 2 - 14, midY), paint);
    canvas.drawLine(
        Offset(size.width / 2 + 14, midY), Offset(size.width - 24, midY), paint);
    final star = Paint()
      ..color = ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final c = Offset(size.width / 2, midY);
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -pi / 2 + i * pi / 4;
      final radius = i.isEven ? 5.0 : 2.0;
      final p = Offset(c.dx + cos(angle) * radius, c.dy + sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, star);
  }

  @override
  bool shouldRepaint(covariant _LedgerStarRulePainter oldDelegate) =>
      oldDelegate.ink != ink;
}

class _LedgerChamferedButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _LedgerChamferedButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkTextColor;
    return CupertinoButton(
      onPressed: enabled ? onPressed : null,
      minSize: 0,
      padding: EdgeInsets.zero,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: CustomPaint(
          painter: _LedgerChamferedBorderPainter(ink: ink),
          child: SizedBox(
            width: 280,
            height: 48,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: ink,
                      fontSize: 17,
                      fontFamily: 'Ruwudu',
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LedgerChamferedBorderPainter extends CustomPainter {
  final Color ink;

  _LedgerChamferedBorderPainter({required this.ink});

  Path _chamfer(Rect r, double c) {
    return Path()
      ..moveTo(r.left + c, r.top)
      ..lineTo(r.right - c, r.top)
      ..lineTo(r.right, r.top + c)
      ..lineTo(r.right, r.bottom - c)
      ..lineTo(r.right - c, r.bottom)
      ..lineTo(r.left + c, r.bottom)
      ..lineTo(r.left, r.bottom - c)
      ..lineTo(r.left, r.top + c)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final inner = Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(
      _chamfer(Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3), 8),
      outer,
    );
    canvas.drawPath(
      _chamfer(Rect.fromLTWH(5, 5, size.width - 10, size.height - 10), 6),
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerChamferedBorderPainter oldDelegate) =>
      oldDelegate.ink != ink;
}
