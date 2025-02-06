import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:quest_keeper/components/card_border.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:themed/themed.dart';
import 'package:transparent_image/transparent_image.dart';

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
