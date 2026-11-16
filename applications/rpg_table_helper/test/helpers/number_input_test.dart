import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/number_input.dart';

void main() {
  group('signedIntKeyboardType', () {
    test('is a number keyboard with a sign (iOS shows minus and return)', () {
      expect(
        signedIntKeyboardType,
        const TextInputType.numberWithOptions(signed: true),
      );
      expect(signedIntKeyboardType, isNot(TextInputType.number));
    });
  });

  group('parseSignedInt', () {
    test('accepts negative and positive whole numbers', () {
      expect(parseSignedInt('-1'), -1);
      expect(parseSignedInt('+2'), 2);
      expect(parseSignedInt('17'), 17);
      expect(parseSignedInt(' -3 '), -3);
    });

    test('accepts the typographic minus signs keyboards insert', () {
      expect(parseSignedInt('−1'), -1); // −1
      expect(parseSignedInt('–4'), -4); // –4
    });

    test('returns null instead of 0 for empty or invalid input', () {
      expect(parseSignedInt(null), isNull);
      expect(parseSignedInt(''), isNull);
      expect(parseSignedInt('   '), isNull);
      expect(parseSignedInt('-'), isNull);
      expect(parseSignedInt('1.5'), isNull);
      expect(parseSignedInt('Waldläuferin'), isNull);
      expect(parseSignedInt('3a'), isNull);
    });
  });

  group('isEmptyOrSignedInt', () {
    test('empty means not filled in yet, which is valid', () {
      expect(isEmptyOrSignedInt(''), isTrue);
      expect(isEmptyOrSignedInt(null), isTrue);
      expect(isEmptyOrSignedInt('-1'), isTrue);
    });

    test('text is invalid', () {
      expect(isEmptyOrSignedInt('abc'), isFalse);
      expect(isEmptyOrSignedInt('-'), isFalse);
    });
  });

  group('parseCharacterLevel', () {
    test('accepts whole numbers of 0 or more', () {
      expect(parseCharacterLevel('0'), 0);
      expect(parseCharacterLevel('3'), 3);
      expect(parseCharacterLevel(' 12 '), 12);
    });

    test('rejects text, empty and negative levels', () {
      expect(parseCharacterLevel('Waldläuferin'), isNull);
      expect(parseCharacterLevel(''), isNull);
      expect(parseCharacterLevel('-1'), isNull);
    });
  });

  group('parseNonNegativeInt (prices, difficulty classes)', () {
    test('accepts 0 and more', () {
      expect(parseNonNegativeInt('0'), 0);
      expect(parseNonNegativeInt(' 250 '), 250);
    });

    test('rejects text, empty and negative values instead of using 0', () {
      expect(parseNonNegativeInt('viel'), isNull);
      expect(parseNonNegativeInt(''), isNull);
      expect(parseNonNegativeInt('-3'), isNull);
      expect(parseNonNegativeInt('−3'), isNull);
    });
  });

  group('parsePositiveInt (amounts)', () {
    test('accepts 1 and more', () {
      expect(parsePositiveInt('1'), 1);
      expect(parsePositiveInt('12'), 12);
    });

    test('rejects text, empty, 0 and negative values instead of using 1', () {
      expect(parsePositiveInt('zwei'), isNull);
      expect(parsePositiveInt(''), isNull);
      expect(parsePositiveInt('0'), isNull);
      expect(parsePositiveInt('-2'), isNull);
    });
  });

  group('numberFieldError', () {
    test('an empty field shows no error yet', () {
      expect(numberFieldError(null, parseSignedInt, 'error'), isNull);
      expect(numberFieldError('  ', parseSignedInt, 'error'), isNull);
    });

    test('shows the message when the parser rejects the text', () {
      expect(numberFieldError('abc', parseSignedInt, 'error'), 'error');
      expect(numberFieldError('-1', parseNonNegativeInt, 'error'), 'error');
      expect(numberFieldError('0', parsePositiveInt, 'error'), 'error');
    });

    test('shows nothing when the parser accepts the text', () {
      expect(numberFieldError('-1', parseSignedInt, 'error'), isNull);
      expect(numberFieldError('0', parseNonNegativeInt, 'error'), isNull);
      expect(numberFieldError('3', parsePositiveInt, 'error'), isNull);
    });
  });
}
