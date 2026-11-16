import 'package:flutter/services.dart';

/// Keyboard for whole numbers that may be negative (modifiers, HP, money).
///
/// iOS shows the plain [TextInputType.number] as a number pad without a minus
/// key and without a return key, so -1 cannot be typed and the keyboard cannot
/// be closed. With `signed: true` iOS shows the numbers-and-punctuation
/// keyboard, which has both.
const TextInputType signedIntKeyboardType = TextInputType.numberWithOptions(
  signed: true,
);

/// Parses a whole number typed by the user.
///
/// Accepts surrounding spaces, a leading `+` or `-`, and the typographic minus
/// signs some keyboards insert (`−`, `–`). Returns null for empty or invalid
/// input, so callers decide what an empty field means instead of silently
/// turning text into 0.
int? parseSignedInt(String? text) {
  if (text == null) return null;
  final normalized = text
      .trim()
      .replaceAll('−', '-') // minus sign
      .replaceAll('–', '-') // en dash
      .replaceAll('‒', '-'); // figure dash
  if (normalized.isEmpty) return null;
  if (!RegExp(r'^[+-]?\d+$').hasMatch(normalized)) return null;
  return int.tryParse(normalized);
}

/// True when [text] is empty or a whole number (see [parseSignedInt]).
///
/// Number fields treat an empty value as "not filled in yet"; anything else
/// that is not a whole number is an input error the UI has to show.
bool isEmptyOrSignedInt(String? text) =>
    text == null || text.trim().isEmpty || parseSignedInt(text) != null;

/// Parses a character level: a whole number of 0 or more. Returns null for
/// empty, negative or non-numeric input.
int? parseCharacterLevel(String? text) {
  final value = parseSignedInt(text);
  if (value == null || value < 0) return null;
  return value;
}
