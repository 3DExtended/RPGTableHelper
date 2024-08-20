// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_localized_locales/flutter_localized_locales.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:golden_toolkit/golden_toolkit.dart';

// const testDevices = [
//   Device(
//     name: 'android 9to16',
//     size: Size(43 * 9, 43 * 16),
//     devicePixelRatio: 3,
//     textScale: 1.0,
//     safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
//   ),
//   Device(
//     // Lisas device
//     name: 'samsungA34',
//     size: Size(1080 / 2.0, 2340 / 2.0),
//     devicePixelRatio: 3,
//     textScale: 1.0,
//     safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
//   ),
//   Device(
//     name: 'pixel 7 pro',
//     size: Size(886 / 2.0, 1929 / 2.0),
//     devicePixelRatio: 2,
//     textScale: 1.0,
//     safeArea: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 0.0),
//   ),
//   Device(
//     name: 'iPhone 15',
//     size: Size(1179 / 3.0, 2556 / 3.0),
//     devicePixelRatio: 3,
//     textScale: 1.0,
//     safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
//   ),
//   Device(
//     name: 'iPhone 15 Pro Max',
//     size: Size(1290 / 3.0, 2796 / 3.0),
//     devicePixelRatio: 3,
//     safeArea: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 60.0),
//     textScale: 1.0,
//   ),
//   Device(
//     name: 'iPhone SE (3rd gen)',
//     size: Size(750 / 2, 1334 / 2),
//     devicePixelRatio: 2,
//     safeArea: EdgeInsets.fromLTRB(0.0, 20.0 / 2, 0.0, 0.0),
//     textScale: 1.0,
//   ),
//   Device(
//     name: 'super high iPhone',
//     size: Size(1290 / 3.0, 2796 / 3.0 * 5.0),
//     devicePixelRatio: 3,
//     safeArea: EdgeInsets.fromLTRB(0.0, 59.0 / 3.0, 0.0, 34.0 / 3.0),
//     textScale: 1.0,
//   ),
// ];

// void testConfigurations({
//   required Widget Function(Locale locale) screenFactory,
//   required Map<String, Widget> Function(Widget widgetToTest)
//       getTestConfigurations,
//   required String widgetName,
//   bool disableLocals = false,
//   Future<void> Function(WidgetTester tester, Locale local)? testerInteractions,
//   bool useMaterialAppWrapper = true,
// }) {
//   Widget? widgetToTest;
//   var supportedLocales = const AppLocalizationDelegate().supportedLocales;
//   if (disableLocals) {
//     supportedLocales = [supportedLocales[0]];
//   }
//   for (var local in supportedLocales) {
//     if (useMaterialAppWrapper) {
//       widgetToTest = ProviderScope(
//         child: MaterialApp(
//           localizationsDelegates: const [
//             S.delegate,
//             GlobalMaterialLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//             GlobalCupertinoLocalizations.delegate,
//           ],
//           locale: local,
//           supportedLocales: const AppLocalizationDelegate().supportedLocales,
//           debugShowCheckedModeBanner: false,
//           debugShowMaterialGrid: false,
//           themeMode: ThemeMode.dark,
//           title: 'TriviaCrusher',
//           theme: ThemeData.dark(useMaterial3: true),
//           builder: (BuildContext context, Widget? child) {
//             // Set a custom screen size for the test
//             return screenFactory(local);
//           },
//         ),
//       );
//     } else {
//       widgetToTest = screenFactory(local);
//     }

//     var counter = 1;

//     for (var widgetConfig in getTestConfigurations(widgetToTest).entries) {
//       var testName =
//           '$counter - $widgetName (Language ${local.languageCode}, ${widgetConfig.key})';
//       counter++;

//       testGoldens(testName, (WidgetTester tester) async {
//         TestWidgetsFlutterBinding.ensureInitialized();
//         await loadAppFonts();
//         await loadAppFonts();
//         await tester.pumpAndSettle();
//         await loadAppFonts();
//         await tester.pumpAndSettle();

//         await tester.pumpWidgetBuilder(
//           Builder(builder: (context) {
//             return Localizations(
//               delegates: const [
//                 LocaleNamesLocalizationsDelegate(),
//                 S.delegate,
//                 GlobalMaterialLocalizations.delegate,
//                 GlobalWidgetsLocalizations.delegate,
//                 GlobalCupertinoLocalizations.delegate,
//               ],
//               locale: local,
//               child: Localizations.override(
//                 context: context,
//                 locale: local,
//                 child: widgetConfig.value,
//               ),
//             );
//           }),
//         );

//         if (testerInteractions != null) {
//           await testerInteractions(tester, local);
//         }
//         await loadAppFonts();

//         await multiScreenGolden(
//           tester,
//           '../../goldens/$widgetName/$testName',
//           devices: testDevices,
//         );
//       });
//     }
//   }
// }
