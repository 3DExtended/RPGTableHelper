import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/page_tab_strip.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

import '../custom_font_loader.dart';

const _phoneWidth = 402.0;

const _playerPages = [
  'Background',
  'Werte',
  'Merkmale',
  'Angriffe',
  'Zauber',
  'Währung',
  'Inventar',
  'Herstellen',
  'Notizen',
];

Future<void> _pumpStrip(
  WidgetTester tester, {
  required List<String> labels,
  required int currentIndex,
  required ValueChanged<int> onSelected,
  bool pinLastItem = false,
}) async {
  tester.view.physicalSize = const Size(_phoneWidth, 874);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await customLoadAppFonts();

  await tester.pumpWidget(
    CustomThemeProvider(
      overrideBrightness: Brightness.dark,
      overrideSkinId: CharacterSheetSkinIds.classicDark,
      child: ThemeConfigurationForApp(
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: PageTabStrip(
                items: [for (final l in labels) PageTabStripItem(label: l)],
                currentIndex: currentIndex,
                onSelected: onSelected,
                pinLastItem: pinLastItem,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

bool _fullyOnScreen(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  return rect.left >= 0 && rect.right <= _phoneWidth;
}

void main() {
  testWidgets('many pages: the pinned notes tab is always in sight', (
    tester,
  ) async {
    final selected = <int>[];
    await _pumpStrip(
      tester,
      labels: _playerPages,
      currentIndex: 0,
      onSelected: selected.add,
      pinLastItem: true,
    );

    final notes = find.byKey(PageTabStrip.tabKey(8));
    expect(_fullyOnScreen(tester, notes), isTrue);
    // more pages than room: the last unpinned one is out of sight
    expect(_fullyOnScreen(tester, find.byKey(PageTabStrip.tabKey(7))), isFalse);

    await tester.tap(notes);
    expect(selected, [8]);
  });

  testWidgets('the current page is scrolled into view', (tester) async {
    await _pumpStrip(
      tester,
      labels: _playerPages,
      currentIndex: 7,
      onSelected: (_) {},
      pinLastItem: true,
    );
    expect(_fullyOnScreen(tester, find.byKey(PageTabStrip.tabKey(7))), isTrue);
  });

  testWidgets('few pages: all names are visible and tappable', (tester) async {
    final selected = <int>[];
    const dmPages = [
      'Kampagne',
      'Charaktere',
      'Kampf',
      'Items',
      'Notizen',
      'Bilder',
    ];
    await _pumpStrip(
      tester,
      labels: dmPages,
      currentIndex: 0,
      onSelected: selected.add,
    );

    for (var i = 0; i < dmPages.length; i++) {
      expect(find.text(dmPages[i]), findsOneWidget);
    }
    await tester.tap(find.text('Notizen'));
    expect(selected, [4]);
  });
}
