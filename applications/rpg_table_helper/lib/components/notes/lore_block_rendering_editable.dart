import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/custom_iterator_extensions.dart';

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
    required this.updateImageContent,
    required this.deleteBlock,
  });

  final Future<bool> Function() deleteBlock;
  final Future<bool> Function(String pathToImageToUpload) updateImageContent;
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
              minSize: 0,
              padding: EdgeInsets.all(0),
              onPressed: () async {
                setState(() {
                  isEditEnabled = !isEditEnabled;
                });
              },
              child: CustomFaIcon(
                icon: FontAwesomeIcons.penToSquare,
                size: 20,
                color: darkColor,
              ),
            ),
          ),
        if (widget.isUserAllowedToEdit == true && isEditEnabled)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.all(0),
              onPressed: () async {
                // TODO make me ask the user if they really want to discard changes
                await widget.deleteBlock();
              },
              child: CustomFaIcon(
                icon: FontAwesomeIcons.trashCan,
                size: 20,
                color: darkColor,
              ),
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
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(fontSize: 16, color: darkTextColor),
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
              minSize: 0,
              padding: EdgeInsets.all(0),
              onPressed: widget.toggleIsVisibleForBarCollapsed,
              child: CustomFaIcon(
                icon: FontAwesomeIcons.users,
                size: 20,
                color: darkColor,
              ),
            ),
          )
      ],
    );
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
        minSize: 0,
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
                .removeWhere((u) => u.$value == permitteddUser.userId.$value);
          }

          updatePermittedUsersOnBlock(newPermittedUsers, block);
        },
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: middleBgColor,
                ),
                padding: EdgeInsets.all(5),
                alignment: Alignment.centerLeft,
                child: Text(
                  permitteddUser.playerCharacterName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: darkTextColor,
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
                color: isProhibited ? lightRed : lightGreen,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(
                  color: darkColor,
                ),
              ),
              child: CustomFaIcon(
                icon: isProhibited
                    ? FontAwesomeIcons.xmark
                    : FontAwesomeIcons.check,
                color: darkColor,
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
                )
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
}
