import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:transparent_image/transparent_image.dart';

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
                    ? imageUrl!.substring(1)
                    : imageUrl!)));
    var backgroundColor = cardBgColorOverride ?? darkColor;
    var lightColor = bgColor;
    var borderSize = 3.5;

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
                child: Container(
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
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: AutoSizeText(
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                              title ?? "Empty title",
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

                            // IMAGE
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: ImageBorders(
                                lightColor: lightColor,
                                backgroundColor: backgroundColor,
                                imageUrl: fullImageUrl,
                                isLoadingNewImage: false,
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
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: AutoSizeText(
                                                  getMarkdownText().$1,
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
                                                  maxLines: getMarkdownText()
                                                              .$2 ==
                                                          true
                                                      ? 7
                                                      : '\n'
                                                              .allMatches(
                                                                  getMarkdownText()
                                                                      .$1)
                                                              .length +
                                                          1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )
                                          // Row(
                                          //   children: [
                                          //     Expanded(
                                          //       child: Column(
                                          //         children: [
                                          //           Expanded(
                                          //             child: AutoSizeText(
                                          //                 "- Voraussetzungen:\n- Voraussetzungen:\n- Voraussetzungen:\n- Voraussetzungen:"),
                                          //           ),
                                          //         ],
                                          //       ),
                                          //     ),
                                          //     Expanded(
                                          //       child: Column(
                                          //         children: [
                                          //           Expanded(
                                          //             child: AutoSizeText(
                                          //                 "- Voraussetzungen:\n- Voraussetzungen:\n- Voraussetzungen:\n- Voraussetzungen:"),
                                          //           ),
                                          //         ],
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          ),
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
      ),
    );
  }

  (String, bool) getMarkdownText({bool? denseText}) {
    var result = "";
    var requirementsAsText =
        requirements.map((t) => "${t.amount}x ${t.itemName}").join(", ");

    var ingredientsAsText = ingedients
        .map(
            (t) => "${denseText == true ? "" : "- "}${t.amount}x ${t.itemName}")
        .join(denseText == true ? ", " : "\n");
    result += "Braucht: ${requirements.isEmpty ? "-" : requirementsAsText}";
    result += denseText == true ? ", " : "\n";
    result +=
        "Zutaten:${denseText == true ? " " : "\n"}${ingedients.isEmpty ? "-" : ingredientsAsText}";

    var numberOfLines = '\n'.allMatches(result).length + 1;
    if (numberOfLines > 7 && denseText != true) {
      return getMarkdownText(denseText: true);
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
              cicleInnerColor: lightColor),
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
            cicleInnerColor: backgroundColor,
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
              cicleInnerColor: lightColor),
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
            cicleInnerColor: backgroundColor,
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
              cicleInnerColor: lightColor),
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
            cicleInnerColor: backgroundColor,
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
              cicleInnerColor: lightColor),
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
            cicleInnerColor: backgroundColor,
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

class QuarterCircleCutout extends StatelessWidget {
  const QuarterCircleCutout({
    super.key,
    required this.circleOuterDiameter,
    required this.circleDegrees,
    required this.circleColor,
    required this.circleInnerDiameter,
    required this.cicleInnerColor,
  });

  final double circleOuterDiameter;
  final int circleDegrees;
  final Color circleColor;
  final double circleInnerDiameter;
  final Color cicleInnerColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: circleOuterDiameter,
      height: circleOuterDiameter,
      child: Transform.rotate(
        angle: circleDegrees * (pi / 180),
        child: Transform.translate(
          offset:
              Offset(-circleOuterDiameter * 2.0, -circleOuterDiameter * 2.0),
          child: ClipRRect(
            child: Transform.translate(
              offset:
                  Offset(circleOuterDiameter * 2.0, circleOuterDiameter * 2.0),
              child: Container(
                width: circleOuterDiameter,
                height: circleOuterDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
                padding: EdgeInsets.all(
                    (circleOuterDiameter - circleInnerDiameter) / 2.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cicleInnerColor,
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

class CustomItemCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String description;
  final Widget? categoryIconOverride;
  final Color? cardBgColorOverride;
  final double? scalarOverride;
  final bool? isLoadingNewImage;
  const CustomItemCard({
    super.key,
    required this.title,
    required this.description,
    this.scalarOverride,
    this.isLoadingNewImage,
    this.imageUrl,
    this.cardBgColorOverride,
    this.categoryIconOverride,
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

    var icon = categoryIconOverride ??
        SvgPicture.asset(
          'assets/images/flask-laboratory-svgrepo-com.svg',
          semanticsLabel: 'My SVG Image',
        );

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
                child: InterruptedBorder(
                  scalar: scalar,
                  lightColor: lightColor,
                  backgroundColor: backgroundColor,
                  child: Container(
                    color: backgroundColor,
                    child: Column(
                      children: [
                        // title
                        CardTitleWithIcon(
                            scalar: scalar,
                            lightColor: lightColor,
                            backgroundColor: backgroundColor,
                            title: title,
                            icon: icon),

                        // image
                        ImageBorders(
                          lightColor: lightColor,
                          backgroundColor: backgroundColor,
                          imageUrl: fullImageUrl,
                          isLoadingNewImage: isLoadingNewImage,
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
                                                  description ??
                                                      "Empty description",
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

class CardTitleWithIcon extends StatelessWidget {
  const CardTitleWithIcon({
    super.key,
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
                            title ?? "Empty title",
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
        CircularBorderedIcon(
            backgroundColor: backgroundColor,
            scalar: scalar,
            lightColor: lightColor,
            icon: icon),
      ],
    );
  }
}

class CircularBorderedIcon extends StatelessWidget {
  const CircularBorderedIcon({
    super.key,
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

class ImageBorders extends StatelessWidget {
  const ImageBorders({
    super.key,
    required this.lightColor,
    required this.backgroundColor,
    required this.imageUrl,
    this.isLoadingNewImage,
  });

  final Color lightColor;
  final Color backgroundColor;
  final String? imageUrl;
  final bool? isLoadingNewImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: CardBorder(
        borderRadius: 17,
        borderSize: 1,
        color: lightColor,
        child: CardBorder(
          borderRadius: 17,
          borderSize: 4,
          color: backgroundColor,
          child: CardBorder(
            borderRadius: 15,
            borderSize: 1,
            color: lightColor,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.asset(
                    imageUrl != null && imageUrl!.startsWith("assets/")
                        ? imageUrl!
                        : "assets/images/itemcard_placeholder.png",
                    fit: BoxFit.fitWidth,
                  ),
                  if (!Platform.environment.containsKey('FLUTTER_TEST') &&
                      imageUrl != null)
                    Center(
                      child: CachedNetworkImage(
                        placeholder: (context, url) {
                          return Image.memory(
                            kTransparentImage,
                            fit: BoxFit.fitWidth,
                          );
                        },
                        imageUrl: imageUrl!,
                        fit: BoxFit.fitWidth,
                        fadeInDuration: const Duration(milliseconds: 500),
                        fadeOutDuration: const Duration(milliseconds: 500),
                      ),
                    ),
                  if (!Platform.environment.containsKey('FLUTTER_TEST') &&
                      isLoadingNewImage == true)
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        color: const Color.fromARGB(174, 40, 40, 40),
                      ),
                    ),
                  if (!Platform.environment.containsKey('FLUTTER_TEST') &&
                      isLoadingNewImage == true)
                    const Center(child: CustomLoadingSpinner()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InterruptedBorder extends StatelessWidget {
  const InterruptedBorder({
    super.key,
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

class BorderCornerStone extends StatelessWidget {
  const BorderCornerStone({
    super.key,
    required this.alignment,
    required this.scalar,
    required this.backgroundColor,
  });

  final Alignment alignment;
  final double scalar;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(alignment.x * 7 * scalar, alignment.y * 7 * scalar),
          child: Transform.rotate(
            angle: 0.785398163,
            child: Container(
              width: 25 * scalar,
              height: 25 * scalar,
              padding: EdgeInsets.all(0),
              child: Container(color: backgroundColor),
            ),
          ),
        ),
      ),
    );
  }
}

class BorderCornerStoneRound extends StatelessWidget {
  const BorderCornerStoneRound({
    super.key,
    required this.alignment,
    required this.scalar,
    required this.backgroundColor,
    required this.lightColor,
  });

  final Color lightColor;
  final Alignment alignment;
  final double scalar;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(alignment.x * 6 * scalar, alignment.y * 6 * scalar),
          child: Container(
            width: 16 * scalar,
            height: 16 * scalar,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            padding: EdgeInsets.all(0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: lightColor,
                    shape: BoxShape.circle,
                  ),
                  width: 7,
                  height: 7,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardBorder extends StatelessWidget {
  const CardBorder({
    super.key,
    required this.borderRadius,
    required this.color,
    required this.borderSize,
    required this.child,
  });

  final double borderRadius;
  final Color color;
  final double borderSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: color,
      ),
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.all(borderSize),
      child: child,
    );
  }
}
