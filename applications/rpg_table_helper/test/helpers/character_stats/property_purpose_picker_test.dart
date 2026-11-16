import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/property_purposes.dart';
import 'package:quest_keeper/helpers/character_stats/show_get_dm_configuration_modal.dart';
import 'package:quest_keeper/helpers/character_stats/show_property_purpose_picker.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// A new property starts with "What do you want to track?" instead of a list
/// of field types, and the editor shows the property as the sheet will.
///
/// The modal's shadow draws its content a second time; use the real one.
Finder real(Finder finder) => finder.last;

void main() {
  group('purposes', () {
    test('each purpose is offered once', () {
      expect(
        PropertyPurposeInfo.all.map((p) => p.purpose),
        unorderedEquals(PropertyPurpose.values),
      );
    });

    test('a purpose stands for an existing field type the app can show', () {
      for (final info in PropertyPurposeInfo.all) {
        final stat = info.newStat();
        expect(stat.valueType, info.valueType);
        expect(stat.editType, info.editType);
        expect(stat.name, isEmpty);
        expect(
          stat.valueType,
          isNot(anyOf(
            CharacterStatValueType.unsupported,
            CharacterStatValueType.characterNameWithLevelAndAdditionalDetails,
          )),
          reason: '${info.purpose}',
        );
      }
    });

    test('values that change during play are edited on the sheet', () {
      for (final purpose in [
        PropertyPurpose.resource,
        PropertyPurpose.counter,
        PropertyPurpose.tickBoxes,
      ]) {
        expect(PropertyPurposeInfo.of(purpose).editType,
            CharacterStatEditType.oneTap,
            reason: '$purpose');
      }
    });

    for (final locale in AppLocalizations.supportedLocales) {
      test('every purpose has a title and a description ($locale)', () async {
        final s = await S.load(locale);
        final titles = PropertyPurposeInfo.all.map((p) => p.title(s)).toList();
        expect(titles.toSet(), hasLength(titles.length));
        for (final info in PropertyPurposeInfo.all) {
          expect(info.title(s).trim(), isNotEmpty);
          expect(info.description(s).trim(), isNotEmpty);
        }
      });
    }
  });

  group('preview sample', () {
    test('a value for every purpose that can show one', () {
      for (final info in PropertyPurposeInfo.all) {
        final sample = propertyPreviewSample(
            info.newStat().copyWith(statUuid: 'p', name: 'Probe'));
        switch (info.purpose) {
          case PropertyPurpose.companions:
          case PropertyPurpose.transformation:
            // Needs a real character.
            expect(sample, isNull, reason: '${info.purpose}');
          case PropertyPurpose.checklist:
          case PropertyPurpose.pickOne:
          case PropertyPurpose.abilities:
          case PropertyPurpose.keyNumbers:
            // Nothing to show before the first entry.
            expect(sample, isNull, reason: '${info.purpose}');
          default:
            expect(sample, isNotNull, reason: '${info.purpose}');
            expect(sample!.statUuid, 'p');
            expect(sample.variant, 0);
        }
      }
    });

    test('lists get a value once they have entries', () {
      final checklist = PropertyPurposeInfo.of(PropertyPurpose.checklist)
          .newStat()
          .copyWith(
            statUuid: 'p',
            jsonSerializedAdditionalData: jsonEncode({
              'options': [
                {'uuid': 'a', 'label': 'Schwimmen', 'description': ''},
              ],
            }),
          );
      expect(propertyPreviewSample(checklist), isNotNull);

      final abilities = PropertyPurposeInfo.of(PropertyPurpose.abilities)
          .newStat()
          .copyWith(
            statUuid: 'p',
            jsonSerializedAdditionalData: jsonEncode({
              'values': [
                {'uuid': 'a', 'label': 'STÄ'},
              ],
            }),
          );
      expect(propertyPreviewSample(abilities), isNotNull);
    });
  });

  Future<Future<Object?> Function()> pumpAndOpen(
    WidgetTester tester,
    Future<Object?> Function(BuildContext context) open,
  ) async {
    Object? saved;
    var done = false;
    tester.view.physicalSize = const Size(1200, 2400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: CustomThemeProvider(
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              home: CustomThemeProvider(
                child: DependencyProvider.getMockedDependecyProvider(
                  child: Scaffold(
                    body: Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () async {
                          saved = await open(context);
                          done = true;
                        },
                        child: const Text('open'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () async {
      expect(done, isTrue);
      return saved;
    };
  }

  Future<void> tapReal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(real(finder));
    await tester.pumpAndSettle();
    await tester.tap(real(finder));
    await tester.pumpAndSettle();
  }

  /// Matches in the editor, the shadow's copy included: use [real] for the
  /// one that is shown.
  Finder inEditor(Finder matching) => find.descendant(
        of: real(find.byType(ShowGetDmConfigurationModalContent)),
        matching: matching,
      );

  Future<void> enterName(WidgetTester tester, String name) async {
    // The shadow's copy comes first; the name is the real copy's first field.
    final fields = inEditor(find.byType(TextField));
    final field = fields.at(fields.evaluate().length ~/ 2);
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.enterText(field, name);
    await tester.pumpAndSettle();
  }

  testWidgets('picking a purpose opens the editor with its field type',
      (tester) async {
    final result = await pumpAndOpen(
      tester,
      (context) => showNewPropertyEditor(context: context),
    );

    expect(find.text(S.current.propertyPurposePickerQuestion), findsWidgets);
    expect(find.text(S.current.propertyPurposeAdvancedTitle), findsWidgets);
    await tapReal(tester,
        find.byKey(PropertyPurposePicker.keyFor(PropertyPurpose.resource)));

    expect(inEditor(find.byKey(const ValueKey('propertyPurposeHeader'))),
        findsWidgets);
    expect(inEditor(find.text(S.current.propertyPurposeResourceTitle)),
        findsWidgets);
    // The field type stays out of the way, folded up.
    expect(inEditor(find.byKey(const ValueKey('propertyTypePickers'))),
        findsWidgets);
    expect(inEditor(find.text(S.current.kindOfProperty)), findsNothing);

    await enterName(tester, 'Trefferpunkte');
    expect(inEditor(find.byKey(const ValueKey('propertyPreview'))),
        findsWidgets);
    expect(
      find.descendant(
        of: real(find.byKey(const ValueKey('propertyPreview'))),
        matching: find.textContaining('Trefferpunkte', findRichText: true),
      ),
      findsWidgets,
      reason: 'the preview follows the name',
    );
    expect(tester.takeException(), isNull);

    await tapReal(tester, find.text(S.current.save));
    final saved =
        ((await result())! as List<CharacterStatDefinition>).single;
    expect(saved.name, 'Trefferpunkte');
    expect(saved.valueType, CharacterStatValueType.intWithMaxValue);
    expect(saved.editType, CharacterStatEditType.oneTap);
    expect(saved.statUuid, isNotEmpty);
  });

  testWidgets('the field type can still be changed', (tester) async {
    await pumpAndOpen(
      tester,
      (context) => showNewPropertyEditor(context: context),
    );
    await tapReal(tester,
        find.byKey(PropertyPurposePicker.keyFor(PropertyPurpose.counter)));

    await tapReal(
        tester, inEditor(find.byKey(const ValueKey('propertyTypePickers'))));
    expect(inEditor(find.text(S.current.kindOfProperty)), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Alle Feldtypen" opens the editor as before', (tester) async {
    final result = await pumpAndOpen(
      tester,
      (context) => showNewPropertyEditor(context: context),
    );
    await tapReal(
        tester, find.byKey(PropertyPurposePicker.keyFor(null)));

    expect(inEditor(find.byKey(const ValueKey('propertyPurposeHeader'))),
        findsNothing);
    expect(inEditor(find.byKey(const ValueKey('propertyTypePickers'))),
        findsNothing);
    expect(inEditor(find.text(S.current.kindOfProperty)), findsWidgets);

    await enterName(tester, 'Gold');
    await tapReal(tester, find.text(S.current.save));
    expect(
        ((await result())! as List<CharacterStatDefinition>).single.name, 'Gold');
  });

  testWidgets('cancelling the picker adds nothing', (tester) async {
    final result = await pumpAndOpen(
      tester,
      (context) => showNewPropertyEditor(context: context),
    );
    await tapReal(tester, find.text(S.current.cancel));

    expect(find.byType(ShowGetDmConfigurationModalContent), findsNothing);
    expect(await result(), isEmpty);
  });

  testWidgets('editing an existing property shows no purpose',
      (tester) async {
    await pumpAndOpen(
      tester,
      (context) => showGetDmConfigurationModal(
        context: context,
        predefinedConfiguration: PropertyPurposeInfo.of(PropertyPurpose.resource)
            .newStat()
            .copyWith(statUuid: 'hp', name: 'TP'),
        purpose: PropertyPurpose.counter,
      ),
    );

    expect(inEditor(find.byKey(const ValueKey('propertyPurposeHeader'))),
        findsNothing);
    expect(inEditor(find.text(S.current.kindOfProperty)), findsWidgets);
    expect(inEditor(find.byKey(const ValueKey('propertyPreview'))),
        findsWidgets);
  });

  for (final info in PropertyPurposeInfo.all) {
    testWidgets('the editor for "${info.purpose.name}" builds',
        (tester) async {
      await pumpAndOpen(
        tester,
        (context) =>
            showGetDmConfigurationModal(context: context, purpose: info.purpose),
      );
      await enterName(tester, 'Probe');

      expect(inEditor(find.byKey(const ValueKey('propertyPurposeHeader'))),
          findsWidgets);
      final shown =
          inEditor(find.byKey(const ValueKey('propertyPreview'))).evaluate().isNotEmpty;
      final empty = inEditor(find.byKey(const ValueKey('propertyPreviewEmpty'))).evaluate().isNotEmpty;
      expect([shown, empty].where((e) => e).length,
          propertyHasPreview(info.valueType) ? 1 : 0,
          reason: 'either the preview or the hint to add entries');
      expect(tester.takeException(), isNull);
    });
  }
}
