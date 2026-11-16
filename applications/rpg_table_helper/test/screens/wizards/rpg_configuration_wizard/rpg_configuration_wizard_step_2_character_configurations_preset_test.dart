import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/wizards/wizard_step_save_registry.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/modals/show_confirm_delete_dialog.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_2_character_configurations_preset.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

CharacterStatDefinition _stat(String uuid, String name, int group) {
  return CharacterStatDefinition(
    statUuid: uuid,
    name: name,
    groupId: group,
    helperText: '',
    valueType: CharacterStatValueType.singleLineText,
    editType: CharacterStatEditType.static,
    isOptionalForAlternateForms: false,
    isOptionalForCompanionCharacters: false,
  );
}

/// "Hintergrund": Name, Alter | Herkunft (second group). "Werte": HP and,
/// if asked for, a property without a name.
RpgConfigurationModel _config({bool withUnnamedStat = false}) {
  return RpgConfigurationModel.getBaseConfiguration().copyWith(
    characterStatTabsDefinition: [
      CharacterStatsTabDefinition(
        uuid: 'tab-a',
        tabName: 'Hintergrund',
        isOptional: false,
        isDefaultTab: true,
        statsInTab: [
          _stat('s-name', 'Name', 0),
          _stat('s-age', 'Alter', 0),
          _stat('s-origin', 'Herkunft', 1),
        ],
      ),
      CharacterStatsTabDefinition(
        uuid: 'tab-b',
        tabName: 'Werte',
        isOptional: false,
        isDefaultTab: false,
        statsInTab: [
          _stat('s-hp', 'HP', 0),
          if (withUnnamedStat) _stat('s-unnamed', '', 0),
        ],
      ),
    ],
  );
}

OpenPlayerConnection _playerWithValueFor(String statUuid) {
  final character = RpgCharacterConfiguration.getBaseConfiguration(_config())
      .copyWith(
        // The sample companion comes with values for every stat.
        companionCharacters: [],
        characterStats: [
          RpgCharacterStatValue(
            statUuid: statUuid,
            serializedValue: '{"value":"Mira"}',
            hideFromCharacterScreen: false,
            variant: null,
            hideLabelOfStat: false,
          ),
        ],
      );
  return OpenPlayerConnection(
    lastPing: null,
    userId: UserIdentifier(value: 'user-1'),
    playerCharacterId: PlayerCharacterIdentifier(value: character.uuid),
    configuration: character,
  );
}

Future<ProviderContainer> _pumpStep(
  WidgetTester tester, {
  List<OpenPlayerConnection> players = const [],
  bool withUnnamedStat = false,
}) async {
  tester.view.physicalSize = const Size(2400, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      rpgConfigurationProvider.overrideWith((ref) {
        return RpgConfigurationNotifier(
          decks: AsyncValue.data(_config(withUnnamedStat: withUnnamedStat)),
          ref: ref,
          runningInTests: true,
        );
      }),
      connectionDetailsProvider.overrideWith((ref) {
        return ConnectionDetailsNotifier(
          initState: AsyncValue.data(
            ConnectionDetails.defaultValue().copyWith(
              isDm: true,
              connectedPlayers: players,
            ),
          ),
          runningInTests: true,
          ref: ref,
        );
      }),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: CustomThemeProvider(
        overrideBrightness: Brightness.dark,
        child: MaterialApp(
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            S.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: RpgConfigurationWizardStep2CharacterConfigurationsPreset(
              onPreviousBtnPressed: () {},
              onNextBtnPressed: () {},
              setWizardTitle: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Finder _deleteTab(String uuid) =>
    find.byKey(ValueKey('$wizardDeleteTabButtonKeyPrefix$uuid'));

Finder _deleteStat(String uuid) =>
    find.byKey(ValueKey('$wizardDeleteStatButtonKeyPrefix$uuid'));

List<CharacterStatsTabDefinition> _savedTabs(ProviderContainer container) {
  flushActiveWizardStepSave();
  return container
      .read(rpgConfigurationProvider)
      .requireValue
      .characterStatTabsDefinition!;
}

void main() {
  group('deleting a tab', () {
    testWidgets('asks with name and number of properties; cancel keeps it', (
      tester,
    ) async {
      final container = await _pumpStep(tester);

      await tester.tap(_deleteTab('tab-a'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Tab „Hintergrund“ mit 3 Eigenschaften löschen? '
          'Werte der Charaktere gehen verloren.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(confirmDeleteDialogCancelKey));
      await tester.pumpAndSettle();

      expect(_deleteTab('tab-a'), findsOneWidget);
      expect(_savedTabs(container).map((t) => t.uuid), ['tab-a', 'tab-b']);
    });

    testWidgets('confirm removes it and keeps a start tab', (tester) async {
      final container = await _pumpStep(tester);

      await tester.tap(_deleteTab('tab-a'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(confirmDeleteDialogConfirmKey));
      await tester.pumpAndSettle();

      expect(_deleteTab('tab-a'), findsNothing);
      final tabs = _savedTabs(container);
      expect(tabs.map((t) => t.uuid), ['tab-b']);
      expect(tabs.single.isDefaultTab, isTrue);
    });
  });

  group('groups', () {
    testWidgets('dividers are numbered, not "Neue Gruppe:"', (tester) async {
      await _pumpStep(tester);
      expect(find.text('Gruppe 2'), findsOneWidget);
      expect(find.text('Neue Gruppe:'), findsNothing);
    });

    testWidgets('deleting the last property of a group removes the divider', (
      tester,
    ) async {
      final container = await _pumpStep(tester);

      await tester.tap(_deleteStat('s-origin'));
      await tester.pumpAndSettle();

      expect(find.text('Gruppe 2'), findsNothing);
      expect(_deleteStat('s-origin'), findsNothing);
      final tab = _savedTabs(container).first;
      expect(tab.statsInTab.map((s) => s.statUuid), ['s-name', 's-age']);
      expect(tab.statsInTab.map((s) => s.groupId), [0, 0]);
    });

    testWidgets('undo brings the property and its group back', (tester) async {
      final container = await _pumpStep(tester);

      await tester.tap(_deleteStat('s-origin'));
      await tester.pumpAndSettle();
      expect(find.text('Eigenschaft „Herkunft“ gelöscht'), findsOneWidget);

      await tester.tap(find.text('Rückgängig'));
      await tester.pumpAndSettle();

      expect(find.text('Gruppe 2'), findsOneWidget);
      expect(_deleteStat('s-origin'), findsOneWidget);
      final tab = _savedTabs(container).first;
      expect(tab.statsInTab.map((s) => s.groupId), [0, 0, 1]);
    });

    testWidgets('a divider has its own delete button', (tester) async {
      final container = await _pumpStep(tester);

      final deleteDivider = find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith(wizardDeleteGroupButtonKeyPrefix);
      });
      expect(deleteDivider, findsOneWidget);

      await tester.tap(deleteDivider);
      await tester.pumpAndSettle();

      expect(find.text('Gruppe 2'), findsNothing);
      // The properties stay and join the group above.
      final tab = _savedTabs(container).first;
      expect(tab.statsInTab.map((s) => s.statUuid), [
        's-name',
        's-age',
        's-origin',
      ]);
      expect(tab.statsInTab.map((s) => s.groupId), [0, 0, 0]);
    });
  });

  group('deleting a property', () {
    testWidgets('asks first when a character has a value for it', (
      tester,
    ) async {
      final container = await _pumpStep(
        tester,
        players: [_playerWithValueFor('s-name')],
      );

      await tester.tap(_deleteStat('s-name'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Eigenschaft „Name“ löschen? Ein Charakter hat dafür '
          'schon einen Wert, er geht verloren.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(confirmDeleteDialogCancelKey));
      await tester.pumpAndSettle();
      expect(_deleteStat('s-name'), findsOneWidget);

      await tester.tap(_deleteStat('s-name'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(confirmDeleteDialogConfirmKey));
      await tester.pumpAndSettle();

      expect(_deleteStat('s-name'), findsNothing);
      expect(_savedTabs(container).first.statsInTab.map((s) => s.statUuid), [
        's-age',
        's-origin',
      ]);
    });

    testWidgets('without values it deletes right away', (tester) async {
      await _pumpStep(tester, players: [_playerWithValueFor('s-hp')]);

      await tester.tap(_deleteStat('s-name'));
      await tester.pumpAndSettle();

      expect(find.byKey(confirmDeleteDialogConfirmKey), findsNothing);
      expect(_deleteStat('s-name'), findsNothing);
    });

    testWidgets('an unnamed property gets a clear placeholder', (tester) async {
      await _pumpStep(tester, withUnnamedStat: true);
      expect(
        find.textContaining('Unbenannte Eigenschaft (', findRichText: true),
        findsOneWidget,
      );
    });
  });

  test('countCharactersWithValuesForStat counts characters, not values', () {
    final players = [
      _playerWithValueFor('s-name'),
      _playerWithValueFor('s-name'),
      _playerWithValueFor('s-hp'),
    ];
    expect(countCharactersWithValuesForStat(players, 's-name'), 2);
    expect(countCharactersWithValuesForStat(players, 's-age'), 0);
    expect(countCharactersWithValuesForStat(null, 's-name'), 0);
  });
}
