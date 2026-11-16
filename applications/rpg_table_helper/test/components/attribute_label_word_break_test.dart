import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/player_stats_configuration_visuals.dart';
import 'package:quest_keeper/helpers/character_stats/stat_visualization_variant_widgets.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_screen_character_money.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

import '../custom_font_loader.dart';

/// SP-9 / B9: labels on a phone (402 pt) neither break a word in the middle
/// ("Geschickl|ichkeit") nor collapse to the same first word ("Guthaben |
/// Guthaben").
void main() {
  const phone = Size(402, 874);

  Future<void> pumpOnPhone(WidgetTester tester, Widget child) async {
    await customLoadAppFonts();
    tester.view.physicalSize = phone * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      CustomThemeProvider(
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
          ],
          child: ThemeConfigurationForApp(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              // German: the main language and the longer labels.
              locale: const Locale('de'),
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                S.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(body: SingleChildScrollView(child: child)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Number of lines [text] is laid out in.
  int lineCount(WidgetTester tester, String text) {
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text(text).last,
    );
    final painter = TextPainter(
      text: paragraph.text,
      textDirection: TextDirection.ltr,
      textScaler: paragraph.textScaler,
      maxLines: paragraph.maxLines,
    )..layout(maxWidth: paragraph.size.width);
    return painter.computeLineMetrics().length;
  }

  testWidgets('tile grid keeps "Geschicklichkeit" on one line', (tester) async {
    await pumpOnPhone(
      tester,
      const MultiselectTileGrid(
        title: 'Rettungswürfe',
        items: [
          (label: 'Geschicklichkeit', description: '', count: 1),
          (label: 'Konstitution', description: '', count: 0),
        ],
      ),
    );

    expect(lineCount(tester, 'Geschicklichkeit'), 1);
    expect(lineCount(tester, 'Konstitution'), 1);
  });

  testWidgets('ability blocks show the full attribute name', (tester) async {
    await pumpOnPhone(
      tester,
      const Wrap(
        children: [
          ModifierFirstBlock(score: 14, modifier: 2, label: 'Geschicklichkeit'),
          ClassicAbilityBlock(
            score: 14,
            modifier: 2,
            label: 'Geschicklichkeit',
          ),
        ],
      ),
    );

    for (final text in ['Geschicklichkeit', 'GESCHICKLICHKEIT']) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text(text).last,
      );
      expect(
        paragraph.didExceedMaxLines,
        isFalse,
        reason: '$text should shrink to fit, not be cut off',
      );
    }
  });

  testWidgets('config form puts attribute names on their own line', (
    tester,
  ) async {
    await pumpOnPhone(
      tester,
      SizedBox(
        width: phone.width - 40,
        child: PlayerStatsConfigurationVisuals(
          statConfiguration: CharacterStatDefinition(
            groupId: null,
            isOptionalForAlternateForms: false,
            isOptionalForCompanionCharacters: false,
            valueType: CharacterStatValueType.listOfIntWithCalculatedValues,
            editType: CharacterStatEditType.static,
            name: 'Attribute',
            statUuid: 'attributes',
            helperText: '',
            jsonSerializedAdditionalData:
                '{"values":[{"uuid":"dex","label":"Geschicklichkeit"}]}',
          ),
          characterName: 'Mira Dornwald',
          characterToRenderStatFor: null,
          hideVariantSelection: true,
          hideAdditionalSetting: true,
          onNewStatValue: (_) {},
        ),
      ),
    );

    expect(lineCount(tester, 'Geschicklichkeit:'), 1);
    // The field labels fit as well ("Erste…" / "Zwei…" before).
    for (final label in [S.current.firstValue, S.current.secondValue]) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text(label).last,
      );
      expect(paragraph.didExceedMaxLines, isFalse, reason: label);
    }
  });

  testWidgets('money page shows two different, unwrapped options', (
    tester,
  ) async {
    final config = RpgConfigurationModel.getBaseConfiguration();
    await pumpOnPhone(
      tester,
      PlayerScreenCharacterMoney(
        rpgConfig: config,
        charToRender: RpgCharacterConfiguration.getBaseConfiguration(null),
      ),
    );

    expect(S.current.moneyModeDeposit, isNot(S.current.moneyModeSpend));
    expect(lineCount(tester, S.current.moneyModeDeposit), 1);
    expect(lineCount(tester, S.current.moneyModeSpend), 1);
    expect(tester.takeException(), isNull);
  });
}
