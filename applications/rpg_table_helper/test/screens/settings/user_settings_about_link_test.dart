import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/screens/about/about_and_licenses_screen.dart';
import 'package:quest_keeper/screens/settings/user_settings_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// The SRD attribution must be reachable in the app (CC BY 4.0).
void main() {
  testWidgets('the settings open the about and licenses page', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final pushed = <String?>[];
    await tester.pumpWidget(
      CustomThemeProvider(
        child: ThemeConfigurationForApp(
          child: MaterialApp(
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateRoute: (settings) {
              pushed.add(settings.name);
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => settings.name == '/'
                    ? DependencyProvider.getMockedDependecyProvider(
                        child: const UserSettingsScreen(
                            showRealtimeSessionHint: false),
                      )
                    : const SizedBox(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Info & Lizenzen'));
    await tester.pumpAndSettle();

    expect(pushed.last, AboutAndLicensesScreen.route);
  });
}
