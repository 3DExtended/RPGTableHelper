import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/join_code_input_formatter.dart';

TextEditingValue _type(String text) => const JoinCodeInputFormatter()
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

void main() {
  group('formatJoinCode', () {
    test('puts the hyphen after the third digit', () {
      expect(formatJoinCode('6'), '6');
      expect(formatJoinCode('699'), '699');
      expect(formatJoinCode('6994'), '699-4');
      expect(formatJoinCode('699457'), '699-457');
    });

    test('keeps at most six digits', () {
      expect(formatJoinCode('6994571'), '699-457');
    });

    test('drops everything but digits (pasted text)', () {
      expect(formatJoinCode('Code: 699 457'), '699-457');
      expect(formatJoinCode('699-457'), '699-457');
      expect(formatJoinCode('abc'), '');
    });
  });

  group('JoinCodeInputFormatter', () {
    test('masks while typing and keeps the cursor at the end', () {
      final value = _type('69945');
      expect(value.text, '699-45');
      expect(value.selection, const TextSelection.collapsed(offset: 6));
    });

    test('deleting back over the hyphen drops it', () {
      expect(_type('699-').text, '699');
    });
  });

  group('validateJoinCode', () {
    test('empty', () {
      expect(validateJoinCode(''), JoinCodeProblem.empty);
      expect(validateJoinCode('-'), JoinCodeProblem.empty);
    });

    test('incomplete', () {
      expect(validateJoinCode('699-45'), JoinCodeProblem.incomplete);
      expect(validateJoinCode('6'), JoinCodeProblem.incomplete);
    });

    test('complete', () {
      expect(validateJoinCode('699-457'), isNull);
      expect(validateJoinCode('699457'), isNull);
    });
  });
}
