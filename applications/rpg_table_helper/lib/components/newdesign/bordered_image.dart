import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/newdesign/card_border.dart';
import 'package:transparent_image/transparent_image.dart';

class BorderedImage extends StatelessWidget {
  const BorderedImage({
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
