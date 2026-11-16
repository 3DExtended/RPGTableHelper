import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/colored_rotated_square.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/page_tab_strip.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

import '../custom_font_loader.dart';

const _iPhone17Pro = Size(402, 874);

const _skins = [
  CharacterSheetSkinIds.classicDark,
  CharacterSheetSkinIds.arcaneLedger,
  CharacterSheetSkinIds.nightCartographer,
];

Future<void> _pumpNavbar(
  WidgetTester tester, {
  required Widget titleWidget,
  String skinId = CharacterSheetSkinIds.classicDark,
  Widget? bottom,
}) async {
  tester.view.physicalSize = _iPhone17Pro;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 62);
  addTearDown(tester.view.reset);
  await customLoadAppFonts();

  await tester.pumpWidget(
    CustomThemeProvider(
      overrideBrightness: Brightness.dark,
      overrideSkinId: skinId,
      child: ThemeConfigurationForApp(
        child: MaterialApp(
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: Column(
              children: [
                Navbar(
                  useTopSafePadding: true,
                  backInsteadOfCloseIcon: true,
                  closeFunction: () {},
                  menuOpen: () {},
                  titleWidget: titleWidget,
                  bottom: bottom,
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The diamond row the setup wizard puts into the navbar, one per step.
Widget _wizardLikeDiamonds(int count, int current, ValueChanged<int> onTap) {
  return Builder(
    builder: (context) {
      return Row(
        children: [
          const Spacer(),
          for (var i = 0; i < count; i++)
            CupertinoButton(
              key: ValueKey('diamond-$i'),
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              onPressed: () => onTap(i),
              child: ColoredRotatedSquare(
                isSolidSquare: i == current,
                color: Colors.white,
              ),
            ),
          const Spacer(),
        ],
      );
    },
  );
}

void main() {
  for (final skinId in _skins) {
    testWidgets('$skinId: 10 diamonds fit into the navbar of a phone', (
      tester,
    ) async {
      final tapped = <int>[];
      await _pumpNavbar(
        tester,
        skinId: skinId,
        titleWidget: _wizardLikeDiamonds(10, 3, tapped.add),
      );

      // An overflow would have failed the test already; all diamonds are on
      // screen and still react.
      for (var i = 0; i < 10; i++) {
        final rect = tester.getRect(find.byKey(ValueKey('diamond-$i')));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(_iPhone17Pro.width));
      }
      await tester.tap(find.byKey(const ValueKey('diamond-9')));
      await tester.tap(find.byKey(const ValueKey('diamond-0')));
      expect(tapped, [9, 0]);
    });
  }

  testWidgets('30 diamonds still do not overflow', (tester) async {
    await _pumpNavbar(tester, titleWidget: _wizardLikeDiamonds(30, 0, (_) {}));
    final last = tester.getRect(find.byKey(const ValueKey('diamond-29')));
    expect(last.right, lessThanOrEqualTo(_iPhone17Pro.width));
  });

  testWidgets('a title that fits keeps its size and a long one still wraps', (
    tester,
  ) async {
    await _pumpNavbar(tester, titleWidget: const Text('Kurz'));
    final shortSize = tester.getSize(find.text('Kurz'));

    await _pumpNavbar(
      tester,
      titleWidget: const Text(
        'Ein sehr langer Titel, der auf einem Telefon in zwei Zeilen umbricht',
        textAlign: TextAlign.center,
      ),
    );
    final long = find.textContaining('Ein sehr langer Titel');
    // wrapped, not shrunk to one tiny line
    expect(tester.getSize(long).height, greaterThan(shortSize.height * 1.5));
    expect(tester.getRect(long).right, lessThanOrEqualTo(_iPhone17Pro.width));
  });

  testWidgets('the bottom row is shown under the bar', (tester) async {
    await _pumpNavbar(
      tester,
      titleWidget: const Text('Notizen'),
      bottom: PageTabStrip(
        items: const [
          PageTabStripItem(label: 'Werte'),
          PageTabStripItem(label: 'Notizen'),
        ],
        currentIndex: 1,
        onSelected: (_) {},
      ),
    );
    expect(
      tester.getRect(find.byKey(PageTabStrip.tabKey(0))).top,
      greaterThan(tester.getRect(find.text('Notizen').first).bottom),
    );
  });
}
