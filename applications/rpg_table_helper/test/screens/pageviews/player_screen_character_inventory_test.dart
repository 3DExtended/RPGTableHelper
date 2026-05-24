import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modals/show_item_card_details.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_inventar.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../custom_font_loader.dart';

void main() {
  final rpgConfig = RpgConfigurationModel.getBaseConfiguration();
  final ownCharacter = RpgCharacterConfiguration.getBaseConfiguration(
    rpgConfig,
    variant: 0,
  );
  final otherCharacter = ownCharacter.copyWith(
    uuid: 'other-player-character-uuid',
    characterName: 'Other Player',
    inventory: [
      RpgCharacterOwnedItemPair(
        itemUuid: rpgConfig.allItems.first.uuid,
        amount: 3,
      ),
    ],
  );

  Widget buildTestApp({
    required Widget child,
    RpgCharacterConfiguration? loadedCharacter,
  }) {
    return ProviderScope(
      overrides: [
        rpgConfigurationProvider.overrideWith((ref) {
          return RpgConfigurationNotifier(
            decks: AsyncValue.data(rpgConfig),
            ref: ref,
            runningInTests: true,
          );
        }),
        rpgCharacterConfigurationProvider.overrideWith((ref) {
          return RpgCharacterConfigurationNotifier(
            decks: AsyncValue.data(loadedCharacter ?? ownCharacter),
            ref: ref,
            runningInTests: true,
          );
        }),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          S.delegate,
        ],
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Ruwudu',
          useMaterial3: true,
        ),
        home: CustomThemeProvider(
          overrideBrightness: Brightness.dark,
          child: DependencyProvider.getMockedDependecyProvider(
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
  }

  group('PlayerScreenCharacterInventory', () {
    testWidgets('hides add button when viewing another character inventory',
        (tester) async {
      await customLoadAppFonts();

      await tester.pumpWidget(
        buildTestApp(
          loadedCharacter: ownCharacter,
          child: PlayerScreenCharacterInventory(
            rpgConfig: rpgConfig,
            charToRender: otherCharacter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add'), findsNothing);
    });

    testWidgets('shows add button when viewing own inventory', (tester) async {
      await customLoadAppFonts();

      await tester.pumpWidget(
        buildTestApp(
          loadedCharacter: ownCharacter,
          child: PlayerScreenCharacterInventory(
            rpgConfig: rpgConfig,
            charToRender: ownCharacter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('PlayerPageScreenRouteSettings for DM player view', () {
    test('includes inventory tab when showInventory is true', () {
      final settings = PlayerPageScreenRouteSettings(
        disableEdit: true,
        showMoney: true,
        characterConfigurationOverride: otherCharacter,
        showInventory: true,
        showLore: false,
        showRecipes: false,
      );

      expect(settings.showInventory, isTrue);
      expect(settings.disableEdit, isTrue);
    });
  });

  group('ItemCardDetailsModalContent readOnly', () {
    testWidgets('hides save button in read-only mode', (tester) async {
      await customLoadAppFonts();

      await tester.pumpWidget(
        buildTestApp(
          child: ItemCardDetailsModalContent(
            modalPadding: 20,
            item: rpgConfig.allItems.first,
            currentlyOwned: 2,
            rpgConfig: rpgConfig,
            readOnly: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsNothing);
      expect(find.textContaining('2'), findsWidgets);
    });
  });
}
