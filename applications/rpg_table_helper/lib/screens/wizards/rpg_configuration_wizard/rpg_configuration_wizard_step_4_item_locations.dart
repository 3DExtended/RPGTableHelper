import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/components/wizards/wizard_step_base.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:uuid/v7.dart';

class RpgConfigurationWizardStep4ItemLocations extends WizardStepBase {
  const RpgConfigurationWizardStep4ItemLocations({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep4ItemLocations> createState() =>
      _RpgConfigurationWizardStep4ItemLocations();
}

class _RpgConfigurationWizardStep4ItemLocations
    extends ConsumerState<RpgConfigurationWizardStep4ItemLocations> {
  bool hasDataLoaded = false;
  bool isFormValid = false;

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
      wizardTitle: "RPG Configuration", // TODO localize
      isLandscapeMode: MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepTitle: "Fundorte", // TODO Localize,
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
        ...locationPairs.asMap().entries.map((e) {
          return Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        keyboardType: TextInputType.text,

                        labelText:
                            "Name der nächst größeren Währung:", // TODO localize
                        textEditingController: e.value.$2,
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
                          setState(() {
                            locationPairs.removeAt(e.key);
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
                                child:
                                    const FaIcon(FontAwesomeIcons.trashCan))),
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
            ),
          );
        }),
        CustomButton(
          onPressed: () {
            setState(() {
              addNewLocationPair("New", const UuidV7().generate());
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
}
