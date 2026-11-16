import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/modals/show_add_further_enemies_to_fight_sequence.dart';
import 'package:quest_keeper/helpers/modals/show_ask_player_for_fight_order_roll.dart';
import 'package:quest_keeper/helpers/number_input.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/l10n/app_localizations.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_screen_grant_items.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_6_create_or_edit_item_modal_new_design.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_create_or_edit_item_recipe_modal.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

/// Number fields in modals (B14): text or negative values never turn into a
/// silent 0 or 1; the field shows an error and saving is blocked. Every field
/// uses the signed keyboard, which has a return key on iOS.
///
/// Modals draw their content twice (the blurred shadow copy behind the real
/// one), so fields and texts are found twice and input goes to the last
/// (top) match.
void main() {
  late S de;
  setUp(() async => de = await S.load(const Locale('de')));

  final config = RpgConfigurationModel.getBaseConfiguration();

  Widget harness({
    required Widget Function(BuildContext context) home,
    List<dynamic> overrides = const [],
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
              decks: AsyncValue.data(config),
              ref: ref,
              runningInTests: true,
            );
          }),
          ...overrides.cast(),
        ],
        child: ThemeConfigurationForApp(
          child: MaterialApp(
            // The modals close themselves through the app's navigator key.
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              S.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            home: DependencyProvider.getMockedDependecyProvider(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Builder(builder: home),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget openButton(Future<void> Function(BuildContext context) onPressed) =>
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => onPressed(context),
          child: const Text('open'),
        ),
      );

  Future<void> useTabletSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1366, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// The top copy of the text field with [label].
  Finder field(String label) => find.widgetWithText(TextField, label).last;

  CustomButton button(WidgetTester tester, String label) => tester
      .widget<CustomButton>(find.widgetWithText(CustomButton, label).last);

  TextField textFieldWidget(WidgetTester tester, String label) =>
      tester.widget<TextField>(field(label));

  group('initiative roll of a player', () {
    testWidgets('text shows an error and cannot be sent', (tester) async {
      await useTabletSize(tester);
      await tester.pumpWidget(
        harness(
          home: (_) => openButton(
            (context) => showAskPlayerForFightOrderRoll(
              context,
              characterName: 'Mira',
              overrideNavigatorKey: navigatorKey,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final label = de.initiativeRollTextFieldLabel;
      expect(
        textFieldWidget(tester, label).keyboardType,
        signedIntKeyboardType,
      );
      expect(button(tester, de.send).onPressed, isNull);

      await tester.enterText(field(label), 'Waldläuferin');
      await tester.pumpAndSettle();

      expect(find.text(de.invalidWholeNumberInput), findsWidgets);
      expect(button(tester, de.send).onPressed, isNull);
    });

    testWidgets('a negative roll is sent as it is', (tester) async {
      await useTabletSize(tester);
      Future<int?>? result;
      await tester.pumpWidget(
        harness(
          home: (_) => openButton((context) async {
            result = showAskPlayerForFightOrderRoll(
              context,
              characterName: 'Mira',
              overrideNavigatorKey: navigatorKey,
            );
          }),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(field(de.initiativeRollTextFieldLabel), '−2');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidWholeNumberInput), findsNothing);

      button(tester, de.send).onPressed!();
      await tester.pumpAndSettle();

      expect(await result, -2);
    });
  });

  group('initiative of further enemies', () {
    testWidgets('text blocks adding, a negative roll is fine', (tester) async {
      await useTabletSize(tester);
      await tester.pumpWidget(
        harness(
          home: (_) => openButton(
            (context) => showAddFurtherEnemiesToFightSequence(
              context: context,
              overrideNavigatorKey: navigatorKey,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(de.addAnAdditionalEnemyBtnLabel).last);
      await tester.pumpAndSettle();

      final label = de.rollOfInititive;
      expect(
        textFieldWidget(tester, label).keyboardType,
        signedIntKeyboardType,
      );
      // No roll yet: nothing to add.
      expect(button(tester, de.add).onPressed, isNull);

      await tester.enterText(field(label), 'abc');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidWholeNumberShort), findsWidgets);
      expect(button(tester, de.add).onPressed, isNull);

      await tester.enterText(field(label), '-1');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidWholeNumberShort), findsNothing);
      expect(button(tester, de.add).onPressed, isNotNull);
    });
  });

  group('item prices and difficulty classes', () {
    Future<void> openItemModal(WidgetTester tester) async {
      await useTabletSize(tester);
      await tester.pumpWidget(
        harness(
          home: (_) => openButton(
            (context) => showCreateOrEditItemModal(
              context,
              RpgItem(
                imageDescription: null,
                imageUrlWithoutBasePath: null,
                uuid: 'item-1',
                name: 'Heiltrank',
                categoryId: '',
                description: 'Heilt 2W4+2 Lebenspunkte',
                patchSize: DiceRoll(numDice: 1, diceSides: 4, modifier: 1),
                baseCurrencyPrice: 1000,
                placeOfFindings: [
                  RpgItemRarity(
                    placeOfFindingId: '5b9690c1-afc9-436d-8912-d223c440eb6a',
                    diceChallenge: 5,
                  ),
                ],
              ),
              overrideNavigatorKey: navigatorKey,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'a price with text or a minus shows an error and blocks saving',
      (tester) async {
        await openItemModal(tester);

        expect(
          textFieldWidget(tester, 'Kupfer:').keyboardType,
          signedIntKeyboardType,
        );
        expect(find.text(de.invalidNonNegativeNumberShort), findsNothing);
        expect(button(tester, de.save).onPressed, isNotNull);

        await tester.enterText(field('Kupfer:'), 'viel');
        await tester.pumpAndSettle();
        expect(find.text(de.invalidNonNegativeNumberShort), findsWidgets);
        expect(button(tester, de.save).onPressed, isNull);

        await tester.enterText(field('Kupfer:'), '-3');
        await tester.pumpAndSettle();
        expect(find.text(de.invalidNonNegativeNumberShort), findsWidgets);
        expect(button(tester, de.save).onPressed, isNull);

        // Empty means none of this currency.
        await tester.enterText(field('Kupfer:'), '');
        await tester.pumpAndSettle();
        expect(find.text(de.invalidNonNegativeNumberShort), findsNothing);
        expect(button(tester, de.save).onPressed, isNotNull);
      },
    );

    testWidgets('a difficulty class must be a number', (tester) async {
      await openItemModal(tester);
      final label = '${de.diceChallengeAbbr}:';

      await tester.enterText(field(label), 'x');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidNonNegativeNumberShort), findsWidgets);
      expect(button(tester, de.save).onPressed, isNull);

      await tester.enterText(field(label), '12');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidNonNegativeNumberShort), findsNothing);
      expect(button(tester, de.save).onPressed, isNotNull);
    });
  });

  group('recipe amounts', () {
    testWidgets('text or 0 shows an error and blocks saving', (tester) async {
      await useTabletSize(tester);
      await tester.pumpWidget(
        harness(
          home: (_) => openButton(
            (context) => showCreateOrEditCraftingRecipeModal(
              context,
              CraftingRecipe(
                recipeUuid: 'recipe-1',
                ingredients: [
                  CraftingRecipeIngredientPair(
                    itemUuid: '8abe00a8-fa94-4e5d-9c99-2a68b9de60e7',
                    amountOfUsedItem: 2,
                  ),
                ],
                requiredItemIds: [],
                createdItem: CraftingRecipeIngredientPair(
                  itemUuid: 'a7537746-260d-4aed-b182-26768a9c2d51',
                  amountOfUsedItem: 1,
                ),
              ),
              overrideNavigatorKey: navigatorKey,
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final amountField = field(de.amount);
      expect(
        tester.widget<TextField>(amountField).keyboardType,
        signedIntKeyboardType,
      );
      expect(button(tester, de.save).onPressed, isNotNull);

      await tester.enterText(amountField, 'zwei');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidPositiveNumberShort), findsWidgets);
      expect(button(tester, de.save).onPressed, isNull);

      await tester.enterText(amountField, '0');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidPositiveNumberShort), findsWidgets);
      expect(button(tester, de.save).onPressed, isNull);

      await tester.enterText(amountField, '3');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidPositiveNumberShort), findsNothing);
      expect(button(tester, de.save).onPressed, isNotNull);
    });
  });

  group('dice rolls when granting items', () {
    testWidgets('text shows an error, a negative roll does not', (
      tester,
    ) async {
      await useTabletSize(tester);
      final player = OpenPlayerConnection(
        userId: UserIdentifier(value: 'user-1'),
        playerCharacterId: PlayerCharacterIdentifier(value: 'character-1'),
        configuration: RpgCharacterConfiguration.getBaseConfiguration(null)
            .copyWith(characterName: 'Mira'),
        lastPing: null,
      );
      await tester.pumpWidget(
        harness(
          overrides: [
            connectionDetailsProvider.overrideWith((ref) {
              return ConnectionDetailsNotifier(
                initState: AsyncValue.data(
                  ConnectionDetails.defaultValue().copyWith(
                    isDm: true,
                    connectedPlayers: [player],
                  ),
                ),
                ref: ref,
                runningInTests: true,
              );
            }),
          ],
          home: (_) => const DmScreenGrantItems(),
        ),
      );
      await tester.pumpAndSettle();

      final rollField = find.widgetWithText(TextField, de.diceRoll);
      expect(
        tester.widget<TextField>(rollField).keyboardType,
        signedIntKeyboardType,
      );

      await tester.enterText(rollField, 'hoch');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidWholeNumberShort), findsOneWidget);

      await tester.enterText(rollField, '-4');
      await tester.pumpAndSettle();
      expect(find.text(de.invalidWholeNumberShort), findsNothing);
    });
  });
}
