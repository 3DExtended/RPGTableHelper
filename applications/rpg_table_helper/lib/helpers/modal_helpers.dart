// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/components/static_grid.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/helpers/validation_helpers.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/humanreadable_response.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

Future<void> showOldVersionUpdateRequired(BuildContext context) async {
  // show error to user
  await customShowCupertinoModalBottomSheet(
    isDismissible: false,
    expand: false,
    closeProgressThreshold: -50000,
    enableDrag: false,
    context: context,
    builder: (context) => Container(
      color: Colors.red,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(21.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "S.of(context).newVersionModalHeader",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontFamily: 'Pangram',
                            color: Colors.white,
                            fontSize: 32,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 42,
              ),
              Text(
                "S.of(context).newVersionModalText",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
              ),
              const SizedBox(
                height: 28 * 2,
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: YourshelfButton(
              //         isAccentColor: true,
              //         text: S.of(context).newVersionModalOpenAppStoreBtnLabel,
              //         onPressed: () {
              //           Future<void> openStore() async {
              //             String packageName = 'YourShelf';
              //             String appStoreUrl =
              //                 'https://apps.apple.com/us/app/yourshelf/id1658328816';
              //             String playStoreUrl =
              //                 'https://play.google.com/store/apps/details?id=$packageName';
              //             if (await canLaunch(appStoreUrl) &&
              //                 !Platform.isAndroid) {
              //               await launch(appStoreUrl);
              //             } else if (await canLaunch(playStoreUrl) &&
              //                 Platform.isAndroid) {
              //               await launch(playStoreUrl);
              //             } else {
              //               throw 'Could not launch store';
              //             }
              //           }
              //           openStore();
              //         },
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Future<bool?> showSynchronizeLocallySavedRpgCampagne(BuildContext context,
//     {GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
//   // show error to user
//   return await customShowCupertinoModalBottomSheet<bool>(
//       isDismissible: false,
//       expand: false,
//       closeProgressThreshold: -50000,
//       enableDrag: false,
//       context: context,
//       overrideNavigatorKey: overrideNavigatorKey,
//       builder: (context) {
//         var modalPadding = 80.0;
//         if (MediaQuery.of(context).size.width < 800) {
//           modalPadding = 20.0;
//         }
//
//         return Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: modalPadding,
//               vertical: modalPadding), // TODO maybe percentage of total width?
//           child: Scaffold(
//             resizeToAvoidBottomInset: false,
//             backgroundColor: Colors.transparent,
//             body: Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   maxWidth: 800.0,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     StyledBox(
//                       borderThickness: 1,
//                       child: Padding(
//                         padding: const EdgeInsets.all(21.0),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: CustomMarkdownBody(
//                                     text:
//                                         "# ‼️ In die Cloud speichern ‼️\n\n__Nur für Marie!__\n\nWir haben festgestellt, dass du eine lokal gespeicherte Kampagne hast. Wenn du DM dieser Kampagne warst (ergo Marie heißt), solltest du die Kampagne jetzt online speichern! Falls du dies jedoch bereits gemacht hast, darfst du nun auf Abbrechen drücken.\n\n__Sage Peter bitte Bescheid, wenn du Fragen hast!__", // TODO localize/ switch text between add and edit
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
//                               child: Row(
//                                 children: [
//                                   CustomButton(
//                                     label: "Abbrechen", // TODO localize
//                                     onPressed: () {
//                                       navigatorKey.currentState!.pop(null);
//                                     },
//                                   ),
//                                   const Spacer(),
//                                   CustomButton(
//                                     label: "Speichern", // TODO localize
//                                     onPressed: () {
//                                       navigatorKey.currentState!.pop(true);
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                         height: EdgeInsets.fromViewPadding(
//                                 View.of(context).viewInsets,
//                                 View.of(context).devicePixelRatio)
//                             .bottom),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       });
// }

Future showPlayerHasBeenGrantedItemsThroughDmModal(BuildContext context,
    {required GrantedItemsForPlayer grantedItems,
    required RpgConfigurationModel rpgConfig,
    GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  var numberOfReceivedItems =
      grantedItems.grantedItems.map((gi) => gi.amount).toList().sum;
  if (numberOfReceivedItems <= 0) return;

  // show error to user
  await customShowCupertinoModalBottomSheet(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: false,
      context: context,
      backgroundColor: const Color.fromARGB(158, 49, 49, 49),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: modalPadding,
              vertical: modalPadding), // TODO maybe percentage of total width?
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: 800.0,
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: StyledBox(
                  borderThickness: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(21.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Builder(builder: (context) {
                                        var text = numberOfReceivedItems > 1
                                            ? "# Neue Items" // TODO localize
                                            : "# Neues Item"; // TODO localize
                                        text += "\n\n";
                                        text += numberOfReceivedItems > 1
                                            ? "Du hast $numberOfReceivedItems neue Items erhalten:"
                                            : "Du hast ein neues Item erhalten";
                                        text += "\n\n";

                                        for (var itemPair
                                            in grantedItems.grantedItems) {
                                          var itemFromId = rpgConfig.allItems
                                              .singleWhereOrNull((i) =>
                                                  i.uuid == itemPair.itemUuid);
                                          if (itemFromId == null) continue;

                                          text +=
                                              "\n- ${itemPair.amount}x ${itemFromId.name}";
                                        }
                                        text += "\n\n";

                                        return CustomMarkdownBody(
                                          text: text,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                          child: Row(
                            children: [
                              const Spacer(),
                              CustomButton(
                                label: "Ok", // TODO localize
                                onPressed: () {
                                  navigatorKey.currentState!.pop(null);
                                },
                              ),
                              const Spacer(),
                            ],
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
      });
}

Future showItemVisualizationWithRecipeDetailsModal(BuildContext context,
    {required CraftingRecipe recipe,
    required RpgItem itemToRender,
    required RpgConfigurationModel rpgConfig,
    required RpgCharacterConfiguration rpgCharConfig,
    GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  await customShowCupertinoModalBottomSheet(
      isDismissible: true,
      expand: true,
      closeProgressThreshold: -50000,
      enableDrag: true,
      context: context,
      backgroundColor: const Color.fromARGB(158, 49, 49, 49),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        var minWidthHeight = min(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height) *
            0.7;

        minWidthHeight = min(470, minWidthHeight);

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: modalPadding,
              vertical: modalPadding), // TODO maybe percentage of total width?
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Center(
              child: StyledBox(
                borderThickness: 1,
                child: SizedBox(
                  height: minWidthHeight,
                  width: minWidthHeight,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            itemToRender.name,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(child: SingleChildScrollView(
                          child: Builder(builder: (context) {
                            var result = "## Beschreibung\n\n";
                            result += itemToRender.description;
                            result += "\n\n";

                            result += "## Herstellung\n\n";

                            if (recipe.requiredItemIds.isNotEmpty) {
                              result += "### Voraussetzung\n\n";

                              for (var requirement in recipe.requiredItemIds) {
                                int numberOfIngredientsInInventar =
                                    rpgCharConfig.inventory
                                            .firstWhereOrNull((inv) =>
                                                inv.itemUuid == requirement)
                                            ?.amount ??
                                        0;

                                var numberOfIngredientsInInventarText =
                                    numberOfIngredientsInInventar.toString();

                                if (numberOfIngredientsInInventar < 1) {
                                  numberOfIngredientsInInventarText += " ❌";
                                } else {
                                  numberOfIngredientsInInventarText += " ✅";
                                }

                                var requirementItem = rpgConfig.allItems
                                    .firstWhereOrNull(
                                        (i) => i.uuid == requirement);
                                if (requirementItem == null) continue;

                                result +=
                                    "- ${requirementItem.name}, in Besitz: $numberOfIngredientsInInventarText\n";
                              }

                              result += "### Zutaten\n\n";
                            }

                            for (var ingredientPair in recipe.ingredients) {
                              var ingredientItem = rpgConfig.allItems
                                  .firstWhereOrNull(
                                      (i) => i.uuid == ingredientPair.itemUuid);
                              if (ingredientItem == null) continue;

                              int numberOfIngredientsInInventar = rpgCharConfig
                                      .inventory
                                      .firstWhereOrNull((inv) =>
                                          inv.itemUuid ==
                                          ingredientPair.itemUuid)
                                      ?.amount ??
                                  0;

                              var numberOfIngredientsInInventarText =
                                  numberOfIngredientsInInventar.toString();

                              if (numberOfIngredientsInInventar <
                                  ingredientPair.amountOfUsedItem) {
                                numberOfIngredientsInInventarText += " ❌";
                              } else {
                                numberOfIngredientsInInventarText += " ✅";
                              }

                              result +=
                                  "- ${ingredientPair.amountOfUsedItem}x ${ingredientItem.name}, in Besitz: $numberOfIngredientsInInventarText\n";
                            }

                            return CustomMarkdownBody(text: result);
                          }),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
}

// Future<bool?> showSynchronizeLocallySavedRpgPlayerCharacter(
//     BuildContext context,
//     {GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
//   // show error to user
//   return await customShowCupertinoModalBottomSheet<bool>(
//       isDismissible: false,
//       expand: false,
//       closeProgressThreshold: -50000,
//       enableDrag: false,
//       context: context,
//       overrideNavigatorKey: overrideNavigatorKey,
//       builder: (context) {
//         var modalPadding = 80.0;
//         if (MediaQuery.of(context).size.width < 800) {
//           modalPadding = 20.0;
//         }
//
//         return Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: modalPadding,
//               vertical: modalPadding), // TODO maybe percentage of total width?
//           child: Scaffold(
//             resizeToAvoidBottomInset: false,
//             backgroundColor: Colors.transparent,
//             body: Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   maxWidth: 800.0,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     StyledBox(
//                       borderThickness: 1,
//                       child: Padding(
//                         padding: const EdgeInsets.all(21.0),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: CustomMarkdownBody(
//                                     text:
//                                         "# ‼️ In die Cloud speichern ‼️\n\n__Für alle Spieler außer Marie (Rachel, Lukas, Tobias, Peter)!__\n\nWir haben festgestellt, dass du einen lokal gespeicherten Charakter hast. Dies ist deine Möglichkeit, diesen Charakter in die Cloud zu speichern. Dies solltest du umbedingt (genau ein mal!) tun! Falls du dies jedoch bereits gemacht hast, darfst du nun auf Abbrechen drücken.\n\n__Sage Peter bitte Bescheid, wenn du Fragen hast!__", // TODO localize/ switch text between add and edit
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
//                               child: Row(
//                                 children: [
//                                   CustomButton(
//                                     label: "Abbrechen", // TODO localize
//                                     onPressed: () {
//                                       navigatorKey.currentState!.pop(null);
//                                     },
//                                   ),
//                                   const Spacer(),
//                                   CustomButton(
//                                     label: "Speichern", // TODO localize
//                                     onPressed: () {
//                                       navigatorKey.currentState!.pop(true);
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                         height: EdgeInsets.fromViewPadding(
//                                 View.of(context).viewInsets,
//                                 View.of(context).devicePixelRatio)
//                             .bottom),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       });
// }

Future<String?> askForCampagneJoinCode(BuildContext context,
    {GlobalKey<NavigatorState>? overrideNavigatorKey}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<String>(
      isDismissible: false,
      expand: false,
      closeProgressThreshold: -50000,
      enableDrag: false,
      context: context,
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return AskForCampagneJoinCodeModalContent(modalPadding: modalPadding);
      });
}

class AskForCampagneJoinCodeModalContent extends StatefulWidget {
  const AskForCampagneJoinCodeModalContent({
    super.key,
    required this.modalPadding,
  });

  final double modalPadding;

  @override
  State<AskForCampagneJoinCodeModalContent> createState() =>
      _AskForCampagneJoinCodeModalContentState();
}

class _AskForCampagneJoinCodeModalContentState
    extends State<AskForCampagneJoinCodeModalContent> {
  var joinCodeTextEditor = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: widget.modalPadding,
          vertical:
              widget.modalPadding), // TODO maybe percentage of total width?
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBox(
                  borderThickness: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(21.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomMarkdownBody(
                                text:
                                    "# Character zu Kampagne hinzufügen\n\nDu hast zwar einen Charakter erstellt, dieser ist aber noch keine Season bzw. Kampagne zugeordnet. Gebe hier den Join Code ein, den du von deinem DM erhältst, um eine Anfrage an deinen DM zu senden.", // TODO localize/ switch text between add and edit
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                keyboardType: TextInputType.text,
                                labelText: "Join Code:", // TODO localize
                                textEditingController: joinCodeTextEditor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                          child: Row(
                            children: [
                              CustomButton(
                                label: "Abbrechen", // TODO localize
                                onPressed: () {
                                  navigatorKey.currentState!.pop(null);
                                },
                              ),
                              const Spacer(),
                              CustomButton(
                                label: "Speichern", // TODO localize
                                onPressed: () {
                                  // TODO activate only when join code matches format
                                  if (joinCodeValid(joinCodeTextEditor.text)) {
                                    navigatorKey.currentState!
                                        .pop(joinCodeTextEditor.text);
                                  } else {}
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                    height: EdgeInsets.fromViewPadding(
                            View.of(context).viewInsets,
                            View.of(context).devicePixelRatio)
                        .bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showGenericErrorModal<T>(
    HRResponseBase response, BuildContext context) async {
  // show error to user
  await customShowCupertinoModalBottomSheet(
    context: context,
    builder: (context) => Container(
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(21.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 7,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "S.of(context).genericErrorModalHeader",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontFamily: 'Pangram',
                        color: Colors.white,
                        fontSize: 32,
                      ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              "Error: ${response.humanReadableError ?? 'An unknown error occured...'}",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(
              height: 28 * 2,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  Text(
                    "S.of(context).genericErrorModalTechnicalDetailsHeader",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontFamily: 'Pangram',
                          color: Colors.white,
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  StaticGrid(
                    rowCrossAxisAlignment: CrossAxisAlignment.start,
                    columnCount: 2,
                    expandedFlexValues: const [1, 3],
                    rowGap: 30,
                    children: [
                      Text(
                        "S.of(context).genericErrorModalTechnicalDetailsErrorCodeRowLabel",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                      ),
                      Text(
                        response.errorCode ?? '',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                      ),
                      Text(
                        "S.of(context).genericErrorModalTechnicalDetailsExceptionRowLabel",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                      ),
                      Text(
                        response.caughtException?.toString() ?? '',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                      ),
                      Text(
                        "S.of(context).genericErrorModalServerErrorMessageExceptionRowLabel",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                      ),
                      Text(
                        response.errorFromServer?.toString() ?? '',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                      ),
                      Text(
                        "S.of(context).genericErrorModalStatusCodeRowLabel",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                      ),
                      Text(
                        response.statusCode?.toString() ?? '',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// ------------Cloned from the original package because the naviator is not exposed-----
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------

const double _kPreviousPageVisibleOffset = 10;

const Radius _kDefaultTopRadius = Radius.circular(12);
const BoxShadow _kDefaultBoxShadow =
    BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);

/// Cupertino Bottom Sheet Container
///
/// Clip the child widget to rectangle with top rounded corners and adds
/// top padding(+safe area padding). This padding [_kPreviousPageVisibleOffset]
/// is the height that will be displayed from previous route.
class _CupertinoBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Radius topRadius;
  final BoxShadow? shadow;

  const _CupertinoBottomSheetContainer({
    required this.child,
    this.backgroundColor,
    required this.topRadius,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    // final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    const topPadding = _kPreviousPageVisibleOffset; // + topSafeAreaPadding;

    final shadow = this.shadow ?? _kDefaultBoxShadow;
    const BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);
    final backgroundColor = this.backgroundColor ??
        CupertinoTheme.of(context).scaffoldBackgroundColor;
    return Padding(
      padding: const EdgeInsets.only(top: topPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: topRadius),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor, // backgroundColor
            boxShadow: [shadow],
          ),
          width: double.infinity,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true, //Remove top Safe Area
            child: CupertinoUserInterfaceLevel(
              data: CupertinoUserInterfaceLevelData.elevated,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> customShowCupertinoModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  Curve? previousRouteAnimationCurve,
  bool useRootNavigator = false,
  bool bounce = true,
  bool? isDismissible,
  bool enableDrag = true,
  Radius topRadius = _kDefaultTopRadius,
  Duration? duration,
  RouteSettings? settings,
  Color? transitionBackgroundColor,
  BoxShadow? shadow,
  SystemUiOverlayStyle? overlayStyle,
  double? closeProgressThreshold,
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  assert(debugCheckHasMediaQuery(context));
  final hasMaterialLocalizations =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) !=
          null;
  final barrierLabel = hasMaterialLocalizations
      ? MaterialLocalizations.of(context).modalBarrierDismissLabel
      : '';

  var nav = overrideNavigatorKey?.currentState ?? navigatorKey.currentState!;

  final result = await nav.push(
    CupertinoModalBottomSheetRoute<T>(
        builder: builder,
        containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
              backgroundColor: backgroundColor,
              topRadius: topRadius,
              shadow: shadow,
              child: child,
            ),
        secondAnimationController: secondAnimation,
        expanded: expand,
        closeProgressThreshold: closeProgressThreshold,
        barrierLabel: barrierLabel,
        elevation: elevation,
        bounce: bounce,
        shape: shape,
        clipBehavior: clipBehavior,
        isDismissible: isDismissible ?? expand == false ? true : false,
        modalBarrierColor: barrierColor ?? Colors.black12,
        enableDrag: enableDrag,
        topRadius: topRadius,
        animationCurve: animationCurve,
        previousRouteAnimationCurve: previousRouteAnimationCurve,
        duration: duration,
        settings: settings,
        transitionBackgroundColor: transitionBackgroundColor ?? Colors.black,
        overlayStyle: overlayStyle),
  );
  return result;
}
