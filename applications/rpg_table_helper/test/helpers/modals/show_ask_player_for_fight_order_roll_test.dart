import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/initiative_bonus_resolver.dart';
import 'package:quest_keeper/helpers/modals/show_ask_player_for_fight_order_roll.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../custom_font_loader.dart';
import '../../test_configuration.dart';

void main() {
  group('showAskPlayerForFightOrderRoll renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    testConfigurations(
      disableLocals: false,
      pathPrefix: "../",
      widgetName: 'showAskPlayerForFightOrderRoll',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) async {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        await customLoadAppFonts();
        await customLoadAppFonts();
        await tester.pumpAndSettle();
        await customLoadAppFonts();
        await tester.pumpAndSettle();
      },
      screenFactory: (Locale locale, Brightness brightnessToTest) =>
          CustomThemeProvider(
        overrideBrightness: brightnessToTest,
        child: ProviderScope(
          overrides: [],
          child: ThemeConfigurationForApp(
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
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  fontFamily: 'Ruwudu',
                  useMaterial3: true,
                  iconTheme: const IconThemeData(
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                home: ThemeConfigurationForApp(
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: Builder(builder: (context) {
                      return ElevatedButton(
                          onPressed: () async {
                            await showAskPlayerForFightOrderRoll(
                              characterName: "Frodo",
                              overrideNavigatorKey: navigatorKey,
                              context,
                            );
                          },
                          child: const Text("Click me"));
                    }),
                  ),
                )),
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
              child: Center(
                child: widgetToTest,
              ),
            ),
          ),
        ),
      ]),
    );

    testConfigurations(
      disableLocals: false,
      pathPrefix: "../",
      widgetName: 'showAskPlayerForFightOrderRoll',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) async {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        await customLoadAppFonts();
        await customLoadAppFonts();
        await tester.pumpAndSettle();
        await customLoadAppFonts();
        await tester.pumpAndSettle();
      },
      screenFactory: (Locale locale, Brightness brightnessToTest) =>
          CustomThemeProvider(
        overrideBrightness: brightnessToTest,
        child: ProviderScope(
          overrides: [],
          child: ThemeConfigurationForApp(
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
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  fontFamily: 'Ruwudu',
                  useMaterial3: true,
                  iconTheme: const IconThemeData(
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                home: ThemeConfigurationForApp(
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: Builder(builder: (context) {
                      return ElevatedButton(
                          onPressed: () async {
                            await showAskPlayerForFightOrderRoll(
                              characterName: "Frodo",
                              overrideNavigatorKey: navigatorKey,
                              context,
                              initiativeBonusHint: const InitiativeBonusHint(
                                label: 'Geschicklichkeit',
                                bonus: 2,
                              ),
                            );
                          },
                          child: const Text("Click me"));
                    }),
                  ),
                )),
          ),
        ),
      ),
      getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
          Map.fromEntries([
        MapEntry(
          'withBonusHint',
          CustomThemeProvider(
            overrideBrightness: brightness,
            child: DependencyProvider.getMockedDependecyProvider(
              child: Center(
                child: widgetToTest,
              ),
            ),
          ),
        ),
      ]),
    );
  });

  testWidgets('shows helper sentence when hint present and hides when null',
      (tester) async {
    await tester.pumpWidget(
      CustomThemeProvider(
        overrideBrightness: Brightness.light,
        child: MaterialApp(
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: PlayerHasBeenAskedToRollForFightOrderModalContent(
              modalPadding: 20,
              characterName: 'Frodo',
              initiativeBonusHint: InitiativeBonusHint(
                label: 'Geschicklichkeit',
                bonus: 2,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Geschicklichkeit (+2) to your roll'),
        findsAtLeastNWidgets(1));

    await tester.pumpWidget(
      CustomThemeProvider(
        overrideBrightness: Brightness.light,
        child: MaterialApp(
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: PlayerHasBeenAskedToRollForFightOrderModalContent(
              modalPadding: 20,
              characterName: 'Frodo',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Geschicklichkeit (+2) to your roll'), findsNothing);
  });
}
