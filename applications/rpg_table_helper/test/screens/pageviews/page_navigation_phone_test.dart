import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/components/page_tab_strip.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:quest_keeper/screens/pageviews/lore_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_tabs.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../custom_font_loader.dart';

/// Page navigation with names on phones (UX test 2026-11-16: B8, SP-5,
/// SL-10).

const _campagneId = '51f263bc-37cf-44d4-90f3-87d656ae29df';
const _iPhone17Pro = Size(402, 874);
const _iPadProLandscape = Size(1366, 1024);

/// No tablet by aspect ratio (1.52), but still an iPad.
const _iPadMiniLandscape = Size(1133, 744);

/// The base configuration plus a tab without any property, like the unused
/// template tabs the test player saw.
RpgConfigurationModel _configWithEmptyTab() {
  final base = RpgConfigurationModel.getBaseConfiguration().copyWith(
    defaultSkinId: CharacterSheetSkinIds.classicDark,
  );
  final tabs = [...base.characterStatTabsDefinition!];
  tabs.insert(
    1,
    CharacterStatsTabDefinition(
      uuid: 'empty-tab',
      tabName: 'Leere Seite',
      isOptional: false,
      isDefaultTab: false,
      statsInTab: [],
    ),
  );
  return base.copyWith(characterStatTabsDefinition: tabs);
}

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required bool isDm,
  required Widget screen,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  addTearDown(tester.view.reset);
  await customLoadAppFonts();

  final config = _configWithEmptyTab();
  final character = RpgCharacterConfiguration.getBaseConfiguration(
    config,
    variant: 0,
  ).copyWith(skinId: CharacterSheetSkinIds.classicDark);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        rpgConfigurationProvider.overrideWith(
          (ref) => RpgConfigurationNotifier(
            decks: AsyncValue.data(config),
            ref: ref,
            runningInTests: true,
          ),
        ),
        rpgCharacterConfigurationProvider.overrideWith(
          (ref) => RpgCharacterConfigurationNotifier(
            decks: AsyncValue.data(character),
            ref: ref,
            runningInTests: true,
          ),
        ),
        connectionDetailsProvider.overrideWith(
          (ref) => ConnectionDetailsNotifier(
            initState: AsyncValue.data(
              ConnectionDetails.defaultValue().copyWith(
                isConnected: true,
                isInSession: true,
                isDm: isDm,
                campagneId: _campagneId,
              ),
            ),
            ref: ref,
            runningInTests: true,
          ),
        ),
      ],
      child: DependencyProvider.getMockedDependecyProvider(
        child: CustomThemeProvider(
          overrideBrightness: Brightness.dark,
          overrideSkinId: CharacterSheetSkinIds.classicDark,
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData.dark(useMaterial3: true),
              home: screen,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

PlayerPageScreen _playerScreen() => PlayerPageScreen(
  routeSettings: PlayerPageScreenRouteSettings(
    characterConfigurationOverride: null,
    showInventory: true,
    showRecipes: true,
    showMoney: true,
    showLore: true,
    disableEdit: false,
  ),
);

Finder get _navbarTitle => find.descendant(
  of: find.byType(Navbar),
  matching: find.byWidgetPredicate(
    (w) => w is Text && w.maxLines == 1 && w.textAlign == TextAlign.center,
  ),
);

String _titleText(WidgetTester tester) =>
    tester.widget<Text>(_navbarTitle).data!;

Finder _navbarIcon(FaIconData icon) => find.descendant(
  of: find.byType(Navbar),
  matching: find.byWidgetPredicate((w) => w is CustomFaIcon && w.icon == icon),
);

bool _fullyOnScreen(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  return rect.left >= 0 && rect.right <= _iPhone17Pro.width;
}

void main() {
  test('tabs without properties are hidden, the default tab is counted '
      'among the shown ones', () {
    final config = _configWithEmptyTab();
    final visible = visibleCharacterStatTabs(config);

    expect(visible.map((t) => t.tabName), isNot(contains('Leere Seite')));
    expect(visible.length, config.characterStatTabsDefinition!.length - 1);
    expect(
      visible[defaultVisibleCharacterStatTabIndex(config)!].tabName,
      'Werte',
    );
  });

  testWidgets('phone, player: every page has a named tab, the notes are in '
      'sight, empty tabs are hidden and the close button stays "X"', (
    tester,
  ) async {
    await _pump(
      tester,
      size: _iPhone17Pro,
      isDm: false,
      screen: _playerScreen(),
    );

    // opens on the default tab, with its name as the title
    expect(_titleText(tester), 'Werte');
    expect(find.text('Leere Seite'), findsNothing);

    final tabs = tester
        .widget<PageTabStrip>(find.byType(PageTabStrip))
        .items
        .map((i) => i.label)
        .toList();
    expect(tabs, [
      'Hintergrund',
      'Werte',
      'Merkmale',
      'Angriffe',
      'Zauber',
      'Währung',
      'Inventar',
      'Herstellen',
      'Notizen',
    ]);

    final notesTab = find.byKey(PageTabStrip.tabKey(8));
    expect(_fullyOnScreen(tester, notesTab), isTrue);
    expect(_navbarIcon(FontAwesomeIcons.xmark), findsOneWidget);

    await tester.tap(notesTab);
    await tester.pumpAndSettle();

    expect(_titleText(tester), 'Notizen');
    expect(find.byType(LoreScreen), findsOneWidget);
    // SP-5: no "<" that jumps back to the stats page
    expect(_navbarIcon(FontAwesomeIcons.chevronLeft), findsNothing);
    expect(_navbarIcon(FontAwesomeIcons.xmark), findsOneWidget);

    // swiping keeps the tabs in step
    await tester.tap(find.byKey(PageTabStrip.tabKey(0)));
    await tester.pumpAndSettle();
    expect(_titleText(tester), 'Hintergrund');
  });

  testWidgets('phone, DM: the pages have short names, the notes are one tap '
      'away', (tester) async {
    await _pump(
      tester,
      size: _iPhone17Pro,
      isDm: true,
      screen: const DmPageScreen(startScreenOverride: 2),
    );

    for (final label in [
      'Kampagne',
      'Charaktere',
      'Kampf',
      'Items',
      'Notizen',
      'Bilder',
    ]) {
      final tab = find.descendant(
        of: find.byType(PageTabStrip),
        matching: find.text(label),
      );
      expect(tab, findsOneWidget, reason: label);
      expect(_fullyOnScreen(tester, tab), isTrue, reason: label);
    }
    expect(_titleText(tester), 'Kampfreihenfolge');

    await tester.tap(
      find.descendant(
        of: find.byType(PageTabStrip),
        matching: find.text('Notizen'),
      ),
    );
    await tester.pumpAndSettle();
    expect(_titleText(tester), 'Notizen');
    expect(find.byType(LoreScreen), findsOneWidget);
  });

  testWidgets('tablet keeps the diamond row without the tab strip', (
    tester,
  ) async {
    await _pump(
      tester,
      size: _iPadProLandscape,
      isDm: false,
      screen: _playerScreen(),
    );
    expect(find.byType(PageTabStrip), findsNothing);
    expect(find.text('Werte'), findsOneWidget);
  });

  testWidgets('iPad mini in landscape keeps the iPad navigation', (
    tester,
  ) async {
    await _pump(
      tester,
      size: _iPadMiniLandscape,
      isDm: true,
      screen: const DmPageScreen(startScreenOverride: 2),
    );
    expect(find.byType(PageTabStrip), findsNothing);
  });
}
