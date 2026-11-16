import 'package:flutter/services.dart';

/// Number of digits in a campagne join code (`123-456`).
const int joinCodeDigitCount = 6;

/// Brings any input into the join code shape `###-###`.
///
/// Drops everything that is not a digit, keeps at most six digits and puts
/// the hyphen after the third one. Pasting "Code: 699 457" gives `699-457`.
String formatJoinCode(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length > joinCodeDigitCount) {
    digits = digits.substring(0, joinCodeDigitCount);
  }
  if (digits.length <= 3) return digits;
  return '${digits.substring(0, 3)}-${digits.substring(3)}';
}

/// Masks a text field as `###-###` while typing.
class JoinCodeInputFormatter extends TextInputFormatter {
  const JoinCodeInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatJoinCode(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

enum JoinCodeProblem { empty, incomplete }

/// `null` when [text] is a complete join code.
JoinCodeProblem? validateJoinCode(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return JoinCodeProblem.empty;
  if (digits.length != joinCodeDigitCount) return JoinCodeProblem.incomplete;
  return null;
}
