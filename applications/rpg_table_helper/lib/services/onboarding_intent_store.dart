import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the user picked on the welcome screen before signing in. The role
/// selection after sign-in can use it to open the matching path.
enum OnboardingIntent {
  /// "I run a game": the user wants to lead a campaign as game master.
  lead,

  /// "I'm joining a game": the user wants to join a campaign with the code
  /// from their game master.
  join,
}

/// SharedPreferences key under which the [OnboardingIntent] is kept.
const onboardingIntentPrefsKey = 'onboardingIntent';

/// Keeps [intent] on this device until it is cleared.
Future<void> saveOnboardingIntent(OnboardingIntent intent) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(onboardingIntentPrefsKey, intent.name);
  } catch (e) {
    debugPrint('Could not save onboarding intent: $e');
  }
}

/// Returns the stored intent, or null if none (or an unknown one) is stored.
Future<OnboardingIntent?> readOnboardingIntent() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(onboardingIntentPrefsKey);
    if (raw == null) return null;
    for (final intent in OnboardingIntent.values) {
      if (intent.name == raw) return intent;
    }
    return null;
  } catch (e) {
    debugPrint('Could not read onboarding intent: $e');
    return null;
  }
}

/// Forgets the stored intent, e.g. once the role selection has used it.
Future<void> clearOnboardingIntent() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(onboardingIntentPrefsKey);
  } catch (e) {
    debugPrint('Could not clear onboarding intent: $e');
  }
}
