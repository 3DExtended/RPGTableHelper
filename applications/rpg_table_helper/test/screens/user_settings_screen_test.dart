import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/screens/settings/user_settings_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../custom_font_loader.dart';
import '../test_configuration.dart';

void main() {
  group('user settings screen — iOS realtime hint visible', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    testConfigurations(
      disableAllScreenSizes: true,
      disableLocals: false,
      pathPrefix: '',
      widgetName: 'user_settings_screen',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) async {
        await tester.pumpAndSettle();
        await customLoadAppFonts();
        await customLoadAppFonts();
        await tester.pumpAndSettle();
        await customLoadAppFonts();
        await tester.pumpAndSettle();
      },
      screenFactory: (Locale locale, Brightness brightnessToTest) =>
          ThemeConfigurationForApp(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate,
          ],
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            fontFamily: 'Ruwudu',
            useMaterial3: true,
            iconTheme: const IconThemeData(
              color: Colors.white,
              size: 16,
            ),
          ),
          home: ThemeConfigurationForApp(
            child: CustomThemeProvider(
              overrideBrightness: brightnessToTest,
              child: const UserSettingsScreen(showRealtimeSessionHint: true),
            ),
          ),
        ),
      ),
      getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
          Map.fromEntries([
        MapEntry(
          'ios_realtime_hint',
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

  group('user settings screen — no iOS hint', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    testConfigurations(
      disableAllScreenSizes: true,
      disableLocals: false,
      pathPrefix: '',
      widgetName: 'user_settings_screen',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) async {
        await tester.pumpAndSettle();
        await customLoadAppFonts();
        await customLoadAppFonts();
        await tester.pumpAndSettle();
        await customLoadAppFonts();
        await tester.pumpAndSettle();
      },
      screenFactory: (Locale locale, Brightness brightnessToTest) =>
          ThemeConfigurationForApp(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate,
          ],
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            fontFamily: 'Ruwudu',
            useMaterial3: true,
            iconTheme: const IconThemeData(
              color: Colors.white,
              size: 16,
            ),
          ),
          home: ThemeConfigurationForApp(
            child: CustomThemeProvider(
              overrideBrightness: brightnessToTest,
              child: const UserSettingsScreen(showRealtimeSessionHint: false),
            ),
          ),
        ),
      ),
      getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
          Map.fromEntries([
        MapEntry(
          'no_ios_hint',
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
}
