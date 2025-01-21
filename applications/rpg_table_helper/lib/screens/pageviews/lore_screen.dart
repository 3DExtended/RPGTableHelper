import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rpg_table_helper/components/colored_rotated_square.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/notes/lore_block_rendering_editable.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.enums.swagger.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/context_extension.dart';
import 'package:rpg_table_helper/helpers/date_time_extensions.dart';
import 'package:rpg_table_helper/helpers/iterable_extension.dart';
import 'package:rpg_table_helper/helpers/list_extensions.dart';
import 'package:rpg_table_helper/helpers/modals/show_edit_lore_page_title.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/note_documents_service.dart';
import 'package:rpg_table_helper/services/rpg_entity_service.dart';
import 'package:rpg_table_helper/services/systemclock_service.dart';

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

  final String otherGroupName = "Sonstiges"; // TODO localize

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
      selectedDocument?.creatingUserId?.$value == _myUser?.$value &&
      context.isTablet; // disable editing on mobile

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await _reloadAllPages();
      setState(() {
        if (!isInTestEnvironment) {
          // so we can see the navbar in golden tests
          _isNavbarCollapsed = !context.isTablet;
        }
      });
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
                                    id: NoteDocumentIdentifier(
                                        $value:
                                            "00000000-0000-0000-0000-000000000000"),
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
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          onPressed: () async {
                            await showEditLorePageTitle(
                              context,
                              allGroupTitles: groupLabels,
                              currentGroupTitle: selectedDocument!.groupName,
                              currentTitle: selectedDocument!.title,
                            ).then((value) async {
                              if (value == null) return;

                              setState(() {
                                isLoading = true;
                              });

                              var updatedDocument = selectedDocument!.copyWith(
                                title: value.title,
                                groupName: value.groupName,
                                lastModifiedAt: systemClock.now(),
                              );

                              // update document
                              var service = DependencyProvider.of(context)
                                  .getService<INoteDocumentService>();
                              var updateResult =
                                  await service.updateDocumentForCampagne(
                                      dto: updatedDocument);

                              if (!mounted || !context.mounted) return;
                              await updateResult.possiblyHandleError(context);
                              if (!mounted || !context.mounted) return;

                              setState(() {
                                isLoading = false;

                                if (updateResult.isSuccessful) {
                                  if (!groupedDocuments
                                      .containsKey(value.groupName)) {
                                    groupedDocuments[value.groupName] = [];
                                  }

                                  var indexToRemove = groupedDocuments[
                                          selectedDocument!.groupName]!
                                      .indexWhere(
                                          (d) => d.id == selectedDocument!.id);
                                  if (indexToRemove >= 0) {
                                    groupedDocuments[
                                            selectedDocument!.groupName]!
                                        .removeAt(indexToRemove);
                                  }

                                  selectedDocument = updatedDocument;

                                  groupedDocuments[value.groupName]!
                                      .add(updatedDocument);

                                  groupLabels = [
                                    ...groupedDocuments.keys,
                                    otherGroupName
                                  ].distinct(by: (e) => e).toList();
                                  groupLabels.sort();
                                }
                              });
                            });
                          },
                          icon: CustomFaIcon(
                              noPadding: true,
                              icon: FontAwesomeIcons.penToSquare,
                              size: 20,
                              color: darkColor),
                          variant: CustomButtonVariant.FlatButton,
                        ),
                    ],
                  ),
                  Text(
                    "Autor: ${_myUser?.$value == selectedDocument!.creatingUserId!.$value! ? "Du" : (usersInCampagne.firstWhereOrNull((u) => u.userId.$value == selectedDocument!.creatingUserId!.$value!)?.playerCharacterName ?? "DM")}",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: darkTextColor,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                selectedDocument!.lastModifiedAt!
                    .format("%H:%M %d.%m.%Y"), // TODO localize
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
      result.add(Builder(builder: (context) {
        assert(block.id != null);

        return LoreBlockRenderingEditable(
            key: ValueKey(block.id),
            block: block,
            usersInCampagne: usersInCampagne,
            updatePermittedUsersOnBlock: _updatePermittedUsersOnBlock,
            isUserAllowedToEdit: _isAllowedToEdit,
            updateTextContent: (String newText) async {
              if (block is! TextBlock && block is! ImageBlock) {
                assert(false); // we should not come here...
                return false;
              }

              if (block is TextBlock) {
                var textBlockCopy = (block).copyWith(markdownText: newText);

                return await updateTextBlock(context, textBlockCopy);
              } else if (block is ImageBlock) {
                var imageBlockCopy = (block).copyWith(markdownText: newText);

                return await updateImageBlock(context, imageBlockCopy);
              }

              return false;
            },
            updateImageContent: (String pathToImageToUpload) async {
              if (block is! ImageBlock) {
                assert(
                    false); // we should not come here... images should run another update method
                return false;
              }

              // TODO make me
              // var textBlockCopy = (block).copyWith(markdownText: newText);
              // return await updateTextBlock(context, textBlockCopy);
              return false;
            },
            deleteBlock: () async {
              var service = DependencyProvider.of(context)
                  .getService<INoteDocumentService>();
              var deleteResult = await service.deleteNoteBlock(
                blockIdToDelete: block.id!,
              );

              if (!mounted || !context.mounted) return false;
              await deleteResult.possiblyHandleError(context);
              if (!mounted || !context.mounted) return false;
              if (deleteResult.isSuccessful == false) return false;

              setState(() {
                if (block is TextBlock) {
                  selectedDocument!.textBlocks
                      .removeWhere((b) => b.id == block.id);
                } else if (block is ImageBlock) {
                  selectedDocument!.imageBlocks
                      .removeWhere((b) => b.id == block.id);
                }
              });
              return true;
            },
            isShowingPermittedUsers: _isVisibleForBarCollapsed,
            toggleIsVisibleForBarCollapsed: () {
              setState(() {
                _isVisibleForBarCollapsed = !_isVisibleForBarCollapsed;
              });
            });
      }));
    }

    if (_isAllowedToEdit) {
      result.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Wrap(
            runAlignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              CustomButton(
                variant: CustomButtonVariant.AccentButton,
                onPressed: () async {
                  var service = DependencyProvider.of(context)
                      .getService<INoteDocumentService>();
                  var createResult =
                      await service.createNewTextBlockForDocument(
                          textBlockToCreate: TextBlock(
                            creationDate: DateTime.now(),
                            lastModifiedAt: DateTime.now(),
                            creatingUserId: _myUser,
                            id: NoteBlockModelBaseIdentifier(
                                $value: "00000000-0000-0000-0000-000000000000"),
                            isDeleted: false,
                            permittedUsers: [],
                            visibility:
                                NotesBlockVisibility.hiddenforallexceptauthor,
                            markdownText: "",
                            noteDocumentId: selectedDocument!.id,
                          ),
                          notedocumentid: selectedDocument!.id!);

                  if (!context.mounted || !mounted) return;
                  await createResult.possiblyHandleError(context);
                  if (!context.mounted || !mounted) return;

                  if (createResult.isSuccessful) {
                    setState(() {
                      selectedDocument!.textBlocks.add(createResult.result!);
                    });
                  }
                },
                label: "Absatz",
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.plus,
                  size: iconSizeInlineButtons,
                  color: textColor,
                ),
              ),
              CustomButton(
                variant: CustomButtonVariant.AccentButton,
                onPressed: () async {
                  var connectionDetails =
                      ref.read(connectionDetailsProvider).requireValue;
                  var campagneId = connectionDetails.campagneId;
                  if (campagneId == null) return;

                  final ImagePicker picker = ImagePicker();
                  try {
                    var pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 4196 * 2,
                      maxHeight: 4196 * 2,
                      requestFullMetadata: false,
                    );
                    setState(() {
                      isLoading = true;
                    });
                    final mimeType = lookupMimeType(pickedFile!.path);

                    if (mimeType == null || !(mimeType.startsWith('image/'))) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Invalid image file selected.")));
                      setState(() {
                        isLoading = false;
                      });
                      return;
                    }

                    final fileName = pickedFile.path.split('/').last;

                    final multipartFile = await MultipartFile.fromPath(
                      'image',
                      pickedFile.path,
                      contentType: MediaType.parse(mimeType),
                      filename: fileName,
                    );
                    if (!context.mounted) return;
                    var service = DependencyProvider.of(context)
                        .getService<IRpgEntityService>();
                    var response = await service.uploadImageToCampagneStorage(
                        campagneId: CampagneIdentifier($value: campagneId),
                        image: multipartFile);

                    if (!context.mounted) return;
                    await response.possiblyHandleError(context);
                    if (!context.mounted) return;

                    if (response.isSuccessful && response.result != null) {
                      // structure: $"/public/getimage/{newMetadata.Id.Value}/{apikey}?metadataid={newMetadata.Id.Value}";
                      var imageUrl = response.result!;

                      // extract metadata id from url
                      var urlSplits = imageUrl.split("?metadataid=");
                      var publicUrl = urlSplits[0];
                      var metadataId = urlSplits[1];

                      var service = DependencyProvider.of(context)
                          .getService<INoteDocumentService>();
                      var createResult =
                          await service.createNewImageBlockForDocument(
                              imageBlockToCreate: ImageBlock(
                                creationDate: DateTime.now(),
                                lastModifiedAt: DateTime.now(),
                                creatingUserId: _myUser,
                                id: NoteBlockModelBaseIdentifier(
                                    $value:
                                        "00000000-0000-0000-0000-000000000000"),
                                isDeleted: false,
                                permittedUsers: [],
                                visibility: NotesBlockVisibility
                                    .hiddenforallexceptauthor,
                                noteDocumentId: selectedDocument!.id,
                                imageMetaDataId:
                                    ImageMetaDataIdentifier($value: metadataId),
                                publicImageUrl: publicUrl,
                              ),
                              notedocumentid: selectedDocument!.id!);

                      if (!context.mounted || !mounted) return;
                      await createResult.possiblyHandleError(context);
                      if (!context.mounted || !mounted) return;

                      if (createResult.isSuccessful) {
                        setState(() {
                          selectedDocument!.imageBlocks
                              .add(createResult.result!);
                        });
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                  } catch (e) {
                    print("------------------------");
                    print("------------------------");
                    print("Image picker exception: ");
                    print(e);
                    print("------------------------");
                    print("------------------------");
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                label: "Bild",
                icon: CustomFaIcon(
                  icon: FontAwesomeIcons.plus,
                  size: iconSizeInlineButtons,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    return result.insertBetween(Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: HorizontalLine(),
    ));
  }

  Future<bool> updateTextBlock(
      BuildContext context, TextBlock textBlockCopy) async {
    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var updateResult =
        await service.updateTextBlock(textBlockToUpdate: textBlockCopy);

    if (!mounted || !context.mounted) return false;
    await updateResult.possiblyHandleError(context);
    if (!mounted || !context.mounted) return false;
    if (updateResult.isSuccessful == false) return false;

    var indexOfTextBlockToUpdate = selectedDocument!.textBlocks
        .indexWhere((tb) => tb.id!.$value == textBlockCopy.id!.$value);

    assert(indexOfTextBlockToUpdate >= 0);
    setState(() {
      selectedDocument!.textBlocks[indexOfTextBlockToUpdate] = textBlockCopy;

      var indexToRemove = groupedDocuments[selectedDocument!.groupName]!
          .indexWhere((d) => d.id == selectedDocument!.id);
      assert(indexToRemove >= 0);

      groupedDocuments[selectedDocument!.groupName]![indexToRemove] =
          selectedDocument!;

      selectedDocument = selectedDocument!
          .copyWith(textBlocks: [...selectedDocument!.textBlocks]);
    });

    return updateResult.isSuccessful;
  }

  Future<bool> updateImageBlock(
      BuildContext context, ImageBlock imageBlockCopy) async {
    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var updateResult =
        await service.updateImageBlock(imageBlockToUpdate: imageBlockCopy);

    if (!mounted || !context.mounted) return false;
    await updateResult.possiblyHandleError(context);
    if (!mounted || !context.mounted) return false;
    if (updateResult.isSuccessful == false) return false;

    var indexOfImageBlockToUpdate = selectedDocument!.imageBlocks
        .indexWhere((tb) => tb.id!.$value == imageBlockCopy.id!.$value);

    assert(indexOfImageBlockToUpdate >= 0);
    setState(() {
      selectedDocument!.imageBlocks[indexOfImageBlockToUpdate] = imageBlockCopy;

      var indexToRemove = groupedDocuments[selectedDocument!.groupName]!
          .indexWhere((d) => d.id == selectedDocument!.id);
      assert(indexToRemove >= 0);

      groupedDocuments[selectedDocument!.groupName]![indexToRemove] =
          selectedDocument!;

      selectedDocument = selectedDocument!
          .copyWith(imageBlocks: [...selectedDocument!.imageBlocks]);
    });

    return updateResult.isSuccessful;
  }

  Future<void> _updatePermittedUsersOnBlock(
      List<UserIdentifier> newPermittedUsers, dynamic block) async {
    newPermittedUsers = newPermittedUsers
        .where(
            (u) => usersInCampagne.any((uic) => uic.userId.$value == u.$value))
        .toList();

    if (block is TextBlock) {
      block = (block).copyWith(
        visibility: _recalculateBlockVisibility(block),
        permittedUsers: newPermittedUsers,
      );

      await updateTextBlock(context, block);
    } else if (block is ImageBlock) {
      block = (block).copyWith(
        visibility: _recalculateBlockVisibility(block),
        permittedUsers: newPermittedUsers,
      );

      await updateImageBlock(context, block);
    }
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
