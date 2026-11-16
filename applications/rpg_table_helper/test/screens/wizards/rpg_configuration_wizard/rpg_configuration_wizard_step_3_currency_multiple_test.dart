import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_3_currency_definition.dart';

/// The exchange rate of a currency (B14): text never turns into a silent 0.
void main() {
  test('accepts whole numbers greater than 1', () {
    expect(parseCurrencyMultiple('2'), 2);
    expect(parseCurrencyMultiple(' 100 '), 100);
  });

  test('rejects text, empty, 0, 1 and negative values', () {
    expect(parseCurrencyMultiple('zehn'), isNull);
    expect(parseCurrencyMultiple(''), isNull);
    expect(parseCurrencyMultiple(null), isNull);
    expect(parseCurrencyMultiple('0'), isNull);
    expect(parseCurrencyMultiple('1'), isNull);
    expect(parseCurrencyMultiple('-10'), isNull);
  });
}
