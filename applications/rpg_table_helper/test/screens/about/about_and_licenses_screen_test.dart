import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/screens/about/about_and_licenses_screen.dart';
import 'package:quest_keeper/screens/about/srd_attribution.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

Future<void> _pumpScreen(WidgetTester tester, Locale locale) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: DependencyProvider.getMockedDependecyProvider(
        child: CustomThemeProvider(
          overrideBrightness: Brightness.light,
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AboutAndLicensesScreen(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _selectableText(WidgetTester tester, String key) =>
    tester.widget<SelectableText>(find.byKey(ValueKey(key))).data!;

void main() {
  test('the attribution is the SRD 5.2.1 wording', () {
    expect(
      srdAttributionEnglish,
      'This work includes material from the System Reference Document 5.2.1 '
      '(“SRD 5.2.1”) by Wizards of the Coast LLC, available at '
      'https://www.dndbeyond.com/srd. The SRD 5.2.1 is licensed under the '
      'Creative Commons Attribution 4.0 International License, available at '
      'https://creativecommons.org/licenses/by/4.0/legalcode.',
    );
    expect(srdAttributionGerman, startsWith('Dieses Werk enthält Material'));
    expect(ccByLicenseUrl, 'https://creativecommons.org/licenses/by/4.0/');
  });

  for (final locale in const [Locale('de'), Locale('en')]) {
    testWidgets('shows the SRD attribution (${locale.languageCode})', (
      tester,
    ) async {
      await _pumpScreen(tester, locale);
      final s = S.current;

      expect(find.text(s.aboutLicensesTitle), findsOneWidget);
      expect(find.text(AboutAndLicensesScreen.appName), findsOneWidget);
      expect(
        _selectableText(tester, 'srdAttributionEnglish'),
        srdAttributionEnglish,
      );
      expect(
        _selectableText(tester, 'srdAttributionGerman'),
        srdAttributionGerman,
      );
      expect(find.text(s.aboutLicensesAuthoritativeHint), findsOneWidget);
      expect(find.text(s.aboutLicensesChanges), findsOneWidget);
      expect(find.text(s.aboutLicensesNotAffiliated), findsOneWidget);
      expect(find.byKey(const ValueKey('openCcByLicense')), findsOneWidget);
      expect(find.byKey(const ValueKey('showFlutterLicenses')), findsOneWidget);
    });
  }

  testWidgets('the button opens Flutter\'s license page', (tester) async {
    await _pumpScreen(tester, const Locale('de'));

    await tester.tap(find.byKey(const ValueKey('showFlutterLicenses')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LicensePage), findsOneWidget);
  });

  test(
    'the license entry for LicenseRegistry carries the attribution',
    () async {
      final entries = await srdLicenseEntries().toList();
      expect(entries, hasLength(1));
      expect(entries.single.packages, [srdLicensePackageName]);
      final text = entries.single.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('System Reference Document 5.2.1'));
      expect(text, contains('Creative Commons Attribution 4.0'));
      expect(text, contains('Systemreferenzdokument 5.2.1'));
      expect(text, contains(ccByLicenseUrl));
    },
  );
}
