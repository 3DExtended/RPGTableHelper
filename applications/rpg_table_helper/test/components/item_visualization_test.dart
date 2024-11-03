import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/components/item_visualization.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';

import '../test_configuration.dart';

void main() {
  group('ItemVisualization rendering', () {
    var baseItem = RpgItem(
        imageDescription: null,
        imageUuid: null,
        uuid: "864c10b9-a6d7-4cbb-862f-c35d51459546",
        name: "Schaufel",
        patchSize: null,
        categoryId: "Asdf",
        description:
            "Ich bin eine lange Beschreibung.\nIch bin eine lange Beschreibung.\n",
        baseCurrencyPrice: 12345,
        placeOfFindings: []);

    var itemRendersToTest = [
      ItemVisualization(
        craftItem: () {},
        itemToRender: baseItem,
        renderRecipeRelatedThings: false,
        itemNameSuffix: null,
        numberOfCreateableInstances: null,
        numberOfItemsInInventory: 3,
        useItem: () {},
      ),
      ItemVisualization(
        craftItem: () {},
        itemToRender: baseItem.copyWith(name: "Ich bin ein langer Itemname"),
        renderRecipeRelatedThings: false,
        itemNameSuffix: null,
        numberOfCreateableInstances: null,
        numberOfItemsInInventory: 3,
        useItem: () {},
      ),
      ItemVisualization(
        craftItem: () {},
        itemToRender: baseItem,
        renderRecipeRelatedThings: true,
        itemNameSuffix: null,
        numberOfCreateableInstances: 345,
        numberOfItemsInInventory: 3,
        useItem: () {},
      ),
      ItemVisualization(
        craftItem: () {},
        itemToRender: baseItem,
        renderRecipeRelatedThings: false,
        itemNameSuffix: "(23x)",
        numberOfCreateableInstances: null,
        numberOfItemsInInventory: 3,
        useItem: () {},
      ),
      ItemVisualization(
        craftItem: () {},
        itemToRender: baseItem,
        renderRecipeRelatedThings: true,
        itemNameSuffix: "(23x)",
        numberOfCreateableInstances: 345,
        numberOfItemsInInventory: 3,
        useItem: () {},
      ),
    ];

    for (var i = 0; i < itemRendersToTest.length; i++) {
      var button = itemRendersToTest[i];
      testConfigurations(
        disableLocals: true,
        widgetName: 'ItemVisualization$i',
        useMaterialAppWrapper: true,
        screenFactory: (Locale locale) => button,
        getTestConfigurations: (Widget widgetToTest) => Map.fromEntries([
          MapEntry(
            'default',
            DependencyProvider.getMockedDependecyProvider(
              child: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: widgetToTest,
                ),
              ),
            ),
          ),
          MapEntry(
            'expanded',
            DependencyProvider.getMockedDependecyProvider(
              child: Center(
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: widgetToTest,
                ),
              ),
            ),
          ),
        ]),
      );
    }
  });
}
