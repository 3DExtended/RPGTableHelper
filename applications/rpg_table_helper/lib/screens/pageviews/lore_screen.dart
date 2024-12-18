import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rpg_table_helper/components/bordered_image.dart';
import 'package:rpg_table_helper/components/colored_rotated_square.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.enums.swagger.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/context_extension.dart';
import 'package:rpg_table_helper/helpers/custom_iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/iterable_extension.dart';
import 'package:rpg_table_helper/helpers/list_extensions.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/note_documents_service.dart';
import 'package:rpg_table_helper/services/rpg_entity_service.dart';
import 'package:rpg_table_helper/services/systemclock_service.dart';
import 'package:timeago/timeago.dart' as timeago;

/// This file defines the `LoreScreen` widget, which is responsible for displaying
/// a screen with various lore-related documents. The screen includes a navigation
/// bar, a list of grouped documents, and drag-and-drop functionality for organizing
/// the documents.
///
/// The main components of the `LoreScreen` include:
/// - A `SingleChildScrollView` that allows the entire content to be scrollable.
/// - A `LayoutBuilder` that provides the constraints for the layout.
/// - A `ConstrainedBox` that ensures the minimum height of the content.
/// - A `Center` widget that centers the content.
/// - A `Column` that arranges the child widgets vertically.
/// - A `DragTarget` for each group of documents, allowing documents to be dragged
///   and dropped into different groups.
/// - A `ListView.builder` that displays the list of documents within each group.
/// - A `CupertinoButton` for each document, allowing the user to select a document.
/// - A `LongPressDraggable` for each document, enabling drag-and-drop functionality.
/// - Conditional widgets that display additional buttons and options based on the
///   state of the navigation bar.
///
/// The `LoreScreen` widget interacts with various providers and state management
/// solutions to handle the loading, refreshing, and organizing of documents.
class LoreScreen extends ConsumerStatefulWidget {
  static String route = "lore";

  const LoreScreen({super.key});

  @override
  ConsumerState<LoreScreen> createState() => _LoreScreenState();
}

class _LoreScreenState extends ConsumerState<LoreScreen> {
  final Duration duration = Duration(milliseconds: 150);

  Map<String, List<NoteDocumentDto>> groupedDocuments = {};
  List<String> groupLabels = [];

  NoteDocumentIdentifier? selectedDocumentId;
  NoteDocumentDto? selectedDocument;

  bool isLoading = true;
  bool _isNavbarCollapsed = false;
  bool _isVisibleForBarCollapsed = false;
  double collapsedWidth = 64.0;
  double expandedWidth = 256.0;

  var refreshController = RefreshController(
    initialRefreshStatus: RefreshStatus.refreshing,
    initialRefresh: false,
  );

  List<NoteDocumentPlayerDescriptorDto> usersInCampagne = [];

  int numberOfDocumentsForThisPlayer = 0;
  UserIdentifier? get _myUser =>
      usersInCampagne.singleWhereOrNull((u) => u.isYou)?.userId;

  bool get _isAllowedToEdit =>
      selectedDocument?.creatingUserId?.$value != null &&
      selectedDocument?.creatingUserId?.$value == _myUser?.$value;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await _reloadAllPages();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // the navbar is rendered on top of the content if this setting is true
    var useStackOption = !context.isTablet;

    var children = [
      // collapsable navbar
      _getCollapsableNavbar(),

      // content
      if (!useStackOption)
        Expanded(
          child: _getContent(),
        ),
      if (useStackOption)
        Padding(
          padding: EdgeInsets.only(left: useStackOption ? collapsedWidth : 0),
          child: _getContent(),
        )
    ];

    if (useStackOption) {
      return Stack(
        children: children.reversed.toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _getCollapsableNavbar() {
    return AnimatedContainer(
      duration: duration,
      width: _isNavbarCollapsed ? collapsedWidth : expandedWidth,
      color: middleBgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: AnimatedAlign(
              duration: duration,
              alignment:
                  _isNavbarCollapsed ? Alignment.center : Alignment.topCenter,
              child: ConditionalWidgetWrapper(
                condition: !_isNavbarCollapsed && !isInTestEnvironment,
                wrapper: (context, child) {
                  return SmartRefresher(
                      controller: refreshController,
                      enablePullDown: true,
                      enablePullUp: false,
                      onRefresh: () async {
                        await _reloadAllPages();

                        refreshController.refreshCompleted();
                      },
                      child: child);
                },
                child: SingleChildScrollView(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.minHeight),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...groupLabels.map((group) {
                              return DragTarget<NoteDocumentDto>(
                                key: ValueKey(group),
                                onWillAcceptWithDetails: (doc) => true,
                                onAcceptWithDetails: (details) {
                                  final draggedDoc = details.data;
                                  final index =
                                      groupedDocuments[group]?.length ?? 0;
                                  _onDocumentDropped(draggedDoc.groupName,
                                      group, index, draggedDoc);
                                },
                                builder:
                                    (context, candidateData, rejectedData) {
                                  return Container(
                                    color: candidateData.isNotEmpty
                                        ? accentColor.withAlpha(25)
                                        : Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildNavItem(group),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount:
                                              groupedDocuments[group]?.length ??
                                                  0,
                                          itemBuilder: (context, index) {
                                            final doc =
                                                groupedDocuments[group]![index];
                                            return CupertinoButton(
                                              minSize: 0,
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                setState(() {
                                                  selectedDocument = doc;
                                                  selectedDocumentId = doc.id;
                                                });
                                              },
                                              child: LongPressDraggable<
                                                  NoteDocumentDto>(
                                                hapticFeedbackOnStart: true,
                                                key: ValueKey(doc.id!.$value!),
                                                data: doc,
                                                feedback: SizedBox(
                                                  width: expandedWidth,
                                                  child: _getDocumentDragChild(
                                                      doc, context),
                                                ),
                                                child: _getDocumentDragChild(
                                                    doc, context),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }),
                            if (!_isNavbarCollapsed)
                              SizedBox(
                                height: 20,
                              ),
                            if (!_isNavbarCollapsed)
                              CustomButton(
                                onPressed: () async {
                                  var campagneId = ref
                                      .read(connectionDetailsProvider)
                                      .valueOrNull
                                      ?.campagneId;
                                  if (campagneId == null) {
                                    return;
                                  }

                                  var systemClock =
                                      DependencyProvider.of(context)
                                          .getService<ISystemClockService>();

                                  setState(() {
                                    isLoading = true;
                                  });

                                  // TODO
                                  var newDocument = NoteDocumentDto(
                                    groupName: "Sonstiges", // TODO localization
                                    title:
                                        "Dokument #${numberOfDocumentsForThisPlayer + 1}",
                                    createdForCampagneId:
                                        CampagneIdentifier($value: campagneId),
                                    lastModifiedAt: systemClock.now(),
                                    creationDate: systemClock.now(),
                                    creatingUserId: _myUser,
                                    isDeleted: false,
                                    imageBlocks: [],
                                    textBlocks: [],
                                  );

                                  var service = DependencyProvider.of(context)
                                      .getService<INoteDocumentService>();
                                  var createResult = await service
                                      .createNewDocumentForCampagne(
                                    dto: newDocument,
                                  );

                                  if (!mounted || !context.mounted) return;
                                  await createResult
                                      .possiblyHandleError(context);
                                  if (!mounted || !context.mounted) return;

                                  setState(() {
                                    isLoading = false;
                                    if (createResult.isSuccessful) {
                                      newDocument = newDocument.copyWith(
                                          id: createResult.result!);

                                      if (!groupedDocuments
                                          .containsKey(newDocument.groupName)) {
                                        groupedDocuments[
                                            newDocument.groupName] = [];
                                      }
                                      groupedDocuments[newDocument.groupName]!
                                          .add(newDocument);
                                    }
                                  });
                                },
                                icon: CustomFaIcon(
                                  icon: FontAwesomeIcons.plus,
                                  size: iconSizeInlineButtons,
                                  color: textColor,
                                ),
                                label: "Neu",
                                variant: CustomButtonVariant.AccentButton,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          _getCollapseButton(duration),
        ],
      ),
    );
  }

  Widget _getDocumentDragChild(NoteDocumentDto doc, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColoredRotatedSquare(
            key: ValueKey("ColoredRotatedSquare${doc.id!.$value!}"),
            isSolidSquare: selectedDocumentId?.$value == doc.id?.$value,
            color: accentColor,
          ),
          if (!_isNavbarCollapsed)
            Expanded(
              child: Text(
                doc.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 16,
                      color: darkTextColor,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getContent() {
    var systemClock =
        DependencyProvider.of(context).getService<ISystemClockService>();

    if (isLoading) {
      return Column(
        children: [
          Center(
            child: CustomLoadingSpinner(),
          )
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10),
          child: Row(
            children: [
              Text(
                selectedDocument?.title ?? "",
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: darkTextColor,
                      fontSize: 24,
                    ),
              ),
              if (_isAllowedToEdit == true)
                CustomButton(
                    onPressed: () {},
                    icon: CustomFaIcon(
                        icon: FontAwesomeIcons.penToSquare,
                        size: 20,
                        color: darkColor),
                    variant: CustomButtonVariant.FlatButton),
              Spacer(),
              Text(
                "Bearbeitet vor:\n${selectedDocument == null ? "" : timeago.format(
                    selectedDocument!.lastModifiedAt!,
                    clock: systemClock.now(),
                    locale: 'de_short',
                  )}",
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: darkTextColor,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: HorizontalLine(
            useDarkColor: true,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _renderContentBlocks(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getCollapseButton(Duration duration) {
    return AnimatedPadding(
      duration: duration,
      padding: EdgeInsets.fromLTRB(0, 0, _isNavbarCollapsed ? 0 : 20, 20),
      child: AnimatedAlign(
        duration: duration,
        alignment:
            _isNavbarCollapsed ? Alignment.center : Alignment.centerRight,
        child: CupertinoButton(
          minSize: 0,
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              _isNavbarCollapsed = !_isNavbarCollapsed;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: darkColor,
              ),
              color: bgColor,
            ),
            padding: EdgeInsets.all(5),
            child: CustomFaIcon(
              icon: !_isNavbarCollapsed
                  ? FontAwesomeIcons.chevronLeft
                  : FontAwesomeIcons.chevronRight,
              color: darkTextColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
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
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var documentsResponse = await service.getDocumentsForCampagne(
        campagneId: CampagneIdentifier($value: campagneId));

    if (!mounted) return;
    var rpgservice =
        DependencyProvider.of(context).getService<IRpgEntityService>();
    var loadedCharsResponse = await rpgservice.getUserDetailsForCampagne(
        campagneId: CampagneIdentifier($value: campagneId));

    if (!mounted) return;
    await loadedCharsResponse.possiblyHandleError(context);
    if (!mounted) return;
    await documentsResponse.possiblyHandleError(context);
    if (!mounted) return;

    if (!documentsResponse.isSuccessful || !loadedCharsResponse.isSuccessful) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      usersInCampagne = loadedCharsResponse.result ?? [];

      var otherGroupName = "Sonstiges"; // TODO localize
      numberOfDocumentsForThisPlayer = (documentsResponse.result ?? []).length;
      groupedDocuments =
          (documentsResponse.result ?? []).groupListsBy((d) => d.groupName);

      // TODO maybe show "sonstiges" only when needed?
      groupLabels = [...groupedDocuments.keys, otherGroupName]
          .distinct(by: (e) => e)
          .toList();
      groupLabels.sort();

      if (!groupedDocuments.containsKey(otherGroupName)) {
        groupedDocuments[otherGroupName] = [];
      }

      if (documentsResponse.result?.isNotEmpty == true) {
        selectedDocumentId = groupedDocuments[groupLabels.first]![0].id;
        selectedDocument = groupedDocuments[groupLabels.first]![0];
      }

      isLoading = false;

      refreshController.loadComplete();
    });
  }

  void _onDocumentDropped(
      String sourceGroup, String targetGroup, int index, NoteDocumentDto doc) {
    setState(() {
      // Remove from source group
      groupedDocuments[sourceGroup]?.remove(doc);

      // Add to target group
      if (groupedDocuments[targetGroup] == null) {
        groupedDocuments[targetGroup] = [];
      }
      groupedDocuments[targetGroup]!.insert(
          min(index, groupedDocuments[targetGroup]!.length),
          doc.copyWith(groupName: targetGroup));

      groupedDocuments[targetGroup]!.sortBy((e) => e.title);
    });
  }

  Widget _buildNavItem(String label) {
    if (_isNavbarCollapsed) {
      return Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Container(
          width: 40,
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(color: bgColor))),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: darkTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  List<dynamic> get getBlocksOfSelectedDocument {
    List<dynamic> blocks = [
      ...selectedDocument!.imageBlocks,
      ...selectedDocument!.textBlocks
    ];

    blocks.sortBy<DateTime>((k) => k.creationDate);

    return blocks;
  }

  List<Widget> _renderContentBlocks() {
    if (selectedDocument == null) return [];
    List<dynamic> blocks = getBlocksOfSelectedDocument;

    List<Widget> result = [];

    for (var block in blocks) {
      Widget? blockRendering;

      if (block is TextBlock) {
        // text block
        blockRendering = _getRenderingForTextBlock(block);
      } else if (block is ImageBlock) {
        // image block
        blockRendering = _getRenderingForImageBlock(block);
      }

      assert(blockRendering != null);

      result.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: blockRendering!),
          if (_isAllowedToEdit == true)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.all(0),
                onPressed: () {
                  // TODO make me
                },
                child: CustomFaIcon(
                  icon: FontAwesomeIcons.penToSquare,
                  size: 20,
                  color: darkColor,
                ),
              ),
            ),
          if (_isVisibleForBarCollapsed == true)
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                child: Column(
                  children: [
                    Text(
                      "Sichtbar für:",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontSize: 16, color: darkTextColor),
                    ),

                    SizedBox(
                      height: 5,
                    ),

                    // for every user create a pill which indicates
                    ..._getPillsToIndicateVisibilityForPlayers(
                        block.id, block.permittedUsers ?? []),
                  ],
                ),
              ),
            ),
          if (_isAllowedToEdit == true)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.all(0),
                onPressed: () {
                  setState(() {
                    _isVisibleForBarCollapsed = !_isVisibleForBarCollapsed;
                  });
                },
                child: CustomFaIcon(
                  icon: FontAwesomeIcons.users,
                  size: 20,
                  color: darkColor,
                ),
              ),
            )
        ],
      ));
    }

    return result.insertBetween(Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: HorizontalLine(),
    ));
  }

  Widget _getRenderingForTextBlock(TextBlock textBlock) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: CustomMarkdownBody(text: textBlock.markdownText ?? ""),
    );
  }

  Widget _getRenderingForImageBlock(ImageBlock imageBlock) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: darkColor),
                ),
                clipBehavior: Clip.hardEdge,
                child: CustomImage(
                  isGreyscale: false,
                  isClickableForZoom: true,
                  isLoading: false,
                  imageUrl: imageBlock.publicImageUrl!,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _getPillsToIndicateVisibilityForPlayers(
      NoteBlockModelBaseIdentifier blockId,
      List<UserIdentifier> permittedUsers) {
    // get all users execpt me:
    var usersExceptMe = usersInCampagne.where((u) => !u.isYou).toList();

    List<NoteDocumentPlayerDescriptorDto> prohibitedUserResult = [];
    List<NoteDocumentPlayerDescriptorDto> permittedUserResult = [];

    for (var user in usersExceptMe) {
      if (permittedUsers.contains(user.userId)) {
        permittedUserResult.add(user.copyWith(
            playerCharacterName: user.isDm ? "DM" : user.playerCharacterName));
      } else {
        prohibitedUserResult.add(user.copyWith(
            playerCharacterName: user.isDm ? "DM" : user.playerCharacterName));
      }
    }

    prohibitedUserResult.sortByDescending((u) => u.playerCharacterName!);
    permittedUserResult.sortByDescending((u) => u.playerCharacterName!);
    List<Widget> result = [];

    for (var permittedUser in permittedUserResult) {
      result.add(_getVisibilityPillForUser(blockId, permittedUser,
          isProhibited: false));
    }
    for (var prohibitedUser in prohibitedUserResult) {
      result.add(_getVisibilityPillForUser(blockId, prohibitedUser,
          isProhibited: true));
    }

    return result;
  }

  Widget _getVisibilityPillForUser(NoteBlockModelBaseIdentifier blockId,
      NoteDocumentPlayerDescriptorDto permitteddUser,
      {required bool isProhibited}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: CupertinoButton(
        minSize: 0,
        padding: EdgeInsets.zero,
        onPressed: () {
          // find correct block to update
          var block =
              getBlocksOfSelectedDocument.singleWhere((b) => b.id == blockId);

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

          _updatePermittedUsersOnBlock(newPermittedUsers, block);
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

  void _updatePermittedUsersOnBlock(
      List<UserIdentifier> newPermittedUsers, block) {
    newPermittedUsers = newPermittedUsers
        .where(
            (u) => usersInCampagne.any((uic) => uic.userId.$value == u.$value))
        .toList();

    setState(() {
      if (block is TextBlock) {
        block = (block as TextBlock).copyWith(
          visibility: _recalculateBlockVisibility(block),
          permittedUsers: newPermittedUsers,
        );

        var indexToReplace =
            selectedDocument!.textBlocks.indexWhere((b) => b.id == block.id);
        if (indexToReplace >= 0) {
          selectedDocument!.textBlocks[indexToReplace] = block;
          selectedDocument = selectedDocument!
              .copyWith(textBlocks: [...selectedDocument!.textBlocks]);
        }
      } else if (block is ImageBlock) {
        block = (block as ImageBlock).copyWith(
          visibility: _recalculateBlockVisibility(block),
          permittedUsers: newPermittedUsers,
        );

        var indexToReplace =
            selectedDocument!.imageBlocks.indexWhere((b) => b.id == block.id);
        if (indexToReplace >= 0) {
          selectedDocument!.imageBlocks[indexToReplace] = block;
          selectedDocument = selectedDocument!
              .copyWith(imageBlocks: [...selectedDocument!.imageBlocks]);
        }
      }
    });
  }

  NotesBlockVisibility _recalculateBlockVisibility(dynamic block) {
    if (block.permittedUsers == null || block.permittedUsers.isEmpty) {
      return NotesBlockVisibility.hiddenforallexceptauthor;
    }

    var userExceptAuthorOfBlock =
        usersInCampagne.where((u) => u.userId != block.creatingUserId).toList();
    if (userExceptAuthorOfBlock
        .any((u) => !block.permittedUsers.contains(u.userId))) {
      return NotesBlockVisibility.visibleforsomeusers;
    }

    return NotesBlockVisibility.visibleforcampagne;
  }
}
