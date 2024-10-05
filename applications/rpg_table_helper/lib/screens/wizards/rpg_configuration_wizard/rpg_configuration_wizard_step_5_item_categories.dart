import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:uuid/v7.dart';

class _ItemCategoryEdit {
  final String uuid;
  final TextEditingController nameController;
  final List<_ItemCategoryEdit> subCategories;
  final bool hideInInventoryFilters;

  _ItemCategoryEdit({
    required this.uuid,
    required this.nameController,
    required this.subCategories,
    this.hideInInventoryFilters = false,
  });

  ItemCategory toItemCategory() {
    return ItemCategory(
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        setState(() {
          hasDataLoaded = true;

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
      wizardTitle: "RPG Configuration", // TODO localize
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepTitle: "Item Kategorien", // TODO Localize,
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
        const SizedBox(
          height: 20,
        ),
        ...categories.asMap().entries.map((e) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      keyboardType: TextInputType.text,
                      labelText: "Name der Kategorie:", // TODO localize
                      textEditingController: e.value.nameController,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 70,
                    clipBehavior: Clip.none,
                    child: CustomButton(
                      onPressed: () {
                        // remove this pair from list
                        // TODO check if assigned...
                        // TODO handle sub categories
                        setState(() {
                          categories.removeAt(e.key);
                        });
                      },
                      icon: const CustomFaIcon(icon: FontAwesomeIcons.trashCan),
                    ),
                  ),
                ],
              ),

              ...(e.value.subCategories).asMap().entries.map(
                    (subCat) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              keyboardType: TextInputType.text,
                              labelText:
                                  "Name der Sub-Kategorie:", // TODO localize
                              textEditingController:
                                  subCat.value.nameController,
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 70,
                            clipBehavior: Clip.none,
                            child: CustomButton(
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
                                      child: const FaIcon(
                                          FontAwesomeIcons.trashCan))),
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
                                  uuid: const UuidV7().generate(),
                                  name: "Neu",
                                  subCategories: []),
                              _updateStateForFormValidation));
                    });
                  },
                  label: "Neue Sub-Kategorie",
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Container(
                            width: 16,
                            height: 16,
                            alignment: AlignmentDirectional.center,
                            child: const FaIcon(FontAwesomeIcons.plus)),
                      )),
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
          onPressed: () {
            setState(() {
              addNewItemCategory(_ItemCategoryEdit.fromItemCategory(
                  ItemCategory(
                      uuid: const UuidV7().generate(),
                      name: "Neu",
                      subCategories: []),
                  _updateStateForFormValidation));
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
}
