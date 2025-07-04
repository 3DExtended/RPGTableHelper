import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_item_card.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

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

      // test different scalarOverride
      CustomItemCard(
        title: "Small Healing Potion",
        imageUrl: "assets/images/itemhealingpotion.png",
        description:
            "Ein mystischer Trank der bei Verzehr 1D4+1 HP wiederherstellt.",
        scalarOverride: 0.9,
      ),

      // test different scalarOverride
      CustomItemCard(
        title: "Small Healing Potion",
        imageUrl: "assets/images/itemhealingpotion.png",
        description:
            "Ein mystischer Trank der bei Verzehr 1D4+1 HP wiederherstellt.",
        scalarOverride: 0.8,
      ),
      // test isGreyscale
      CustomItemCard(
        title: "Small Healing Potion",
        imageUrl: "assets/images/itemhealingpotion.png",
        description:
            "Ein mystischer Trank der bei Verzehr 1D4+1 HP wiederherstellt.",
        isGreyscale: true,
      ),

      CustomItemCard(
        title: "Small Healing Potion",
        imageUrl: "assets/images/itemhealingpotion.png",
        description:
            "Ein mystischer Trank der bei Verzehr 1D4+1 HP wiederherstellt.",
        scalarOverride: 1,
        categoryIconColor: Colors.red,
      ),

      CustomItemCard(
        title: "Small Healing Potion",
        imageUrl: "assets/images/itemhealingpotion.png",
        description:
            "Ein mystischer Trank der bei Verzehr 1D4+1 HP wiederherstellt.",
        scalarOverride: 1,
        categoryIconName: "sword-svgrepo-com",
      ),

      CustomItemCard(
        title: "Small Healing Potion",
        imageUrl: "assets/images/itemhealingpotion.png",
        description:
            "Ein mystischer Trank der bei Verzehr 1D4+1 HP wiederherstellt.",
        scalarOverride: 1,
        categoryIconColor: Colors.yellow,
        categoryIconName: "bone",
      ),
    ];

    for (var i = 0; i < itemCards.length; i++) {
      var itemcard = itemCards[i];
      testConfigurations(
        disableLocals: false,
        widgetName: 'CustomItemCard$i',
        pathPrefix: "../",
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale, Brightness brightnessToTest) =>
            CustomThemeProvider(
          overrideBrightness: brightnessToTest,
          child: SizedBox(
            width: 300,
            height: 600,
            child: itemcard,
          ),
        ),
        getTestConfigurations: (Widget widgetToTest, Brightness brightness) =>
            Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: CustomThemeProvider(
                overrideBrightness: brightness,
                child: Center(
                    child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      itemcard,
                    ],
                  ),
                )),
              ),
            ),
          ),
        ]),
      );
    }
  });
}
