import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/services/character_setup_prompt_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The character form opens by itself only once per character.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('a new character was not prompted yet', () async {
    expect(await wasCharacterSetupPrompted('char-1'), isFalse);
  });

  test('remembers each prompted character on its own', () async {
    await markCharacterSetupPrompted('char-1');

    expect(await wasCharacterSetupPrompted('char-1'), isTrue);
    expect(await wasCharacterSetupPrompted('char-2'), isFalse);

    await markCharacterSetupPrompted('char-2');
    await markCharacterSetupPrompted('char-1');

    expect(await wasCharacterSetupPrompted('char-2'), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(characterSetupPromptedPrefsKey),
        ['char-1', 'char-2']);
  });
}
