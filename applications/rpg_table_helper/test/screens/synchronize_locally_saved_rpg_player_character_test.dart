import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('showSynchronizeLocallySavedRpgPlayerCharacter renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    testConfigurations(
      disableLocals: true,
      pathPrefix: "",
      widgetName: 'showSynchronizeLocallySavedRpgPlayerCharacter',
      useMaterialAppWrapper: true,
      testerInteractions: (tester, local) async {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        await loadAppFonts();
        await loadAppFonts();
        await tester.pumpAndSettle();
        await loadAppFonts();
        await tester.pumpAndSettle();
      },
      screenFactory: (Locale locale) => ProviderScope(
        overrides: [],
        child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
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
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Builder(builder: (context) {
                return ElevatedButton(
                    onPressed: () async {
                      await showSynchronizeLocallySavedRpgPlayerCharacter(
                        overrideNavigatorKey: navigatorKey,
                        context,
                      );
                    },
                    child: const Text("Click me"));
              }),
            )),
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
