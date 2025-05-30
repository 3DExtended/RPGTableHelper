import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_recipe_card.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_create_or_edit_item_recipe_modal.dart';
import 'package:uuid/v7.dart';

class RpgConfigurationWizardStep7CraftingRecipes extends WizardStepBase {
  const RpgConfigurationWizardStep7CraftingRecipes({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
    required super.setWizardTitle,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep7CraftingRecipes> createState() =>
      _RpgConfigurationWizardStep7CraftingRecipesState();
}

class _RpgConfigurationWizardStep7CraftingRecipesState
    extends ConsumerState<RpgConfigurationWizardStep7CraftingRecipes> {
  bool hasDataLoaded = false;
  bool isFormValid = false;

  List<CraftingRecipe> _recipes = [];
  List<RpgItem> _allItems = [];

  void _updateStateForFormValidation() {
    var newIsFormValid = getIsFormValid();

    if (newIsFormValid != isFormValid) {
      setState(() {
        isFormValid = newIsFormValid;
      });
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      widget.setWizardTitle("Rezepte");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        setState(() {
          hasDataLoaded = true;
          _recipes = data.craftingRecipes;
          _allItems = data.allItems;
        });
        _updateStateForFormValidation();
      }
    });

    var stepHelperText = '''

Nachdem du nun alle Items hinzugefügt hast, kannst du deinen Spieler Rezepte hinzufügen, damit sie selber bspw. Heiltränke craften können.

Für manche Rezepte ist es natürlich Voraussetzung, dass du ein Tool (wie ein Kräuterkunde-Set) hast.
Auch dies kannst du in deinen Rezepten hinterlegen und die Spieler benötigen dann die entsprechenden Tools um die Rezepte nutzen zu können.
'''; // TODO localize

    return TwoPartWizardStepBody(
        isLandscapeMode: MediaQuery.of(context).size.width >
            MediaQuery.of(context).size.height,
        stepHelperText: stepHelperText,
        sideBarFlex: 1,
        contentFlex: 2,
        onNextBtnPressed: !isFormValid
            ? null
            : () {
                saveChanges();
                widget.onNextBtnPressed();
              },
        onPreviousBtnPressed: () {
          // TODO as we dont validate the state of this form we are not saving changes. hence we should inform the user that their changes are revoked.
          widget.onPreviousBtnPressed();
        },
        contentWidget: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 10),
              child: Row(
                children: [
                  Spacer(),
                  CustomButton(
                    variant: CustomButtonVariant.AccentButton,
                    onPressed: () async {
                      // add new recipes
                      await showCreateOrEditCraftingRecipeModal(
                          context,
                          CraftingRecipe(
                            recipeUuid: const UuidV7().generate(),
                            ingredients: [],
                            requiredItemIds: [],
                            createdItem: CraftingRecipeIngredientPair(
                              itemUuid: "",
                              amountOfUsedItem: 1,
                            ),
                          )).then((returnValue) {
                        if (returnValue == null) {
                          return;
                        }

                        setState(() {
                          _recipes.add(returnValue);
                          saveChanges();
                        });
                      });
                    },
                    label: "+ Hinzufügen",
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: LayoutBuilder(builder: (context, constraints) {
                  var layoutWidth = constraints.maxWidth;
                  const scalar = 1.0;

                  const cardHeight = 423 * scalar;
                  const cardWidth = 289 * scalar;

                  const targetedCardHeight = cardHeight;
                  const targetedCardWidth = cardWidth;
                  const itemCardPadding = 9.0;

                  var numberOfColumnsOnScreen = 1;
                  var calculatedWidth = itemCardPadding + targetedCardWidth;

                  while (calculatedWidth < layoutWidth) {
                    calculatedWidth += itemCardPadding + targetedCardWidth;
                    numberOfColumnsOnScreen++;
                  }

                  numberOfColumnsOnScreen--;

                  var recipesAsMapList = _recipes.asMap().entries.toList();
                  return ListView.builder(
                    itemCount: ((recipesAsMapList.length ~/
                                    numberOfColumnsOnScreen) *
                                numberOfColumnsOnScreen ==
                            recipesAsMapList.length)
                        ? (recipesAsMapList.length ~/ numberOfColumnsOnScreen)
                        : (recipesAsMapList.length ~/ numberOfColumnsOnScreen) +
                            1,
                    itemExtent: targetedCardHeight + itemCardPadding,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ...List.generate(numberOfColumnsOnScreen, (subindex) {
                            var indexOfRecipeToRender =
                                index * numberOfColumnsOnScreen + subindex;
                            if (indexOfRecipeToRender >=
                                recipesAsMapList.length) {
                              return List<Widget>.empty();
                            }

                            var recipeToRender =
                                recipesAsMapList[indexOfRecipeToRender];

                            var createdItem = getItemForId(
                                recipeToRender.value.createdItem.itemUuid);
                            if (createdItem == null) {
                              return List<Widget>.empty();
                            }

                            List<CustomRecipeCardItemPair> requirements =
                                recipeToRender.value.requiredItemIds
                                    .map((ingred) {
                              var ingredItem = getItemForId(ingred);
                              return CustomRecipeCardItemPair(
                                  amount: 1, itemName: ingredItem?.name ?? "");
                            }).toList();

                            List<CustomRecipeCardItemPair> ingredients =
                                recipeToRender.value.ingredients.map((ingred) {
                              var ingredItem = getItemForId(ingred.itemUuid);
                              return CustomRecipeCardItemPair(
                                  amount: ingred.amountOfUsedItem,
                                  itemName: ingredItem?.name ?? "");
                            }).toList();

                            return [
                              CupertinoContextMenu(
                                actions: [
                                  CupertinoContextMenuAction(
                                    isDestructiveAction: false,
                                    isDefaultAction: true,
                                    child: Text('Details öffnen'),
                                    onPressed: () async {
                                      Navigator.pop(context); // Close the popup

                                      // open edit modal with clicked item
                                      await showCreateOrEditCraftingRecipeModal(
                                              context, recipeToRender.value)
                                          .then((returnValue) {
                                        if (returnValue == null) {
                                          return;
                                        }

                                        setState(() {
                                          _recipes[recipeToRender.key] =
                                              returnValue;
                                          _recipes = [..._recipes];
                                          saveChanges();
                                        });
                                      });
                                    },
                                  ),
                                  CupertinoContextMenuAction(
                                    isDestructiveAction: false,
                                    isDefaultAction: false,
                                    child: Text('Duplizieren und öffnen'),
                                    onPressed: () async {
                                      Navigator.pop(context); // Close the popup

                                      // open edit modal with clicked item
                                      await showCreateOrEditCraftingRecipeModal(
                                              context,
                                              recipeToRender.value.copyWith(
                                                  recipeUuid:
                                                      UuidV7().generate()))
                                          .then((returnValue) {
                                        if (returnValue == null) {
                                          return;
                                        }

                                        setState(() {
                                          _recipes.insert(
                                              recipeToRender.key + 1,
                                              returnValue);
                                          _recipes = [..._recipes];
                                          saveChanges();
                                        });
                                      });
                                    },
                                  ),
                                  CupertinoContextMenuAction(
                                    isDestructiveAction: true,
                                    child: Text('Unwiderruflich Löschen'),
                                    onPressed: () {
                                      Navigator.pop(context); // Close the popup
                                      setState(() {
                                        _recipes.removeAt(recipeToRender.key);
                                        _recipes = [..._recipes];
                                        saveChanges();
                                      });
                                    },
                                  ),
                                ],
                                child: CupertinoButton(
                                  minSize: 0,
                                  padding: EdgeInsets.zero,
                                  onPressed: () async {
                                    // open edit modal with clicked item
                                    await showCreateOrEditCraftingRecipeModal(
                                            context, recipeToRender.value)
                                        .then((returnValue) {
                                      if (returnValue == null) {
                                        return;
                                      }

                                      setState(() {
                                        _recipes[recipeToRender.key] =
                                            returnValue;
                                        _recipes = [..._recipes];
                                        saveChanges();
                                      });
                                    });
                                  },
                                  child: CustomRecipeCard(
                                    imageUrl:
                                        createdItem.imageUrlWithoutBasePath,
                                    title: createdItem.name,
                                    requirements: requirements,
                                    ingedients: ingredients,
                                  ),
                                ),
                              ),
                              if (numberOfColumnsOnScreen != subindex + 1)
                                SizedBox(
                                  width: itemCardPadding,
                                ),
                            ];
                          }).expand((i) => i),
                        ],
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
        contentChildren: const []);
  }

  void saveChanges() {
    ref.read(rpgConfigurationProvider.notifier).updateRecipes(_recipes);
  }

  bool getIsFormValid() {
    return hasDataLoaded == true;
  }

  String getItemCategoryPathName(List<ItemCategory>? path) {
    if (path == null) return "N/A";

    return path.map((c) => c.name).join(" > ");
  }

  RpgItem? getItemForId(String itemId) {
    return _allItems.where((i) => i.uuid == itemId).firstOrNull;
  }
}

class ConditionalWidgetWrapper extends StatelessWidget {
  const ConditionalWidgetWrapper({
    super.key,
    required this.condition,
    required this.wrapper,
    required this.child,
  });

  final bool condition;
  final Widget Function(BuildContext context, Widget child) wrapper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: condition ? wrapper(context, child) : child,
    );
  }
}
