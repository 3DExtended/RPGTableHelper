import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

import 'custom_font_loader.dart';

/// Canonical golden device set (skin-01 keep-list).
/// Additional sizes/orientations were dropped to keep visual CI maintainable
/// ahead of character-sheet skins. See planning/character-sheet-skins/golden-keep-list.md
const testDevices = [
  Device(
    name: 'ipad pro 12-9 landscape',
    size: Size(1366, 1024),
    devicePixelRatio: 3,
    textScale: 1.0,
    safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
  ),
];

/// Lower DPR for heavy skin goldens (parchment textures) to keep PNGs reviewable in git.
const testDevicesLedger = [
  Device(
    name: 'ipad pro 12-9 landscape',
    size: Size(1366, 1024),
    devicePixelRatio: 1,
    textScale: 1.0,
    safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
  ),
];

var brightnessTests = [
  Brightness.light,
  Brightness.dark,
];

void testConfigurations({
  required Widget Function(Locale locale, Brightness brightness) screenFactory,
  required Map<String, Widget> Function(
          Widget widgetToTest, Brightness brightness)
      getTestConfigurations,
  required String widgetName,
  bool disableLocals = false,
  Future<void> Function(WidgetTester tester, Locale local)? testerInteractions,
  bool useMaterialAppWrapper = true,
  String? pathPrefix = "",
  /// Retained for call-site compatibility. All goldens use [testDevices]
  /// (single canonical iPad landscape after skin-01 cleanup).
  bool disableAllScreenSizes = false,
  /// When true, only [Brightness.light] is snapshotted (no Darkmode suffix).
  bool disableDarkMode = false,
  /// When set, [CustomThemeProvider] uses this skin instead of brightness mapping.
  String? overrideSkinId,
  /// Override golden devices (defaults to [testDevices]).
  List<Device>? devices,
}) {
  // Touch the flag so existing call sites stay valid without analyzer noise.
  assert(disableAllScreenSizes || !disableAllScreenSizes);
  final goldenDevices = devices ?? testDevices;
  Widget? widgetToTest;
  var supportedLocales = S.delegate.supportedLocales;
  if (disableLocals) {
    supportedLocales = [supportedLocales[0]];
  }
  final brightnessesToTest =
      disableDarkMode ? [Brightness.light] : brightnessTests;
  for (var i = 0; i < brightnessesToTest.length; i++) {
    var brightnessToTest = brightnessesToTest[i];

    for (var local in supportedLocales) {
      if (useMaterialAppWrapper) {
        widgetToTest = MaterialApp(
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate,
          ],
          locale: local,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          debugShowMaterialGrid: false,
          themeMode: brightnessToTest == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          title: 'TriviaCrusher',
          color: Colors.black,
          theme: ThemeData.dark(useMaterial3: true),
          builder: (BuildContext context, Widget? child) {
            // Set a custom screen size for the test
            return ThemeConfigurationForApp(
                child: screenFactory(local, brightnessToTest));
          },
        );
      } else {
        widgetToTest = ThemeConfigurationForApp(
            child: screenFactory(local, brightnessToTest));
      }

      var counter = 1;

      for (var widgetConfig
          in getTestConfigurations(widgetToTest, brightnessToTest).entries) {
        var testName =
            '$counter - $widgetName (Language ${local.languageCode}, ${widgetConfig.key})';
        if (brightnessToTest == Brightness.dark) {
          testName += ' - Darkmode';
        }
        counter++;

        testGoldens(testName, (WidgetTester tester) async {
          TestWidgetsFlutterBinding.ensureInitialized();
          await customLoadAppFonts();
          await customLoadAppFonts();
          await tester.pumpAndSettle();
          await customLoadAppFonts();
          await tester.pumpAndSettle();

          tester.view.platformDispatcher.platformBrightnessTestValue =
              brightnessToTest;
          await tester.pumpAndSettle();

          await tester.pumpWidgetBuilder(
            wrapper: (w) => Builder(builder: (context) {
              return CustomThemeProvider(
                  overrideBrightness: brightnessToTest,
                  overrideSkinId: overrideSkinId,
                  child: Localizations(
                    delegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      ...AppLocalizations.localizationsDelegates,
                      S.delegate,
                    ],
                    locale: local,
                    child: w,
                  ));
            }),
            Builder(builder: (context) {
              return ThemeConfigurationForApp(child: widgetConfig.value);
            }),
          );

          if (testerInteractions != null) {
            await testerInteractions(tester, local);
          }
          await customLoadAppFonts();

          await multiScreenGolden(
            tester,
            '${pathPrefix ?? ""}../../goldens/$widgetName/$testName',
            devices: goldenDevices,
          );
        });
      }
    }
  }
}
