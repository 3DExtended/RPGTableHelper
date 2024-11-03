import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/components/newdesign/custom_item_card.dart';
import 'package:rpg_table_helper/components/newdesign/navbar_new_design.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/image_generation_service.dart';
import 'package:shadow_widget/shadow_widget.dart';

import '../../../helpers/modal_helpers.dart';

Future<RpgItem?> showCreateOrEditItemModalNewDesign(
    BuildContext context, RpgItem itemToEdit,
    {GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<RpgItem>(
    isDismissible: false,
    expand: true,
    closeProgressThreshold: -50000,
    enableDrag: false,
    backgroundColor: const Color.fromARGB(192, 21, 21, 21),
    context: context,
    // barrierColor: const Color.fromARGB(20, 201, 201, 201),
    builder: (context) => CreateOrEditItemModalContent(itemToEdit: itemToEdit),
    overrideNavigatorKey: overrideNavigatorKey,
  );
}

class CreateOrEditItemModalContent extends ConsumerStatefulWidget {
  final RpgItem itemToEdit;

  const CreateOrEditItemModalContent({super.key, required this.itemToEdit});

  @override
  ConsumerState<CreateOrEditItemModalContent> createState() =>
      _CreateOrEditItemModalContentState();
}

class _CreateOrEditItemModalContentState
    extends ConsumerState<CreateOrEditItemModalContent> {
  TextEditingController nameController = TextEditingController();
  TextEditingController patchSizeTextController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imageDescriptionController = TextEditingController();
  List<TextEditingController> currencyControllers = [];

  String? selectedItemCategoryId;

  bool hasDataLoaded = false;
  bool isSaveButtonDisabled = true;
  bool isLoadingNewImage = false;

  List<String> _urlsOfGeneratedImages = [];
  int? _selectedGeneratedImage;

  List<ItemCategory> _allItemCategories = [];
  CurrencyDefinition? _currencyDefinition;
  List<PlaceOfFinding> _allPlacesOfFindings = [];

  List<(String? id, TextEditingController)> _placesOfFinding = [];

  bool getSaveButtonValid() {
    if (nameController.text.isEmpty || nameController.text.length < 3) {
      return false;
    }
    if (descriptionController.text.isEmpty ||
        descriptionController.text.length < 3) {
      return false;
    }

    if (currencyControllers.every((c) => c.text.isEmpty)) {
      return false;
    }

    if (selectedItemCategoryId == null) {
      return false;
    }

    return true;
  }

  void _updateStateForFormValidation() {
    var newIsSaveButtonValid = getSaveButtonValid();

    setState(() {
      isSaveButtonDisabled = !newIsSaveButtonValid;
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      nameController.addListener(_updateStateForFormValidation);
      descriptionController.addListener(_updateStateForFormValidation);
      imageDescriptionController.addListener(_updateStateForFormValidation);
      patchSizeTextController.addListener(_updateStateForFormValidation);

      setState(() {
        if (widget.itemToEdit.imageUrlWithoutBasePath != null &&
            widget.itemToEdit.imageUrlWithoutBasePath!.isNotEmpty) {
          _selectedGeneratedImage = 0;
          _urlsOfGeneratedImages = [widget.itemToEdit.imageUrlWithoutBasePath!];
        }

        nameController.text = widget.itemToEdit.name;
        descriptionController.text = widget.itemToEdit.description;
        imageDescriptionController.text =
            widget.itemToEdit.imageDescription ?? widget.itemToEdit.description;
        selectedItemCategoryId = widget.itemToEdit.categoryId;
        patchSizeTextController.text =
            widget.itemToEdit.patchSize?.toString() ?? "1D4+1";

        _placesOfFinding = widget.itemToEdit.placeOfFindings
            .map((pair) => (
                  pair.placeOfFindingId,
                  TextEditingController(text: pair.diceChallenge.toString())
                ))
            .toList();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rpgConfigurationProvider).whenData((data) {
      if (!hasDataLoaded) {
        setState(() {
          hasDataLoaded = true;
          _allItemCategories = data.itemCategories;
          _allPlacesOfFindings = data.placesOfFindings;
          _currencyDefinition = data.currencyDefinition;

          if (widget.itemToEdit.baseCurrencyPrice != 0) {
            currencyControllers = CurrencyDefinition.valueOfItemForDefinition(
                    _currencyDefinition!, widget.itemToEdit.baseCurrencyPrice)
                .map((e) {
              var result = TextEditingController(text: e.toString());
              result.addListener(_updateStateForFormValidation);
              return result;
            }).toList();
          } else {
            // get price in currency values
            currencyControllers =
                List.generate(_currencyDefinition!.currencyTypes.length, (i) {
              var result = TextEditingController();
              result.addListener(_updateStateForFormValidation);
              return result;
            });
          }
        });
      }
    });

    var modalPadding = 80.0;
    if (MediaQuery.of(context).size.width < 800) {
      modalPadding = 20.0;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: true,
        bottom: true,
        right: false,
        left: false,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: 20, top: 20, left: modalPadding, right: modalPadding),
          child: Center(
            child: ShadowWidget(
              offset: Offset(-4, 4),
              blurRadius: 5,
              child: Container(
                color: bgColor,
                child: Column(
                  children: [
                    NavbarNewDesign(
                      backInsteadOfCloseIcon: false,
                      closeFunction: () {
                        navigatorKey.currentState!.pop(null);
                      },
                      menuOpen: null,
                      useTopSafePadding: false,
                      titleWidget: Text(
                        "Item bearbeiten", // TODO localize/ switch text between add and edit
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: textColor, fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: darkColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: SingleChildScrollView(
                                      child: getLeftModalColumn(context)),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: SingleChildScrollView(
                                    child: getRightModalColumn(context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column getLeftModalColumn(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                newDesign: true,
                keyboardType: TextInputType.text,
                labelText: "Name des Items:", // TODO localize
                textEditingController: nameController,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: CustomDropdownMenu(
                  newDesign: true,
                  selectedValueTemp: selectedItemCategoryId == ""
                      ? null
                      : selectedItemCategoryId,
                  setter: (newValue) {
                    setState(() {
                      selectedItemCategoryId = newValue;
                    });
                  },
                  label: 'Kategorie', // TODO localize
                  items: [
                    ...(ItemCategory.flattenCategoriesRecursive(
                            categories: _allItemCategories,
                            combineCategoryNames: true)
                        .sortBy((e) => e.name)),
                  ].map((category) {
                    return DropdownMenuItem<String?>(
                      value: category.uuid,
                      child: Text(
                        category.name,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: darkTextColor),
                      ),
                    );
                  }).toList()),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        // Currency value
        if (_currencyDefinition != null &&
            currencyControllers.length ==
                _currencyDefinition!.currencyTypes.length)
          Row(
            children: _currencyDefinition!.currencyTypes.reversed
                .toList()
                .asMap()
                .entries
                .map((e) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    e.key == 0 ? 0 : 10,
                    0,
                    e.key == _currencyDefinition!.currencyTypes.length - 1
                        ? 0
                        : 10,
                    0,
                  ),
                  child: CustomTextField(
                    newDesign: true,
                    keyboardType: TextInputType.number,
                    labelText: "${e.value.name}:", // TODO localize
                    textEditingController: currencyControllers[e.key],
                  ),
                ),
              );
            }).toList(),
          ),

        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                newDesign: true,
                keyboardType: TextInputType.text,
                labelText: "Fundgröße: (optional)", // TODO localize
                textEditingController: patchSizeTextController,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                newDesign: true,
                keyboardType: TextInputType.multiline,
                labelText: "Beschreibung:", // TODO localize
                textEditingController: descriptionController,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                newDesign: true,
                keyboardType: TextInputType.multiline,
                labelText: "Bild-Beschreibung:", // TODO localize
                textEditingController: imageDescriptionController,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const HorizontalLine(),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Fundorte:",
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: darkTextColor, fontSize: 16),
        ),
        const SizedBox(
          height: 10,
        ),
        ..._placesOfFinding.asMap().entries.map(
              (tuple) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomDropdownMenu(
                          newDesign: true,
                          selectedValueTemp: tuple.value.$1,
                          setter: (newValue) {
                            setState(() {
                              _placesOfFinding[tuple.key] =
                                  (newValue, _placesOfFinding[tuple.key].$2);
                            });
                          },
                          label: 'Fundort #${tuple.key + 1}', // TODO localize
                          items: _allPlacesOfFindings
                              .sortBy((p) => p.name)
                              .map((placeOfFinding) {
                            return DropdownMenuItem<String?>(
                              value: placeOfFinding.uuid == ""
                                  ? null
                                  : placeOfFinding.uuid,
                              child: Text(placeOfFinding.name),
                            );
                          }).toList()),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 75,
                      child: CustomTextField(
                        newDesign: true,
                        keyboardType: TextInputType.number,
                        labelText: "DC:", // TODO localize
                        textEditingController: tuple.value.$2,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 70,
                      clipBehavior: Clip.none,
                      child: CustomButtonNewdesign(
                        variant: CustomButtonNewdesignVariant.FlatButton,
                        onPressed: () {
                          // remove this pair from list
                          setState(() {
                            _placesOfFinding.removeAt(tuple.key);
                          });
                        },
                        icon: const CustomFaIcon(
                          icon: FontAwesomeIcons.trashCan,
                          color: darkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomButtonNewdesign(
                variant: CustomButtonNewdesignVariant.Default,
                isSubbutton: true,
                onPressed: () {
                  setState(() {
                    _placesOfFinding.add((
                      _allPlacesOfFindings.isNotEmpty
                          ? _allPlacesOfFindings[0].uuid
                          : "",
                      TextEditingController(text: "10")
                    ));
                  });
                },
                label: "Neuer Fundort",
                icon: Theme(
                    data: ThemeData(
                      iconTheme: const IconThemeData(
                        color: darkTextColor,
                        size: 16,
                      ),
                      textTheme: const TextTheme(
                        bodyMedium: TextStyle(
                          color: darkTextColor,
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
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  int getBaseCurrencyPrice() {
    int result = 0;

    for (var i = 0; i < currencyControllers.length; i++) {
      var controller = currencyControllers[i];
      var currencyType =
          _currencyDefinition!.currencyTypes.reversed.toList()[i];

      var parsedUserInput = int.tryParse(controller.text) ?? 0;

      result += parsedUserInput;

      if (i != currencyControllers.length - 1) {
        assert(currencyType.multipleOfPreviousValue != null,
            "Required for all entries but the last (base) one");

        result *= currencyType.multipleOfPreviousValue!;
      }
    }

    return result;
  }

  DiceRoll? getPatchSize() {
    var userInput = patchSizeTextController.text;
    if (userInput.isEmpty) {
      return null;
    }

    try {
      return DiceRoll.parse(userInput);
    } catch (e) {
      return null;
    }
  }

  Column getRightModalColumn(BuildContext context) {
    return Column(
      children: [
        // Item Card visualization
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Vorschau:",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: darkTextColor,
                    fontSize: 24,
                  ),
            ),
            SizedBox(
              height: 12,
            ),
            CustomItemCard(
              scalarOverride: 1,
              title: nameController.text.isEmpty
                  ? "Enter a name"
                  : nameController.text,
              description: descriptionController.text.isEmpty
                  ? "Enter some description on the left"
                  : descriptionController.text,
              imageUrl: _urlsOfGeneratedImages.isEmpty
                  ? null
                  : _urlsOfGeneratedImages[_selectedGeneratedImage!],
              isLoadingNewImage: isLoadingNewImage,
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                CustomButtonNewdesign(
                    variant: CustomButtonNewdesignVariant.FlatButton,
                    icon: CustomFaIcon(
                      icon: FontAwesomeIcons.chevronLeft,
                      color: isShowPreviousGeneratedImageButtonDisabled
                          ? middleBgColor
                          : darkColor,
                    ),
                    onPressed: isShowPreviousGeneratedImageButtonDisabled
                        ? null
                        : () {
                            setState(() {
                              if (_selectedGeneratedImage != null) {
                                _selectedGeneratedImage =
                                    max(_selectedGeneratedImage! - 1, 0);
                              }
                            });
                          }),
                Spacer(),
                CupertinoButton(
                  onPressed: isLoadingNewImage == true
                      ? null
                      : () async {
                          // TODO show loading spinner...
                          if (imageDescriptionController.text == "" ||
                              imageDescriptionController.text.length < 5) {
                            return;
                          }

                          var connectionDetails =
                              ref.read(connectionDetailsProvider).requireValue;
                          var campagneId = connectionDetails.campagneId;
                          if (campagneId == null) return;

                          setState(() {
                            isLoadingNewImage = true;
                          });

                          // TODO generate image!
                          var service = DependencyProvider.of(context)
                              .getService<IImageGenerationService>();

                          var generationResult =
                              await service.createNewImageAndGetUrl(
                            prompt: imageDescriptionController.text,
                            campagneId: CampagneIdentifier($value: campagneId),
                          );

                          if (!context.mounted) return;
                          await generationResult.possiblyHandleError(context);
                          if (!context.mounted) return;

                          if (generationResult.isSuccessful &&
                              generationResult.result != null) {
                            setState(() {
                              _urlsOfGeneratedImages
                                  .add(generationResult.result!);
                              _selectedGeneratedImage =
                                  _urlsOfGeneratedImages.length - 1;
                            });
                          }
                          setState(() {
                            isLoadingNewImage = false;
                          });
                        },
                  minSize: 0,
                  padding: EdgeInsets.all(0),
                  child: Text(
                    "Neues Bild",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              isLoadingNewImage ? middleBgColor : accentColor,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              isLoadingNewImage ? middleBgColor : accentColor,
                          fontSize: 16,
                        ),
                  ),
                ),
                Spacer(),
                CustomButtonNewdesign(
                    variant: CustomButtonNewdesignVariant.FlatButton,
                    icon: CustomFaIcon(
                      icon: FontAwesomeIcons.chevronRight,
                      color: isShowNextGeneratedButtonDisabled
                          ? middleBgColor
                          : darkColor,
                    ),
                    onPressed: isShowNextGeneratedButtonDisabled
                        ? null
                        : () {
                            setState(() {
                              if (_selectedGeneratedImage != null) {
                                _selectedGeneratedImage = min(
                                    _selectedGeneratedImage! + 1,
                                    _urlsOfGeneratedImages.length - 1);
                              }
                            });
                          }),
              ],
            ),
          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 20),
            child: CustomButtonNewdesign(
              variant: CustomButtonNewdesignVariant.Default,

              label: "Speichern", // TODO localize
              onPressed: () {
                if (selectedItemCategoryId == null ||
                    selectedItemCategoryId!.isEmpty) return;

                navigatorKey.currentState!.pop(RpgItem(
                    imageUrlWithoutBasePath: _urlsOfGeneratedImages.isEmpty
                        ? null
                        : _urlsOfGeneratedImages[_selectedGeneratedImage!],
                    uuid: widget.itemToEdit.uuid,
                    name: nameController.text,
                    categoryId: selectedItemCategoryId!,
                    description: descriptionController.text,
                    imageDescription: imageDescriptionController.text,
                    patchSize: getPatchSize(),
                    baseCurrencyPrice: getBaseCurrencyPrice(),
                    placeOfFindings: _placesOfFinding
                        .map((pair) => RpgItemRarity(
                            placeOfFindingId: pair.$1!,
                            diceChallenge: int.parse(pair.$2.text)))
                        .toList()));
              },
            ),
          ),
        ),
      ],
    );
  }

  bool get isShowPreviousGeneratedImageButtonDisabled {
    return _selectedGeneratedImage == null || _selectedGeneratedImage == 0;
  }

  bool get isShowNextGeneratedButtonDisabled {
    return _selectedGeneratedImage == null ||
        _selectedGeneratedImage! >= _urlsOfGeneratedImages.length - 1;
  }
}
