import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/generated/l10n.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/select_game_mode_screen.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('selectGameMode screen renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    testConfigurations(
      disableLocals: false,
      pathPrefix: "",
      widgetName: 'selectGameModescreen',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) async {
        await tester.pumpAndSettle();
        await loadAppFonts();
        await loadAppFonts();
        await tester.pumpAndSettle();
        await loadAppFonts();
        await tester.pumpAndSettle();
      },
      screenFactory: (Locale locale) => ProviderScope(
        overrides: [
          rpgCharacterConfigurationProvider.overrideWith((ref) {
            return RpgCharacterConfigurationNotifier(
              decks: AsyncValue.data(
                RpgCharacterConfiguration.getBaseConfiguration(null),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
          rpgConfigurationProvider.overrideWith((ref) {
            return RpgConfigurationNotifier(
              decks: AsyncValue.data(
                RpgConfigurationModel.getBaseConfiguration(),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
        ],
        child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate
            ],
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              fontFamily: 'Roboto',
              useMaterial3: true,
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 16,
              ),
            ),
            home: SelectGameModeScreen()),
      ),
      getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
        MapEntry(
          'default',
          DependencyProvider.getMockedDependecyProvider(
            child: Center(
              child: widgetToTest,
            ),
          ),
        ),
      ]),
    );
  });
}
