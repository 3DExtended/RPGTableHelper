import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:transparent_image/transparent_image.dart';

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
        : (apiBaseUrl +
            (imageUrl!.startsWith("/") ? imageUrl!.substring(1) : imageUrl!));
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
                                                child: Text(
                                                  description,
                                                  softWrap: false,
                                                  maxLines: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium!
                                                      .copyWith(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: darkColor),
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
                child: Padding(
              padding: EdgeInsets.fromLTRB(15 * scalar, 0, 8 * scalar, 0),
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
                    borderSize: 10 * scalar,
                    color: lightColor,
                    child: Padding(
                      padding: EdgeInsets.only(left: 24.0 * scalar),
                      child: Container(
                        color: lightColor,
                        height: 8 * scalar,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            softWrap: false,
                            maxLines: 2,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    fontSize: 32,
                                    height: 0.7,
                                    fontWeight: FontWeight.bold,
                                    color: darkColor),
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
                      ),
                    ),
                  if (!Platform.environment.containsKey('FLUTTER_TEST') &&
                      isLoadingNewImage == true)
                    const Center(
                        child:
                            CircularProgressIndicator()), // TODO use yourshelf loading spinner...
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
        GetBorderCornerStone(
            alignment: Alignment.topLeft,
            scalar: scalar,
            backgroundColor: backgroundColor),
        GetBorderCornerStone(
            alignment: Alignment.topRight,
            scalar: scalar,
            backgroundColor: backgroundColor),
        GetBorderCornerStone(
            alignment: Alignment.bottomLeft,
            scalar: scalar,
            backgroundColor: backgroundColor),
        GetBorderCornerStone(
            alignment: Alignment.bottomRight,
            scalar: scalar,
            backgroundColor: backgroundColor),

        // TODO discuss with marie if good
        // GetBorderCornerStone(
        //     alignment: Alignment.centerLeft,
        //     scalar: scalar,
        //     backgroundColor: backgroundColor),
        // GetBorderCornerStone(
        //     alignment: Alignment.centerRight,
        //     scalar: scalar,
        //     backgroundColor: backgroundColor),

        Padding(padding: EdgeInsets.all(borderSize * scalar), child: child),
      ],
    );
  }
}

class GetBorderCornerStone extends StatelessWidget {
  const GetBorderCornerStone({
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
      padding: const EdgeInsets.all(1.0),
      child: Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(alignment.x * 7 * scalar, alignment.y * 7 * scalar),
          child: Transform.rotate(
            angle: 0.785398163,
            child: Container(
              width: 25 * scalar,
              height: 25 * scalar,
              padding: EdgeInsets.all(5),
              child: Container(color: backgroundColor),
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
