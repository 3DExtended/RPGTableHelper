import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/newdesign/border_corner_stone.dart';
import 'package:rpg_table_helper/components/newdesign/bordered_image.dart';
import 'package:rpg_table_helper/components/newdesign/card_border.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/helpers/icons_helper.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class CustomCharacterCard extends StatelessWidget {
  final String characterName;
  final String? imageUrl;

  final (
    CharacterStatDefinition statDef,
    RpgCharacterStatValue statValue
  )? characterStatWithMaxValueForBarVisuals;

  final List<(CharacterStatDefinition statDef, RpgCharacterStatValue statValue)>
      characterSingleNumberStats;

  final bool? greyScale;
  final bool? isLoadingNewImage;

  const CustomCharacterCard({
    super.key,
    required this.characterName,
    this.imageUrl,
    this.greyScale,
    this.isLoadingNewImage,
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
                        ? imageUrl!.substring(1)
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
                child: _InterruptedBorder(
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
                            withoutPadding: true,
                            lightColor: lightColor,
                            backgroundColor: backgroundColor,
                            imageUrl: fullImageUrl,
                            isLoadingNewImage: isLoadingNewImage,
                            greyscale: greyScale,
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

  Widget getTextForStatTuple(BuildContext context,
      (CharacterStatDefinition, RpgCharacterStatValue) statTuple) {
    assert(statTuple.$1.valueType == CharacterStatValueType.int);

    var nameOfStat = statTuple.$1.name;
    var deserializedValues = jsonDecode(statTuple.$2.serializedValue);
    var currentIntValue = int.parse(deserializedValues["value"].toString());

    return Text(
      "$nameOfStat: $currentIntValue",
      style: Theme.of(context)
          .textTheme
          .headlineMedium!
          .copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: bgColor),
    );
  }
}

class CustomItemCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String description;

  final Color? cardBgColorOverride;

  final double? scalarOverride;
  final bool? isLoadingNewImage;
  final bool? greyScale;

  final String? categoryIconName;
  final Color? categoryIconColor;
  const CustomItemCard({
    super.key,
    required this.title,
    required this.description,
    this.scalarOverride,
    this.isLoadingNewImage,
    this.imageUrl,
    this.cardBgColorOverride,
    this.categoryIconName,
    this.categoryIconColor,
    this.greyScale,
  });

  @override
  Widget build(BuildContext context) {
    var fullImageUrl = imageUrl == null
        ? null
        : (imageUrl!.startsWith("assets")
            ? imageUrl
            : (apiBaseUrl +
                (imageUrl!.startsWith("/")
                    ? imageUrl!.substring(1)
                    : imageUrl!)));

    var backgroundColor = cardBgColorOverride ?? darkColor;
    var lightColor = bgColor;

    var icon = getIconForIdentifier(
      name: categoryIconName ?? "flask-laboratory-svgrepo-com",
      color: categoryIconColor ?? bgColor,
    ).$2;

    var scalar = scalarOverride ?? 1.25;

    // First dark border
    return SizedBox(
      height: 423 * scalar,
      width: 289 * scalar,
      child: CardBorder(
        borderRadius: 15 * scalar,
        color: backgroundColor,
        borderSize: 7 * scalar,
        child: CardBorder(
          borderRadius: 11 * scalar,
          color: lightColor,
          borderSize: 1 * scalar,
          child: CardBorder(
            borderRadius: 11 * scalar,
            color: backgroundColor,
            borderSize: 6 * scalar,
            child: CardBorder(
              borderRadius: 7 * scalar,
              color: lightColor,
              borderSize: 4 * scalar,
              child: CardBorder(
                borderRadius: 4 * scalar,
                color: backgroundColor,
                borderSize: 6 * scalar,

                // This border has to be interrupted
                child: _InterruptedBorder(
                  scalar: scalar,
                  lightColor: lightColor,
                  backgroundColor: backgroundColor,
                  child: Container(
                    color: backgroundColor,
                    child: Column(
                      children: [
                        // title
                        _CardTitleWithIcon(
                          scalar: scalar,
                          lightColor: lightColor,
                          backgroundColor: backgroundColor,
                          title: title,
                          icon: icon,
                        ),

                        // image
                        BorderedImage(
                          lightColor: lightColor,
                          backgroundColor: backgroundColor,
                          imageUrl: fullImageUrl,
                          isLoadingNewImage: isLoadingNewImage,
                          greyscale: greyScale,
                        ),

                        // description
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CardBorder(
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
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: AutoSizeText(
                                                  description,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium!
                                                      .copyWith(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: darkColor),
                                                  minFontSize: 10,
                                                  maxFontSize: 12,
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ))))),
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
}

class _CardTitleWithIcon extends StatelessWidget {
  const _CardTitleWithIcon({
    required this.scalar,
    required this.lightColor,
    required this.backgroundColor,
    required this.title,
    required this.icon,
  });

  final double scalar;
  final Color lightColor;
  final Color backgroundColor;
  final String title;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Row(
          children: [
            Expanded(
                child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 50),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    15 * scalar, 4 * scalar, 8 * scalar, 4 * scalar),
                child: CardBorder(
                  borderRadius: 5 * scalar,
                  borderSize: 3 * scalar,
                  color: lightColor,
                  child: CardBorder(
                    borderRadius: 3 * scalar,
                    borderSize: 1 * scalar,
                    color: backgroundColor,
                    child: CardBorder(
                      borderRadius: 2 * scalar,
                      borderSize: 5 * scalar,
                      color: lightColor,
                      child: Padding(
                        padding: EdgeInsets.only(left: 35.0 * scalar),
                        child: Container(
                          color: lightColor,
                          child: AutoSizeText(
                            softWrap: true,
                            textAlign: TextAlign.center,
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: darkColor),
                            minFontSize: 10,
                            maxFontSize: 32,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
        _CircularBorderedIcon(
            backgroundColor: backgroundColor,
            scalar: scalar,
            lightColor: lightColor,
            icon: icon),
      ],
    );
  }
}

class _CircularBorderedIcon extends StatelessWidget {
  const _CircularBorderedIcon({
    required this.backgroundColor,
    required this.scalar,
    required this.lightColor,
    required this.icon,
  });

  final Color backgroundColor;
  final double scalar;
  final Color lightColor;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      height: 55 * scalar,
      width: 55 * scalar,
      padding: EdgeInsets.all(4 * scalar),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: lightColor,
        ),
        padding: EdgeInsets.all(2 * scalar),
        child: Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
          padding: EdgeInsets.all(7 * scalar),
          child: Container(
            child: icon,
          ),
        ),
      ),
    );
  }
}

class _InterruptedBorder extends StatelessWidget {
  const _InterruptedBorder({
    required this.scalar,
    required this.lightColor,
    required this.child,
    required this.backgroundColor,
  });

  final double scalar;
  final Color lightColor;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    var borderSize = 3.5;
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        CardBorder(
          borderRadius: 4.0 * scalar,
          color: lightColor,
          borderSize: borderSize * scalar,
          child: Container(),
        ),
        BorderCornerStone(
            alignment: Alignment.topLeft,
            scalar: scalar,
            backgroundColor: backgroundColor),
        BorderCornerStone(
            alignment: Alignment.topRight,
            scalar: scalar,
            backgroundColor: backgroundColor),
        BorderCornerStone(
            alignment: Alignment.bottomLeft,
            scalar: scalar,
            backgroundColor: backgroundColor),
        BorderCornerStone(
            alignment: Alignment.bottomRight,
            scalar: scalar,
            backgroundColor: backgroundColor),

        // TODO discuss with marie if good
        // BorderCornerStone(
        //     alignment: Alignment.centerLeft,
        //     scalar: scalar,
        //     backgroundColor: backgroundColor),
        // BorderCornerStone(
        //     alignment: Alignment.centerRight,
        //     scalar: scalar,
        //     backgroundColor: backgroundColor),

        Padding(padding: EdgeInsets.all(borderSize * scalar), child: child),
      ],
    );
  }
}
