import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rpg_table_helper/components/bordered_image.dart';
import 'package:rpg_table_helper/components/colored_rotated_square.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/static_grid.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.enums.swagger.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/custom_iterator_extensions.dart';
import 'package:rpg_table_helper/helpers/iterable_extension.dart';
import 'package:rpg_table_helper/helpers/list_extensions.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/note_documents_service.dart';
import 'package:rpg_table_helper/services/rpg_entity_service.dart';
import 'package:rpg_table_helper/services/systemclock_service.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  bool _isCollapsed = false;
  double collapsedWidth = 64.0;
  double expandedWidth = 256.0;

  var refreshController = RefreshController(
    initialRefreshStatus: RefreshStatus.refreshing,
    initialRefresh: false,
  );

  List<NoteDocumentPlayerDescriptorDto> usersInCampagne = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await reloadAllPages();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // collapsable navbar
        AnimatedContainer(
          duration: duration,
          width: _isCollapsed ? collapsedWidth : expandedWidth,
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
                      _isCollapsed ? Alignment.center : Alignment.topCenter,
                  child: ConditionalWidgetWrapper(
                    condition: !_isCollapsed,
                    wrapper: (context, child) {
                      return SmartRefresher(
                          controller: refreshController,
                          enablePullDown: true,
                          enablePullUp: false,
                          onRefresh: () async {
                            await reloadAllPages();

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
                              children: groupLabels.map((group) {
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
                                            itemCount: groupedDocuments[group]
                                                    ?.length ??
                                                0,
                                            itemBuilder: (context, index) {
                                              final doc = groupedDocuments[
                                                  group]![index];
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
                                                  key:
                                                      ValueKey(doc.id!.$value!),
                                                  data: doc,
                                                  feedback: SizedBox(
                                                    width: expandedWidth,
                                                    child:
                                                        _getDocumentDragChild(
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
                              }).toList(),
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
        ),
        // content
        Expanded(child: _getContent())
      ],
    );
  }

  Padding _getDocumentDragChild(NoteDocumentDto doc, BuildContext context) {
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
          if (!_isCollapsed)
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
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child:
                        CupertinoSlidingSegmentedControl<NotesBlockVisibility>(
                      backgroundColor: middleBgColor,
                      thumbColor: darkColor,
                      // This represents the currently selected segmented control.
                      groupValue: getVisibilityForSelectedDocument(),
                      // Callback that sets the selected segmented control.
                      onValueChanged: (NotesBlockVisibility? value) {
                        // TODO make me
                      },
                      children: <NotesBlockVisibility, Widget>{
                        NotesBlockVisibility.hiddenforallexceptauthor: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'Versteckt', // TODO localize
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    fontSize: 16,
                                    color: getVisibilityForSelectedDocument() ==
                                            NotesBlockVisibility
                                                .hiddenforallexceptauthor
                                        ? textColor
                                        : darkTextColor),
                          ),
                        ),
                        NotesBlockVisibility.visibleforsomeusers: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'Teilweise Sichtbar', // TODO localize
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    fontSize: 16,
                                    color: getVisibilityForSelectedDocument() ==
                                            NotesBlockVisibility
                                                .visibleforsomeusers
                                        ? textColor
                                        : darkTextColor),
                          ),
                        ),
                        NotesBlockVisibility.visibleforcampagne: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'Sichtbar', // TODO localize
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    fontSize: 16,
                                    color: getVisibilityForSelectedDocument() ==
                                            NotesBlockVisibility
                                                .visibleforcampagne
                                        ? textColor
                                        : darkTextColor),
                          ),
                        ),
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ..._renderContentBlocks()
                ],
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
      padding: EdgeInsets.fromLTRB(0, 0, _isCollapsed ? 0 : 20, 20),
      child: AnimatedAlign(
        duration: duration,
        alignment: _isCollapsed ? Alignment.center : Alignment.centerRight,
        child: CupertinoButton(
          minSize: 0,
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              _isCollapsed = !_isCollapsed;
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
              icon: !_isCollapsed
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

  Future reloadAllPages() async {
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
    if (_isCollapsed) {
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

  NotesBlockVisibility getVisibilityForSelectedDocument() {
    if (selectedDocument == null) {
      return NotesBlockVisibility.hiddenforallexceptauthor;
    }

    List<dynamic> blocks = getBlocksOfSelectedDocument;

    if (blocks.every(
        (b) => b.visibility == NotesBlockVisibility.visibleforcampagne)) {
      return NotesBlockVisibility.visibleforcampagne;
    }

    if (blocks
        .any((b) => b.visibility == NotesBlockVisibility.visibleforsomeusers)) {
      return NotesBlockVisibility.visibleforsomeusers;
    }

    return NotesBlockVisibility.hiddenforallexceptauthor;
  }

  // TODO for every blocklist in selectedDocument:
  List<dynamic> get getBlocksOfSelectedDocument {
    List<dynamic> blocks = [
      ...selectedDocument!.imageBlocks,
      ...selectedDocument!.textBlocks
    ];

    blocks.sortBy<DateTime>((k) => k.creationDate);

    return blocks;
  }

  List<Widget> _renderContentBlocks() {
    List<dynamic> blocks = getBlocksOfSelectedDocument;

    List<Widget> result = [];

    for (var block in blocks) {
      Widget? blockRendering;
      // TODO add block types
      if (block is TextBlock) {
        // text block
        blockRendering = getRenderingForTextBlock(block);
      } else if (block is ImageBlock) {
        // image block
        blockRendering = getRenderingForImageBlock(block);
      }

      assert(blockRendering != null);

      result.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: blockRendering!),
          Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                child: StaticGrid(
                  children: [
                    Text(
                      "Versteckt",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontSize: 16, color: darkTextColor),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border:
                              Border(left: BorderSide(color: middleBgColor))),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Sichtbar",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(fontSize: 16, color: darkTextColor),
                        ),
                      ),
                    ),

                    // for every user create a pill which indicates
                    ...getPillsToIndicateVisibilityForPlayers(
                        block.id, block.permittedUsers ?? []),
                  ],
                ),
              )),
        ],
      ));
    }

    return result.insertBetween(Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: HorizontalLine(),
    ));
  }

  Widget getRenderingForTextBlock(TextBlock textBlock) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: CustomMarkdownBody(text: textBlock.markdownText ?? ""),
    );
  }

  Widget getRenderingForImageBlock(ImageBlock imageBlock) {
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

  List<Widget> getPillsToIndicateVisibilityForPlayers(
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

    while (permittedUserResult.isNotEmpty || prohibitedUserResult.isNotEmpty) {
      if (prohibitedUserResult.isNotEmpty) {
        var prohibitedUser = prohibitedUserResult.removeLast();
        result.add(getVisibilityPillForUser(blockId, prohibitedUser,
            isProhibited: true));
      } else {
        result.add(Container());
      }

      if (permittedUserResult.isNotEmpty) {
        var permitteddUser = permittedUserResult.removeLast();
        result.add(getVisibilityPillForUser(blockId, permitteddUser,
            isProhibited: false));
      } else {
        result.add(Container());
      }
    }

    return result;
  }

  Widget getVisibilityPillForUser(NoteBlockModelBaseIdentifier blockId,
      NoteDocumentPlayerDescriptorDto permitteddUser,
      {required bool isProhibited}) {
    return ConditionalWidgetWrapper(
      condition: !isProhibited,
      wrapper: (context, child) {
        return Container(
          decoration: BoxDecoration(
              border: Border(left: BorderSide(color: middleBgColor))),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: child,
          ),
        );
      },
      child: CupertinoButton(
        minSize: 0,
        padding: EdgeInsets.zero,
        onPressed: () {
          // TODO Switch user
          // find correct block to update
          var block =
              getBlocksOfSelectedDocument.singleWhere((b) => b.id == blockId);

          if (isProhibited) {
            // add user to permitted users
            setState(() {
              var newPermittedUsers =
                  (block.permittedUsers as List<UserIdentifier>?) ?? [];
              newPermittedUsers.add(permitteddUser.userId);
            });
          } else {
            // remove user from permitted users
            setState(() {
              var newPermittedUsers =
                  (block.permittedUsers as List<UserIdentifier>?) ?? [];
              newPermittedUsers.removeWhere((u) => u == permitteddUser.userId);
            });
          }
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: darkColor,
              ),
              child: CustomFaIcon(
                  icon: isProhibited
                      ? FontAwesomeIcons.chevronRight
                      : FontAwesomeIcons.chevronLeft),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
