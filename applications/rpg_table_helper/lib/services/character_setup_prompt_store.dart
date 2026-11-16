import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers on this device for which characters the character form was
/// already opened by itself. It opens by itself only once per character;
/// after that the "Noch leer – tippen zum Ausfüllen" placeholders on the
/// sheet lead to the missing fields.
const characterSetupPromptedPrefsKey = 'characterSetupPrompted';

/// True if the form was already opened by itself for [characterUuid].
Future<bool> wasCharacterSetupPrompted(String characterUuid) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(characterSetupPromptedPrefsKey) ?? const [])
        .contains(characterUuid);
  } catch (e) {
    debugPrint('Could not read character setup prompts: $e');
    // Better to skip the form than to open it on every visit.
    return true;
  }
}

/// Notes that the form was opened by itself for [characterUuid].
Future<void> markCharacterSetupPrompted(String characterUuid) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final prompted =
        prefs.getStringList(characterSetupPromptedPrefsKey) ?? <String>[];
    if (prompted.contains(characterUuid)) return;
    await prefs.setStringList(
        characterSetupPromptedPrefsKey, [...prompted, characterUuid]);
  } catch (e) {
    debugPrint('Could not save character setup prompt: $e');
  }
}
