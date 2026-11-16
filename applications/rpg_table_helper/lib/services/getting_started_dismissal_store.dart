import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers on this device for which campagne the game master hid "Erste
/// Schritte".
const gettingStartedDismissedPrefsKeyPrefix = 'gettingStartedDismissed:';

Future<bool> isGettingStartedDismissed(String campagneId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$gettingStartedDismissedPrefsKeyPrefix$campagneId') ??
        false;
  } catch (e) {
    debugPrint('Could not read the hidden getting started list: $e');
    return false;
  }
}

Future<void> dismissGettingStarted(String campagneId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$gettingStartedDismissedPrefsKeyPrefix$campagneId', true);
  } catch (e) {
    debugPrint('Could not save the hidden getting started list: $e');
  }
}
