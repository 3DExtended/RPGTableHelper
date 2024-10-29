import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

const testDevices = [
  Device(
    name: 'ipad pro 12-9 landscape',
    size: Size(1366, 1024),
    devicePixelRatio: 3,
    textScale: 1.0,
    safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
  ),
  Device(
    name: 'ipad pro 12-9 portrait',
    size: Size(1024, 1366),
    devicePixelRatio: 3,
    textScale: 1.0,
    safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
  ),
  Device(
    name: 'ipad 6th gen landscape',
    size: Size(1024, 768),
    devicePixelRatio: 2,
    textScale: 1.0,
    safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
  ),
  Device(
    name: 'ipad pro 11inch 4th gen',
    size: Size(1210, 834),
    devicePixelRatio: 2,
    textScale: 1.0,
    safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
  ),
  // Device(
  //   name: 'iphone 16',
  //   size: Size(852, 393),
  //   devicePixelRatio: 3,
  //   textScale: 1.0,
  //   safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
  // ),
];

void testConfigurations({
  required Widget Function(Locale locale) screenFactory,
  required Map<String, Widget> Function(Widget widgetToTest)
      getTestConfigurations,
  required String widgetName,
  bool disableLocals = false,
  Future<void> Function(WidgetTester tester, Locale local)? testerInteractions,
  bool useMaterialAppWrapper = true,
  String? pathPrefix = "",
}) {
  Widget? widgetToTest;
  var supportedLocales = AppLocalizations.supportedLocales;
  if (disableLocals) {
    supportedLocales = [supportedLocales[0]];
  }
  for (var local in supportedLocales) {
    if (useMaterialAppWrapper) {
      widgetToTest = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: local,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        themeMode: ThemeMode.dark,
        title: 'TriviaCrusher',
        color: Colors.black,
        theme: ThemeData.dark(useMaterial3: true),
        builder: (BuildContext context, Widget? child) {
          // Set a custom screen size for the test
          return screenFactory(local);
        },
      );
    } else {
      widgetToTest = screenFactory(local);
    }

    var counter = 1;

    for (var widgetConfig in getTestConfigurations(widgetToTest).entries) {
      var testName =
          '$counter - $widgetName (Language ${local.languageCode}, ${widgetConfig.key})';
      counter++;

      testGoldens(testName, (WidgetTester tester) async {
        TestWidgetsFlutterBinding.ensureInitialized();
        await loadAppFonts();
        await loadAppFonts();
        await tester.pumpAndSettle();
        await loadAppFonts();
        await tester.pumpAndSettle();

        await tester.pumpWidgetBuilder(
          Builder(builder: (context) {
            return Localizations(
              delegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: local,
              child: Localizations.override(
                context: context,
                locale: local,
                child: widgetConfig.value,
              ),
            );
          }),
        );

        if (testerInteractions != null) {
          await testerInteractions(tester, local);
        }
        await loadAppFonts();

        await multiScreenGolden(
          tester,
          '${pathPrefix ?? ""}../../goldens/$widgetName/$testName',
          devices: testDevices,
        );
      });
    }
  }
}
