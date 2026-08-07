import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:quest_keeper/components/border_corner_stone.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/card_border.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/night_cartographer_ornaments.dart';
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

  /// When set (Ledger inventory), amount is drawn inside the plate footer.
  final String? amountText;

  /// Plate body line budget (recipes pass a higher value for requires/ingredients).
  final int descriptionMaxLines;

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
    this.amountText,
    this.descriptionMaxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (isDecoratedSheetSkinActive(context)) {
      return _buildLedgerPlate(context);
    }
    return _buildClassicCard(context);
  }

  Widget _buildLedgerPlate(BuildContext context) {
    final ink = CustomThemeProvider.of(context).theme.darkTextColor;
    final scalar = scalarOverride ?? 1.0;
    final cartographer = isNightCartographerActive(context);
    final fullImageUrl = imageUrl == null
        ? null
        : (imageUrl!.startsWith("assets")
            ? imageUrl
            : (apiBaseUrl +
                (imageUrl!.startsWith("/")
                    ? (imageUrl!.length > 1 ? imageUrl!.substring(1) : '')
                    : imageUrl!)));
    final icon = getIconForIdentifier(
      name: categoryIconName ?? "flask-laboratory-svgrepo-com",
      color: categoryIconColor ?? ink,
      size: 18 * scalar,
    ).$2;

    Widget corner({required Alignment alignment, required int turns}) {
      final size = 28 * scalar;
      if (cartographer) {
        return Align(
          alignment: alignment,
          child: Padding(
            padding: EdgeInsets.all(6 * scalar),
            child: CartographerCornerBracket(
              size: size,
              color: ink,
              opacity: 0.7,
              quarterTurns: turns,
            ),
          ),
        );
      }
      return Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(6 * scalar),
          child: Opacity(
            opacity: 0.55,
            child: RotatedBox(
              quarterTurns: turns,
              child: Image.asset(
                ArcaneLedgerAssets.cornerFlourish,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 400 * scalar,
      width: 260 * scalar,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        child: CustomPaint(
          painter: _LedgerItemPlatePainter(
            ink: ink,
            fill: cardBgColorOverride,
          ),
          child: Stack(
            children: [
              corner(alignment: Alignment.topLeft, turns: 0),
              corner(alignment: Alignment.topRight, turns: 1),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    14 * scalar, 16 * scalar, 14 * scalar, 12 * scalar),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28 * scalar,
                          height: 28 * scalar,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: ink.withValues(alpha: 0.7)),
                          ),
                          alignment: Alignment.center,
                          child: icon,
                        ),
                        SizedBox(width: 8 * scalar),
                        Expanded(
                          child: AutoSizeText(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            minFontSize: 11,
                            maxFontSize: 20,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: ink,
                                  fontFamily: 'Ruwudu',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                          ),
                        ),
                        SizedBox(width: 28 * scalar),
                      ],
                    ),
                    SizedBox(height: 10 * scalar),
                    Expanded(
                      flex: 5,
                      child: BorderedImage(
                        lightColor: ink,
                        backgroundColor:
                            cardBgColorOverride ?? Colors.transparent,
                        imageUrl: fullImageUrl,
                        isLoading: isLoading,
                        isGreyscale: true,
                        noPadding: true,
                      ),
                    ),
                    SizedBox(height: 8 * scalar),
                    Expanded(
                      flex: 3,
                      child: AutoSizeText(
                        description,
                        textAlign: TextAlign.center,
                        maxLines: descriptionMaxLines,
                        minFontSize: 10,
                        maxFontSize: 13,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: ink,
                              fontFamily: 'Ruwudu',
                              fontSize: 12,
                              height: 1.25,
                            ),
                      ),
                    ),
                    if (amountText != null) ...[
                      SizedBox(height: 6 * scalar),
                      CustomPaint(
                        painter: _LedgerMiniStarRulePainter(ink: ink),
                        child: SizedBox(
                            width: double.infinity, height: 14 * scalar),
                      ),
                      SizedBox(height: 4 * scalar),
                      Text(
                        amountText!,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: ink,
                                  fontFamily: 'Ruwudu',
                                  fontSize: 14,
                                ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassicCard(BuildContext context) {
    var fullImageUrl = imageUrl == null
        ? null
        : (imageUrl!.startsWith("assets")
            ? imageUrl
            : (apiBaseUrl +
                (imageUrl!.startsWith("/")
                    ? (imageUrl!.length > 1 ? imageUrl!.substring(1) : '')
                    : imageUrl!)));

    var backgroundColor = cardBgColorOverride ??
        (CustomThemeProvider.of(context).brightnessNotifier.value ==
                Brightness.light
            ? CustomThemeProvider.of(context).theme.darkColor
            : CustomThemeProvider.of(context).theme.bgColor);
    var lightColor = CustomThemeProvider.of(context).brightnessNotifier.value ==
            Brightness.light
        ? CustomThemeProvider.of(context).theme.bgColor
        : CustomThemeProvider.of(context).theme.darkColor;

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
                                                          color: CustomThemeProvider.of(
                                                                          context)
                                                                      .brightnessNotifier
                                                                      .value ==
                                                                  Brightness
                                                                      .light
                                                              ? CustomThemeProvider
                                                                      .of(
                                                                          context)
                                                                  .theme
                                                                  .darkColor
                                                              : CustomThemeProvider
                                                                      .of(context)
                                                                  .theme
                                                                  .bgColor),
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

class _LedgerItemPlatePainter extends CustomPainter {
  final Color ink;
  final Color? fill;

  _LedgerItemPlatePainter({required this.ink, this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 3.0;
    final outerR = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
      const Radius.circular(2),
    );
    if (fill != null) {
      canvas.drawRRect(outerR, Paint()..color = fill!);
    }
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final inner = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(outerR, outer);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          inset + 3.5,
          inset + 3.5,
          size.width - (inset + 3.5) * 2,
          size.height - (inset + 3.5) * 2,
        ),
        const Radius.circular(1.5),
      ),
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerItemPlatePainter oldDelegate) =>
      oldDelegate.ink != ink || oldDelegate.fill != fill;
}

class _LedgerMiniStarRulePainter extends CustomPainter {
  final Color ink;

  _LedgerMiniStarRulePainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    final midY = size.height / 2;
    canvas.drawLine(Offset(8, midY), Offset(size.width / 2 - 10, midY), paint);
    canvas.drawLine(
        Offset(size.width / 2 + 10, midY), Offset(size.width - 8, midY), paint);
    final c = Offset(size.width / 2, midY);
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = -3.14159265 / 2 + i * 3.14159265 / 4;
      final radius = i.isEven ? 3.5 : 1.4;
      final p = Offset(c.dx + cos(angle) * radius, c.dy + sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = ink.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _LedgerMiniStarRulePainter oldDelegate) =>
      oldDelegate.ink != ink;
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
                                                .brightnessNotifier
                                                .value ==
                                            Brightness.light
                                        ? CustomThemeProvider.of(context)
                                            .theme
                                            .darkColor
                                        : CustomThemeProvider.of(context)
                                            .theme
                                            .bgColor),
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
