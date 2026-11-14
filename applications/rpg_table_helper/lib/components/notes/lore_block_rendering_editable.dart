import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/notes/note_block_menu.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/custom_iterator_extensions.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:themed/themed.dart';

class LoreBlockRenderingEditable extends StatefulWidget {
  const LoreBlockRenderingEditable({
    super.key,
    required this.isUserAllowedToEdit,
    required this.updateTextContent,
    required this.isShowingPermittedUsers,
    required this.toggleIsVisibleForBarCollapsed,
    required this.block,
    required this.usersInCampagne,
    required this.updatePermittedUsersOnBlock,
    required this.deleteBlock,
    this.attachImage,
    this.replaceImage,
    this.removeImage,
    this.moveUp,
    this.moveDown,
  });

  final Future<bool> Function() deleteBlock;

  /// Text blocks only: adds an image, which turns the block into an image block.
  final Future<bool> Function(NoteImageSource source)? attachImage;

  /// Image blocks only: puts another image into the block.
  final Future<bool> Function(NoteImageSource source)? replaceImage;

  /// Image blocks only: removes the image, which turns the block into a text block.
  final Future<bool> Function()? removeImage;

  /// Moves the block one up; null for the first block.
  final Future<void> Function()? moveUp;

  /// Moves the block one down; null for the last block.
  final Future<void> Function()? moveDown;
  final List<NoteDocumentPlayerDescriptorDto> usersInCampagne;
  final void Function(List<UserIdentifier> newPermittedUsers, dynamic block)
      updatePermittedUsersOnBlock;
  final dynamic block;
  final bool isUserAllowedToEdit;
  final Future<bool> Function(String newText) updateTextContent;
  final bool isShowingPermittedUsers;
  final Null Function() toggleIsVisibleForBarCollapsed;

  @override
  State<LoreBlockRenderingEditable> createState() =>
      _LoreBlockRenderingEditableState();
}

class _LoreBlockRenderingEditableState
    extends State<LoreBlockRenderingEditable> {
  bool isEditEnabled = false;
  bool get hasChanged =>
      (widget.block.markdownText ?? "") != _textEditingController.text;

  final TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    // text block
    _textEditingController.text = widget.block.markdownText ?? "";

    _textEditingController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? blockRendering;

    if (widget.block is TextBlock) {
      // text block
      blockRendering = _getRenderingForTextBlock(widget.block.markdownText);
    } else if (widget.block is ImageBlock) {
      // image block
      blockRendering = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _getRenderingForImageBlock(widget.block)),
          _getRenderingForTextBlock(widget.block.markdownText)
        ],
      );
    }

    assert(blockRendering != null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: blockRendering!),
        if (widget.isUserAllowedToEdit == true && !isEditEnabled)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CupertinoButton(
              padding: EdgeInsets.all(0),
              onPressed: () async {
                setState(() {
                  isEditEnabled = !isEditEnabled;
                });
              },
              minimumSize: Size(0, 0),
              child: CustomFaIcon(
                icon: FontAwesomeIcons.penToSquare,
                size: 20,
                color: CustomThemeProvider.of(context).theme.darkColor,
              ),
            ),
          ),
        if (widget.isUserAllowedToEdit == true && isEditEnabled)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _iconButton(
                  icon: FontAwesomeIcons.trashCan,
                  onPressed: () async {
                    // TODO make me ask the user if they really want to discard changes
                    await widget.deleteBlock();
                  },
                ),
                if (widget.moveUp != null || widget.moveDown != null) ...[
                  const SizedBox(height: 16),
                  _iconButton(
                    key: const ValueKey('moveNoteBlockUp'),
                    icon: FontAwesomeIcons.arrowUp,
                    onPressed: widget.moveUp,
                  ),
                  const SizedBox(height: 12),
                  _iconButton(
                    key: const ValueKey('moveNoteBlockDown'),
                    icon: FontAwesomeIcons.arrowDown,
                    onPressed: widget.moveDown,
                  ),
                ],
              ],
            ),
          ),
        if (widget.isShowingPermittedUsers == true &&
            widget.isUserAllowedToEdit)
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
              child: Column(
                children: [
                  Text(
                    S.of(context).noteblockVisibleFor,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontSize: 16,
                        color: CustomThemeProvider.of(context)
                            .theme
                            .darkTextColor),
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  // for every user create a pill which indicates
                  ...getPillsToIndicateVisibilityForPlayers(
                    widget.block.id,
                    widget.block.permittedUsers ?? [],
                    widget.usersInCampagne,
                    widget.block,
                    widget.updatePermittedUsersOnBlock,
                    context,
                  ),
                ],
              ),
            ),
          ),
        if (widget.isUserAllowedToEdit == true)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CupertinoButton(
              padding: EdgeInsets.all(0),
              onPressed: widget.toggleIsVisibleForBarCollapsed,
              minimumSize: Size(0, 0),
              child: CustomFaIcon(
                icon: FontAwesomeIcons.users,
                size: 20,
                color: CustomThemeProvider.of(context).theme.darkColor,
              ),
            ),
          )
      ],
    );
  }

  Widget _iconButton({
    Key? key,
    required FaIconData icon,
    required Future<void> Function()? onPressed,
  }) {
    final color = CustomThemeProvider.of(context).theme.darkColor;
    return CupertinoButton(
      key: key,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      minimumSize: Size(0, 0),
      child: CustomFaIcon(
        icon: icon,
        size: 20,
        color: onPressed == null ? color.withValues(alpha: 0.3) : color,
      ),
    );
  }

  /// Saves unsaved text first, so it is not lost when the block is replaced.
  Future<void> _saveTextIfChanged() async {
    if (hasChanged) {
      await widget.updateTextContent(_textEditingController.text);
    }
  }

  Widget _imageSourceButton({
    required Key key,
    required String label,
    required Future<bool> Function(NoteImageSource source) onChosen,
  }) {
    return Builder(builder: (anchorContext) {
      return CustomButton(
        key: key,
        variant: CustomButtonVariant.Default,
        icon: CustomFaIcon(
          icon: FontAwesomeIcons.image,
          size: 16,
          color: CustomThemeProvider.of(context).theme.textColor,
        ),
        onPressed: () async {
          final source = await showNoteImageSourceMenu(anchorContext);
          if (source == null) return;
          await _saveTextIfChanged();
          await onChosen(source);
        },
        label: label,
      );
    });
  }

  List<Widget> getPillsToIndicateVisibilityForPlayers(
    NoteBlockModelBaseIdentifier blockId,
    List<UserIdentifier> permittedUsers,
    List<NoteDocumentPlayerDescriptorDto> usersInCampagne,
    dynamic block,
    void Function(List<UserIdentifier> newPermittedUsers, dynamic block)
        updatePermittedUsersOnBlock,
    BuildContext context,
  ) {
    // get all users execpt me:
    var usersExceptMe = usersInCampagne.where((u) => !u.isYou).toList();

    List<NoteDocumentPlayerDescriptorDto> prohibitedUserResult = [];
    List<NoteDocumentPlayerDescriptorDto> permittedUserResult = [];

    for (var user in usersExceptMe) {
      if (permittedUsers.contains(user.userId)) {
        permittedUserResult.add(user.copyWith(
            playerCharacterName:
                user.isDm ? S.of(context).dm : user.playerCharacterName));
      } else {
        prohibitedUserResult.add(user.copyWith(
            playerCharacterName:
                user.isDm ? S.of(context).dm : user.playerCharacterName));
      }
    }

    prohibitedUserResult.sortByDescending((u) => u.playerCharacterName!);
    permittedUserResult.sortByDescending((u) => u.playerCharacterName!);
    List<Widget> result = [];

    for (var permittedUser in permittedUserResult) {
      result.add(_getVisibilityPillForUser(
        blockId,
        permittedUser,
        block,
        updatePermittedUsersOnBlock,
        context,
        isProhibited: false,
      ));
    }
    for (var prohibitedUser in prohibitedUserResult) {
      result.add(_getVisibilityPillForUser(
        blockId,
        prohibitedUser,
        block,
        updatePermittedUsersOnBlock,
        context,
        isProhibited: true,
      ));
    }

    return result;
  }

  Widget _getVisibilityPillForUser(
      NoteBlockModelBaseIdentifier blockId,
      NoteDocumentPlayerDescriptorDto permitteddUser,
      dynamic block,
      void Function(List<UserIdentifier> newPermittedUsers, dynamic block)
          updatePermittedUsersOnBlock,
      BuildContext context,
      {required bool isProhibited}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // find correct block to update

          var newPermittedUsers =
              (block.permittedUsers as List<UserIdentifier>?) ?? [];
          if (isProhibited) {
            // add user to permitted users
            newPermittedUsers.add(permitteddUser.userId);
          } else {
            // remove user from permitted users
            newPermittedUsers
                .removeWhere((u) => u.value == permitteddUser.userId.value);
          }

          updatePermittedUsersOnBlock(newPermittedUsers, block);
        },
        minimumSize: Size(0, 0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: CustomThemeProvider.of(context)
                              .brightnessNotifier
                              .value ==
                          Brightness.light
                      ? CustomThemeProvider.of(context).theme.middleBgColor
                      : CustomThemeProvider.of(context)
                          .theme
                          .bgColor
                          .darker(0.2),
                ),
                padding: EdgeInsets.all(5),
                alignment: Alignment.centerLeft,
                child: Text(
                  permitteddUser.playerCharacterName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color:
                            CustomThemeProvider.of(context).theme.darkTextColor,
                        fontSize: 16,
                      ),
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              decoration: BoxDecoration(
                color: isProhibited
                    ? CustomThemeProvider.of(context).theme.lightRed
                    : CustomThemeProvider.of(context).theme.lightGreen,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(
                  color: CustomThemeProvider.of(context).theme.darkColor,
                ),
              ),
              child: CustomFaIcon(
                icon: isProhibited
                    ? FontAwesomeIcons.xmark
                    : FontAwesomeIcons.check,
                color: CustomThemeProvider.of(context).theme.darkColor,
                size: 22,
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getRenderingForTextBlock(String? markdownText) {
    var padding = EdgeInsets.fromLTRB(0, 10, 10, 10);

    if (!isEditEnabled) {
      return Padding(
        padding: padding,
        child: CustomMarkdownBody(text: markdownText ?? ""),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: Column(
        children: [
          CustomTextField(
            keyboardType: TextInputType.multiline,
            labelText: "Text",
            password: false,
            textEditingController: _textEditingController,
            disableMaxLineLimit: true,
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Wrap(
              runSpacing: 10,
              spacing: 10,
              children: [
                CustomButton(
                  variant: CustomButtonVariant.AccentButton,
                  onPressed: hasChanged
                      ? () async {
                          var _ = await widget
                              .updateTextContent(_textEditingController.text);
                          setState(() {
                            isEditEnabled = false;
                          });
                        }
                      : null,
                  label: S.of(context).save,
                ),
                CustomButton(
                  variant: CustomButtonVariant.Default,
                  onPressed: () {
                    // reset text block
                    setState(() {
                      _textEditingController.text =
                          (widget.block).markdownText ?? "";

                      isEditEnabled = false;
                    });
                  },
                  label: S.of(context).cancel,
                ),
                if (widget.attachImage != null)
                  _imageSourceButton(
                    key: const ValueKey('attachImageToNoteBlock'),
                    label: S.of(context).attachImageBtnLabel,
                    onChosen: widget.attachImage!,
                  ),
                if (widget.replaceImage != null)
                  _imageSourceButton(
                    key: const ValueKey('replaceNoteBlockImage'),
                    label: S.of(context).replaceImageBtnLabel,
                    onChosen: widget.replaceImage!,
                  ),
                if (widget.removeImage != null)
                  CustomButton(
                    key: const ValueKey('removeNoteBlockImage'),
                    variant: CustomButtonVariant.Default,
                    onPressed: () async {
                      await _saveTextIfChanged();
                      await widget.removeImage!();
                    },
                    label: S.of(context).removeImageBtnLabel,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getRenderingForImageBlock(ImageBlock imageBlock) {
    return LayoutBuilder(builder: (context, constraints) {
      var imageUrl = imageBlock.publicImageUrl as String?;
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
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
              child: BorderedImage(
                backgroundColor: CustomThemeProvider.of(context).theme.bgColor,
                lightColor: CustomThemeProvider.of(context).theme.darkColor,
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
}
