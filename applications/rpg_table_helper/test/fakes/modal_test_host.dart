import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

const openModalButtonKey = ValueKey('openModalUnderTest');

/// The app shell the modals expect: Riverpod, the mocked services, the theme
/// and a [MaterialApp] on the global [navigatorKey] (the modal helpers push
/// onto it).
Widget appTestShell({
  required Widget home,
  Map<Type, dynamic Function()>? mockOverrides,
  List<dynamic> providerOverrides = const [],
  Locale locale = const Locale('de'),
  RouteFactory? onGenerateRoute,
}) {
  return ProviderScope(
    overrides: providerOverrides.cast(),
    child: DependencyProvider.getMockedDependecyProvider(
      mockOverrides: mockOverrides,
      child: CustomThemeProvider(
        overrideBrightness: Brightness.light,
        child: ThemeConfigurationForApp(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            home: home,
            onGenerateRoute: onGenerateRoute,
          ),
        ),
      ),
    ),
  );
}

void useTabletView(WidgetTester tester, {Size size = const Size(1200, 1600)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Pumps a page with one button; tapping [openModalButtonKey] runs [open].
Future<void> pumpModalHost(
  WidgetTester tester, {
  required Future<void> Function(BuildContext context) open,
  Map<Type, dynamic Function()>? mockOverrides,
}) async {
  useTabletView(tester);
  await tester.pumpWidget(
    appTestShell(
      mockOverrides: mockOverrides,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              key: openModalButtonKey,
              onPressed: () => open(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
