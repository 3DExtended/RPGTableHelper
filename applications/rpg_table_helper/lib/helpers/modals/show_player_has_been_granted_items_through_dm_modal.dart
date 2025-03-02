// cannot figure out how to fix the canLaunch stuff in here...
// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_item_card.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_shadow_widget.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/color_extension.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:shadow_widget/shadow_widget.dart';

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
      backgroundColor: const Color.fromARGB(192, 21, 21, 21),
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return PlayerHasBeenGrantedItemsThroughDmModalContent(
            modalPadding: modalPadding,
            numberOfReceivedItems: numberOfReceivedItems,
            grantedItems: grantedItems,
            rpgConfig: rpgConfig);
      });
}

class PlayerHasBeenGrantedItemsThroughDmModalContent extends StatefulWidget {
  const PlayerHasBeenGrantedItemsThroughDmModalContent({
    super.key,
    required this.modalPadding,
    required this.numberOfReceivedItems,
    required this.grantedItems,
    required this.rpgConfig,
  });

  final RpgConfigurationModel rpgConfig;
  final GrantedItemsForPlayer grantedItems;
  final double modalPadding;
  final int numberOfReceivedItems;

  @override
  State<PlayerHasBeenGrantedItemsThroughDmModalContent> createState() =>
      _PlayerHasBeenGrantedItemsThroughDmModalContentState();
}

class _PlayerHasBeenGrantedItemsThroughDmModalContentState
    extends State<PlayerHasBeenGrantedItemsThroughDmModalContent> {
  int alreadySeenItems = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
            left: widget.modalPadding,
            right: widget.modalPadding),
        child: Center(
          child: CustomShadowWidget(
            child: Container(
              color: bgColor,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Navbar(
                    backInsteadOfCloseIcon: false,
                    closeFunction: () {
                      navigatorKey.currentState!.pop(null);
                    },
                    menuOpen: null,
                    useTopSafePadding: false,
                    titleWidget: Text(
                      S.of(context).receivedItemsModalHeader,
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
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 423,
                              width: MediaQuery.of(context).size.width,
                              child: buildStackForCards(
                                  widget.rpgConfig,
                                  widget.numberOfReceivedItems,
                                  widget.grantedItems.grantedItems),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Builder(builder: (context) {
                                    var text = widget.numberOfReceivedItems > 1
                                        ? S.of(context).newItemsMarkdownPlural
                                        : S
                                            .of(context)
                                            .newItemsMarkdownSingular;
                                    text += "\n\n";
                                    text += widget.numberOfReceivedItems > 1
                                        ? S.of(context).receivedXNewItems(
                                            widget.numberOfReceivedItems)
                                        : S.of(context).receivedOneNewItemText;
                                    text += "\n\n";

                                    for (var itemPair
                                        in widget.grantedItems.grantedItems) {
                                      var itemFromId = widget.rpgConfig.allItems
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
                          label: S.of(context).ok,
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
    );
  }

  void hideNextCard() {
    setState(() {
      alreadySeenItems++;
    });
  }

  Widget buildStackForCards(RpgConfigurationModel rpgConfig,
      int numberOfReceivedItems, List<RpgCharacterOwnedItemPair> grantedItems) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.topCenter,
        children: [
          ...grantedItems
              .take(grantedItems.length - alreadySeenItems)
              .toList()
              .asMap()
              .entries
              .map((grantedItem) {
            var itemFromId = widget.rpgConfig.allItems
                .singleWhereOrNull((i) => i.uuid == grantedItem.value.itemUuid);
            var allItemCategories = ItemCategory.flattenCategoriesRecursive(
                categories: widget.rpgConfig.itemCategories);

            var categoryForItem = itemFromId == null
                ? null
                : allItemCategories
                    .firstWhereOrNull((c) => c.uuid == itemFromId.categoryId);

            if (itemFromId == null) return Container();

            var isLast =
                grantedItem.key == grantedItems.length - alreadySeenItems - 1;
            var leftValue = ((grantedItems.length - alreadySeenItems - 1) -
                    grantedItem.key) *
                20;

            return AnimatedPositioned(
                key: ValueKey("animatedPosition${grantedItem.value.itemUuid}"),
                duration: DependencyProvider.of(context).isMocked
                    ? Duration.zero
                    : Durations.medium2,
                height: 423,
                width: 289,
                top: 0,
                right: (constraints.maxWidth - 289) / 2.0 - leftValue,
                child: ConditionalWidgetWrapper(
                  condition: isLast,
                  wrapper: (context, child) => CupertinoButton(
                      minSize: 0,
                      padding: EdgeInsets.zero,
                      child: child,
                      onPressed: () {
                        hideNextCard();
                      }),
                  child: Transform.scale(
                    scale: max(
                        0,
                        1 -
                            ((grantedItems.length - alreadySeenItems - 1) -
                                    grantedItem.key) *
                                0.05),
                    child: ShadowWidget(
                      offset: Offset(2, 4),
                      blurRadius: 5,
                      color: const Color.fromARGB(91, 0, 0, 0),
                      child: CustomItemCard(
                        title: itemFromId.name,
                        description: itemFromId.description,
                        imageUrl: itemFromId.imageUrlWithoutBasePath,
                        categoryIconColor: categoryForItem?.colorCode
                            ?.parseHexColorRepresentation(),
                        categoryIconName: categoryForItem?.iconName,
                      ),
                    ),
                  ),
                ));
          }),
        ],
      );
    });
  }
}
