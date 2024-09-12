import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_6_create_or_edit_item_modal.dart';
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

  List<RpgItem> _items = [];

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
        });
        _updateStateForFormValidation();
      }
    });

    var stepHelperText = '''

Nun ist es Zeit, die Items des RPGs zu hinterlegen. Egal ob Heiltränke, Waffen, Questitems oder Zutaten für Gifte, hier kannst du alles anlegen was in die Taschen deiner Player wandern könnte. 

Außerdem kannst du hier auch hinterlegen, welche Wirkungen ein Trank hat. 

Tipp: Versuche die Wirkungen, Schäden oder ähnliches am Anfang einer jeden Beschreibung zu stellen, damit deine Spieler die wichtigsten Infos auf den ersten Blick sehen können!'''; // TODO localize

    return TwoPartWizardStepBody(
      wizardTitle: "RPG Configuration", // TODO localize
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepTitle: "Items", // TODO Localize,
      stepHelperText: stepHelperText,
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
      contentChildren: [
        ..._items.asMap().entries.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: StyledBox(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 20.0, bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.value.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                              ),
                            ),

                            // Edit Button
                            Container(
                              height: 50,
                              width: 50,
                              clipBehavior: Clip.none,
                              child: CustomButton(
                                onPressed: () async {
                                  // open edit modal with clicked item
                                  await showCreateOrEditItemModal(
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

                            // Remove button
                            Container(
                              height: 50,
                              width: 70,
                              clipBehavior: Clip.none,
                              child: CustomButton(
                                onPressed: () {
                                  // remove this pair from list
                                  // TODO check if assigned...
                                  setState(() {
                                    _items.removeAt(item.key);
                                  });
                                },
                                icon: const CustomFaIcon(
                                    icon: FontAwesomeIcons.trashCan),
                              ),
                            ),
                          ],
                        ),
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
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        CustomButton(
          onPressed: () async {
            // open create modal with new item
            await showCreateOrEditItemModal(
                context,
                RpgItem(
                  baseCurrencyPrice: 0,
                  categoryId: null,
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
        const SizedBox(
          height: 20,
        ),
      ],
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
