import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/bordered_image.dart';
import 'package:rpg_table_helper/components/card_border.dart';
import 'package:rpg_table_helper/components/custom_item_card.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class CustomCharacterCard extends StatelessWidget {
  final String characterName;
  final String? imageUrl;

  final (
    CharacterStatDefinition statDef,
    RpgCharacterStatValue statValue
  )? characterStatWithMaxValueForBarVisuals;

  final List<({String label, int value})> characterSingleNumberStats;

  final bool? isGreyscale;
  final bool? isLoading;

  const CustomCharacterCard({
    super.key,
    required this.characterName,
    this.imageUrl,
    this.isGreyscale,
    this.isLoading,
    this.characterStatWithMaxValueForBarVisuals,
    required this.characterSingleNumberStats,
  });

  @override
  Widget build(BuildContext context) {
    var fullImageUrl = imageUrl == null
        ? "assets/images/charactercard_placeholder.png"
        : (imageUrl!.startsWith("assets")
                ? imageUrl
                : (apiBaseUrl +
                    (imageUrl!.startsWith("/")
                        ? (imageUrl!.length > 1 ? imageUrl!.substring(1) : '')
                        : imageUrl!))) ??
            "assets/images/charactercard_placeholder.png";

    var backgroundColor = darkColor;
    var lightColor = bgColor;

    return SizedBox(
      height: 423,
      width: 289,
      child: CardBorder(
        borderRadius: 15,
        color: backgroundColor,
        borderSize: 7,
        child: CardBorder(
          borderRadius: 11,
          color: lightColor,
          borderSize: 1,
          child: CardBorder(
            borderRadius: 11,
            color: backgroundColor,
            borderSize: 6,
            child: CardBorder(
              borderRadius: 7,
              color: lightColor,
              borderSize: 4,
              child: CardBorder(
                borderRadius: 4,
                color: backgroundColor,
                borderSize: 6,

                // This border has to be interrupted
                child: InterruptedBorder(
                  scalar: 1,
                  lightColor: lightColor,
                  backgroundColor: backgroundColor,
                  child: Container(
                    color: backgroundColor,
                    child: Column(
                      children: [
                        // image
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 10),
                          child: BorderedImage(
                            noPadding: true,
                            lightColor: lightColor,
                            backgroundColor: backgroundColor,
                            imageUrl: fullImageUrl,
                            isLoading: isLoading,
                            isGreyscale: isGreyscale,
                          ),
                        ),

                        // TODO TITLE
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CardBorder(
                              borderRadius: 7,
                              color: lightColor,
                              borderSize: 4,
                              child: CardBorder(
                                borderRadius: 5,
                                color: backgroundColor,
                                borderSize: 1,
                                child: CardBorder(
                                  borderRadius: 4,
                                  color: lightColor,
                                  borderSize: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: AutoSizeText(
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      characterName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: darkColor),
                                      minFontSize: 10,
                                      maxFontSize: 16,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 10.0),
                            child: Column(
                              children: [
                                if (characterStatWithMaxValueForBarVisuals !=
                                    null)
                                  renderProgressBarForStat(context,
                                      characterStatWithMaxValueForBarVisuals!),
                                if (characterStatWithMaxValueForBarVisuals !=
                                    null)
                                  SizedBox(
                                    height: 10,
                                  ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          alignment: WrapAlignment.spaceAround,
                                          children: characterSingleNumberStats
                                              .map((statTuple) =>
                                                  getTextForStatTuple(
                                                      context, statTuple))
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget renderProgressBarForStat(
      BuildContext context,
      (
        CharacterStatDefinition,
        RpgCharacterStatValue
      ) characterStatWithMaxValueForBarVisuals) {
    assert(characterStatWithMaxValueForBarVisuals.$1.valueType ==
        CharacterStatValueType.intWithMaxValue);
    var nameOfStat = characterStatWithMaxValueForBarVisuals.$1.name;
    var deserializedValues =
        jsonDecode(characterStatWithMaxValueForBarVisuals.$2.serializedValue);
    var currentIntValue = int.parse(deserializedValues["value"].toString());
    var maxIntValue = int.parse(deserializedValues["maxValue"].toString());
    if (maxIntValue == 0) {
      maxIntValue = 1;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$nameOfStat: $currentIntValue/$maxIntValue",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: 12, fontWeight: FontWeight.bold, color: bgColor),
        ),
        SizedBox(
          height: 4,
        ),
        CardBorder(
            borderRadius: 2,
            borderSize: 2,
            color: bgColor,
            child: LayoutBuilder(builder: (context, contraints) {
              var maxSize = contraints.maxWidth;
              var sizeBasedOnCurrentIntValue = maxSize *
                  (currentIntValue.toDouble() / maxIntValue.toDouble());
              return CardBorder(
                borderRadius: 1,
                borderSize: 0,
                color: darkColor,
                child: Row(
                  children: [
                    Container(
                      width: sizeBasedOnCurrentIntValue,
                      height: 10,
                      color: bgColor,
                    ),
                  ],
                ),
              );
            })),
      ],
    );
  }

  Widget getTextForStatTuple(
      BuildContext context, ({String label, int value}) statTuple) {
    var nameOfStat = statTuple.label;
    var currentIntValue = statTuple.value;

    return Text(
      "$nameOfStat: $currentIntValue",
      style: Theme.of(context)
          .textTheme
          .headlineMedium!
          .copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: bgColor),
    );
  }
}
