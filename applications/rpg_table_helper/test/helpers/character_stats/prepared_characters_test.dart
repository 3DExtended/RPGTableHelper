import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/character_stats_form_pages.dart';
import 'package:quest_keeper/helpers/character_stats/level_up.dart';
import 'package:quest_keeper/helpers/character_stats/prepared_characters.dart';
import 'package:quest_keeper/helpers/character_stats/show_character_stats_form.dart';
import 'package:quest_keeper/helpers/character_stats/show_prepared_character_picker.dart';
import 'package:quest_keeper/helpers/modals/show_confirm_delete_dialog.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/prepared_character.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/prepared_characters_section.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Characters the game master prepares in the campaign; a joining player
/// takes one over instead of filling in the sheet.
void main() {
  final srd = RpgConfigurationTemplates.fantasySrd();
  final summary = levelStatOf(srd)!;
  const classUuid = '019317b8-49eb-7575-9f8e-c28c9c8eded2';
  const speciesUuid = '019317b8-4bb6-7881-a4db-2a8ec3c751f6';

  RpgCharacterStatValue value(String statUuid, Map<String, dynamic> json) =>
      RpgCharacterStatValue(
        statUuid: statUuid,
        serializedValue: jsonEncode(json),
        hideFromCharacterScreen: false,
        variant: 0,
        hideLabelOfStat: false,
      );

  PreparedCharacter thorin() => PreparedCharacter(
        uuid: 'thorin',
        characterName: 'Thorin',
        characterStats: [
          value(summary.statUuid, {
            'level': 3,
            'values': [
              {'uuid': classUuid, 'value': 'Kämpfer'},
              {'uuid': speciesUuid, 'value': 'Zwerg'},
            ],
          }),
          value('origin', {'value': 'Aus den Bergen'}),
        ],
      );

  group('in the campaign', () {
    test('travel with the configuration and stay out of it when there are none',
        () {
      final config = srd.copyWith(preparedCharacters: [thorin()]);
      final json = jsonDecode(jsonEncode(config)) as Map<String, dynamic>;
      final back = RpgConfigurationModel.fromJson(json);
      expect(back.preparedCharacters!.single.characterName, 'Thorin');
      expect(back.preparedCharacters!.single.characterStats, hasLength(2));

      expect(jsonDecode(jsonEncode(srd)), isNot(contains('preparedCharacters')),
          reason: 'templates and old campaigns stay as they were');
      expect(RpgConfigurationTemplates.matchingTemplateOf(srd),
          RpgConfigurationTemplateId.fantasySrd);
    });

    test('are added, replaced and removed by uuid', () {
      var config = withPreparedCharacter(srd, thorin());
      config = withPreparedCharacter(
          config, thorin().copyWith(characterName: 'Thorin II'));
      expect(config.preparedCharacters!.single.characterName, 'Thorin II');
      config = withPreparedCharacter(config, newPreparedCharacter());
      expect(config.preparedCharacters, hasLength(2));
      config = withoutPreparedCharacter(config, 'thorin');
      expect(config.preparedCharacters, hasLength(1));
      expect(
        withoutPreparedCharacter(config, config.preparedCharacters!.single.uuid)
            .preparedCharacters,
        isNull,
      );
    });
  });

  test('the form asks for every field, the name on the first page', () {
    final pages = preparedCharacterPages(srd);
    expect(pages.first.showNameField, isTrue);
    expect(pages.skip(1).every((p) => !p.showNameField), isTrue);
    final all = pages.expand((p) => p.stats).map((s) => s.statUuid).toSet();
    for (final tab in srd.characterStatTabsDefinition!) {
      for (final stat in fillableStatsOfTab(tab, isCompanion: false)) {
        expect(all, contains(stat.statUuid), reason: stat.name);
      }
    }
    expect(
      pages.expand((p) => p.stats).where((s) =>
          s.valueType == CharacterStatValueType.companionSelector ||
          s.valueType == CharacterStatValueType.transformIntoAlternateFormBtn),
      isEmpty,
    );
  });

  test('values stored page by page merge into the prepared character', () {
    final next = withPreparedValues(
      thorin(),
      [value('origin', {'value': 'Aus dem Tal'}), value('drive', {'value': 'Gold'})],
      null,
    );
    expect(next.characterName, 'Thorin');
    expect(next.characterStats.map((s) => s.statUuid),
        [summary.statUuid, 'origin', 'drive']);
    expect(jsonDecode(next.characterStats[1].serializedValue)['value'],
        'Aus dem Tal');
    expect(withPreparedValues(next, const [], 'Dáin').characterName, 'Dáin');
  });

  test('one line says who it is', () async {
    final s = await S.load(const Locale('de'));
    expect(preparedCharacterSummary(s, srd, thorin()),
        '${s.level} 3 · Kämpfer · Zwerg');
    expect(
      preparedCharacterSummary(
          s, RpgConfigurationTemplates.narrative(), thorin()),
      isEmpty,
      reason: 'the narrative summary has another uuid',
    );
    expect(preparedCharacterSummary(s, srd, newPreparedCharacter()), isEmpty);
  });

  test('taking one over brings its name and values', () {
    final own = RpgCharacterConfiguration.getBaseConfiguration(null).copyWith(
      characterName: 'Mira',
      characterStats: [
        value('origin', {'value': 'Eigenes'}),
        value('own', {'value': 'bleibt'}),
      ],
    );
    final taken = takePreparedCharacter(own, thorin());
    expect(taken.uuid, own.uuid);
    expect(taken.characterName, 'Thorin');
    final byUuid = {for (final s in taken.characterStats) s.statUuid: s};
    expect(byUuid.keys, unorderedEquals(['own', summary.statUuid, 'origin']));
    expect(jsonDecode(byUuid['origin']!.serializedValue)['value'],
        'Aus den Bergen');

    expect(
      takePreparedCharacter(own, thorin().copyWith(characterName: ' '))
          .characterName,
      'Mira',
    );
  });

  Widget harness({
    required RpgConfigurationModel config,
    required Widget Function(BuildContext context) child,
    GlobalKey<NavigatorState>? key,
  }) =>
      CustomThemeProvider(
        overrideBrightness: Brightness.light,
        child: ProviderScope(
          overrides: [
            rpgCharacterConfigurationProvider.overrideWith((ref) =>
                RpgCharacterConfigurationNotifier(
                  decks: AsyncValue.data(
                      RpgCharacterConfiguration.getBaseConfiguration(null)),
                  ref: ref,
                  runningInTests: true,
                )),
            rpgConfigurationProvider.overrideWith((ref) =>
                RpgConfigurationNotifier(
                  decks: AsyncValue.data(config),
                  ref: ref,
                  runningInTests: true,
                )),
          ],
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              navigatorKey: key ?? navigatorKey,
              locale: const Locale('de'),
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: DependencyProvider.getMockedDependecyProvider(
                child: Scaffold(body: Builder(builder: child)),
              ),
            ),
          ),
        ),
      );

  void bigView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> tapLast(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder.last);
    await tester.pumpAndSettle();
    await tester.tap(finder.last);
    await tester.pumpAndSettle();
  }

  group('the player', () {
    testWidgets('is offered them on the first page of the setup',
        (tester) async {
      bigView(tester);
      final key = GlobalKey<NavigatorState>();
      final character = RpgCharacterConfiguration.getBaseConfiguration(null)
          .copyWith(characterName: 'Mira', characterStats: []);
      var asked = 0;
      var take = false;
      CharacterStatsFormOutcome? outcome;

      await tester.pumpWidget(harness(
        config: srd,
        key: key,
        child: (context) => ElevatedButton(
          onPressed: () async {
            outcome = await showCharacterStatsForm(
              context: context,
              pages: buildCharacterStatsFormPages(
                rpgConfig: srd,
                character: character,
                isCompanion: false,
              ),
              mode: CharacterStatsFormMode.setup,
              characterName: 'Mira',
              initialValues: const {},
              characterToRenderStatFor: character,
              isEditingAlternateForm: false,
              overrideNavigatorKey: key,
              onPersist: (_, _) {},
              onChoosePrepared: (_) async {
                asked++;
                return take;
              },
            );
          },
          child: const Text('open'),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(S.current.preparedCharactersOfferTitle), findsWidgets);
      await tapLast(
          tester, find.byKey(CharacterStatsFormContent.choosePreparedKey));
      expect(asked, 1);
      expect(outcome, isNull, reason: 'nothing taken, the form stays');

      take = true;
      await tapLast(
          tester, find.byKey(CharacterStatsFormContent.choosePreparedKey));
      expect(outcome, CharacterStatsFormOutcome.tookPrepared);
    });

    testWidgets('picks one in the list', (tester) async {
      bigView(tester);
      final config = srd.copyWith(preparedCharacters: [
        thorin(),
        PreparedCharacter(uuid: 'ayla', characterName: 'Ayla', characterStats: []),
      ]);
      PreparedCharacter? chosen;
      var done = false;

      await tester.pumpWidget(harness(
        config: config,
        child: (context) => ElevatedButton(
          onPressed: () async {
            chosen = await showPreparedCharacterPicker(
                context: context, config: config);
            done = true;
          },
          child: const Text('open'),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Thorin'), findsWidgets);
      expect(find.text('${S.current.level} 3 · Kämpfer · Zwerg'), findsWidgets);
      await tapLast(tester, find.byKey(PreparedCharacterPicker.keyFor('ayla')));
      await tapLast(tester, find.text(S.current.preparedCharactersTake));
      expect(done, isTrue);
      expect(chosen!.uuid, 'ayla');
    });
  });

  testWidgets('the game master prepares, edits and deletes them',
      (tester) async {
    bigView(tester);
    // "Leer": one page with the name, the summary and a description.
    final config = RpgConfigurationTemplates.empty();
    late WidgetRef widgetRef;

    await tester.pumpWidget(harness(
      config: config,
      child: (context) => SingleChildScrollView(
        child: Consumer(builder: (context, ref, _) {
          widgetRef = ref;
          return const PreparedCharactersSection();
        }),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text(S.current.preparedCharactersTitle), findsOneWidget);

    await tapLast(tester, find.byKey(PreparedCharactersSection.addKey));
    expect(find.text(S.current.preparedCharactersAdd), findsWidgets);
    expect(find.text(S.current.fillInLater), findsNothing);
    await tester.enterText(
        find.widgetWithText(TextField, S.current.characterName).last, 'Ayla');
    await tester.pumpAndSettle();
    await tapLast(tester, find.text(S.current.characterSetupFinish));

    var prepared =
        widgetRef.read(rpgConfigurationProvider).value!.preparedCharacters!;
    expect(prepared.single.characterName, 'Ayla');
    expect(prepared.single.characterStats, isNotEmpty);
    expect(find.text('Ayla'), findsOneWidget);

    // Editing keeps it one character.
    await tapLast(
        tester, find.byKey(PreparedCharactersSection.cardKeyFor(prepared.single.uuid)));
    await tester.enterText(
        find.widgetWithText(TextField, S.current.characterName).last, 'Ayla Sturm');
    await tester.pumpAndSettle();
    await tapLast(tester, find.text(S.current.characterSetupFinish));
    prepared =
        widgetRef.read(rpgConfigurationProvider).value!.preparedCharacters!;
    expect(prepared.single.characterName, 'Ayla Sturm');

    await tapLast(tester,
        find.byKey(PreparedCharactersSection.deleteKeyFor(prepared.single.uuid)));
    await tapLast(tester, find.byKey(confirmDeleteDialogConfirmKey));
    expect(widgetRef.read(rpgConfigurationProvider).value!.preparedCharacters,
        isNull);
    expect(find.text('Ayla Sturm'), findsNothing);
  });
}
