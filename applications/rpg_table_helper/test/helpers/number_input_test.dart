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
}
