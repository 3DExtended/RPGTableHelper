import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/onboarding_intent_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('nothing is stored before the user picked a way in', () async {
    expect(await readOnboardingIntent(), isNull);
  });

  test('stores, reads and clears the picked intent', () async {
    await saveOnboardingIntent(OnboardingIntent.join);
    expect(await readOnboardingIntent(), OnboardingIntent.join);

    await saveOnboardingIntent(OnboardingIntent.lead);
    expect(await readOnboardingIntent(), OnboardingIntent.lead);

    await clearOnboardingIntent();
    expect(await readOnboardingIntent(), isNull);
  });

  test('an unknown stored value reads as no intent', () async {
    SharedPreferences.setMockInitialValues({
      onboardingIntentPrefsKey: 'spectate',
    });

    expect(await readOnboardingIntent(), isNull);
  });
}
