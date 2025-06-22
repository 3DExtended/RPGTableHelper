import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_grid_list_view.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/image_generation_service.dart';

class GeneratedImagesScreen extends ConsumerStatefulWidget {
  static String route = "generatedimages";

  const GeneratedImagesScreen({super.key});

  @override
  ConsumerState<GeneratedImagesScreen> createState() =>
      _GeneratedImagesScreenState();
}

class _GeneratedImagesScreenState extends ConsumerState<GeneratedImagesScreen> {
  final Duration duration = Duration(milliseconds: 150);

  bool isLoading = true;

  List<ImageMetaData> imagesInCampagne = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await _reloadAllPages();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: [
          Center(
            child: CustomLoadingSpinner(),
          )
        ],
      );
    }

    if (imagesInCampagne.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  S.of(context).noImagesInCampagne,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: darkColor, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 3),
      child: CustomGridListView(
          itemCount: imagesInCampagne.length,
          numberOfColumns: (MediaQuery.of(context).size.width / 300).ceil(),
          horizontalSpacing: 20,
          verticalSpacing: 20,
          itemBuilder: (context, index) {
            var image = imagesInCampagne[index];
            return _getRenderingForImageBlock(
                pubicImageUrl: getPublicImageUrl(image) ?? '');
          }),
    );
  }

  Widget _getRenderingForImageBlock({required String pubicImageUrl}) {
    return LayoutBuilder(builder: (context, constraints) {
      var imageUrl = pubicImageUrl as String?;
      var fullImageUrl = imageUrl == null
          ? "assets/images/charactercard_placeholder.png"
          : (imageUrl.startsWith("assets")
              ? imageUrl
              : (apiBaseUrl +
                  (imageUrl.startsWith("/")
                      ? (imageUrl.length > 1 ? imageUrl.substring(1) : '')
                      : imageUrl)));

      return Container(
        padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
              child: BorderedImage(
                backgroundColor: bgColor,
                lightColor: darkColor,
                hideLoadingImage: true,
                isGreyscale: false,
                isClickableForZoom: true,
                isLoading: false,
                imageUrl: fullImageUrl,
                aspectRatio: null,
              ),
            ),
          ],
        ),
      );
    });
  }

  Future _reloadAllPages() async {
    var campagneId =
        ref.read(connectionDetailsProvider).valueOrNull?.campagneId;
    if (campagneId == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    var service =
        DependencyProvider.of(context).getService<IImageGenerationService>();
    var imagesResponse = await service.getImagesForCampagne(
        campagneId: CampagneIdentifier($value: campagneId));

    if (!mounted) return;
    await imagesResponse.possiblyHandleError(context);
    if (!mounted) return;

    if (!imagesResponse.isSuccessful) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      imagesInCampagne = imagesResponse.result ?? [];

      isLoading = false;
    });
  }

  String getPublicImageUrl(ImageMetaData image) {
    var urlForImage = "/public/getimage/${image.id!.$value!}/${image.apiKey!}";

    return urlForImage;
  }
}
