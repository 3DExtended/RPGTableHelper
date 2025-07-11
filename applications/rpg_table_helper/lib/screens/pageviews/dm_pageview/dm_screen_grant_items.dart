import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_dropdown_menu.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/custom_iterator_extensions.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/server_methods_service.dart';

class DmScreenGrantItems extends ConsumerStatefulWidget {
  const DmScreenGrantItems({
    super.key,
  });

  @override
  ConsumerState<DmScreenGrantItems> createState() => _DmScreenGrantItemsState();
}

class _DmScreenGrantItemsState extends ConsumerState<DmScreenGrantItems> {
  String? selectedPlaceOfFindingId;
  List<(String uuid, String playerName, TextEditingController)> playerRolls =
      [];
  var isSendItemsButtonDisabled = true;
  List<String> excludedItems = [];

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
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;

    ref.watch(connectionDetailsProvider).whenData((cb) {
      var playerIds = (cb.connectedPlayers ?? [])
          .map((p) => (p.configuration.uuid, p.configuration.characterName))
          .toList();

      for (var playerId in playerIds) {
        if (playerRolls.every((pr) => pr.$1 != playerId.$1)) {
          var newTextEditContoller = TextEditingController(text: "0");
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

    return Container(
      color: CustomThemeProvider.of(context).theme.bgColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).lastGrantedItems,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: CustomThemeProvider.of(context)
                              .theme
                              .darkTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    if (connectionDetails == null ||
                        connectionDetails.lastGrantedItems == null ||
                        connectionDetails.lastGrantedItems!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: CustomMarkdownBody(
                          text: S.of(context).noItemsGranted,
                        ),
                      ),
                    if (connectionDetails != null &&
                        connectionDetails.lastGrantedItems != null &&
                        connectionDetails.lastGrantedItems!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: CustomMarkdownBody(
                            text: getLastGrantedItemsMarkdownText(
                                rpgConfig, connectionDetails)),
                      ),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                        child: Text(
                          S.of(context).grantItems,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color: CustomThemeProvider.of(context)
                                      .theme
                                      .darkTextColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomDropdownMenu(
                                selectedValueTemp: selectedPlaceOfFindingId,
                                setter: (newValue) {
                                  setState(() {
                                    selectedPlaceOfFindingId = newValue;
                                  });
                                },
                                label: S.of(context).placeOfFinding,
                                items: [
                                  ...(placesOfFindings.sortBy((e) => e.name)),
                                ].map((placeOfFinding) {
                                  return DropdownMenuItem<String?>(
                                    value: placeOfFinding.uuid,
                                    child: Text(placeOfFinding.name),
                                  );
                                }).toList()),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CustomMarkdownBody(
                          text: "## ${S.of(context).playerRolls}",
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          ...playerRolls,
                        ]
                            .map(
                              (playerRollPair) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: CustomTextField(
                                      labelText: S.of(context).diceRoll,
                                      textEditingController: playerRollPair.$3,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CustomMarkdownBody(
                                      text:
                                          "${S.of(context).player} __${playerRollPair.$2.isNotEmpty ? playerRollPair.$2.trim() : S.of(context).characterNameDefault}__"),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: CustomButton(
                            variant: CustomButtonVariant.AccentButton,
                            onPressed: isSendItemsButtonDisabled
                                ? null
                                : () {
                                    grantItemsToPlayerForPlaceOfFindingRoll(
                                        rpgConfig, context);
                                  },
                            label: S.of(context).sendItems,
                          ),
                        ),
                      ),
                      const HorizontalLine(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...getWidgetsOfFindableItemsInPlaceOfFinding(
                                rpgConfig, selectedPlaceOfFindingId)
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void grantItemsToPlayerForPlaceOfFindingRoll(
      RpgConfigurationModel? rpgConfig, BuildContext context) {
    List<GrantedItemsForPlayer> result = [];

    List<(RpgItem, int)> itemsInPlaceOfFinding =
        getItemsForSelectedPlaceOfFinding(
            rpgConfig!, selectedPlaceOfFindingId!);

    // remove manually excluded items:
    itemsInPlaceOfFinding = itemsInPlaceOfFinding
        .where((t) => !excludedItems.contains(t.$1.uuid))
        .toList();

    for (var playerTuple in playerRolls) {
      var playerId = playerTuple.$1;
      var playerName = playerTuple.$2;
      var playerRoll = int.parse(playerTuple.$3.text);

      List<RpgCharacterOwnedItemPair> itemsGrantedForPlayer = [];

      for (var possibleItemToGet in itemsInPlaceOfFinding) {
        // for every player and every item in itemsInPlaceOfFinding
        // check if player hit the dc
        var itemDc = possibleItemToGet.$2;

        // meats it beats it
        if (playerRoll < itemDc) continue;

        // now roll the amount for the item
        var amountOfItem = possibleItemToGet.$1.patchSize?.roll() ?? 0;

        if (amountOfItem > 0) {
          itemsGrantedForPlayer.add(RpgCharacterOwnedItemPair(
              itemUuid: possibleItemToGet.$1.uuid, amount: amountOfItem));
        }
      }

      result.add(GrantedItemsForPlayer(
        characterName: playerName,
        grantedItems: itemsGrantedForPlayer,
        playerId: playerId,
      ));
    }

    var connectionDetails = ref.read(connectionDetailsProvider).requireValue;
    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
        connectionDetails.copyWith(lastGrantedItems: result));

    // send updates to players
    var com =
        DependencyProvider.of(context).getService<IServerMethodsService>();
    if (connectionDetails.sessionConnectionNumberForPlayers != null) {
      com.sendGrantedItemsToPlayers(
        campagneId: connectionDetails.campagneId!,
        grantedItems: result,
      );
    }
  }

  List<Widget> getWidgetsOfFindableItemsInPlaceOfFinding(
    RpgConfigurationModel? rpgConfig,
    String? selectedPlaceOfFindingId,
  ) {
    List<Widget> result = [
      CustomMarkdownBody(
        text: S.of(context).itemsToBeFoundInPlaceMarkdown,
      )
    ];

    if (rpgConfig == null) return result;

    if (selectedPlaceOfFindingId == null) {
      result.add(CustomMarkdownBody(
        text: S.of(context).noPlaceOfFindingSelected,
      ));
    } else {
      result.add(CustomMarkdownBody(
        text: S.of(context).followingItemsArePossibleAtPlaceOfFinding,
      ));

      List<(RpgItem, int)> itemsWithTheirDcSorted =
          getItemsForSelectedPlaceOfFinding(
              rpgConfig, selectedPlaceOfFindingId);

      for (var item in itemsWithTheirDcSorted) {
        result.add(CheckboxListTile.adaptive(
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          splashRadius: 0,
          dense: true,
          checkColor: const Color.fromARGB(255, 57, 245, 88),
          activeColor:
              CustomThemeProvider.of(context).brightnessNotifier.value ==
                      Brightness.light
                  ? CustomThemeProvider.of(context).theme.darkColor
                  : Colors.transparent,
          visualDensity: VisualDensity(vertical: -2),
          title: Text(
            "${item.$1.name} (${S.of(context).diceChallengeAbbr}: ${item.$2})",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: CustomThemeProvider.of(context).theme.darkTextColor,
                fontSize: 16),
          ),
          value: !excludedItems.contains(item.$1.uuid),
          onChanged: (val) {
            setState(() {
              if (excludedItems.contains(item.$1.uuid)) {
                excludedItems.removeWhere((e) => e == item.$1.uuid);
              } else {
                excludedItems.add(item.$1.uuid);
              }
            });
          },
        ));
      }
    }

    return result;
  }

  List<(RpgItem, int)> getItemsForSelectedPlaceOfFinding(
      RpgConfigurationModel rpgConfig, String selectedPlaceOfFindingId) {
    var itemsInPlaceOfFinding = rpgConfig.allItems
        .where((it) => it.placeOfFindings
            .any((pof) => pof.placeOfFindingId == selectedPlaceOfFindingId))
        .toList();

    var itemsWithTheirDcSorted = itemsInPlaceOfFinding
        .map((it) {
          var dcForItemInPlace = it.placeOfFindings
              .where((pof) => pof.placeOfFindingId == selectedPlaceOfFindingId)
              .single
              .diceChallenge;
          return (it, dcForItemInPlace);
        })
        .sortByDescending<num>((t) => t.$2)
        .toList();
    return itemsWithTheirDcSorted;
  }

  List<PlaceOfFinding> getAllPlaceOfFindingsWithItemsWithin(
      RpgConfigurationModel? rpgConfig) {
    if (rpgConfig == null) return [];

    return rpgConfig.placesOfFindings
        .where((pof) => rpgConfig.allItems.any((it) => it.placeOfFindings
            .any((itpof) => itpof.placeOfFindingId == pof.uuid)))
        .toList();
  }

  String getLastGrantedItemsMarkdownText(
      RpgConfigurationModel? rpgConfig, ConnectionDetails connectionDetails) {
    if (rpgConfig == null) return "";

    var result = "${S.of(context).lastGrantedItemsMarkdownPrefix}\n\n";

    for (var grantForPlayer in (connectionDetails.lastGrantedItems ??
        List<GrantedItemsForPlayer>.empty())) {
      result +=
          "- ${S.of(context).player} __${grantForPlayer.characterName.isNotEmpty ? grantForPlayer.characterName.trim() : S.of(context).characterNameDefault}:__\n";

      if (grantForPlayer.grantedItems.isEmpty) {
        result += "  - ${S.of(context).noItemsGrantedToPlayerThisRound}\n";
      } else {
        for (var grantedItem in grantForPlayer.grantedItems) {
          var item = rpgConfig.allItems
              .where((it) => it.uuid == grantedItem.itemUuid)
              .single;
          result += "  - ${item.name} (x${grantedItem.amount})\n";
        }
      }
    }

    return result;
  }
}
