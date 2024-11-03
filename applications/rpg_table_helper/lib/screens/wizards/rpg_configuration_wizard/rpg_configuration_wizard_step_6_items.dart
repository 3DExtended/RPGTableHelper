import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/components/newdesign/custom_item_card.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_6_create_or_edit_item_modal_new_design.dart';
import 'package:uuid/v7.dart';

class RpgConfigurationWizardStep6Items extends WizardStepBase {
  const RpgConfigurationWizardStep6Items({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep6Items> createState() =>
      _RpgConfigurationWizardStep6ItemsState();
}

class _RpgConfigurationWizardStep6ItemsState
    extends ConsumerState<RpgConfigurationWizardStep6Items> {
  bool hasDataLoaded = false;
  bool isFormValid = false;

  String? selectedItemCategoryId;

  List<RpgItem> _items = [];
  List<ItemCategory> _allItemCategories = [];

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
          _items = data.allItems;
          _allItemCategories = data.itemCategories;
        });
        _updateStateForFormValidation();
      }
    });

    // TODO where do I show this?
    var stepHelperText = '''

Nun ist es Zeit, die Items des RPGs zu hinterlegen. Egal ob Heiltränke, Waffen, Questitems oder Zutaten für Gifte, hier kannst du alles anlegen was in die Taschen deiner Player wandern könnte.

Außerdem kannst du hier auch hinterlegen, welche Wirkungen ein Trank hat.

Tipp: Versuche die Wirkungen, Schäden oder ähnliches am Anfang einer jeden Beschreibung zu stellen, damit deine Spieler die wichtigsten Infos auf den ersten Blick sehen können!'''; // TODO localize

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...[
                        ItemCategory(
                          colorCode: null,
                          iconName: null,
                          name: "Alles",
                          subCategories: [],
                          uuid: "",
                          hideInInventoryFilters: false,
                        ),
                        ..._allItemCategories.sortBy((e) => e.name),
                      ].map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: CustomButtonNewdesign(
                            variant: (selectedItemCategoryId == e.uuid ||
                                    (e.uuid == "" &&
                                        selectedItemCategoryId == null))
                                ? CustomButtonNewdesignVariant.DarkButton
                                : CustomButtonNewdesignVariant.Default,
                            onPressed: () {
                              setState(() {
                                selectedItemCategoryId =
                                    e.uuid == "" ? null : e.uuid;
                              });
                            },
                            label: e.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 50,
              ),
              CustomButtonNewdesign(
                onPressed: () async {
                  // open create modal with new item
                  await showCreateOrEditItemModalNewDesign(
                      context,
                      RpgItem(
                        imageDescription: null,
                        imageUrlWithoutBasePath: null,
                        baseCurrencyPrice: 0,
                        categoryId: "",
                        description: "",
                        name: "",
                        placeOfFindings: [],
                        patchSize: null,
                        uuid: const UuidV7().generate(),
                      )).then((returnValue) {
                    if (returnValue == null) {
                      return;
                    }

                    setState(() {
                      _items.add(returnValue);
                      saveChanges();
                    });
                  });
                },
                label: "+ Hinzufügen",
              )
            ],
          ),
        ),
        SizedBox(
          height: 0,
        ),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          var layoutWidth = constraints.maxWidth;
          const scalar = 1.0;

          const cardHeight = 423 * scalar;
          const cardWidth = 289 * scalar;

          const targetedCardHeight = cardHeight;
          const targetedCardWidth = cardWidth;
          const itemCardPadding = 13.0;

          var numberOfColumnsOnScreen = 1;
          var calculatedWidth = itemCardPadding + targetedCardWidth;

          while (calculatedWidth < layoutWidth) {
            calculatedWidth += itemCardPadding + targetedCardWidth;
            numberOfColumnsOnScreen++;
          }

          numberOfColumnsOnScreen--;

          // print(
          //     "I am missing: ${calculatedWidth - layoutWidth}px for a column more...");

          var itemsAsMapList = _items.asMap().entries.where((it) {
            var itemCategoryForItem =
                ItemCategory.parentCategoryForCategoryIdRecursive(
                    categories: _allItemCategories,
                    categoryId: it.value.categoryId);

            return selectedItemCategoryId == null ||
                it.value.categoryId == selectedItemCategoryId ||
                (itemCategoryForItem != null &&
                    itemCategoryForItem.uuid == selectedItemCategoryId);
          }).toList();

          if (itemsAsMapList.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Keine Items unter dieser Kategorie",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 24, color: darkTextColor),
                ),
              ],
            );
          }

          return ListView.builder(
            itemCount: ((itemsAsMapList.length ~/ numberOfColumnsOnScreen) *
                        numberOfColumnsOnScreen ==
                    itemsAsMapList.length)
                ? (itemsAsMapList.length ~/ numberOfColumnsOnScreen)
                : (itemsAsMapList.length ~/ numberOfColumnsOnScreen) + 1,
            itemExtent: targetedCardHeight + itemCardPadding,
            itemBuilder: (context, index) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(numberOfColumnsOnScreen, (subindex) {
                      var indexOfItemToRender =
                          index * numberOfColumnsOnScreen + subindex;
                      if (indexOfItemToRender >= itemsAsMapList.length) {
                        return [
                          Container(),
                        ];
                      }

                      var itemToRender = itemsAsMapList[indexOfItemToRender];
                      return [
                        CupertinoButton(
                          minSize: 0,
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            // open edit modal with clicked item
                            await showCreateOrEditItemModalNewDesign(
                                    context, itemToRender.value)
                                .then((returnValue) {
                              if (returnValue == null) {
                                return;
                              }

                              setState(() {
                                _items.removeAt(itemToRender.key);
                                _items.insert(itemToRender.key, returnValue);
                                saveChanges();
                              });
                            });
                          },
                          child: CustomItemCard(
                              scalarOverride: scalar,
                              imageUrl:
                                  itemToRender.value.imageUrlWithoutBasePath,
                              title: itemToRender.value.name,
                              description: itemToRender.value.description),
                        ),
                        if (numberOfColumnsOnScreen != subindex + 1)
                          SizedBox(
                            width: itemCardPadding,
                          ),
                      ];
                    }).expand((i) => i),
                  ]);
            },
          );
        }))
      ],
    );
  }

  // TODO see what we need from this...
  Padding getItemVisualisation(
      MapEntry<int, RpgItem> item, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: StyledBox(
        child: SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.value.name,
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
                          await showCreateOrEditItemModalNewDesign(
                              context,
                              item.value.copyWith(
                                uuid: const UuidV7().generate(),
                              )).then((returnValue) {
                            if (returnValue == null) {
                              return;
                            }

                            setState(() {
                              _items.add(returnValue);
                              saveChanges();
                            });
                          });
                        },
                        icon: const CustomFaIcon(icon: FontAwesomeIcons.clone),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Edit Button
                    Container(
                      height: 50,
                      width: 50,
                      clipBehavior: Clip.none,
                      child: CustomButton(
                        onPressed: () async {
                          // open edit modal with clicked item
                          await showCreateOrEditItemModalNewDesign(
                                  context, item.value)
                              .then((returnValue) {
                            if (returnValue == null) {
                              return;
                            }

                            setState(() {
                              _items.removeAt(item.key);
                              _items.insert(item.key, returnValue);
                              saveChanges();
                            });
                          });
                        },
                        icon: const CustomFaIcon(
                            icon: FontAwesomeIcons.penToSquare),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Remove button
                    Container(
                      height: 50,
                      width: 50,
                      clipBehavior: Clip.none,
                      child: CustomButton(
                        onPressed: () {
                          // remove this pair from list
                          // TODO check if assigned...
                          setState(() {
                            _items.removeAt(item.key);
                          });
                        },
                        icon:
                            const CustomFaIcon(icon: FontAwesomeIcons.trashCan),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LabeledRow(
                          label: "Kategorie:", // TODO localize
                          text: getItemCategoryPathName(
                            getItemCategoryById(item.value.categoryId),
                          ),
                        ),
                        if (item.value.placeOfFindings.isNotEmpty)
                          _LabeledRow(
                            label: "Fundort:", // TODO localize
                            // TODO append difficulty and patchSize
                            text: item.value.placeOfFindings.isNotEmpty
                                ? item.value.placeOfFindings
                                    .map((plid) =>
                                        formatRpgItemRarityToString(plid))
                                    .join(", ")
                                : "N/A",
                          ),
                        if (item.value.placeOfFindings.isNotEmpty)
                          _LabeledRow(
                            label: "Fundgröße:", // TODO localize
                            text: item.value.patchSize?.toString() ?? "N/A",
                          ),
                        _LabeledRow(
                          label: "Verkaufswert:", // TODO localize
                          text: getValueOfItem(item.value.baseCurrencyPrice),
                        ),
                        Text(
                          "Beschreibung:",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: MarkdownBody(
                            data: item.value.description,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatRpgItemRarityToString(RpgItemRarity plid) {
    var result = "";
    var placeOfFinding = getPlaceOfFinding(plid.placeOfFindingId);
    if (placeOfFinding == null) return result;

    result += placeOfFinding.name;

    // TODO decide if I want to show this...
    result += " (DC: ${plid.diceChallenge})";

    return result;
  }

  void saveChanges() {
    ref.read(rpgConfigurationProvider.notifier).updateItems(_items);
  }

  bool getIsFormValid() {
    return hasDataLoaded == true;
  }

  String getItemCategoryPathName(List<ItemCategory>? path) {
    if (path == null) return "N/A";

    return path.map((c) => c.name).join(" > ");
  }

  PlaceOfFinding? getPlaceOfFinding(String placeOfFindingID) {
    var provider = ref.read(rpgConfigurationProvider);

    if (!provider.hasValue) return null;
    var places = provider.requireValue.placesOfFindings;

    var place = places.where((p) => p.uuid == placeOfFindingID).singleOrNull;

    return place;
  }

  List<ItemCategory>? getItemCategoryById(String? categoryId,
      {List<ItemCategory>? searchList}) {
    if (categoryId == null) return [];
    var searchField = searchList;

    if (searchField == null) {
      var provider = ref.read(rpgConfigurationProvider);

      if (!provider.hasValue) return null;
      searchField = provider.requireValue.itemCategories;
    }

    var category = searchField.where((c) => c.uuid == categoryId).singleOrNull;

    if (category == null) {
      // search sub categories
      for (var i = 0; i < searchField.length; i++) {
        var subSearchResult = getItemCategoryById(categoryId,
            searchList: searchField[i].subCategories);
        if (subSearchResult != null) {
          return [searchField[i], ...subSearchResult];
        }
      }
    }

    return category == null ? null : [category];
  }

  String getValueOfItem(int baseCurrencyPrice) {
    var provider = ref.read(rpgConfigurationProvider);
    if (!provider.hasValue) return "N/A";
    var currencySetting =
        provider.requireValue.currencyDefinition.currencyTypes;

    var currencySettingReversed = currencySetting.reversed.toList();

    var moneyPricesAsMultipleOfBasePrice = [1];
    for (var i = 1; i < currencySetting.length; i++) {
      moneyPricesAsMultipleOfBasePrice.add(
          currencySetting[i].multipleOfPreviousValue! *
              moneyPricesAsMultipleOfBasePrice.last);
    }

    var reversedmoneyPricesAsMultipleOfBasePrice =
        moneyPricesAsMultipleOfBasePrice.reversed.toList();

    var valueLeft = baseCurrencyPrice;
    var result = "";

    for (var i = 0; i < reversedmoneyPricesAsMultipleOfBasePrice.length; i++) {
      var divisionWithLeftOver =
          valueLeft ~/ reversedmoneyPricesAsMultipleOfBasePrice[i];
      if (divisionWithLeftOver > 0) {
        if (result.isNotEmpty) {
          result += " ";
        }

        // find name of currency symbol
        result += "$divisionWithLeftOver ${currencySettingReversed[i].name}";

        valueLeft -=
            divisionWithLeftOver * reversedmoneyPricesAsMultipleOfBasePrice[i];
      }
    }

    return result;
  }
}

class _LabeledRow extends StatelessWidget {
  const _LabeledRow({
    required this.label,
    required this.text,
  });

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
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
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
