import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:quest_keeper/components/card_border.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:themed/themed.dart';
import 'package:transparent_image/transparent_image.dart';

List<Widget> _ledgerCornerFlourishOverlays() {
  const size = 48.0;
  Widget flourish({required double? left, required double? top, required double? right, required double? bottom, required int turns}) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: RotatedBox(
        quarterTurns: turns,
        child: Opacity(
          opacity: 0.78,
          child: Image.asset(
            ArcaneLedgerAssets.cornerFlourish,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  return [
    flourish(left: -6, top: -6, right: null, bottom: null, turns: 0),
    flourish(left: null, top: -6, right: -6, bottom: null, turns: 1),
    flourish(left: null, top: null, right: -6, bottom: -6, turns: 2),
    flourish(left: -6, top: null, right: null, bottom: -6, turns: 3),
  ];
}
class BorderedImage extends StatelessWidget {
  const BorderedImage({
    super.key,
    required this.lightColor,
    required this.backgroundColor,
    required this.imageUrl,
    this.isLoading,
    this.noPadding,
    this.isGreyscale,
    this.hideLoadingImage,
    this.isClickableForZoom,
    this.aspectRatio = 1.0,
  });

  final Color lightColor;
  final Color backgroundColor;
  final String? imageUrl;
  final bool? isLoading;
  final bool? noPadding;
  final bool? hideLoadingImage;
  final bool? isClickableForZoom;

  final bool? isGreyscale;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    if (isArcaneLedgerActive(context)) {
      return Padding(
        padding: noPadding == true
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              painter: _LedgerPortraitFramePainter(ink: lightColor),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: CustomImage(
                    aspectRatio: aspectRatio,
                    isGreyscale: isGreyscale,
                    imageUrl: imageUrl,
                    hideLoadingImage: hideLoadingImage,
                    isClickableForZoom: isClickableForZoom,
                    isLoading: isLoading,
                  ),
                ),
              ),
            ),
            // Corner flourish plates (mock ornament).
            ..._ledgerCornerFlourishOverlays(),
          ],
        ),
      );
    }

    return Padding(
      padding: noPadding == true
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
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
              child: CustomImage(
                  aspectRatio: aspectRatio,
                  isGreyscale: isGreyscale,
                  imageUrl: imageUrl,
                  hideLoadingImage: hideLoadingImage,
                  isClickableForZoom: isClickableForZoom,
                  isLoading: isLoading),
            ),
          ),
        ),
      ),
    );
  }
}

class _LedgerPortraitFramePainter extends CustomPainter {
  final Color ink;

  _LedgerPortraitFramePainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = ink.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final inner = Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const inset = 2.0;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
      const Radius.circular(2),
    );
    canvas.drawRRect(r, outer);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          inset + 4,
          inset + 4,
          size.width - (inset + 4) * 2,
          size.height - (inset + 4) * 2,
        ),
        const Radius.circular(2),
      ),
      inner,
    );

    // Corner flourishes (double L-marks matching mock ornament weight).
    final f = Paint()
      ..color = ink.withValues(alpha: 0.6)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 16.0;
    void corner(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * len, y), f);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * len), f);
      canvas.drawLine(
          Offset(x + dx * 3, y + dy * 3), Offset(x + dx * (len - 2), y + dy * 3), f);
      canvas.drawLine(
          Offset(x + dx * 3, y + dy * 3), Offset(x + dx * 3, y + dy * (len - 2)), f);
    }

    corner(inset + 2, inset + 2, 1, 1);
    corner(size.width - inset - 2, inset + 2, -1, 1);
    corner(inset + 2, size.height - inset - 2, 1, -1);
    corner(size.width - inset - 2, size.height - inset - 2, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _LedgerPortraitFramePainter oldDelegate) =>
      oldDelegate.ink != ink;
}

class CustomImage extends StatelessWidget {
  const CustomImage({
    super.key,
    required this.isGreyscale,
    required this.imageUrl,
    required this.isLoading,
    this.aspectRatio,
    this.isClickableForZoom,
    this.hideLoadingImage,
  });

  final bool? hideLoadingImage;
  final bool? isGreyscale;
  final bool? isClickableForZoom;
  final String? imageUrl;
  final bool? isLoading;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        if (hideLoadingImage != true)
          ChangeColors(
            saturation: isGreyscale == true ? -1 : 0,
            child: ConditionalWidgetWrapper(
              condition: aspectRatio != null,
              wrapper: (context, child) => AspectRatio(
                aspectRatio: aspectRatio!,
                child: child,
              ),
              child: Image.asset(
                imageUrl != null && imageUrl!.startsWith("assets/")
                    ? imageUrl!
                    : "assets/images/itemcard_placeholder.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        if (!isInTestEnvironment &&
            imageUrl != null &&
            !imageUrl!.startsWith("assets/"))
          Center(
            child: ChangeColors(
              saturation: isGreyscale == true ? -1 : 0,
              child: ConditionalWidgetWrapper(
                condition: aspectRatio != null,
                wrapper: (context, child) => AspectRatio(
                  aspectRatio: aspectRatio!,
                  child: child,
                ),
                child: ConditionalWidgetWrapper(
                  condition: isClickableForZoom == true,
                  wrapper: (context, child) {
                    return CupertinoButton(
                        minSize: 0,
                        padding: EdgeInsets.zero,
                        pressedOpacity: 1,
                        child: child,
                        onPressed: () {
                          showImageViewer(
                              context,
                              swipeDismissible: true,
                              useSafeArea: true,
                              doubleTapZoomable: true,
                              // barrierColor: Colors.black12,
                              CachedNetworkImageProvider(
                                imageUrl!,
                                cacheManager: CacheManager(Config(
                                  "rpgborderedimage",
                                  stalePeriod: const Duration(
                                      days: 30), // images dont change, urls to
                                )),
                              ),
                              onViewerDismissed: () {});
                        });
                  },
                  child: CachedNetworkImage(
                    placeholder: (context, url) {
                      return Image.memory(
                        kTransparentImage,
                        fit: BoxFit.cover,
                      );
                    },
                    imageUrl: imageUrl!,
                    cacheManager: CacheManager(Config(
                      "rpgborderedimage",
                      stalePeriod: const Duration(
                          days: 30), // images dont change, urls to
                    )),
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 500),
                    fadeOutDuration: const Duration(milliseconds: 500),
                  ),
                ),
              ),
            ),
          ),
        if (!isInTestEnvironment && isLoading == true)
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: const Color.fromARGB(174, 40, 40, 40),
            ),
          ),
        if (!isInTestEnvironment && isLoading == true)
          const Center(child: CustomLoadingSpinner()),
      ],
    );
  }
}
