import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_renderer_for_configuration.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';
import 'package:quest_keeper/helpers/initiative_bonus_wizard_draft_provider.dart';
import 'package:quest_keeper/helpers/modals/show_confirm_delete_dialog.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_0_character_sheet_skin.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_1_campagne_name.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_template_choice.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/auth/api_connector_service.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';

import '../../../custom_font_loader.dart';

const _campaignName = "Die Klingen von Varn";

/// A campaign as `createNewCampagne` creates it.
RpgConfigurationModel _newCampaign() =>
    RpgConfigurationTemplates.fantasySrd().copyWith(rpgName: _campaignName);

final _wizard = allWizardConfigurations['/rpgconfigurationwizard']!;

/// Pumps a home page and pushes the setup wizard on top, like the app does
/// after creating a campaign ([isNewSetup]) or from the gear icon.
Future<ProviderContainer> _pumpWizard(
  WidgetTester tester, {
  RpgConfigurationModel? config,
  bool isNewSetup = true,
  Size? size,
  String skinId = CharacterSheetSkinIds.classicDark,
  Locale locale = const Locale('de'),
  List<Campagne>? ownCampagnes,
}) async {
  if (size != null) {
    // Real fonts: the test font draws every glyph as a wide square.
    await customLoadAppFonts();
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  final container = ProviderContainer(
    overrides: [
      rpgConfigurationProvider.overrideWith((ref) {
        return RpgConfigurationNotifier(
          decks: AsyncValue.data(config ?? _newCampaign()),
          ref: ref,
          runningInTests: true,
        );
      }),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: CustomThemeProvider(
        overrideSkinId: skinId,
        child: DependencyProvider.getMockedDependecyProvider(
          mockOverrides: {
            IRpgEntityService: () => MockRpgEntityService(
              apiConnectorService: DependencyProvider.getIt!
                  .get<IApiConnectorService>(),
              getCampagnesWithPlayerAsDmOverride: HRResponse.fromResult(
                ownCampagnes ?? const [],
              ),
            ),
          },
          child: MaterialApp(
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WizardRendererForConfiguration(
                            configuration: _wizard,
                            isNewSetup: isNewSetup,
                          ),
                        ),
                      ),
                      child: const Text('Home'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Home'));
  await tester.pumpAndSettle();
  return container;
}

Finder _card(RpgConfigurationTemplateId id) =>
    find.byKey(RpgTemplateCard.keyFor(id));

RpgConfigurationTemplateId? _selectedCard(WidgetTester tester) {
  for (final id in RpgConfigurationTemplates.ids) {
    if (tester.widget<RpgTemplateCard>(_card(id)).isSelected) return id;
  }
  return null;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

RpgConfigurationModel _config(ProviderContainer container) =>
    container.read(rpgConfigurationProvider).requireValue;

/// The configuration is template [id] with the campaign's name.
void _expectTemplate(
  ProviderContainer container,
  RpgConfigurationTemplateId id,
) {
  final config = _config(container);
  expect(config.rpgName, _campaignName);
  expect(RpgConfigurationTemplates.matchingTemplateOf(config), id);
}

/// A campaign of the game master with [config].
Campagne _ownCampagne(
  String id,
  String name, {
  RpgConfigurationModel? config,
  String? json,
  DateTime? lastModifiedAt,
}) => Campagne(
  id: CampagneIdentifier(value: id),
  campagneName: name,
  joinCode: '111-222',
  dmUserId: UserIdentifier(value: 'dm'),
  creationDate: DateTime(2026, 1, 1),
  lastModifiedAt: lastModifiedAt ?? DateTime(2026, 1, 1),
  rpgConfiguration: json ?? (config == null ? null : jsonEncode(config)),
);

/// "Die Ödlande": the narrative template with an extra currency, an item
/// and its own sheet skin.
RpgConfigurationModel _ownConfig() => RpgConfigurationTemplates.narrative()
    .copyWith(
      rpgName: 'Die Ödlande',
      defaultSkinId: CharacterSheetSkinIds.arcaneLedger,
      allItems: RpgConfigurationModel.getBaseConfiguration().allItems.take(2)
          .toList(),
    );

void main() {
  group('another campaign of the game master', () {
    test('only others with a readable configuration, newest first', () {
      final config = _ownConfig();
      final list = ownCampagneConfigurations([
        _ownCampagne('current', 'Diese', config: config),
        _ownCampagne('old', 'Alt', config: config,
            lastModifiedAt: DateTime(2025, 1, 1)),
        _ownCampagne('none', 'Ohne'),
        _ownCampagne('broken', 'Kaputt', json: '{"rpgName": 3'),
        _ownCampagne('new', 'Neu', config: config,
            lastModifiedAt: DateTime(2026, 6, 1)),
      ], 'current');

      expect(list.map((c) => c.campagne.campagneName), ['Neu', 'Alt']);
      expect(list.first.config.allItems, hasLength(2));
    });

    test('everything but the name is taken over', () {
      final current = _newCampaign();
      final copied = configurationCopiedFrom(_ownConfig(), current);

      expect(copied.rpgName, _campaignName);
      expect(copied.defaultSkinId, CharacterSheetSkinIds.arcaneLedger);
      expect(copied.allItems, hasLength(2));
      expect(
        RpgConfigurationTemplates.comparableJson(copied),
        RpgConfigurationTemplates.comparableJson(
          _ownConfig().copyWith(rpgName: _campaignName),
        ),
      );
      // Without a skin of its own the current one stays.
      final current2 = current.copyWith(
          defaultSkinId: CharacterSheetSkinIds.nightCartographer);
      expect(
        configurationCopiedFrom(
          RpgConfigurationTemplates.narrative(),
          current2,
        ).defaultSkinId,
        CharacterSheetSkinIds.nightCartographer,
      );
    });

    testWidgets('no section without other campaigns', (tester) async {
      await _pumpWizard(tester);
      expect(find.text(S.current.wizardTemplateFromCampagneHeader),
          findsNothing);
    });

    testWidgets('picking one takes over its configuration', (tester) async {
      final container = await _pumpWizard(
        tester,
        ownCampagnes: [_ownCampagne('own-1', 'Die Ödlande', config: _ownConfig())],
      );
      final card = find.byKey(RpgTemplateCard.keyForCampagne('own-1'));

      expect(find.text(S.current.wizardTemplateFromCampagneHeader),
          findsOneWidget);
      expect(find.text('Die Ödlande'), findsOneWidget);
      expect(
        find.textContaining('2 Items', findRichText: true),
        findsOneWidget,
      );

      await _tap(tester, card);
      expect(find.byKey(confirmDeleteDialogConfirmKey), findsNothing);
      expect(tester.widget<RpgTemplateCard>(card).isSelected, isTrue);
      expect(_selectedCard(tester), isNull);

      final config = _config(container);
      expect(config.rpgName, _campaignName);
      expect(config.allItems, hasLength(2));
      expect(config.defaultSkinId, CharacterSheetSkinIds.arcaneLedger);
      expect(
        RpgConfigurationTemplates.matchingTemplateOf(config),
        isNull,
        reason: 'the extra items set it apart from the template',
      );

      // Nothing changed since: a template replaces it without a question.
      await _tap(tester, _card(RpgConfigurationTemplateId.empty));
      expect(find.byKey(confirmDeleteDialogConfirmKey), findsNothing);
      _expectTemplate(container, RpgConfigurationTemplateId.empty);
      expect(tester.widget<RpgTemplateCard>(card).isSelected, isFalse);
    });

    testWidgets('asks before changes since the last choice are lost', (
      tester,
    ) async {
      final container = await _pumpWizard(
        tester,
        ownCampagnes: [_ownCampagne('own-1', 'Die Ödlande', config: _ownConfig())],
      );
      container.read(rpgConfigurationProvider.notifier).updateCurrency(
            CurrencyDefinition(
              currencyTypes: [
                CurrencyType(name: 'Taler', multipleOfPreviousValue: null),
              ],
            ),
          );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(RpgTemplateCard.keyForCampagne('own-1')));
      expect(find.byKey(confirmDeleteDialogConfirmKey), findsOneWidget);
      await _tap(tester, find.byKey(confirmDeleteDialogConfirmKey));
      expect(_config(container).allItems, hasLength(2));
    });
  });

  group('when the step is shown', () {
    test('only for a new campaign, as first step', () {
      final newSetup = _wizard.stepsFor(isNewSetup: true);
      final editing = _wizard.stepsFor(isNewSetup: false);

      expect(newSetup.length, editing.length + 1);
      expect(newSetup.first.onlyForNewSetup, isTrue);
      expect(
        newSetup.first.builder(() {}, () {}, (_) {}),
        isA<RpgConfigurationWizardStepTemplateChoice>(),
      );
      expect(
        editing.map((s) => s.builder(() {}, () {}, (_) {})),
        everyElement(isNot(isA<RpgConfigurationWizardStepTemplateChoice>())),
      );
      expect(
        editing.first.builder(() {}, () {}, (_) {}),
        isA<RpgConfigurationWizardStep0CharacterSheetSkin>(),
      );
      // Tests and goldens that walk the steps see the editing wizard.
      expect(_wizard.stepBuilders, hasLength(editing.length));
    });

    test('route arguments default to editing', () {
      expect(WizardRouteArguments.of(null).isNewSetup, isFalse);
      expect(WizardRouteArguments.of("something else").isNewSetup, isFalse);
      expect(
        WizardRouteArguments.of(const WizardRouteArguments(isNewSetup: true))
            .isNewSetup,
        isTrue,
      );
    });

    testWidgets('after creating a campaign the wizard starts with it', (
      tester,
    ) async {
      await _pumpWizard(tester, isNewSetup: true);

      expect(
        find.byType(RpgConfigurationWizardStepTemplateChoice),
        findsOneWidget,
      );
      expect(find.text(S.current.wizardTemplateNarrativeName), findsOneWidget);
      // First step: there is nothing to go back to.
      expect(find.byKey(wizardPreviousButtonKey), findsNothing);
    });

    testWidgets('the gear icon (editing) never shows it', (tester) async {
      await _pumpWizard(tester, isNewSetup: false);

      expect(
        find.byType(RpgConfigurationWizardStep0CharacterSheetSkin),
        findsOneWidget,
      );
      expect(
        find.byType(RpgConfigurationWizardStepTemplateChoice),
        findsNothing,
      );
      // The skin step welcomes as before.
      expect(find.textContaining('Willkommen bei QuestKeeper'), findsWidgets);

      // The skin step is the first one: there is no way back to a template.
      expect(find.byKey(wizardPreviousButtonKey), findsNothing);
    });

    testWidgets('after the template the skin step does not welcome again', (
      tester,
    ) async {
      await _pumpWizard(tester, isNewSetup: true);
      expect(find.textContaining('Willkommen bei QuestKeeper'), findsWidgets);

      await _tap(tester, find.byKey(wizardNextButtonKey));

      expect(
        find.byType(RpgConfigurationWizardStep0CharacterSheetSkin),
        findsOneWidget,
      );
      expect(find.textContaining('Willkommen bei QuestKeeper'), findsNothing);
      expect(find.textContaining('Darstellung'), findsWidgets);
    });
  });

  group('choosing a template', () {
    testWidgets('Fantasy 5E (SRD) is preselected for a new campaign', (
      tester,
    ) async {
      final container = await _pumpWizard(tester);

      expect(_selectedCard(tester), RpgConfigurationTemplateId.fantasySrd);
      _expectTemplate(container, RpgConfigurationTemplateId.fantasySrd);
    });

    testWidgets('sets the configuration and keeps the campaign name', (
      tester,
    ) async {
      final container = await _pumpWizard(tester);

      await _tap(tester, _card(RpgConfigurationTemplateId.narrative));
      expect(find.byKey(confirmDeleteDialogConfirmKey), findsNothing);
      expect(_selectedCard(tester), RpgConfigurationTemplateId.narrative);
      _expectTemplate(container, RpgConfigurationTemplateId.narrative);

      // Nothing changed since: the next template comes without a question.
      await _tap(tester, _card(RpgConfigurationTemplateId.empty));
      expect(find.byKey(confirmDeleteDialogConfirmKey), findsNothing);
      _expectTemplate(container, RpgConfigurationTemplateId.empty);

      await _tap(tester, _card(RpgConfigurationTemplateId.fantasySrd));
      _expectTemplate(container, RpgConfigurationTemplateId.fantasySrd);
      expect(_config(container).allItems, isEmpty);
    });

    testWidgets('keeps the sheet skin picked in a later step', (tester) async {
      final container = await _pumpWizard(
        tester,
        config: _newCampaign().copyWith(
          defaultSkinId: CharacterSheetSkinIds.arcaneLedger,
        ),
      );

      await _tap(tester, _card(RpgConfigurationTemplateId.empty));

      expect(
        _config(container).defaultSkinId,
        CharacterSheetSkinIds.arcaneLedger,
      );
    });

    testWidgets('asks before changes since the last choice are lost', (
      tester,
    ) async {
      final container = await _pumpWizard(tester);
      await _tap(tester, _card(RpgConfigurationTemplateId.narrative));

      // Next, back: the choice is remembered.
      await _tap(tester, find.byKey(wizardNextButtonKey));
      // A later step changes the currency.
      final changed = _config(container).copyWith(
        currencyDefinition: CurrencyDefinition(
          currencyTypes: [
            CurrencyType(name: "Taler", multipleOfPreviousValue: null),
          ],
        ),
      );
      container
          .read(rpgConfigurationProvider.notifier)
          .updateConfiguration(changed);
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(wizardPreviousButtonKey));

      expect(
        find.byType(RpgConfigurationWizardStepTemplateChoice),
        findsOneWidget,
      );
      expect(_selectedCard(tester), RpgConfigurationTemplateId.narrative);

      // Tapping the chosen template again does nothing.
      await _tap(tester, _card(RpgConfigurationTemplateId.narrative));
      expect(find.byKey(confirmDeleteDialogConfirmKey), findsNothing);

      await _tap(tester, _card(RpgConfigurationTemplateId.fantasySrd));
      expect(find.text(S.current.wizardTemplateReplaceTitle), findsOneWidget);

      // Cancel keeps everything.
      await _tap(tester, find.byKey(confirmDeleteDialogCancelKey));
      expect(jsonEncode(_config(container)), jsonEncode(changed));
      expect(_selectedCard(tester), RpgConfigurationTemplateId.narrative);

      await _tap(tester, _card(RpgConfigurationTemplateId.fantasySrd));
      await _tap(tester, find.byKey(confirmDeleteDialogConfirmKey));
      _expectTemplate(container, RpgConfigurationTemplateId.fantasySrd);
      expect(_selectedCard(tester), RpgConfigurationTemplateId.fantasySrd);

      // Freshly applied again: no question for the next switch.
      await _tap(tester, _card(RpgConfigurationTemplateId.empty));
      expect(find.byKey(confirmDeleteDialogConfirmKey), findsNothing);
      _expectTemplate(container, RpgConfigurationTemplateId.empty);
    });

    testWidgets('walking through skin and name changes nothing to ask about', (
      tester,
    ) async {
      final container = await _pumpWizard(tester);
      await _tap(tester, _card(RpgConfigurationTemplateId.narrative));

      // Skin step (stores the default skin) and name step.
      await _tap(tester, find.byKey(wizardNextButtonKey));
      await _tap(tester, find.text('Klassisch Hell').last);
      await _tap(tester, find.byKey(wizardNextButtonKey));
      expect(
        find.byType(RpgConfigurationWizardStep1CampagneName),
        findsOneWidget,
      );
      await _tap(tester, find.byKey(wizardPreviousButtonKey));
      await _tap(tester, find.byKey(wizardPreviousButtonKey));

      await _tap(tester, _card(RpgConfigurationTemplateId.empty));
      expect(find.byKey(confirmDeleteDialogConfirmKey), findsNothing);
      _expectTemplate(container, RpgConfigurationTemplateId.empty);
      expect(
        _config(container).defaultSkinId,
        CharacterSheetSkinIds.classicLight,
      );
    });

    testWidgets('drops a half-picked initiative of the old configuration', (
      tester,
    ) async {
      final container = await _pumpWizard(tester);
      container
          .read(initiativeBonusWizardDraftProvider.notifier)
          .state = const InitiativeBonusWizardDraft(
        selectedStatUuid: "44ab4bcc-0f90-42e0-b9f5-9d4dffc9ffc3",
        selectedListEntryUuid: null,
        selectedField: null,
      );

      await _tap(tester, _card(RpgConfigurationTemplateId.narrative));

      expect(container.read(initiativeBonusWizardDraftProvider), isNull);
    });
  });

  group('layout', () {
    const skins = [
      CharacterSheetSkinIds.classicLight,
      CharacterSheetSkinIds.classicDark,
      CharacterSheetSkinIds.arcaneLedger,
      CharacterSheetSkinIds.nightCartographer,
    ];
    const sizes = {
      'iPhone portrait': Size(402, 874),
      'iPad landscape': Size(1366, 1024),
      'iPad mini landscape': Size(1133, 744),
    };

    for (final skin in skins) {
      for (final MapEntry(key: name, value: size) in sizes.entries) {
        for (final locale in const [Locale('de'), Locale('en')]) {
          testWidgets('$skin, $name, ${locale.languageCode}: no overflow', (
            tester,
          ) async {
            final container = await _pumpWizard(
              tester,
              size: size,
              skinId: skin,
              locale: locale,
              ownCampagnes: [
                _ownCampagne(
                  'own-1',
                  'Die Chroniken der verlorenen Sternenwächter',
                  config: _ownConfig(),
                ),
              ],
            );
            expect(tester.takeException(), isNull);

            for (final id in RpgConfigurationTemplates.ids) {
              await tester.ensureVisible(_card(id));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            await tester.ensureVisible(
                find.byKey(RpgTemplateCard.keyForCampagne('own-1')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.byType(RpgTemplateCard), findsNWidgets(4));

            // The question fits as well.
            container
                .read(rpgConfigurationProvider.notifier)
                .updateCurrency(
                  CurrencyDefinition(
                    currencyTypes: [
                      CurrencyType(
                        name: "Taler",
                        multipleOfPreviousValue: null,
                      ),
                    ],
                  ),
                );
            await tester.pumpAndSettle();
            await _tap(tester, _card(RpgConfigurationTemplateId.narrative));
            expect(find.byKey(confirmDeleteDialogConfirmKey), findsOneWidget);
            expect(tester.takeException(), isNull);
            await _tap(tester, find.byKey(confirmDeleteDialogConfirmKey));
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
