import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/components/custom_recipe_card.dart';
import 'package:quest_keeper/components/quarter_circle_cutout.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/services/dependency_provider.dart';

import '../../test_configuration.dart';

void main() {
  group('CustomRecipeCard rendering', () {
    var recipeCards = [
      // display placeholder image
      () => CustomRecipeCard(
            title: "Small Healing Potion",
            requirements: [],
            ingedients: [
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
              CustomRecipeCardItemPair(amount: 1, itemName: "Blüte der Nacht"),
              CustomRecipeCardItemPair(amount: 2, itemName: "Mondgrass"),
              CustomRecipeCardItemPair(amount: 2, itemName: "Dunkelflechte"),
            ],
          ),

      // test test asset image override
      () => CustomRecipeCard(
            title: "Small Healing Potion",
            imageUrl: "assets/images/itemhealingpotion.png",
            requirements: [],
            ingedients: [
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
              CustomRecipeCardItemPair(amount: 1, itemName: "Blüte der Nacht"),
              CustomRecipeCardItemPair(amount: 2, itemName: "Mondgrass"),
              CustomRecipeCardItemPair(amount: 2, itemName: "Dunkelflechte"),
            ],
          ),

      () => Container(
            width: 100,
            height: 100,
            color: Colors.orange,
            child: QuarterCircleCutout(
                circleOuterDiameter: 50.0,
                circleDegrees: 45,
                circleColor: bgColor,
                circleInnerDiameter: 40.0,
                circleInnerColor: darkColor),
          ),

      () => CustomRecipeCard(
            title: "Small Healing Potion",
            imageUrl: "assets/images/itemhealingpotion.png",
            requirements: [],
            ingedients: [
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
              CustomRecipeCardItemPair(amount: 1, itemName: "Blüte der Nacht"),
              CustomRecipeCardItemPair(amount: 2, itemName: "Mondgrass"),
              CustomRecipeCardItemPair(amount: 2, itemName: "Dunkelflechte"),
            ],
          ),

      () => CustomRecipeCard(
            title: "Small Healing Potion",
            imageUrl: "assets/images/itemhealingpotion.png",
            requirements: [
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
            ],
            ingedients: [
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
              CustomRecipeCardItemPair(amount: 1, itemName: "Blüte der Nacht"),
            ],
          ),

      () => CustomRecipeCard(
            title: "Small Healing Potion",
            imageUrl: "assets/images/itemhealingpotion.png",
            requirements: [
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
            ],
            ingedients: [
              CustomRecipeCardItemPair(
                  amount: 2, itemName: "Roter Fuchsschwanz"),
              CustomRecipeCardItemPair(amount: 1, itemName: "Blüte der Nacht"),
              CustomRecipeCardItemPair(amount: 2, itemName: "Mondgrass"),
              CustomRecipeCardItemPair(amount: 2, itemName: "Dunkelflechte"),
            ],
          ),
    ];

    for (var i = 0; i < recipeCards.length; i++) {
      var itemcard = recipeCards[i];
      testConfigurations(
        disableLocals: false,
        widgetName: 'CustomRecipeCard$i',
        pathPrefix: "../",
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => Builder(builder: (context) {
          return itemcard();
        }),
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: Center(
                  child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [widgetToTest],
                ),
              )),
            ),
          ),
        ]),
      );
    }
  });
}
