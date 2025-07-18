import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/helpers/color_extension.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/helpers/modals/show_select_icon_with_color_modal.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:uuid/v7.dart';

part 'rpg_configuration_wizard_step_5_item_categories.g.dart';

@CopyWith()
class _ItemCategoryEdit {
  final String uuid;
  final String? iconName;
  final Color? iconColor;
  final TextEditingController nameController;
  final List<_ItemCategoryEdit> subCategories;
  final bool hideInInventoryFilters;

  _ItemCategoryEdit({
    required this.uuid,
    required this.nameController,
    required this.iconName,
    required this.iconColor,
    required this.subCategories,
    this.hideInInventoryFilters = false,
  });

  ItemCategory toItemCategory() {
    return ItemCategory(
      colorCode: iconColor?.toHex(),
      iconName: iconName,
      uuid: uuid,
      name: nameController.text,
      subCategories: subCategories.isNotEmpty
          ? subCategories.map((e) => e.toItemCategory()).toList()
          : [],
      hideInInventoryFilters: hideInInventoryFilters,
    );
  }

  static _ItemCategoryEdit fromItemCategory(
      ItemCategory cat, void Function() listener) {
    var editController = TextEditingController(text: cat.name);
    editController.addListener(listener);

    return _ItemCategoryEdit(
      nameController: editController,
      uuid: cat.uuid,
      iconName: cat.iconName,
      iconColor: cat.colorCode?.parseHexColorRepresentation(),
      hideInInventoryFilters: cat.hideInInventoryFilters,
      subCategories: cat.subCategories
          .map((e) => _ItemCategoryEdit.fromItemCategory(e, listener))
          .toList(),
    );
  }
}

class RpgConfigurationWizardStep5ItemCategories extends WizardStepBase {
  const RpgConfigurationWizardStep5ItemCategories({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
    required super.setWizardTitle,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep5ItemCategories> createState() =>
      _RpgConfigurationWizardStep5ItemCategories();
}

class _RpgConfigurationWizardStep5ItemCategories
    extends ConsumerState<RpgConfigurationWizardStep5ItemCategories> {
  bool hasDataLoaded = false;
  bool isFormValid = false;

  List<_ItemCategoryEdit> categories = [];

  void _updateStateForFormValidation() {
    var newIsFormValid = getIsFormValid();

    setState(() {
      if (newIsFormValid != isFormValid) {
        isFormValid = newIsFormValid;
      }
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      widget.setWizardTitle("Item Kategorien");
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  RpgConfigurationModel? rpgConfig;

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        setState(() {
          hasDataLoaded = true;
          rpgConfig = data;

          var loadedItemCategories = data.itemCategories;
          if (loadedItemCategories.isNotEmpty) {
            for (var i = 0; i < loadedItemCategories.length; i++) {
              addNewItemCategory(_ItemCategoryEdit.fromItemCategory(
                  loadedItemCategories[i], _updateStateForFormValidation));
            }
          }
        });
        _updateStateForFormValidation();
      }
    });

    var stepHelperText = '''

Damit die Spieler ihre Items filtern können, wollen wir die Items in bestimmte Kategorien einsortieren. Hierzu haben wir dir eine Reihe von Kategorien und Subkategorien vorbereitet.

Nimm gerne Anpassungen vor, wenn diese Kategorien nicht zu eurem RPG passen!

Hinweis: Wir legen automatisch eine Kategorie “Sonstiges” an, in der alle Items auflaufen, die keiner anderen Kategorie zugewiesen wurden.
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
      contentChildren: [
        const SizedBox(
          height: 20,
        ),
        ...categories.asMap().entries.map((e) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                    child: CustomButton(
                      isSubbutton: true,
                      variant: CustomButtonVariant.Default,
                      onPressed: () async {
                        // open icon and color selector
                        await showSelectIconWithColorModal(context,
                                alreadySelectedIcoName: e.value.iconName,
                                alreadySelectedIconColor: e.value.iconColor,
                                titleSuffix:
                                    " (für Kategorie ${e.value.nameController.text})")
                            .then((value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            categories[e.key] = categories[e.key].copyWith(
                              iconName: value.$1,
                              iconColor: value.$2,
                            );
                          });
                        });
                      },
                      icon: Padding(
                        padding: const EdgeInsets.all(4.5),
                        child: getIconForIdentifier(
                          name: e.value.iconName ?? "leaf",
                          color:
                              CustomThemeProvider.of(context).theme.darkColor,
                          size: 32,
                        ).$2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      keyboardType: TextInputType.text,
                      labelText: "Name der Kategorie:", // TODO localize
                      textEditingController: e.value.nameController,
                      placeholderText: rpgConfig == null
                          ? null
                          : "In dieser Kategorie sind ${getNumberOfToCategoryAssignedItems(rpgConfig!, e.value.uuid)} Items.",
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 40,
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: CustomButton(
                      variant: CustomButtonVariant.FlatButton,
                      isSubbutton: true,
                      onPressed: () {
                        // remove this pair from list
                        // TODO check if assigned...
                        // TODO handle sub categories
                        setState(() {
                          categories.removeAt(e.key);
                        });
                      },
                      icon: CustomFaIcon(
                        icon: FontAwesomeIcons.trashCan,
                        color: CustomThemeProvider.of(context).theme.darkColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              ...(e.value.subCategories).asMap().entries.map(
                    (subCat) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              keyboardType: TextInputType.text,
                              labelText:
                                  "Name der Sub-Kategorie:", // TODO localize
                              textEditingController:
                                  subCat.value.nameController,
                              placeholderText: rpgConfig == null
                                  ? null
                                  : "In dieser Kategorie sind ${getNumberOfToCategoryAssignedItems(rpgConfig!, subCat.value.uuid)} Items.",
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 40,
                            clipBehavior: Clip.none,
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: CustomButton(
                              variant: CustomButtonVariant.FlatButton,
                              isSubbutton: true,
                              onPressed: () {
                                // remove this pair from list
                                // TODO check if assigned...
                                // TODO handle sub categories
                                setState(() {
                                  categories[e.key]
                                      .subCategories
                                      .removeAt(subCat.key);
                                });
                              },
                              icon: CustomFaIcon(
                                icon: FontAwesomeIcons.trashCan,
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkColor,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: CustomButton(
                  isSubbutton: true,
                  onPressed: () {
                    setState(() {
                      categories[e.key].subCategories.add(
                          _ItemCategoryEdit.fromItemCategory(
                              ItemCategory(
                                  colorCode: "#ffff00ff",
                                  iconName: "spellbook-svgrepo-com",
                                  uuid: const UuidV7().generate(),
                                  name: "Neu",
                                  subCategories: []),
                              _updateStateForFormValidation));
                    });
                  },
                  label: "Neue Sub-Kategorie",
                  icon: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Container(
                        width: 16,
                        height: 16,
                        alignment: AlignmentDirectional.center,
                        child: CustomFaIcon(
                          icon: FontAwesomeIcons.plus,
                          color:
                              CustomThemeProvider.of(context).theme.darkColor,
                        )),
                  ),
                ),
              ),
              // const SizedBox(
              //   height: 20,
              // ),
              // const HorizontalLine(),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        }),
        CustomButton(
          variant: CustomButtonVariant.Default,
          onPressed: () {
            setState(() {
              addNewItemCategory(_ItemCategoryEdit.fromItemCategory(
                  ItemCategory(
                      colorCode: "#ffff00ff",
                      iconName: "spellbook-svgrepo-com",
                      uuid: const UuidV7().generate(),
                      name: "Neu",
                      subCategories: []),
                  _updateStateForFormValidation));
            });
          },
          icon: Container(
              width: 24,
              height: 24,
              alignment: AlignmentDirectional.center,
              child: CustomFaIcon(
                icon: FontAwesomeIcons.plus,
                size: 16,
                color: CustomThemeProvider.of(context).theme.darkColor,
              )),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void addNewItemCategory(_ItemCategoryEdit category) {
    categories.add(category);
  }

  void saveChanges() {
    List<ItemCategory> newItemCategories = [];

    for (var pair in categories) {
      newItemCategories.add(pair.toItemCategory());
    }

    ref
        .read(rpgConfigurationProvider.notifier)
        .updateItemCategories(newItemCategories);
  }

  List<_ItemCategoryEdit> flattenitemCategories() {
    List<_ItemCategoryEdit> flattenCategorieList = [];
    var queue = categories.toList();

    while (queue.isNotEmpty) {
      var pop = queue.removeLast();
      flattenCategorieList.add(pop);

      if (pop.subCategories.isNotEmpty) {
        queue.addAll(pop.subCategories);
      }
    }

    return flattenCategorieList;
  }

  bool getIsFormValid() {
    const currencyNameMinLenght = 3;
    if (hasDataLoaded != true) {
      return false;
    }

    var flattenedList = flattenitemCategories();

    for (var editPair in flattenedList) {
      if (editPair.nameController.text.isEmpty ||
          editPair.nameController.text.length < currencyNameMinLenght) {
        return false;
      }
    }

    return true;
  }

  int getNumberOfToCategoryAssignedItems(
      RpgConfigurationModel rpgConfigurationModel, String uuid) {
    return rpgConfigurationModel.allItems
        .where((it) => it.categoryId == uuid)
        .length;
  }
}
