import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_dropdown_menu.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class DmGrantItemsScreenContent extends ConsumerStatefulWidget {
  const DmGrantItemsScreenContent({
    super.key,
  });

  @override
  ConsumerState<DmGrantItemsScreenContent> createState() =>
      _DmGrantItemsScreenContentState();
}

class _DmGrantItemsScreenContentState
    extends ConsumerState<DmGrantItemsScreenContent> {
  String? selectedPlaceOfFindingId;
  List<(String uuid, String playerName, TextEditingController)> playerRolls =
      [];
  var isSendItemsButtonDisabled = true;

  bool _getIsSendItemsButtonDisabled() {
    if (selectedPlaceOfFindingId == null) {
      return true;
    }

    if (playerRolls.any((t) => t.$3.text.isEmpty)) return true;
    if (playerRolls.any((t) => int.tryParse(t.$3.text) == null)) return true;

    return false;
  }

  void _updateStateForFormValidation() {
    var newIsSendItemsButtonValid = _getIsSendItemsButtonDisabled();

    setState(() {
      isSendItemsButtonDisabled = newIsSendItemsButtonValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;

    ref.watch(connectionDetailsProvider).whenData((cb) {
      var playerIds = (cb.playerProfiles ?? [])
          .map((p) => (p.uuid, p.characterName))
          .toList();

      // TODO remove me
      if (playerIds.isEmpty) {
        playerIds = [
          ("4ada920c-fd40-45ec-9892-a16a822fbc47", "Kardan"),
          ("9877f8bf-4ef1-4dcd-b922-b29e3e90c4ae", "Marie")
        ];
      }

      for (var playerId in playerIds) {
        if (playerRolls.every((pr) => pr.$1 != playerId.$1)) {
          var newTextEditContoller = TextEditingController();
          newTextEditContoller.addListener(_updateStateForFormValidation);
          playerRolls.add((playerId.$1, playerId.$2, newTextEditContoller));
        }
      }

      var newPlayerRolls = [...playerRolls];
      for (var editTuple in playerRolls) {
        if (playerIds.every((pi) => pi.$1 != editTuple.$1)) {
          newPlayerRolls.removeWhere((npr) => npr.$1 == editTuple.$1);
        }
      }

      setState(() {
        playerRolls = newPlayerRolls;
      });
    });

    var placesOfFindings = getAllPlaceOfFindingsWithItemsWithin(rpgConfig);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 9.0),
          child: Text(
            "Items verteilen",
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: Colors.white, fontSize: 32),
          ),
        ),
        const HorizontalLine(),
        Expanded(
          flex: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: whiteBgTint,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 9.0),
                          child: Text(
                            "Letzte verteilte Items",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                      const HorizontalLine(),
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CustomMarkdownBody(
                            text: "Noch keine Items verteilt..."),
                      ),
                      // TODO build me...
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 9.0),
                            child: Text(
                              "Neue Items verteilen",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(color: Colors.white, fontSize: 24),
                            ),
                          ),
                        ),
                        const HorizontalLine(),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomDropdownMenu(
                                    selectedValueTemp: selectedPlaceOfFindingId,
                                    setter: (newValue) {
                                      setState(() {
                                        selectedPlaceOfFindingId = newValue;
                                      });
                                    },
                                    label: 'Fundort', // TODO localize
                                    items: [
                                      ...(placesOfFindings
                                          .sortBy((e) => e.name)),
                                    ].map((placeOfFinding) {
                                      return DropdownMenuItem<String?>(
                                        value: placeOfFinding.uuid,
                                        child: Text(placeOfFinding.name),
                                      );
                                    }).toList()),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: CustomMarkdownBody(text: "## Spieler Würfe"),
                        ),
                        ...playerRolls.map(
                          (playerRollPair) => Row(
                            children: [
                              const SizedBox(
                                width: 40,
                              ),
                              Expanded(
                                flex: 3,
                                child: CustomMarkdownBody(
                                    text: "Spieler __${playerRollPair.$2}__"),
                              ),
                              SizedBox(
                                width: 80,
                                child: CustomTextField(
                                  labelText: "Wurf",
                                  textEditingController: playerRollPair.$3,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: CustomButton(
                              onPressed: isSendItemsButtonDisabled
                                  ? null
                                  : () {
                                      // TODO make me
                                    },
                              label: "Items verschicken",
                            ),
                          ),
                        ),
                        const HorizontalLine(),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CustomMarkdownBody(
                              text: getTextOfFindableItemsInPlaceOfFinding(
                                  rpgConfig, selectedPlaceOfFindingId)),
                        ),
                        SizedBox(
                            height: EdgeInsets.fromViewPadding(
                                    View.of(context).viewInsets,
                                    View.of(context).devicePixelRatio)
                                .bottom),
                      ],
                    ),
                  )),
            ],
          ),
        )
      ],
    );
  }

  String getTextOfFindableItemsInPlaceOfFinding(
    RpgConfigurationModel? rpgConfig,
    String? selectedPlaceOfFindingId,
  ) {
    var result = "## Auffindbare Items in Fundort: ";

    if (rpgConfig == null) return result;
    result += "\n\n";
    if (selectedPlaceOfFindingId == null) {
      result += "Es wurde noch kein Fundort ausgewählt.";
    } else {
      result += "Diese Items gibt es am/im Fundort:\n";

      var itemsInPlaceOfFinding = rpgConfig.allItems
          .where((it) => it.placeOfFindings
              .any((pof) => pof.placeOfFindingId == selectedPlaceOfFindingId))
          .toList();

      var itemsWithTheirDcSorted = itemsInPlaceOfFinding
          .map((it) {
            var dcForItemInPlace = it.placeOfFindings
                .where(
                    (pof) => pof.placeOfFindingId == selectedPlaceOfFindingId)
                .single
                .diceChallenge;
            return (it, dcForItemInPlace);
          })
          .sortByDescending<num>((t) => t.$2)
          .toList();

      for (var item in itemsWithTheirDcSorted) {
        result += "\n- ${item.$1.name} (DC: ${item.$2})";
      }
    }

    return result;
  }

  List<PlaceOfFinding> getAllPlaceOfFindingsWithItemsWithin(
      RpgConfigurationModel? rpgConfig) {
    if (rpgConfig == null) return [];

    return rpgConfig.placesOfFindings
        .where((pof) => rpgConfig.allItems.any((it) => it.placeOfFindings
            .any((itpof) => itpof.placeOfFindingId == pof.uuid)))
        .toList();
  }
}
