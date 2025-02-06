import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/border_corner_stone_round.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/card_border.dart';
import 'package:quest_keeper/components/quarter_circle_cutout.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';

class CustomRecipeCardItemPair {
  final int amount;
  final String itemName;

  CustomRecipeCardItemPair({required this.amount, required this.itemName});
}

class CustomRecipeCard extends StatelessWidget {
  final String? imageUrl;
  final String title;

  final List<CustomRecipeCardItemPair> requirements;
  final List<CustomRecipeCardItemPair> ingedients;
  final Color? cardBgColorOverride;

  const CustomRecipeCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.requirements,
    required this.ingedients,
    this.cardBgColorOverride,
  });

  @override
  Widget build(BuildContext context) {
    var fullImageUrl = imageUrl == null
        ? null
        : (imageUrl!.startsWith("assets")
            ? imageUrl
            : (apiBaseUrl +
                (imageUrl!.startsWith("/")
                    ? (imageUrl!.length > 1 ? imageUrl!.substring(1) : '')
                    : imageUrl!)));
    var backgroundColor = cardBgColorOverride ?? darkColor;
    var lightColor = bgColor;
    var borderSize = 3.5;

    return Builder(builder: (context) {
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
                  child: RecipeCardBorders(
                      lightColor: lightColor,
                      borderSize: borderSize,
                      backgroundColor: backgroundColor,
                      child: Container(
                        color: backgroundColor,
                        child: Column(
                          children: [
                            // TITLE
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: CardBorder(
                                borderRadius: 5,
                                color: lightColor,
                                borderSize: 3,
                                child: CardBorder(
                                  borderRadius: 4,
                                  color: backgroundColor,
                                  borderSize: 2,
                                  child: CardBorder(
                                    borderRadius: 2,
                                    color: lightColor,
                                    borderSize: 2,
                                    child: SizedBox(
                                      height: 32,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: AutoSizeText(
                                                softWrap: true,
                                                textAlign: TextAlign.center,
                                                title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium!
                                                    .copyWith(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: darkColor),
                                                minFontSize: 10,
                                                maxFontSize: 24,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // IMAGE
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: BorderedImage(
                                lightColor: lightColor,
                                backgroundColor: backgroundColor,
                                imageUrl: fullImageUrl,
                                isLoading: false,
                              ),
                            ),

                            // Text
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: CardBorder(
                                  borderRadius: 5,
                                  color: lightColor,
                                  borderSize: 3,
                                  child: CardBorder(
                                    borderRadius: 4,
                                    color: backgroundColor,
                                    borderSize: 2,
                                    child: CardBorder(
                                      borderRadius: 2,
                                      color: lightColor,
                                      borderSize: 2,
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: AutoSizeText(
                                                  getMarkdownText(context).$1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium!
                                                      .copyWith(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: darkColor),
                                                  minFontSize: 10,
                                                  maxFontSize: 16,
                                                  textAlign: TextAlign.left,
                                                  maxLines: getMarkdownText(
                                                                  context)
                                                              .$2 ==
                                                          true
                                                      ? 7
                                                      : '\n'
                                                              .allMatches(
                                                                  getMarkdownText(
                                                                          context)
                                                                      .$1)
                                                              .length +
                                                          1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  (String, bool) getMarkdownText(BuildContext context, {bool? denseText}) {
    var result = "";
    var requirementsAsText =
        requirements.map((t) => "${t.amount}x ${t.itemName}").join(", ");

    var ingredientsAsText = ingedients
        .map(
            (t) => "${denseText == true ? "" : "- "}${t.amount}x ${t.itemName}")
        .join(denseText == true ? ", " : "\n");
    result +=
        "${S.of(context).itemCardDescRequires} ${requirements.isEmpty ? "-" : requirementsAsText}";
    result += denseText == true ? ", " : "\n";
    result +=
        "${S.of(context).recipeIngredients}${denseText == true ? " " : "\n"}${ingedients.isEmpty ? "-" : ingredientsAsText}";

    var numberOfLines = '\n'.allMatches(result).length + 1;
    if (numberOfLines > 7 && denseText != true) {
      return getMarkdownText(context, denseText: true);
    }

    return (result, denseText == true);
  }
}

class RecipeCardBorders extends StatelessWidget {
  const RecipeCardBorders({
    super.key,
    required this.lightColor,
    required this.borderSize,
    required this.backgroundColor,
    required this.child,
  });

  final Color lightColor;
  final double borderSize;
  final Color backgroundColor;
  final Container child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        CardBorder(
          borderRadius: 4.0,
          color: lightColor,
          borderSize: borderSize,
          child: Container(),
        ),

        // child
        Padding(
          padding: EdgeInsets.all(borderSize),
          child: Container(
            color: backgroundColor,
            padding: EdgeInsets.all(2),
            child: child,
          ),
        ),

        // top left
        Positioned(
          top: -20,
          left: -20,
          width: 37.5,
          height: 37.5,
          child: QuarterCircleCutout(
              circleOuterDiameter: 10.0,
              circleDegrees: 180,
              circleColor: lightColor,
              circleInnerDiameter: 5.0,
              circleInnerColor: lightColor),
        ),
        Positioned(
          top: -25,
          left: -25,
          width: 40,
          height: 40,
          child: QuarterCircleCutout(
            circleOuterDiameter: 10.0,
            circleDegrees: 180,
            circleColor: backgroundColor,
            circleInnerDiameter: 5.0,
            circleInnerColor: backgroundColor,
          ),
        ),

        BorderCornerStoneRound(
          lightColor: lightColor,
          alignment: Alignment.topLeft,
          scalar: 1.0,
          backgroundColor: backgroundColor,
        ),

        // top right
        Positioned(
          top: -20,
          right: -20,
          width: 37.5,
          height: 37.5,
          child: QuarterCircleCutout(
              circleOuterDiameter: 10.0,
              circleDegrees: 270,
              circleColor: lightColor,
              circleInnerDiameter: 5.0,
              circleInnerColor: lightColor),
        ),
        Positioned(
          top: -25,
          right: -25,
          width: 40,
          height: 40,
          child: QuarterCircleCutout(
            circleOuterDiameter: 10.0,
            circleDegrees: 270,
            circleColor: backgroundColor,
            circleInnerDiameter: 5.0,
            circleInnerColor: backgroundColor,
          ),
        ),

        BorderCornerStoneRound(
          lightColor: lightColor,
          alignment: Alignment.topRight,
          scalar: 1.0,
          backgroundColor: backgroundColor,
        ),

        // bottom right
        Positioned(
          bottom: -20,
          right: -20,
          width: 37.5,
          height: 37.5,
          child: QuarterCircleCutout(
              circleOuterDiameter: 10.0,
              circleDegrees: 0,
              circleColor: lightColor,
              circleInnerDiameter: 5.0,
              circleInnerColor: lightColor),
        ),
        Positioned(
          bottom: -25,
          right: -25,
          width: 40,
          height: 40,
          child: QuarterCircleCutout(
            circleOuterDiameter: 10.0,
            circleDegrees: 0,
            circleColor: backgroundColor,
            circleInnerDiameter: 5.0,
            circleInnerColor: backgroundColor,
          ),
        ),

        BorderCornerStoneRound(
          lightColor: lightColor,
          alignment: Alignment.bottomRight,
          scalar: 1.0,
          backgroundColor: backgroundColor,
        ),

        // bottom left
        Positioned(
          bottom: -20,
          left: -20,
          width: 37.5,
          height: 37.5,
          child: QuarterCircleCutout(
              circleOuterDiameter: 10.0,
              circleDegrees: 90,
              circleColor: lightColor,
              circleInnerDiameter: 5.0,
              circleInnerColor: lightColor),
        ),
        Positioned(
          bottom: -25,
          left: -25,
          width: 40,
          height: 40,
          child: QuarterCircleCutout(
            circleOuterDiameter: 10.0,
            circleDegrees: 90,
            circleColor: backgroundColor,
            circleInnerDiameter: 5.0,
            circleInnerColor: backgroundColor,
          ),
        ),

        BorderCornerStoneRound(
          lightColor: lightColor,
          alignment: Alignment.bottomLeft,
          scalar: 1.0,
          backgroundColor: backgroundColor,
        ),
      ],
    );
  }
}
