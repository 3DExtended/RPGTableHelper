import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/components/modal_content_wrapper.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/modal_helpers.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/image_generation_service.dart';

Future<({String publicUrl, String description})?> showGenerateLoreImageModal(
  BuildContext context, {
  GlobalKey<NavigatorState>? overrideNavigatorKey,
}) async {
  // show error to user
  return await customShowCupertinoModalBottomSheet<
          ({String publicUrl, String description})>(
      isDismissible: true,
      expand: false,
      closeProgressThreshold: -50000,
      backgroundColor: const Color.fromARGB(192, 21, 21, 21),
      enableDrag: true,
      context: context,
      overrideNavigatorKey: overrideNavigatorKey,
      builder: (context) {
        var modalPadding = 80.0;
        if (MediaQuery.of(context).size.width < 800) {
          modalPadding = 20.0;
        }

        return ShowGenerateLoreImageModalModalContent(
          modalPadding: modalPadding,
          overrideNavigatorKey: overrideNavigatorKey,
        );
      });
}

class ShowGenerateLoreImageModalModalContent extends ConsumerStatefulWidget {
  const ShowGenerateLoreImageModalModalContent({
    super.key,
    required this.modalPadding,
    this.overrideNavigatorKey,
  });

  final double modalPadding;
  final GlobalKey<NavigatorState>? overrideNavigatorKey;

  @override
  ConsumerState<ShowGenerateLoreImageModalModalContent> createState() =>
      _ShowGenerateLoreImageModalModalContentState();
}

class _ShowGenerateLoreImageModalModalContentState
    extends ConsumerState<ShowGenerateLoreImageModalModalContent> {
  var imageDescriptionController = TextEditingController();

  bool isLoading = false;

  final List<String> _urlsOfGeneratedImages = [];
  int? _selectedGeneratedImage;

  @override
  Widget build(BuildContext context) {
    return ModalContentWrapper<({String publicUrl, String description})>(
      isFullscreen: false,
      title: S.of(context).generateLoreImageTitle,
      navigatorKey: widget.overrideNavigatorKey ?? navigatorKey,
      onCancel: () async {},
      onSave: _selectedGeneratedImage == null
          ? null
          : () async {
              return (
                publicUrl: _urlsOfGeneratedImages[_selectedGeneratedImage ?? 0],
                description: imageDescriptionController.text
              );
            },
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomMarkdownBody(
                text: "Beschreibe das Bild, das du generieren möchtest. "
                    "Die Beschreibung sollte so detailliert wie möglich sein,"
                    "damit die KI ein passendes Bild generieren kann."),
            SizedBox(
              height: 10,
            ),
            CustomTextField(
              keyboardType: TextInputType.multiline,
              labelText: S.of(context).documentTitleLabel,
              placeholderText: "z.B. 'Ein mystischer Wald mit Elfen'",
              textEditingController: imageDescriptionController,
            ),
            SizedBox(
              height: 10,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
              child: Builder(builder: (context) {
                var imageUrl = _urlsOfGeneratedImages.isEmpty
                    ? null
                    : _urlsOfGeneratedImages[_selectedGeneratedImage ?? 0];

                var fullImageUrl = imageUrl == null
                    ? "assets/images/charactercard_placeholder.png"
                    : (imageUrl.startsWith("assets")
                        ? imageUrl
                        : (apiBaseUrl +
                            (imageUrl.startsWith("/")
                                ? (imageUrl.length > 1
                                    ? imageUrl.substring(1)
                                    : '')
                                : imageUrl)));

                return BorderedImage(
                  lightColor: darkColor,
                  backgroundColor: bgColor,
                  imageUrl: fullImageUrl,
                  isGreyscale: false,
                  isLoading: isLoading,
                  noPadding: true,
                );
              }),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                CustomButton(
                    variant: CustomButtonVariant.FlatButton,
                    icon: CustomFaIcon(
                      icon: FontAwesomeIcons.chevronLeft,
                      color: isShowPreviousGeneratedImageButtonDisabled
                          ? middleBgColor
                          : darkColor,
                    ),
                    onPressed: isShowPreviousGeneratedImageButtonDisabled
                        ? null
                        : () {
                            setState(() {
                              if (_selectedGeneratedImage != null) {
                                _selectedGeneratedImage =
                                    max(_selectedGeneratedImage! - 1, 0);
                              }
                            });
                          }),
                Spacer(),
                CustomButton(
                  onPressed: isLoading == true
                      ? null
                      : () async {
                          if (imageDescriptionController.text == "" ||
                              imageDescriptionController.text.length < 5) {
                            return;
                          }

                          var connectionDetails =
                              ref.read(connectionDetailsProvider).requireValue;
                          var campagneId = connectionDetails.campagneId;
                          if (campagneId == null) return;

                          setState(() {
                            isLoading = true;
                          });

                          // TODO generate image!
                          var service = DependencyProvider.of(context)
                              .getService<IImageGenerationService>();

                          var generationResult =
                              await service.createNewImageAndGetUrl(
                            prompt: imageDescriptionController.text,
                            campagneId: CampagneIdentifier($value: campagneId),
                          );

                          if (!context.mounted || !mounted) return;
                          await generationResult.possiblyHandleError(context);
                          if (!context.mounted || !mounted) return;

                          if (generationResult.isSuccessful &&
                              generationResult.result != null) {
                            setState(() {
                              _urlsOfGeneratedImages
                                  .add(generationResult.result!);
                              _selectedGeneratedImage =
                                  _urlsOfGeneratedImages.length - 1;
                            });
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                  label: "Neues Bild",
                  variant: CustomButtonVariant.AccentButton,
                  icon: CustomFaIcon(icon: FontAwesomeIcons.arrowRotateLeft),
                ),
                Spacer(),
                CustomButton(
                    variant: CustomButtonVariant.FlatButton,
                    icon: CustomFaIcon(
                      icon: FontAwesomeIcons.chevronRight,
                      color: isShowNextGeneratedButtonDisabled
                          ? middleBgColor
                          : darkColor,
                    ),
                    onPressed: isShowNextGeneratedButtonDisabled
                        ? null
                        : () {
                            setState(() {
                              if (_selectedGeneratedImage != null) {
                                _selectedGeneratedImage = min(
                                    _selectedGeneratedImage! + 1,
                                    _urlsOfGeneratedImages.length - 1);
                              }
                            });
                          }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get isShowPreviousGeneratedImageButtonDisabled {
    return _selectedGeneratedImage == null || _selectedGeneratedImage == 0;
  }

  bool get isShowNextGeneratedButtonDisabled {
    return _selectedGeneratedImage == null ||
        _selectedGeneratedImage! >= _urlsOfGeneratedImages.length - 1;
  }
}
