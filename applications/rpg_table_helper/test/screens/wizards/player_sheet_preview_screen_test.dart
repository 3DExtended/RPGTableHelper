import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/phone_layout.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/screens/wizards/player_sheet_preview_screen.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Phase 3: the game master sees the sheet as a player will.
void main() {
  final rpgConfig = RpgConfigurationModel.getBaseConfiguration();

  test('the sample character has values but no template sample data', () {
    final sample =
        PlayerSheetPreviewScreen.sampleCharacter(rpgConfig, 'Beispielfigur');

    expect(sample.characterName, 'Beispielfigur');
    expect(sample.characterStats, isNotEmpty);
    expect(sample.companionCharacters, isEmpty);
    expect(sample.transformationComponents, isEmpty);
    expect(sample.inventory, isEmpty);
  });

  Future<void> pumpPreview(WidgetTester tester) async {
    tester.view.physicalSize = const Size(2752, 2064);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(overrides: [
      rpgConfigurationProvider.overrideWith((ref) => RpgConfigurationNotifier(
            decks: AsyncValue.data(rpgConfig),
            ref: ref,
            runningInTests: true,
          )),
      rpgCharacterConfigurationProvider.overrideWith(
        (ref) => RpgCharacterConfigurationNotifier(
          decks: const AsyncValue.loading(),
          ref: ref,
          runningInTests: true,
        ),
      ),
      connectionDetailsProvider.overrideWith(
        (ref) => ConnectionDetailsNotifier(
          initState: AsyncValue.data(ConnectionDetails.defaultValue()
              .copyWith(isDm: true, isInSession: true)),
          ref: ref,
          runningInTests: true,
        ),
      ),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      CustomThemeProvider(
        child: UncontrolledProviderScope(
          container: container,
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              home: DependencyProvider.getMockedDependecyProvider(
                child: const Scaffold(body: SizedBox()),
              ),
            ),
          ),
        ),
      ),
    );

    PlayerSheetPreviewScreen.open(rpgConfig);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 50));
  }

  bool previewLaysOutAsPhone(WidgetTester tester) =>
      tester.element(find.byType(PlayerPageScreen)).isPhone;

  testWidgets('shows the sheet with the sample character on a phone first',
      (tester) async {
    await pumpPreview(tester);

    expect(find.byType(PlayerPageScreen), findsOneWidget);
    expect(find.text('Spieleransicht'), findsOneWidget);
    expect(previewLaysOutAsPhone(tester), isTrue,
        reason: 'the iPad shows the phone layout inside the frame');

    final shown = tester
        .widget<PlayerPageScreen>(find.byType(PlayerPageScreen))
        .routeSettings!;
    expect(shown.disableEdit, isTrue);
    expect(
        (shown.characterConfigurationOverride as RpgCharacterConfiguration)
            .characterName,
        'Beispielfigur');
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches to the tablet layout', (tester) async {
    await pumpPreview(tester);

    await tester.tap(find.byKey(const ValueKey('playerPreviewTablet')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 50));

    expect(previewLaysOutAsPhone(tester), isFalse);
    expect(tester.takeException(), isNull);
  });
}
