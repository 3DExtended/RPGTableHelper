import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/modals/show_select_transformation_components_for_transformation.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('showSelectTransformationComponentsForTransformation renderings', () {
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    List<int> screensToRender = [0];

    for (var sc in screensToRender) {
      testConfigurations(
        disableLocals: false,
        pathPrefix: "",
        widgetName: 'showSelectTransformationComponentsForTransformation_$sc',
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
        screenFactory: (Locale locale, Brightness brightnessToTest) =>
            ProviderScope(
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
                  child: CustomThemeProvider(
                    overrideBrightness: brightnessToTest,
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: Builder(builder: (context) {
                        return ElevatedButton(
                            onPressed: () async {
                              await showSelectTransformationComponentsForTransformation(
                                overrideNavigatorKey: navigatorKey,
                                context,
                                rpgCharConfig: RpgCharacterConfiguration
                                    .getBaseConfiguration(null),
                                rpgConfig: RpgConfigurationModel
                                    .getBaseConfiguration(),
                              );
                            },
                            child: const Text("Click me"));
                      }),
                    ),
                  ),
                )),
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
    }
  });
}
