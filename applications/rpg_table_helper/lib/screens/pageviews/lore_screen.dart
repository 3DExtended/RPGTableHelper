import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quest_keeper/components/colored_rotated_square.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/notes/lore_block_rendering_editable.dart';
import 'package:quest_keeper/components/notes/note_block_menu.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/arcane_ledger_lore_chrome.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_level_seal.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/context_extension.dart';
import 'package:quest_keeper/helpers/phone_layout.dart';
import 'package:quest_keeper/helpers/date_time_extensions.dart';
import 'package:quest_keeper/helpers/iterable_extension.dart';
import 'package:quest_keeper/helpers/list_extensions.dart';
import 'package:quest_keeper/helpers/modals/show_edit_lore_page_title.dart';
import 'package:quest_keeper/helpers/modals/show_generate_lore_image_modal.dart';
import 'package:quest_keeper/helpers/note_document_grouping.dart';
import 'package:quest_keeper/helpers/note_block_order.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/note_documents_service.dart';
import 'package:quest_keeper/services/notes/note_access_notification_controller.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/snack_bar_service.dart';
import 'package:quest_keeper/services/sse/events_client.dart';
import 'package:quest_keeper/services/systemclock_service.dart';
import 'package:themed/themed.dart';

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

  /// Decorated skins (Ledger/Cartographer) draw a frame ~10px inset from the
  /// sidebar edge; the plain [collapsedWidth] only leaves ~3px of clearance
  /// for the collapse button once centered, so give it more breathing room.
  double get _collapsedNavbarWidth =>
      isDecoratedSheetSkinActive(context) ? 96.0 : collapsedWidth;

  /// Width of [_getCollapsableNavbar]'s AnimatedContainer for the current
  /// collapsed/expanded state. On narrow (`useStackOption`) layouts the
  /// navbar overlays the content in a [Stack], so content must reserve
  /// exactly this much left padding — otherwise an expanded navbar draws
  /// over the content instead of the content sitting beside/below it.
  double get _currentNavbarWidth => _isNavbarCollapsed
      ? _collapsedNavbarWidth
      : _expandedNavbarWidth;

  double get _expandedNavbarWidth =>
      isDecoratedSheetSkinActive(context) ? 320.0 : expandedWidth;

  /// "+ New" and the chevron need about this much of the list's width.
  static const double _minWidthForListFooter = 200;

  /// Phones: the open document list lies over the content (SP-8) and is at
  /// most this wide, so a strip of the page stays visible to tap it away.
  double _overlayNavbarWidth(double availableWidth) => _isNavbarCollapsed
      ? _collapsedNavbarWidth
      : min(_expandedNavbarWidth, max(_collapsedNavbarWidth, availableWidth - 56));

  bool get _amIDm =>
      usersInCampagne.firstWhereOrNull((u) => u.isYou)?.isDm ??
      ref.read(connectionDetailsProvider).value?.isDm ??
      false;

  /// The group that is always listed and takes new documents. Players get
  /// their own group (B10), so their notes do not end up between the DM's.
  String get otherGroupName => _amIDm
      ? S.of(context).defaultGroupNameForDocuments
      : S.of(context).myNotesGroupName;

  var refreshController = RefreshController(
    initialRefreshStatus: RefreshStatus.refreshing,
    initialRefresh: false,
  );

  List<NoteDocumentPlayerDescriptorDto> usersInCampagne = [];

  NoteAccessNotificationController? _noteAccessController;

  int numberOfDocumentsForThisPlayer = 0;
  UserIdentifier? get _myUser =>
      usersInCampagne.firstWhereOrNull((u) => u.isYou)?.userId;

  /// Owners edit their documents on every device, phones included (B1).
  bool get _isAllowedToEdit =>
      selectedDocument?.creatingUserId?.value != null &&
      selectedDocument?.creatingUserId?.value == _myUser?.value;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await _reloadAllPages();
      if (!mounted) return;
      setState(() {
        if (!isInTestEnvironment) {
          // so we can see the navbar in golden tests
          // Phones start on the document. Without any document the list
          // stays open, so "+ New" is in sight.
          _isNavbarCollapsed = _isOverlayLayout
              ? selectedDocument != null
              : !context.isTablet;
        }
      });
      await _startNoteAccessNotifications();
    });
    super.initState();
  }

  @override
  void dispose() {
    _noteAccessController?.stop();
    super.dispose();
  }

  /// sse-07: listens for membership-scoped `noteAccessChanged` notifies -
  /// even without an active table session - so a revoked share disappears
  /// from this player's lore immediately, and a granted/updated share is
  /// picked up via a fresh `GET /Notes/getdocuments/{campagneId}`.
  Future<void> _startNoteAccessNotifications() async {
    if (!mounted) return;
    final eventsClient = DependencyProvider.of(context).getService<EventsClient>();
    await eventsClient.ensureConnected();
    if (!mounted) return;

    _noteAccessController ??= NoteAccessNotificationController(
      eventsClient: eventsClient,
      onNoteAccessChanged: _onNoteAccessChanged,
    );
    _noteAccessController!.start();
  }

  void _onNoteAccessChanged(NoteAccessChangedEvent event) {
    if (!mounted) return;

    final currentCampagneId =
        ref.read(connectionDetailsProvider).value?.campagneId;
    if (currentCampagneId == null || currentCampagneId != event.campagneId) {
      return;
    }

    switch (event.changeKind) {
      case NoteAccessChangeKind.revoked:
        _dropRevokedContentFromLocalLore(event);
        break;
      case NoteAccessChangeKind.granted:
      case NoteAccessChangeKind.updated:
        // Background refresh: keep the editors mounted so text the user is
        // currently typing survives someone else sharing/updating a note.
        _reloadAllPages(showLoadingSpinner: false);
        break;
    }
  }

  /// Drops the document/block named in a `revoked` [event] from local lore
  /// state immediately, without waiting for a refetch.
  void _dropRevokedContentFromLocalLore(NoteAccessChangedEvent event) {
    setState(() {
      if (event.blockId == null) {
        // document-level revoke (document deleted, or all its blocks lost)
        for (final group in groupedDocuments.keys.toList()) {
          groupedDocuments[group]
              ?.removeWhere((d) => d.id?.value == event.documentId);
        }

        if (selectedDocument?.id?.value == event.documentId) {
          selectedDocument = null;
          selectedDocumentId = null;
        }
        return;
      }

      for (final group in groupedDocuments.keys) {
        final doc = groupedDocuments[group]
            ?.firstWhereOrNull((d) => d.id?.value == event.documentId);
        if (doc == null) continue;

        doc.textBlocks.removeWhere((b) => b.id?.value == event.blockId);
        doc.imageBlocks.removeWhere((b) => b.id?.value == event.blockId);
      }

      if (selectedDocument?.id?.value == event.documentId) {
        selectedDocument!.textBlocks
            .removeWhere((b) => b.id?.value == event.blockId);
        selectedDocument!.imageBlocks
            .removeWhere((b) => b.id?.value == event.blockId);
      }
    });
  }

  /// Narrow screens (phones held upright): the document list is an overlay
  /// over the content (SP-8). Wider screens keep it beside the content.
  bool get _isOverlayLayout =>
      MediaQuery.sizeOf(context).width < phoneShortestSideMax;

  @override
  Widget build(BuildContext context) {
    final ledger = isDecoratedSheetSkinActive(context);

    if (_isOverlayLayout) {
      // The content always keeps only the collapsed strip free. The open
      // list lies over it with a scrim; tapping the scrim closes the list.
      return LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: _collapsedNavbarWidth),
              child: _getContent(),
            ),
            if (!_isNavbarCollapsed)
              Positioned.fill(
                child: GestureDetector(
                  key: const ValueKey('loreDocumentListScrim'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _isNavbarCollapsed = true;
                    });
                  },
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
              ),
            _getCollapsableNavbar(
              overlayWidth: _overlayNavbarWidth(constraints.maxWidth),
            ),
          ],
        );
      });
    }

    if (!context.isTablet) {
      // Wide screens that are no tablet by aspect ratio (e.g. iPad mini in
      // landscape): the list lies on top of the content, as before.
      return Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: _currentNavbarWidth),
            child: _getContent(),
          ),
          _getCollapsableNavbar(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // collapsable navbar
        _getCollapsableNavbar(),

        // Mock: binder rings (Ledger) or thin atlas rule (Cartographer) between panes.
        if (ledger && !_isNavbarCollapsed)
          isNightCartographerActive(context)
              ? const CartographerLoreDivider()
              : const LedgerBinderSpine(),

        // content
        Expanded(
          child: _getContent(),
        ),
      ],
    );
  }

  /// Selects [doc]. On phones the document list then closes, so the
  /// document is in view.
  void _selectDocument(NoteDocumentDto doc) {
    setState(() {
      selectedDocument = doc;
      selectedDocumentId = doc.id;
      if (_isOverlayLayout) {
        _isNavbarCollapsed = true;
      }
    });
  }

  /// [overlayWidth] is set on phones, where the list lies over the content.
  Widget _getCollapsableNavbar({double? overlayWidth}) {
    final ledger = isDecoratedSheetSkinActive(context);
    final theme = CustomThemeProvider.of(context).theme;
    final Color sidebarColor;
    if (ledger) {
      // Parchment chrome shows through — no solid classic sidebar panel.
      sidebarColor = Colors.transparent;
    } else if (CustomThemeProvider.of(context).brightnessNotifier.value ==
        Brightness.light) {
      sidebarColor = theme.middleBgColor;
    } else {
      sidebarColor = theme.bgColor.darker(0.2);
    }

    BoxDecoration? overlayDecoration;
    if (overlayWidth != null) {
      final open = !_isNavbarCollapsed;
      // An open list covers the content, so it needs a solid backing - on
      // decorated skins the page's own paper or star chart.
      DecorationImage? backing;
      if (open && isArcaneLedgerActive(context)) {
        backing = const DecorationImage(
          image: AssetImage(ArcaneLedgerAssets.parchment),
          fit: BoxFit.cover,
          opacity: 0.82,
        );
      } else if (open && isNightCartographerActive(context)) {
        backing = const DecorationImage(
          image: AssetImage(NightCartographerAssets.constellation),
          fit: BoxFit.cover,
          opacity: 0.55,
        );
      }
      overlayDecoration = BoxDecoration(
        color: open && ledger ? theme.bgColor : sidebarColor,
        image: backing,
        boxShadow: open
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(2, 0),
                ),
              ]
            : null,
      );
    }

    return AnimatedContainer(
      duration: duration,
      width: overlayWidth ?? _currentNavbarWidth,
      color: overlayDecoration == null ? sidebarColor : null,
      decoration: overlayDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: ledger ? 20 : 5,
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
                                        ? CustomThemeProvider.of(context)
                                            .theme
                                            .accentColor
                                            .withAlpha(25)
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
                                            Widget listChild =
                                                LongPressDraggable<
                                                    NoteDocumentDto>(
                                              hapticFeedbackOnStart: true,
                                              key: ValueKey(doc.id!.value!),
                                              data: doc,
                                              feedback: SizedBox(
                                                width: expandedWidth,
                                                child: _getDocumentDragChild(
                                                    doc, context),
                                              ),
                                              child: _getDocumentDragChild(
                                                  doc, context),
                                            );
                                            if (ledger) {
                                              // Avoid CupertinoButton's primaryColor
                                              // tint — Ledger list ink stays dark.
                                              return GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () =>
                                                    _selectDocument(doc),
                                                child: listChild,
                                              );
                                            }
                                            return CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () =>
                                                  _selectDocument(doc),
                                              minimumSize: Size(0, 0),
                                              child: listChild,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: ledger ? 10 : 10),
            child: ledger
                ? const LedgerDoubleRule()
                : const HorizontalLine(
                    useDarkColor: true,
                  ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: ledger && !_isNavbarCollapsed ? 8 : 0,
              right: ledger && !_isNavbarCollapsed ? 8 : 0,
              bottom: ledger ? 22 : 0,
            ),
            // Collapsed: only the chevron remains, so center it explicitly —
            // a single child in a spaceBetween Row sits flush at the start
            // instead of centering, which let it collide with the
            // CharacterSheetSkinChrome frame border on decorated skins.
            // While the list is still opening (animated width), there is no
            // room for "+ New" yet either.
            child: LayoutBuilder(builder: (context, constraints) {
              return _isNavbarCollapsed ||
                      constraints.maxWidth < _minWidthForListFooter
                  ? Center(child: _getCollapseButton(duration))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: ledger ? 20.0 : 20.0,
                            bottom: ledger ? 0 : 10,
                          ),
                          child: _buildNewDocumentButton(ledger),
                        ),
                        _getCollapseButton(duration),
                      ],
                    );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNewDocumentButton(bool ledger) {
    Future<void> onPressed() async {
      var campagneId =
          ref.read(connectionDetailsProvider).value?.campagneId;
      if (campagneId == null) {
        return;
      }

      var systemClock =
          DependencyProvider.of(context).getService<ISystemClockService>();

      setState(() {
        isLoading = true;
      });

      var newDocument = NoteDocumentDto(
        // the group of the selected document, if it is mine (B10)
        groupName: groupNameForNewNoteDocument(
          selectedDocument: selectedDocument,
          myUserId: _myUser?.value,
          defaultGroupName: otherGroupName,
        ),
        title:
            "${S.of(context).documentDefaultNamePrefix} #${numberOfDocumentsForThisPlayer + 1}",
        createdForCampagneId: CampagneIdentifier(value: campagneId),
        lastModifiedAt: systemClock.now(),
        creationDate: systemClock.now(),
        creatingUserId: _myUser,
        isDeleted: false,
        imageBlocks: [],
        textBlocks: [],
        id: NoteDocumentIdentifier(
            value: "00000000-0000-0000-0000-000000000000"),
      );

      var service =
          DependencyProvider.of(context).getService<INoteDocumentService>();
      var createResult = await service.createNewDocumentForCampagne(
        dto: newDocument,
      );

      if (!mounted || !context.mounted) return;
      await createResult.possiblyHandleError(context);
      if (!mounted || !context.mounted) return;

      setState(() {
        isLoading = false;
        if (createResult.isSuccessful) {
          newDocument = newDocument.copyWith(id: createResult.result!);

          if (!groupedDocuments.containsKey(newDocument.groupName)) {
            groupedDocuments[newDocument.groupName] = [];
          }
          groupedDocuments[newDocument.groupName]!.add(newDocument);

          groupedDocuments[newDocument.groupName]!.sortBy((e) => e.title);
          if (!groupLabels.contains(newDocument.groupName)) {
            groupLabels = [...groupLabels, newDocument.groupName]..sort();
          }
          numberOfDocumentsForThisPlayer++;

          // select new document; on phones close the list to show it
          selectedDocument = newDocument;
          selectedDocumentId = newDocument.id;
          if (_isOverlayLayout) {
            _isNavbarCollapsed = true;
          }
        }
      });
    }

    if (ledger) {
      return LedgerOutlinedAccentButton(
        onPressed: onPressed,
        label: '+ ${S.of(context).newItem}',
      );
    }

    return CustomButton(
      onPressed: onPressed,
      icon: CustomFaIcon(
        icon: FontAwesomeIcons.plus,
        size: iconSizeInlineButtons,
        color: CustomThemeProvider.of(context).theme.textColor,
      ),
      label: S.of(context).newItem,
      variant: CustomButtonVariant.AccentButton,
    );
  }

  Widget _getDocumentDragChild(NoteDocumentDto doc, BuildContext context) {
    final ledger = isDecoratedSheetSkinActive(context);
    final selected = selectedDocumentId?.value == doc.id?.value;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ledger ? 32 : 5,
        vertical: ledger ? 3 : 5,
      ),
      child: Row(
        mainAxisAlignment:
            ledger ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          if (ledger)
            LedgerLoreListDiamond(
              key: ValueKey("ColoredRotatedSquare${doc.id!.value!}"),
              selected: selected,
            )
          else
            ColoredRotatedSquare(
              key: ValueKey("ColoredRotatedSquare${doc.id!.value!}"),
              isSolidSquare: selected,
              color: CustomThemeProvider.of(context).theme.accentColor,
            ),
          if (!_isNavbarCollapsed)
            Expanded(
              child: Text(
                doc.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: ledger ? 17 : 16,
                      fontFamily: ledger ? 'Ruwudu' : null,
                      fontWeight: FontWeight.w400,
                      color:
                          CustomThemeProvider.of(context).theme.darkTextColor,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  /// Below this height (e.g. iPad landscape with the software keyboard open)
  /// the decorative document header and footer are dropped so the text
  /// editor keeps enough room.
  static const double _compactContentMaxHeight = 480;

  Widget _getContent() {
    return LayoutBuilder(
      builder: (context, constraints) => _getContentForHeight(
        compact: constraints.maxHeight < _compactContentMaxHeight,
      ),
    );
  }

  Widget _getContentForHeight({required bool compact}) {
    if (isLoading) {
      return Column(
        children: [
          Center(
            child: CustomLoadingSpinner(),
          )
        ],
      );
    }

    final ledger = isDecoratedSheetSkinActive(context);
    final ink = CustomThemeProvider.of(context).theme.darkTextColor;
    final authorName = selectedDocument == null
        ? ''
        : (_myUser?.value == selectedDocument!.creatingUserId!.value!
            ? S.of(context).you
            : (usersInCampagne
                    .firstWhereOrNull((u) =>
                        u.userId.value ==
                        selectedDocument!.creatingUserId!.value!)
                    ?.playerCharacterName ??
                S.of(context).dm));

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            ledger ? 28.0 : 20.0,
            compact ? 8.0 : (ledger ? 24.0 : 20.0),
            ledger ? 28.0 : 20.0,
            ledger ? 6 : 3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: ledger
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            selectedDocument?.title ?? "",
                            maxLines: compact ? 1 : null,
                            overflow: compact ? TextOverflow.ellipsis : null,
                            textAlign:
                                ledger ? TextAlign.center : TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: ink,
                                  fontSize: ledger
                                      ? (compact ? 22 : 34)
                                      : (compact ? 18 : 24),
                                  fontFamily: ledger ? 'Ruwudu' : null,
                                  fontWeight:
                                      ledger ? FontWeight.w600 : FontWeight.w500,
                                  height: 1.05,
                                ),
                          ),
                        ),
                        if (_isAllowedToEdit == true)
                          CustomButton(
                            onPressed: () async {
                              await modalBasedEditPageEdit(context);
                            },
                            icon: CustomFaIcon(
                                noPadding: true,
                                icon: FontAwesomeIcons.penToSquare,
                                size: 20,
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkColor),
                            variant: CustomButtonVariant.FlatButton,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (selectedDocument != null && !compact) ...[
                SizedBox(height: ledger ? 10 : 4),
                if (ledger)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${S.of(context).authorLabel} $authorName',
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: ink.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontFamily: 'Ruwudu',
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _ledgerManuscriptDate(
                            selectedDocument!.lastModifiedAt!.toLocal()),
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: ink.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontFamily: 'Ruwudu',
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  )
                else
                  // Author left, time right; on a narrow page the time
                  // moves to the next line instead of overflowing (B7).
                  SizedBox(
                    key: const ValueKey('loreDocumentAuthorAndTime'),
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 2,
                      children: [
                        Text(
                          ("${S.of(context).authorLabel} $authorName"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelLarge!.copyWith(
                                    color: ink,
                                    fontSize: 12,
                                  ),
                        ),
                        Text(
                          // The server sends UTC; show the reader's local time.
                          selectedDocument!.lastModifiedAt!.toLocal().format(
                              S.of(context).hourMinutesDayMonthYearFormatString),
                          textAlign: TextAlign.end,
                          style:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: ink,
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        // Always one child here (no `if`): changing the child count before
        // the Expanded below would remount it and kill an open editor.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ledger ? 28 : 20),
          child: ledger
              ? (compact
                  ? const SizedBox(height: 4)
                  : const LedgerStarRule(height: 22, horizontalInset: 0))
              : const HorizontalLine(
                  useDarkColor: true,
                ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                ledger ? 28.0 : 20.0,
                ledger ? 8 : 0,
                ledger ? 28.0 : 20,
                20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _renderContentBlocks(),
              ),
            ),
          ),
        ),
        if (ledger && selectedDocument != null && !compact)
          const LedgerLorePageFooter(),
      ],
    );
  }

  Widget _getCollapseButton(Duration duration) {
    final ledger = isDecoratedSheetSkinActive(context);
    return AnimatedPadding(
      duration: duration,
      padding: EdgeInsets.fromLTRB(
        10,
        0,
        10,
        ledger ? 0 : 10,
      ),
      child: AnimatedAlign(
        duration: duration,
        alignment:
            _isNavbarCollapsed ? Alignment.center : Alignment.centerRight,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              _isNavbarCollapsed = !_isNavbarCollapsed;
            });
          },
          minimumSize: Size(0, 0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: CustomThemeProvider.of(context).theme.darkColor,
                width: ledger ? 1.2 : 1.0,
              ),
              color: ledger
                  ? Colors.transparent
                  : CustomThemeProvider.of(context).theme.bgColor,
            ),
            padding: EdgeInsets.all(ledger ? 6 : 5),
            child: CustomFaIcon(
              icon: !_isNavbarCollapsed
                  ? FontAwesomeIcons.chevronLeft
                  : FontAwesomeIcons.chevronRight,
              color: CustomThemeProvider.of(context).theme.darkTextColor,
              size: ledger ? 18 : 24,
            ),
          ),
        ),
      ),
    );
  }

  Future _reloadAllPages({bool showLoadingSpinner = true}) async {
    var campagneId =
        ref.read(connectionDetailsProvider).value?.campagneId;
    if (campagneId == null) {
      return;
    }

    if (showLoadingSpinner) {
      setState(() {
        isLoading = true;
      });
    }
    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var documentsResponse = await service.getDocumentsForCampagne(
        campagneId: CampagneIdentifier(value: campagneId));

    if (!mounted) return;
    var rpgservice =
        DependencyProvider.of(context).getService<IRpgEntityService>();
    var loadedCharsResponse = await rpgservice.getUserDetailsForCampagne(
        campagneId: CampagneIdentifier(value: campagneId));

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

      // Groups A→Z, then titles A→Z within each group.
      groupedDocuments.forEach((key, list) {
        list.sort((a, b) => a.title.compareTo(b.title));
      });

      // TODO maybe show "sonstiges" only when needed?
      groupLabels = [...groupedDocuments.keys, otherGroupName]
          .distinct(by: (e) => e)
          .toList();
      groupLabels.sort();

      if (!groupedDocuments.containsKey(otherGroupName)) {
        groupedDocuments[otherGroupName] = [];
      }

      // Stay on the document the user is looking at (it may be open in an
      // editor) - only fall back to a default when it is gone.
      final previouslySelected = selectedDocumentId == null
          ? null
          : documentsResponse.result?.firstWhereOrNull(
              (d) => d.id?.value == selectedDocumentId!.value);
      if (previouslySelected != null) {
        selectedDocument = previouslySelected;
      } else if (documentsResponse.result?.isNotEmpty == true) {
        // Prefer Skadi in Ledger golden fixtures so lore content matches the mock.
        final preferredSkadi = isInTestEnvironment &&
                isArcaneLedgerActive(context)
            ? documentsResponse.result!
                .firstWhereOrNull((d) => d.title == 'Skadi')
            : null;
        // The first group label can be the (possibly empty) default group.
        final firstDocument = preferredSkadi ??
            groupLabels
                .map((label) => groupedDocuments[label] ?? const [])
                .firstWhere((docs) => docs.isNotEmpty)
                .first;
        selectedDocumentId = firstDocument.id;
        selectedDocument = firstDocument;
      } else {
        selectedDocumentId = null;
        selectedDocument = null;
      }

      isLoading = false;

      refreshController.loadComplete();
    });
  }

  Future<void> _onDocumentDropped(String sourceGroup, String targetGroup,
      int index, NoteDocumentDto doc) async {
    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();

    var updateResponse = await service.updateDocumentForCampagne(
      dto: doc.copyWith(groupName: targetGroup),
    );

    if (!mounted || !context.mounted) return;
    await updateResponse.possiblyHandleError(context);
    if (!mounted || !context.mounted) return;

    if (!updateResponse.isSuccessful) return;

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
    final ledger = isDecoratedSheetSkinActive(context);
    if (_isNavbarCollapsed) {
      return Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Container(
          width: 40,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: CustomThemeProvider.of(context).theme.bgColor))),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ledger ? 36 : 5,
        ledger ? 14 : 5,
        ledger ? 20 : 5,
        ledger ? 4 : 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: ledger ? 0 : 8.0),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: CustomThemeProvider.of(context).theme.darkTextColor,
                    fontSize: ledger ? 18 : 16,
                    fontFamily: ledger ? 'Ruwudu' : null,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (ledger)
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 2),
              child: LedgerStarRule(height: 16, horizontalInset: 0),
            ),
        ],
      ),
    );
  }

  List<dynamic> get getBlocksOfSelectedDocument {
    return sortNoteBlocksInDocumentOrder([
      ...selectedDocument!.imageBlocks,
      ...selectedDocument!.textBlocks
    ]);
  }

  List<Widget> _renderContentBlocks() {
    if (selectedDocument == null) return [];
    List<dynamic> blocks = getBlocksOfSelectedDocument;
    final ledger = isDecoratedSheetSkinActive(context);

    List<Widget> blockWidgets = [];

    for (var (index, block) in blocks.indexed) {
      final isFirst = index == 0;
      final isLast = index == blocks.length - 1;

      // Keyed on the list's direct child so a block keeps its editor state
      // (unsaved text, edit mode) when other blocks are added or removed.
      blockWidgets.add(Builder(key: ValueKey(block.id), builder: (context) {
        assert(block.id != null);

        return LoreBlockRenderingEditable(
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
            attachImage: block is TextBlock
                ? (source) => _attachImageToTextBlock(block, source)
                : null,
            replaceImage: block is ImageBlock
                ? (source) => _replaceImageOfImageBlock(block, source)
                : null,
            removeImage: block is ImageBlock
                ? () => _removeImageFromImageBlock(block)
                : null,
            moveUp: isFirst ? null : () => _moveBlock(block, up: true),
            moveDown: isLast ? null : () => _moveBlock(block, up: false),
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
                _markSelectedDocumentChangedNow();
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

    final divider = ledger
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: LedgerDoubleRule(),
          )
        : const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: HorizontalLine(),
          );

    if (!_isAllowedToEdit) {
      return blockWidgets.insertBetween(divider);
    }

    Widget addActionButton({
      required Future<void> Function() onPressed,
      required String label,
    }) {
      if (ledger) {
        return LedgerOutlinedAccentButton(
          onPressed: () {
            onPressed();
          },
          label: '+ $label',
        );
      }
      return CustomButton(
        variant: CustomButtonVariant.AccentButton,
        onPressed: onPressed,
        label: label,
        icon: CustomFaIcon(
          icon: FontAwesomeIcons.plus,
          size: iconSizeInlineButtons,
          color: CustomThemeProvider.of(context).theme.textColor,
        ),
      );
    }

    final addButtons = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Wrap(
          runAlignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            addActionButton(
              onPressed: () => _createTextBlock(),
              label: S.of(context).addParagraphBtnLabel,
            ),
            addActionButton(
              onPressed: () => _createImageBlock(NoteImageSource.upload),
              label: S.of(context).addImageBtnLabel,
            ),
            addActionButton(
              onPressed: () => _createImageBlock(NoteImageSource.generate),
              label: S.of(context).generateImageBtnLabel,
            ),
          ],
        ),
      ),
    );

    // Owners get a "+" on each divider (and above the first block) to insert
    // a block right there; the buttons below still add at the end.
    return [
      for (var (index, blockWidget) in blockWidgets.indexed) ...[
        _buildInsertDivider(
          before: blocks[index].id as NoteBlockModelBaseIdentifier,
          ledger: ledger,
        ),
        blockWidget,
      ],
      if (blockWidgets.isNotEmpty) divider,
      addButtons,
    ];
  }

  Widget _buildInsertDivider({
    required NoteBlockModelBaseIdentifier before,
    required bool ledger,
  }) {
    final theme = CustomThemeProvider.of(context).theme;
    final line = ledger ? const LedgerDoubleRule() : const HorizontalLine();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ledger ? 8 : 4),
      child: Row(
        children: [
          Expanded(child: line),
          Builder(builder: (anchorContext) {
            return CupertinoButton(
              key: ValueKey('insertNoteBlockBefore-${before.value}'),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
              onPressed: () => _showInsertMenu(anchorContext, before),
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.bgColor,
                  border: Border.all(
                    color: theme.darkColor.withValues(alpha: 0.5),
                  ),
                ),
                child: CustomFaIcon(
                  icon: FontAwesomeIcons.plus,
                  size: 12,
                  color: theme.darkColor,
                ),
              ),
            );
          }),
          Expanded(child: line),
        ],
      ),
    );
  }

  Future<void> _showInsertMenu(
      BuildContext anchorContext, NoteBlockModelBaseIdentifier before) async {
    final kind = await showNoteBlockMenu(anchorContext, [
      NoteBlockMenuItem(
        NoteBlockInsertKind.paragraph,
        FontAwesomeIcons.alignLeft,
        S.of(context).insertParagraphMenuLabel,
      ),
      NoteBlockMenuItem(
        NoteBlockInsertKind.uploadImage,
        FontAwesomeIcons.image,
        S.of(context).uploadImageMenuLabel,
      ),
      NoteBlockMenuItem(
        NoteBlockInsertKind.generateImage,
        FontAwesomeIcons.wandMagicSparkles,
        S.of(context).generateImageBtnLabel,
      ),
    ]);
    switch (kind) {
      case NoteBlockInsertKind.paragraph:
        await _createTextBlock(before: before);
      case NoteBlockInsertKind.uploadImage:
        await _createImageBlock(NoteImageSource.upload, before: before);
      case NoteBlockInsertKind.generateImage:
        await _createImageBlock(NoteImageSource.generate, before: before);
      case null:
        break;
    }
  }

  /// Creates an empty text block at the end, or right before [before].
  Future<void> _createTextBlock({NoteBlockModelBaseIdentifier? before}) async {
    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var createResult = await service.createNewTextBlockForDocument(
      textBlockToCreate: TextBlock(
        creationDate: DateTime.now(),
        lastModifiedAt: DateTime.now(),
        creatingUserId: _myUser,
        id: NoteBlockModelBaseIdentifier(
            value: "00000000-0000-0000-0000-000000000000"),
        isDeleted: false,
        permittedUsers: [],
        markdownText: "",
        noteDocumentId: selectedDocument!.id,
      ),
      notedocumentid: selectedDocument!.id!,
      insertBeforeBlockId: before,
    );

    if (!mounted) return;
    await createResult.possiblyHandleError(context);
    if (!mounted || !createResult.isSuccessful) return;

    if (before != null) {
      // the blocks after it moved down: take the server's order
      await _reloadSelectedDocument();
      return;
    }

    setState(() {
      selectedDocument!.textBlocks.add(createResult.result!);
      _markSelectedDocumentChangedNow();
    });
  }

  /// Creates an image block (uploaded or generated image) at the end, or
  /// right before [before].
  Future<void> _createImageBlock(NoteImageSource source,
      {NoteBlockModelBaseIdentifier? before}) async {
    final image = await _acquireImage(source);
    if (image == null || !mounted) return;

    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var createResult = await service.createNewImageBlockForDocument(
      imageBlockToCreate: ImageBlock(
        creationDate: DateTime.now(),
        lastModifiedAt: DateTime.now(),
        creatingUserId: _myUser,
        id: NoteBlockModelBaseIdentifier(
            value: "00000000-0000-0000-0000-000000000000"),
        isDeleted: false,
        permittedUsers: [],
        noteDocumentId: selectedDocument!.id,
        imageMetaDataId: image.imageMetaDataId,
        publicImageUrl: image.publicImageUrl,
      ),
      notedocumentid: selectedDocument!.id!,
      insertBeforeBlockId: before,
    );

    if (!mounted) return;
    await createResult.possiblyHandleError(context);
    if (!mounted || !createResult.isSuccessful) return;

    if (before != null) {
      await _reloadSelectedDocument();
      return;
    }

    setState(() {
      selectedDocument!.imageBlocks.add(createResult.result!);
      _markSelectedDocumentChangedNow();
    });
  }

  /// Uploads a picked image or lets the user generate one. Null if the user
  /// cancelled or something failed (errors are shown to the user).
  Future<NoteBlockImageDto?> _acquireImage(NoteImageSource source) async {
    var campagneId = ref.read(connectionDetailsProvider).requireValue.campagneId;
    if (campagneId == null) return null;

    final String? imageUrl;
    if (source == NoteImageSource.generate) {
      imageUrl = (await showGenerateLoreImageModal(context))?.publicUrl;
    } else {
      imageUrl = await _pickAndUploadImage(campagneId);
    }
    if (imageUrl == null) return null;

    // structure: $"/public/getimage/{newMetadata.Id.Value}/{apikey}?metadataid={newMetadata.Id.Value}";
    var urlSplits = imageUrl.split("?metadataid=");
    if (urlSplits.length != 2) return null;
    return NoteBlockImageDto(
      imageMetaDataId: ImageMetaDataIdentifier(value: urlSplits[1]),
      publicImageUrl: urlSplits[0],
    );
  }

  /// Lets the user pick an image from the gallery and uploads it to the
  /// campaign. Returns the image url (with `?metadataid=`), or null.
  Future<String?> _pickAndUploadImage(String campagneId) async {
    final ImagePicker picker = ImagePicker();
    try {
      var pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4196 * 2,
        maxHeight: 4196 * 2,
        requestFullMetadata: false,
      );
      if (pickedFile == null || !mounted) return null;

      setState(() {
        isLoading = true;
      });
      final mimeType = lookupMimeType(pickedFile.path);

      if (mimeType == null || !(mimeType.startsWith('image/'))) {
        if (!mounted) return null;
        DependencyProvider.of(context).getService<ISnackBarService>().showSnackBar(
              uniqueId:
                  "invalidImageFileSelected-df3316eb-aefa-4ed8-bedb-22efdde25522",
              snack: SnackBar(
                content: Text(S.of(context).invalidImageFileSelected),
              ),
            );
        return null;
      }

      final fileName = pickedFile.path.split('/').last;

      final multipartFile = await MultipartFile.fromPath(
        'image',
        pickedFile.path,
        contentType: MediaType.parse(mimeType),
        filename: fileName,
      );
      if (!mounted) return null;
      var service =
          DependencyProvider.of(context).getService<IRpgEntityService>();
      var response = await service.uploadImageToCampagneStorage(
          campagneId: CampagneIdentifier(value: campagneId),
          image: multipartFile);

      if (!mounted) return null;
      await response.possiblyHandleError(context);
      if (!response.isSuccessful) return null;
      return response.result;
    } catch (e) {
      return null;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Moves [block] one up or down, by putting it before its new successor.
  Future<void> _moveBlock(dynamic block, {required bool up}) async {
    final blocks = getBlocksOfSelectedDocument;
    final index = blocks.indexWhere((b) => b.id?.value == block.id?.value);
    if (index < 0) return;

    final NoteBlockModelBaseIdentifier? before;
    if (up) {
      if (index == 0) return;
      before = blocks[index - 1].id;
    } else {
      if (index >= blocks.length - 1) return;
      before = index + 2 < blocks.length ? blocks[index + 2].id : null;
    }

    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var response = await service.moveNoteBlock(
      blockId: block.id as NoteBlockModelBaseIdentifier,
      beforeBlockId: before,
    );

    if (!mounted) return;
    await response.possiblyHandleError(context);
    if (!mounted || !response.isSuccessful || response.result == null) return;
    _showUpdatedDocument(response.result!);
  }

  Future<bool> _attachImageToTextBlock(
      TextBlock block, NoteImageSource source) async {
    final image = await _acquireImage(source);
    if (image == null || !mounted) return false;

    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var response =
        await service.attachImageToTextBlock(blockId: block.id!, image: image);

    if (!mounted) return false;
    await response.possiblyHandleError(context);
    if (!mounted || !response.isSuccessful) return false;

    // the text block is gone and the image block has a new id
    await _reloadSelectedDocument();
    return true;
  }

  Future<bool> _replaceImageOfImageBlock(
      ImageBlock block, NoteImageSource source) async {
    final image = await _acquireImage(source);
    if (image == null || !mounted) return false;

    return await updateImageBlock(
      context,
      block.copyWith(
        imageMetaDataId: image.imageMetaDataId,
        publicImageUrl: image.publicImageUrl,
      ),
    );
  }

  Future<bool> _removeImageFromImageBlock(ImageBlock block) async {
    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var response = await service.removeImageFromImageBlock(blockId: block.id!);

    if (!mounted) return false;
    await response.possiblyHandleError(context);
    if (!mounted || !response.isSuccessful) return false;

    await _reloadSelectedDocument();
    return true;
  }

  /// Loads the selected document again, e.g. after its order changed.
  Future<void> _reloadSelectedDocument() async {
    final documentId = selectedDocument?.id;
    if (documentId == null) return;

    var service =
        DependencyProvider.of(context).getService<INoteDocumentService>();
    var response = await service.getDocument(notedocumentid: documentId);

    if (!mounted) return;
    await response.possiblyHandleError(context);
    if (!mounted || !response.isSuccessful || response.result == null) return;
    _showUpdatedDocument(response.result!);
  }

  /// The server dates a document by its latest change, its blocks included.
  /// After an own change show that time right away, not the time the
  /// document was loaded (B11). Call inside `setState`.
  void _markSelectedDocumentChangedNow() {
    final document = selectedDocument;
    if (document == null) return;

    final now =
        DependencyProvider.of(context).getService<ISystemClockService>().now();
    final touched = document.copyWith(lastModifiedAt: now);

    final group = groupedDocuments[document.groupName];
    final index =
        group?.indexWhere((d) => d.id?.value == document.id?.value) ?? -1;
    if (index >= 0) {
      group![index] = touched;
    }
    selectedDocument = touched;
  }

  /// Shows [document] in place of its older version.
  void _showUpdatedDocument(NoteDocumentDto document) {
    setState(() {
      final group = groupedDocuments[document.groupName];
      final index =
          group?.indexWhere((d) => d.id?.value == document.id?.value) ?? -1;
      if (index >= 0) {
        group![index] = document;
      }

      if (selectedDocument?.id?.value == document.id?.value) {
        selectedDocument = document;
      }
    });
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
        .indexWhere((tb) => tb.id!.value == textBlockCopy.id!.value);

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
      _markSelectedDocumentChangedNow();
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
        .indexWhere((tb) => tb.id!.value == imageBlockCopy.id!.value);

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
      _markSelectedDocumentChangedNow();
    });

    return updateResult.isSuccessful;
  }

  Future<void> _updatePermittedUsersOnBlock(
      List<UserIdentifier> newPermittedUsers, dynamic block) async {
    newPermittedUsers = newPermittedUsers
        .where(
            (u) => usersInCampagne.any((uic) => uic.userId.value == u.value))
        .toList();

    if (block is TextBlock) {
      block = (block).copyWith(
        permittedUsers: newPermittedUsers,
      );

      await updateTextBlock(context, block);
    } else if (block is ImageBlock) {
      block = (block).copyWith(
        permittedUsers: newPermittedUsers,
      );

      await updateImageBlock(context, block);
    }
  }

  Future<void> modalBasedEditPageEdit(BuildContext context) async {
    var systemClock =
        DependencyProvider.of(context).getService<ISystemClockService>();

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
      if (!context.mounted || !mounted) return;

      var service =
          DependencyProvider.of(context).getService<INoteDocumentService>();
      var updateResult =
          await service.updateDocumentForCampagne(dto: updatedDocument);

      if (!mounted || !context.mounted) return;
      await updateResult.possiblyHandleError(context);
      if (!mounted || !context.mounted) return;

      setState(() {
        isLoading = false;

        if (updateResult.isSuccessful) {
          if (!groupedDocuments.containsKey(value.groupName)) {
            groupedDocuments[value.groupName] = [];
          }

          var indexToRemove = groupedDocuments[selectedDocument!.groupName]!
              .indexWhere((d) => d.id == selectedDocument!.id);
          if (indexToRemove >= 0) {
            groupedDocuments[selectedDocument!.groupName]!
                .removeAt(indexToRemove);
          }

          selectedDocument = updatedDocument;

          groupedDocuments[value.groupName]!.add(updatedDocument);
          groupedDocuments[value.groupName]!.sortBy((e) => e.title);

          groupLabels = [...groupedDocuments.keys, otherGroupName]
              .distinct(by: (e) => e)
              .toList();
          groupLabels.sort();
        }
      });
    });
  }

  /// Matches `arcane-ledger-mock-lore.png` manuscript date line, in the
  /// reader's language ("December 9, 2024, 1:34 PM" / "9. Dezember 2024, 13:34").
  String _ledgerManuscriptDate(DateTime dt) {
    return DateFormat(
      S.of(context).ledgerManuscriptDateFormat,
      Localizations.localeOf(context).toString(),
    ).format(dt);
  }
}
