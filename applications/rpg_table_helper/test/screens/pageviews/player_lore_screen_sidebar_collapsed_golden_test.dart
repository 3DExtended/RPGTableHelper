import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/lore_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/note_documents_service.dart';

import '../../custom_font_loader.dart';
import '../../test_configuration.dart';

/// Player lore screen (tab index 8) with the lore sidebar collapsed, once per
/// character-sheet skin. Collapsing is pure `_LoreScreenState` widget state
/// (no provider hook), so every configuration below taps the collapse
/// chevron and waits out its animation before capturing the golden.
Future<void> _collapseLoreSidebarAndSettle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await customLoadAppFonts();
  await customLoadAppFonts();
  await tester.pumpAndSettle();
  await customLoadAppFonts();
  await tester.pumpAndSettle();

  await tester.tap(find.descendant(
    of: find.byType(LoreScreen),
    matching: find.byWidgetPredicate(
      (w) => w is CustomFaIcon && w.icon == FontAwesomeIcons.chevronLeft,
    ),
  ));
  await tester.pumpAndSettle();
}

RpgCharacterConfiguration _classicCharacterForGoldens() {
  final base = RpgCharacterConfiguration.getBaseConfiguration(
    RpgConfigurationModel.getBaseConfiguration(),
    variant: 0,
  );
  return base;
}

RpgCharacterConfiguration _ledgerCharacterForGoldens() {
  final base = RpgCharacterConfiguration.getBaseConfiguration(
    RpgConfigurationModel.getBaseConfiguration(),
    variant: 0,
  );
  return base.copyWith(skinId: CharacterSheetSkinIds.arcaneLedger);
}

RpgCharacterConfiguration _cartographerCharacterForGoldens() {
  final base = RpgCharacterConfiguration.getBaseConfiguration(
    RpgConfigurationModel.getBaseConfiguration(),
    variant: 0,
  );
  return base.copyWith(skinId: CharacterSheetSkinIds.nightCartographer);
}

ConnectionDetails _connectionDetailsForGoldens(
  RpgCharacterConfiguration playerCharacter,
) {
  return ConnectionDetails.defaultValue().copyWith(
    fightSequence: FightSequence(
      fightUuid: "f10526be-c69a-46be-8802-df9421e6187b",
      sequence: [
        ("575fb9d9-c2a0-47df-bec4-5de1b3d5ca4d", "Frodo", 17),
        ("0eff8827-14f1-46a1-8695-ef7dc5323137", "Gandalf", 17),
      ],
    ),
    isConnected: true,
    isConnecting: true,
    isDm: true,
    campagneId: "51f263bc-37cf-44d4-90f3-87d656ae29df",
    isInSession: true,
    sessionConnectionNumberForPlayers: "123-321",
    lastGrantedItems: [
      GrantedItemsForPlayer(
        characterName: "Frodo",
        playerId: "fghjkl",
        grantedItems: [],
      ),
      GrantedItemsForPlayer(
        characterName: "Gandalf",
        playerId: "ghjiuhjkiujhn",
        grantedItems: [
          RpgCharacterOwnedItemPair(
            itemUuid:
                RpgConfigurationModel.getBaseConfiguration().allItems.first.uuid,
            amount: 2,
          ),
          RpgCharacterOwnedItemPair(
            itemUuid:
                RpgConfigurationModel.getBaseConfiguration().allItems[2].uuid,
            amount: 12,
          ),
        ],
      ),
    ],
    connectedPlayers: [
      OpenPlayerConnection(
        lastPing: DateTime(2025, 02, 26, 12, 00),
        userId: UserIdentifier($value: "9a709402-5620-479c-85b7-718ae01e0a83"),
        playerCharacterId: PlayerCharacterIdentifier(
          $value: "575fb9d9-c2a0-47df-bec4-5de1b3d5ca4d",
        ),
        configuration: playerCharacter.copyWith(characterName: 'Gandalf'),
      ),
    ],
  );
}

Widget _loreScreenHome({
  required GlobalKey<NavigatorState> navigatorKey,
  required Locale locale,
  required Brightness brightness,
  required Color seedColor,
  String? overrideSkinId,
}) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    localizationsDelegates: [
      ...AppLocalizations.localizationsDelegates,
      S.delegate,
    ],
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    darkTheme: ThemeData.dark(),
    themeMode: brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      fontFamily: 'Ruwudu',
      useMaterial3: true,
      iconTheme: const IconThemeData(color: Colors.white, size: 16),
    ),
    home: ThemeConfigurationForApp(
      child: CustomThemeProvider(
        overrideBrightness: brightness,
        overrideSkinId: overrideSkinId,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Builder(builder: (context) {
            return PlayerPageScreen(
              startScreenOverride: 8,
              routeSettings: PlayerPageScreenRouteSettings(
                characterConfigurationOverride: null,
                showInventory: true,
                showRecipes: true,
                showMoney: true,
                showLore: true,
                disableEdit: false,
              ),
            );
          }),
        ),
      ),
    ),
  );
}

void main() {
  group('player lore screen sidebar collapsed - classic', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    testConfigurations(
      pathPrefix: "../",
      widgetName: 'playerlorescreen-sidebar-collapsed',
      useMaterialAppWrapper: true,
      devices: [...testDevices, ...testDevicesIpadMini],
      testerInteractions: (tester, local) => _collapseLoreSidebarAndSettle(tester),
      screenFactory: (Locale locale, Brightness brightnessToTest) =>
          ProviderScope(
        overrides: [
          rpgConfigurationProvider.overrideWith((ref) {
            final skinId = brightnessToTest == Brightness.light
                ? CharacterSheetSkinIds.classicLight
                : CharacterSheetSkinIds.classicDark;
            return RpgConfigurationNotifier(
              decks: AsyncValue.data(
                RpgConfigurationModel.getBaseConfiguration()
                    .copyWith(defaultSkinId: skinId),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
          rpgCharacterConfigurationProvider.overrideWith((ref) {
            return RpgCharacterConfigurationNotifier(
              decks: AsyncValue.data(_classicCharacterForGoldens()),
              ref: ref,
              runningInTests: true,
            );
          }),
          connectionDetailsProvider.overrideWith((ref) {
            return ConnectionDetailsNotifier(
              initState: AsyncValue.data(
                _connectionDetailsForGoldens(_classicCharacterForGoldens()),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
        ],
        child: ThemeConfigurationForApp(
          child: _loreScreenHome(
            navigatorKey: navigatorKey,
            locale: locale,
            brightness: brightnessToTest,
            seedColor: Colors.deepPurple,
          ),
        ),
      ),
      getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
          Map.fromEntries([
        MapEntry(
          'default',
          CustomThemeProvider(
            overrideBrightness: brightness,
            child: DependencyProvider.getMockedDependecyProvider(
              child: Center(child: widgetToTest),
            ),
          ),
        ),
      ]),
    );
  });

  group('player lore screen sidebar collapsed - arcane ledger', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    setUp(() {
      MockNoteDocumentService.preferArcaneLedgerLoreFixtures = true;
    });
    tearDown(() {
      MockNoteDocumentService.preferArcaneLedgerLoreFixtures = false;
    });

    testConfigurations(
      disableLocals: true,
      disableDarkMode: true,
      pathPrefix: "../",
      overrideSkinId: CharacterSheetSkinIds.arcaneLedger,
      devices: [...testDevicesLedger, ...testDevicesIpadMiniLedger],
      widgetName: 'arcane-ledger-playerlorescreen-sidebar-collapsed',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) => _collapseLoreSidebarAndSettle(tester),
      screenFactory: (Locale locale, Brightness brightnessToTest) =>
          ProviderScope(
        overrides: [
          rpgConfigurationProvider.overrideWith((ref) {
            return RpgConfigurationNotifier(
              decks: AsyncValue.data(
                RpgConfigurationModel.getBaseConfiguration().copyWith(
                  defaultSkinId: CharacterSheetSkinIds.arcaneLedger,
                ),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
          rpgCharacterConfigurationProvider.overrideWith((ref) {
            return RpgCharacterConfigurationNotifier(
              decks: AsyncValue.data(_ledgerCharacterForGoldens()),
              ref: ref,
              runningInTests: true,
            );
          }),
          connectionDetailsProvider.overrideWith((ref) {
            return ConnectionDetailsNotifier(
              initState: AsyncValue.data(
                _connectionDetailsForGoldens(_ledgerCharacterForGoldens()),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
        ],
        child: ThemeConfigurationForApp(
          child: _loreScreenHome(
            navigatorKey: navigatorKey,
            locale: locale,
            brightness: Brightness.light,
            seedColor: Colors.brown,
            overrideSkinId: CharacterSheetSkinIds.arcaneLedger,
          ),
        ),
      ),
      getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
          Map.fromEntries([
        MapEntry(
          'arcane_ledger',
          CustomThemeProvider(
            overrideBrightness: Brightness.light,
            overrideSkinId: CharacterSheetSkinIds.arcaneLedger,
            child: DependencyProvider.getMockedDependecyProvider(
              child: Center(child: widgetToTest),
            ),
          ),
        ),
      ]),
    );
  });

  group('player lore screen sidebar collapsed - night cartographer', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    setUp(() {
      MockNoteDocumentService.preferArcaneLedgerLoreFixtures = true;
    });
    tearDown(() {
      MockNoteDocumentService.preferArcaneLedgerLoreFixtures = false;
    });

    testConfigurations(
      disableLocals: true,
      disableDarkMode: true,
      pathPrefix: "../",
      overrideSkinId: CharacterSheetSkinIds.nightCartographer,
      devices: [...testDevicesLedger, ...testDevicesIpadMiniLedger],
      widgetName: 'night-cartographer-playerlorescreen-sidebar-collapsed',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) => _collapseLoreSidebarAndSettle(tester),
      screenFactory: (Locale locale, Brightness brightnessToTest) =>
          ProviderScope(
        overrides: [
          rpgConfigurationProvider.overrideWith((ref) {
            return RpgConfigurationNotifier(
              decks: AsyncValue.data(
                RpgConfigurationModel.getBaseConfiguration().copyWith(
                  defaultSkinId: CharacterSheetSkinIds.nightCartographer,
                ),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
          rpgCharacterConfigurationProvider.overrideWith((ref) {
            return RpgCharacterConfigurationNotifier(
              decks: AsyncValue.data(_cartographerCharacterForGoldens()),
              ref: ref,
              runningInTests: true,
            );
          }),
          connectionDetailsProvider.overrideWith((ref) {
            return ConnectionDetailsNotifier(
              initState: AsyncValue.data(
                _connectionDetailsForGoldens(_cartographerCharacterForGoldens()),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
        ],
        child: ThemeConfigurationForApp(
          child: _loreScreenHome(
            navigatorKey: navigatorKey,
            locale: locale,
            brightness: Brightness.dark,
            seedColor: Colors.brown,
            overrideSkinId: CharacterSheetSkinIds.nightCartographer,
          ),
        ),
      ),
      getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
          Map.fromEntries([
        MapEntry(
          'night_cartographer',
          CustomThemeProvider(
            overrideBrightness: Brightness.dark,
            overrideSkinId: CharacterSheetSkinIds.nightCartographer,
            child: DependencyProvider.getMockedDependecyProvider(
              child: Center(child: widgetToTest),
            ),
          ),
        ),
      ]),
    );
  });
}
