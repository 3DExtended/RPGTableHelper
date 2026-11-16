import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers on this device which template update the game master set
/// aside per campaign ("Ausblenden"). A later template change gives a new
/// signature, and the note shows again.
const templateUpdateDismissedPrefsKeyPrefix = 'templateUpdateDismissed:';

/// Whether the update with [signature] was set aside for [campagneKey].
Future<bool> isTemplateUpdateDismissed(
  String campagneKey,
  String signature,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$templateUpdateDismissedPrefsKeyPrefix$campagneKey') ==
        signature;
  } catch (e) {
    debugPrint('Could not read the dismissed template update: $e');
    return false;
  }
}

Future<void> dismissTemplateUpdate(String campagneKey, String signature) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$templateUpdateDismissedPrefsKeyPrefix$campagneKey',
      signature,
    );
  } catch (e) {
    debugPrint('Could not save the dismissed template update: $e');
  }
}
