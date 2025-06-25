import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/border_corner_stone.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/card_border.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/helpers/icons_helper.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class CustomItemCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String description;

  final Color? cardBgColorOverride;

  final double? scalarOverride;
  final bool? isLoading;
  final bool? isGreyscale;

  final String? categoryIconName;
  final Color? categoryIconColor;
  const CustomItemCard({
    super.key,
    required this.title,
    required this.description,
    this.scalarOverride,
    this.isLoading,
    this.imageUrl,
    this.cardBgColorOverride,
    this.categoryIconName,
    this.categoryIconColor,
    this.isGreyscale,
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

    var backgroundColor =
        cardBgColorOverride ?? CustomThemeProvider.of(context).theme.darkColor;
    var lightColor = CustomThemeProvider.of(context).theme.bgColor;

    var icon = getIconForIdentifier(
      name: categoryIconName ?? "flask-laboratory-svgrepo-com",
      color: categoryIconColor ?? CustomThemeProvider.of(context).theme.bgColor,
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
                child: InterruptedBorder(
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
                          isLoading: isLoading,
                          isGreyscale: isGreyscale,
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
                                                          color:
                                                              CustomThemeProvider
                                                                      .of(context)
                                                                  .theme
                                                                  .darkColor),
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
                                    color: CustomThemeProvider.of(context)
                                        .theme
                                        .darkColor),
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
        Padding(padding: EdgeInsets.all(borderSize * scalar), child: child),
      ],
    );
  }
}
