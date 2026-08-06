import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CharacterSheetLevelSeal shows dynamic level and abbr',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CharacterSheetLevelSeal(
              level: 12,
              levelAbbr: 'LVL',
              size: 96,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('12'), findsOneWidget);
    expect(find.text('LVL'), findsOneWidget);
    expect(find.text('6'), findsNothing);
  });

  testWidgets('CharacterSheetLevelSeal updates when level changes',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CharacterSheetLevelSeal(level: 3, levelAbbr: 'LVL'),
        ),
      ),
    );
    expect(find.text('3'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CharacterSheetLevelSeal(level: 9, levelAbbr: 'LVL'),
        ),
      ),
    );
    expect(find.text('9'), findsOneWidget);
    expect(find.text('3'), findsNothing);
  });
}
