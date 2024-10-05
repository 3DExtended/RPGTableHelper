import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_create_or_edit_item_recipe_modal.dart';
import 'package:uuid/v7.dart';

class RpgConfigurationWizardStep7CraftingRecipes extends WizardStepBase {
  const RpgConfigurationWizardStep7CraftingRecipes({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
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
      wizardTitle: "RPG Configuration", // TODO localize
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepTitle: "Rezepte", // TODO Localize,
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
      contentWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Builder(builder: (context) {
          var recipesAsMapList = _recipes.asMap().entries.toList();
          return ListView.builder(
            itemCount: recipesAsMapList.length,
            prototypeItem: recipesAsMapList.isEmpty
                ? null
                : getRecipeVisualisation(recipesAsMapList[0], context),
            itemBuilder: (context, index) {
              var recipe = recipesAsMapList[index];
              return getRecipeVisualisation(recipe, context);
            },
          );
        }),
      ),
      contentChildren: const [
        //  ..._recipes.asMap().entries.map(
        //        (item) => getRecipeVisualisation(item, context),
        //      ),
      ],
      centerNavBarWidget: CustomButton(
        onPressed: () async {
          // open create modal with new item
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
        icon: Theme(
            data: ThemeData(
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 16,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            child: Container(
                width: 24,
                height: 24,
                alignment: AlignmentDirectional.center,
                child: const FaIcon(FontAwesomeIcons.plus))),
      ),
    );
  }

  Padding getRecipeVisualisation(
      MapEntry<int, CraftingRecipe> item, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: StyledBox(
        child: SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${getItemForId(item.value.createdItem.itemUuid)?.name ?? "N/A"} (${item.value.createdItem.amountOfUsedItem}x)",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                      ),
                    ),

                    // Duplicate Button
                    Container(
                      height: 50,
                      width: 50,
                      clipBehavior: Clip.none,
                      child: CustomButton(
                        onPressed: () async {
                          // open edit modal with clicked item
                          await showCreateOrEditCraftingRecipeModal(
                              context,
                              item.value.copyWith(
                                recipeUuid: const UuidV7().generate(),
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
                        icon: const CustomFaIcon(icon: FontAwesomeIcons.clone),
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    // Edit Button
                    Container(
                      height: 50,
                      width: 50,
                      clipBehavior: Clip.none,
                      child: CustomButton(
                        onPressed: () async {
                          // open edit modal with clicked item
                          await showCreateOrEditCraftingRecipeModal(
                                  context, item.value)
                              .then((returnValue) {
                            if (returnValue == null) {
                              return;
                            }
                            setState(() {
                              _recipes.removeAt(item.key);
                              _recipes.insert(item.key, returnValue);
                              saveChanges();
                            });
                          });
                        },
                        icon: const CustomFaIcon(
                            icon: FontAwesomeIcons.penToSquare),
                      ),
                    ),

                    // Remove button
                    Container(
                      height: 50,
                      width: 70,
                      clipBehavior: Clip.none,
                      child: CustomButton(
                        onPressed: () {
                          // remove this pair from list
                          setState(() {
                            _recipes.removeAt(item.key);
                          });
                        },
                        icon:
                            const CustomFaIcon(icon: FontAwesomeIcons.trashCan),
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _LabeledRow(
                        labelWidthFlex: 2,
                        valueWidthFlex: 5,
                        label: "Voraussetzungen:", // TODO localize
                        text: item.value.requiredItemIds
                            .map((id) => getItemForId(id))
                            .where((e) => e != null)
                            .map((e) => " - ${e!.name}")
                            .join("\n"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _LabeledRow(
                        labelWidthFlex: 2,
                        valueWidthFlex: 5,
                        label: "Zutaten:", // TODO localize
                        text: item.value.ingredients
                            .map((pair) => (pair, getItemForId(pair.itemUuid)))
                            .where((e) => e.$2 != null)
                            .map((e) =>
                                " - ${e.$1.amountOfUsedItem}x ${e.$2!.name}")
                            .join("\n"),
                      ),
                      //
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 20.0),
                      //   child: MarkdownBody(
                      //     data: item.value.description,
                      //   ),
                      // )
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
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

class _LabeledRow extends StatelessWidget {
  const _LabeledRow({
    required this.label,
    required this.text,
    required this.labelWidthFlex,
    required this.valueWidthFlex,
  });
  final int? labelWidthFlex;
  final int? valueWidthFlex;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConditionalWidgetWrapper(
              condition: labelWidthFlex != null,
              wrapper: (BuildContext context, Widget child) =>
                  Expanded(flex: labelWidthFlex!, child: child),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: valueWidthFlex ?? 1,
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
      ],
    );
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
  final Expanded Function(BuildContext context, Widget child) wrapper;
  final Text child;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: condition ? wrapper(context, child) : child,
    );
  }
}
