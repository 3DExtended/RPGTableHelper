import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_player_configuration_modal.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Regression coverage for the first-time stat wizard aborting after the
/// character portrait.
///
/// `handlePossiblyMissingCharacterStats` walks every unconfigured stat, opens
/// `showGetPlayerConfigurationModal` for each, and treats a `null` result as
/// "user cancelled -> stop configuring the rest". The modal must therefore
/// return `null` ONLY for the explicit Cancel/close buttons — never for a
/// Save on a stat the user opened but left at its default. The singleImage
/// portrait is the stat players routinely skip (generating an image costs an
/// AI call), so it was the one that silently aborted every remaining stat.
void main() {
  CharacterStatDefinition portraitStat() => CharacterStatDefinition(
        groupId: null,
        isOptionalForAlternateForms: false,
        isOptionalForCompanionCharacters: null,
        valueType: CharacterStatValueType.singleImage,
        editType: CharacterStatEditType.static,
        name: "Aussehen",
        statUuid: "1b3b65c3-b58f-4b00-8616-c229b103c311",
        helperText: "Wie sieht dein Charakter aus?",
        jsonSerializedAdditionalData: null,
      );

  CharacterStatDefinition textStat() => CharacterStatDefinition(
        groupId: null,
        isOptionalForAlternateForms: false,
        isOptionalForCompanionCharacters: null,
        valueType: CharacterStatValueType.singleLineText,
        editType: CharacterStatEditType.static,
        name: "Background",
        statUuid: "057ab833-ce74-4feb-9b0d-4f53a83b3c21",
        helperText: "What is your tragic background story?",
        jsonSerializedAdditionalData: null,
      );

  Widget buildHarness({
    required GlobalKey<NavigatorState> navigatorKey,
    required Future<void> Function(BuildContext context) onPressed,
  }) {
    return CustomThemeProvider(
      overrideBrightness: Brightness.light,
      child: ProviderScope(
        overrides: [
          rpgCharacterConfigurationProvider.overrideWith((ref) {
            return RpgCharacterConfigurationNotifier(
              decks: AsyncValue.data(
                RpgCharacterConfiguration.getBaseConfiguration(null),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
          rpgConfigurationProvider.overrideWith((ref) {
            return RpgConfigurationNotifier(
              decks: AsyncValue.data(
                RpgConfigurationModel.getBaseConfiguration(),
              ),
              ref: ref,
              runningInTests: true,
            );
          }),
        ],
        child: ThemeConfigurationForApp(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: DependencyProvider.getMockedDependecyProvider(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () => onPressed(context),
                    child: const Text("open"),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'Save on an untouched fresh singleImage stat returns a non-null value '
    '(so the first-time wizard does not treat it as a cancel and abort)',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      RpgCharacterStatValue? result;
      var completed = false;

      await tester.pumpWidget(buildHarness(
        navigatorKey: navigatorKey,
        onPressed: (context) async {
          result = await showGetPlayerConfigurationModal(
            context: context,
            statConfiguration: portraitStat(),
            characterValue: null, // first-time config: nothing filled yet
            characterName: "Frodo",
            isEditingAlternateForm: false,
            // Drop the live preview; only the footer Save/Cancel contract
            // is under test here.
            hideVariantSelection: true,
            characterToRenderStatFor:
                RpgCharacterConfiguration.getBaseConfiguration(
                    RpgConfigurationModel.getBaseConfiguration()),
            overrideNavigatorKey: navigatorKey,
          );
          completed = true;
        },
      ));

      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      // Save WITHOUT touching the prompt field or generating an image.
      // The footer button is last in tree order (below the config form).
      await tester.tap(find.text("Save").last);
      await tester.pumpAndSettle();

      expect(completed, isTrue,
          reason: 'the modal future should have resolved after Save');
      expect(result, isNotNull,
          reason:
              'Save must yield the stat default, not null — null would make '
              'handlePossiblyMissingCharacterStats abort the remaining stats');
      expect(result!.statUuid, portraitStat().statUuid);

      final decoded = jsonDecode(result!.serializedValue) as Map<String, dynamic>;
      expect(decoded['imageUrl'],
          'assets/images/charactercard_placeholder.png',
          reason: 'an unset portrait should default to the placeholder image');
    },
  );

  testWidgets(
    'Cancel on the stat modal still returns null '
    '(preserving the deliberate "cancel stops the wizard" behavior)',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      RpgCharacterStatValue? result;
      var completed = false;

      await tester.pumpWidget(buildHarness(
        navigatorKey: navigatorKey,
        onPressed: (context) async {
          result = await showGetPlayerConfigurationModal(
            context: context,
            statConfiguration: portraitStat(),
            characterValue: null,
            characterName: "Frodo",
            isEditingAlternateForm: false,
            hideVariantSelection: true,
            characterToRenderStatFor:
                RpgCharacterConfiguration.getBaseConfiguration(
                    RpgConfigurationModel.getBaseConfiguration()),
            overrideNavigatorKey: navigatorKey,
          );
          completed = true;
        },
      ));

      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Cancel").last);
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(result, isNull,
          reason: 'Cancel must remain the signal that aborts configuration');
    },
  );

  testWidgets(
    'Save preserves an already-set portrait image url '
    '(uploaded or generated images survive a round-trip)',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      RpgCharacterStatValue? result;

      // A url shaped like what /Image/streamimageupload returns for an
      // uploaded device image (the generate path yields the same shape).
      const uploadedUrl =
          '/public/getimage/2b3c4d5e-6f70-4812-9a3b-4c5d6e7f8091/apikey'
          '?metadataid=2b3c4d5e-6f70-4812-9a3b-4c5d6e7f8091';

      await tester.pumpWidget(buildHarness(
        navigatorKey: navigatorKey,
        onPressed: (context) async {
          result = await showGetPlayerConfigurationModal(
            context: context,
            statConfiguration: portraitStat(),
            // Portrait already carries a selected image, as it would right
            // after the user uploaded one.
            characterValue: RpgCharacterStatValue(
              variant: 0,
              statUuid: portraitStat().statUuid,
              hideFromCharacterScreen: false,
              hideLabelOfStat: false,
              serializedValue: jsonEncode({
                'value': 'A grim dwarf',
                'imageUrl': uploadedUrl,
              }),
            ),
            characterName: "Frodo",
            isEditingAlternateForm: false,
            hideVariantSelection: true,
            characterToRenderStatFor:
                RpgCharacterConfiguration.getBaseConfiguration(
                    RpgConfigurationModel.getBaseConfiguration()),
            overrideNavigatorKey: navigatorKey,
          );
        },
      ));

      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Save").last);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      final decoded = jsonDecode(result!.serializedValue) as Map<String, dynamic>;
      expect(decoded['imageUrl'], uploadedUrl,
          reason: 'a selected portrait image must persist across Save');
    },
  );

  testWidgets(
    'Save on an untouched fresh text stat also returns a non-null value '
    '(the seeding fix is not image-specific)',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      RpgCharacterStatValue? result;
      var completed = false;

      await tester.pumpWidget(buildHarness(
        navigatorKey: navigatorKey,
        onPressed: (context) async {
          result = await showGetPlayerConfigurationModal(
            context: context,
            statConfiguration: textStat(),
            characterValue: null, // first-time config: nothing typed yet
            characterName: "Frodo",
            isEditingAlternateForm: false,
            hideVariantSelection: true,
            characterToRenderStatFor:
                RpgCharacterConfiguration.getBaseConfiguration(
                    RpgConfigurationModel.getBaseConfiguration()),
            overrideNavigatorKey: navigatorKey,
          );
          completed = true;
        },
      ));

      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      // Save WITHOUT typing anything into the field.
      await tester.tap(find.text("Save").last);
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(result, isNotNull,
          reason:
              'an empty text Save must yield the default value, not null — '
              'otherwise the wizard aborts here just as it did on the portrait');
      expect(result!.statUuid, textStat().statUuid);

      final decoded = jsonDecode(result!.serializedValue) as Map<String, dynamic>;
      expect(decoded['value'], '',
          reason: 'an untouched text stat defaults to an empty string');
    },
  );

  CharacterStatDefinition healthBarStat() => CharacterStatDefinition(
        groupId: null,
        isOptionalForAlternateForms: false,
        isOptionalForCompanionCharacters: null,
        valueType: CharacterStatValueType.intWithMaxValue,
        editType: CharacterStatEditType.oneTap,
        name: "HP",
        statUuid: "df25675c-d989-4a63-92b3-e395ef4b5769",
        helperText: "How many health points do you have?",
        jsonSerializedAdditionalData: null,
      );

  testWidgets(
    'testing the health bar in the preview (tapping +) does NOT leak into the '
    'saved value on Save (the preview is an ephemeral sandbox)',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      RpgCharacterStatValue? result;

      await tester.pumpWidget(buildHarness(
        navigatorKey: navigatorKey,
        onPressed: (context) async {
          result = await showGetPlayerConfigurationModal(
            context: context,
            statConfiguration: healthBarStat(),
            characterValue: RpgCharacterStatValue(
              variant: 0,
              statUuid: healthBarStat().statUuid,
              hideFromCharacterScreen: false,
              hideLabelOfStat: false,
              serializedValue: jsonEncode({"value": 5, "maxValue": 10}),
            ),
            characterName: "Frodo",
            isEditingAlternateForm: false,
            // Keep the live preview so its interactive +/- controls render.
            hideVariantSelection: false,
            characterToRenderStatFor:
                RpgCharacterConfiguration.getBaseConfiguration(
                    RpgConfigurationModel.getBaseConfiguration()),
            overrideNavigatorKey: navigatorKey,
          );
        },
      ));

      await tester.tap(find.text("open"));
      await tester.pumpAndSettle();

      // Drive the health bar in the preview, as a player "testing" it would.
      // hitTestable() picks the button on the visible page (adjacent pages are
      // built offstage and would not receive the tap).
      final previewPlus = find
          .descendant(
            of: find.byType(PageView),
            matching: find.byIcon(FontAwesomeIcons.plus),
          )
          .hitTestable()
          .first;
      await tester.ensureVisible(previewPlus);
      await tester.tap(previewPlus);
      await tester.pumpAndSettle();

      // The reset affordance only appears once the sandbox is dirty, so this
      // confirms the test tap actually registered (making the no-leak check
      // below meaningful rather than trivially true).
      expect(find.text(S.current.previewTestReset), findsOneWidget,
          reason: 'the + tap should have activated the preview sandbox');

      await tester.tap(find.text("Save").last);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      final decoded = jsonDecode(result!.serializedValue) as Map<String, dynamic>;
      expect(decoded['value'], 5,
          reason: 'the saved value must be the configured value, not the '
              'sandbox value the player test-drove in the preview');
      expect(decoded['maxValue'], 10);
    },
  );
}
