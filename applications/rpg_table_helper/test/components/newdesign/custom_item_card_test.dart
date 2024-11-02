import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/newdesign/custom_item_card.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../../test_configuration.dart';

void main() {
  group('CustomItemCard rendering', () {
    var itemCards = [
      // display placeholder image
      CustomItemCard(
        title: "Small Healing Potion",
        description:
            "Ein mystischer Trank der bei Verzehr 1D4+1 HP wiederherstellt.",
      ),

      // test very long description
      CustomItemCard(
        title: "Small Healing Potion",
        description:
            "Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion",
      ),

      // test cardBgColorOverride
      CustomItemCard(
        cardBgColorOverride: Color(0xff22573E),
        title: "Small Healing Potion Small Healing Potion",
        description:
            "Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion Small Healing Potion",
      ),

      // test test asset image override
      CustomItemCard(
        title: "Small Healing Potion",
        imageUrl: "assets/images/itemhealingpotion.png",
        description:
            "Ein mystischer Trank der bei Verzehr 1D4+1 HP wiederherstellt.",
      ),
    ];

    for (var i = 0; i < itemCards.length; i++) {
      var itemcard = itemCards[i];
      testConfigurations(
        disableLocals: true,
        widgetName: 'CustomItemCard$i',
        pathPrefix: "../",
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => SizedBox(
          width: 300,
          height: 600,
          child: itemcard,
        ),
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  itemcard,
                ],
              )),
            ),
          ),
        ]),
      );
    }
  });
}
