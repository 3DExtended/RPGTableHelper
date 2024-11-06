import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/newdesign/custom_button_newdesign.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:uuid/v7.dart';

class RpgConfigurationWizardStep4ItemLocations extends WizardStepBase {
  const RpgConfigurationWizardStep4ItemLocations({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
    required super.setWizardTitle,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep4ItemLocations> createState() =>
      _RpgConfigurationWizardStep4ItemLocations();
}

class _RpgConfigurationWizardStep4ItemLocations
    extends ConsumerState<RpgConfigurationWizardStep4ItemLocations> {
  bool hasDataLoaded = false;
  bool isFormValid = false;
  RpgConfigurationModel? rpgConfig;
  List<(String uuid, TextEditingController nameControlle)> locationPairs = [];

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
      widget.setWizardTitle("Fundorte");
    });

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

          rpgConfig = data;

          var loadedItemLocations = data.placesOfFindings;
          if (loadedItemLocations.isNotEmpty) {
            for (var i = 0; i < loadedItemLocations.length; i++) {
              var newLocationName = loadedItemLocations[i].name;
              var newLocationUuid = loadedItemLocations[i].uuid;

              addNewLocationPair(newLocationName, newLocationUuid);
            }
          }
        });
        _updateStateForFormValidation();
      }
    });

    var stepHelperText = '''

Als nächstes wollen wir uns um die Items für deine Spieler kümmern.

Manche Items können dabei an bestimmten Orten gefunden werden: Am Strand, in Höhlen, in Grotten usw.

Damit wir in den nächsten Schritten diese Items mit Fundorten verknüpfen können, hinterleg bitte die unterschiedlichen Orte, an denen deine Items gefunden werden können.
'''; // TODO localize

    return TwoPartWizardStepBody(
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
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
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: [
        const SizedBox(
          height: 20,
        ),
        ...locationPairs.asMap().entries.map((e) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      newDesign: true,
                      keyboardType: TextInputType.text,
                      placeholderText: rpgConfig == null
                          ? null
                          : "An diesem Fundort können ${getNumberOfToPlaceAssignedItems(rpgConfig!, e.value.$1)} Items gefunden werden.",

                      labelText: "Fundort #${e.key + 1}", // TODO localize
                      textEditingController: e.value.$2,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 40,
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: CustomButtonNewdesign(
                      variant: CustomButtonNewdesignVariant.FlatButton,
                      isSubbutton: true,
                      onPressed: () {
                        // remove this pair from list
                        // TODO check if assigned...
                        setState(() {
                          locationPairs.removeAt(e.key);
                        });
                        _updateStateForFormValidation();
                      },
                      icon: const CustomFaIcon(
                        icon: FontAwesomeIcons.trashCan,
                        size: 22,
                        color: darkColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const HorizontalLine(),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        }),
        CustomButtonNewdesign(
          variant: CustomButtonNewdesignVariant.Default,
          isSubbutton: true,
          onPressed: () {
            setState(() {
              addNewLocationPair("", const UuidV7().generate());
            });
          },
          icon: Container(
              width: 24,
              height: 24,
              alignment: AlignmentDirectional.center,
              child: const FaIcon(
                FontAwesomeIcons.plus,
                color: darkColor,
              )),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void addNewLocationPair(String newLocationName, String newLocationUuid) {
    var temp1 = TextEditingController(text: newLocationName);

    temp1.addListener(() {
      _updateStateForFormValidation();
    });

    locationPairs.add((newLocationUuid, temp1));
  }

  void saveChanges() {
    // TODO change me

    List<PlaceOfFinding> newLocations = [];

    for (var pair in locationPairs) {
      newLocations.add(PlaceOfFinding(
        name: pair.$2.text,
        uuid: pair.$1,
      ));
    }

    ref.read(rpgConfigurationProvider.notifier).updateLocations(newLocations);
  }

  bool getIsFormValid() {
    const currencyNameMinLenght = 3;
    if (hasDataLoaded != true) {
      return false;
    }

    for (var editPair in locationPairs) {
      if (editPair.$2.text.isEmpty ||
          editPair.$2.text.length < currencyNameMinLenght) {
        return false;
      }

      if (editPair.$1.isEmpty) {
        return false;
      }
    }

    return true;
  }

  int getNumberOfToPlaceAssignedItems(
      RpgConfigurationModel rpgConfig, String placeOfFindingUuid) {
    var itemsWithSamePlaceOfFindingAssigned = rpgConfig.allItems
        .where((it) => it.placeOfFindings
            .any((pof) => pof.placeOfFindingId == placeOfFindingUuid))
        .length;

    return itemsWithSamePlaceOfFindingAssigned;
  }
}
