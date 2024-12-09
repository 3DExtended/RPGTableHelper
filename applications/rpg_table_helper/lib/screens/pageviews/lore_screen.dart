import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/colored_rotated_square.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/iterable_extension.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/note_documents_service.dart';

class LoreScreen extends ConsumerStatefulWidget {
  static String route = "lore";

  const LoreScreen({super.key});

  @override
  ConsumerState<LoreScreen> createState() => _LoreScreenState();
}

class _LoreScreenState extends ConsumerState<LoreScreen> {
  var isLoading = true;

  Map<String, List<NoteDocumentDto>> groupedDocuments = {};
  List<String> groupLabels = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await reloadAllPages();
    });
    super.initState();
  }

  bool _isCollapsed = false;
  double collapsedWidth = 64.0;
  double expandedWidth = 250.0;

  @override
  Widget build(BuildContext context) {
    var duration = Duration(milliseconds: 300);
    return Row(
      children: [
        // collapsable navbar
        AnimatedContainer(
          duration: duration,
          width: _isCollapsed ? collapsedWidth : expandedWidth,
          color: middleBgColor,
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: groupLabels.map((group) {
                      return DragTarget<NoteDocumentDto>(
                        key: ValueKey(group),
                        onWillAcceptWithDetails: (doc) => true,
                        onAcceptWithDetails: (details) {
                          final draggedDoc = details.data;
                          final index = groupedDocuments[group]?.length ?? 0;
                          onDocumentDropped(
                              draggedDoc.groupName, group, index, draggedDoc);
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            color: candidateData.isNotEmpty
                                ? Colors.blue[50]
                                : Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNavItem(group),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(0),
                                  itemCount:
                                      groupedDocuments[group]?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final doc = groupedDocuments[group]![index];
                                    return LongPressDraggable<NoteDocumentDto>(
                                      key: ValueKey(doc.id!.$value!),
                                      data: doc,
                                      feedback: SizedBox(
                                        width: expandedWidth,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 5, 20, 5),
                                          child: Text(
                                            doc.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall!
                                                .copyWith(
                                                  fontSize: 16,
                                                  color: darkTextColor,
                                                ),
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 5, 20, 5),
                                        child: Text(
                                          doc.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                                fontSize: 16,
                                                color: darkTextColor,
                                              ),
                                        ),
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

  Widget _getContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 500,
            width: 200,
            color: Colors.red,
          )
        ],
      ),
    );
  }

  AnimatedPadding _getCollapseButton(Duration duration) {
    return AnimatedPadding(
      duration: duration,
      padding: EdgeInsets.fromLTRB(0, 0, _isCollapsed ? 0 : 20, 20),
      child: AnimatedAlign(
        duration: duration,
        alignment: _isCollapsed ? Alignment.center : Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
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
    await documentsResponse.possiblyHandleError(context);
    if (!mounted) return;

    if (!documentsResponse.isSuccessful) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      var otherGroupName = "Sonstiges"; // TODO localize
      groupedDocuments =
          (documentsResponse.result ?? []).groupListsBy((d) => d.groupName);

      // TODO maybe show "sonstiges" only when needed?
      groupLabels = [...groupedDocuments.keys, otherGroupName]
          .distinct(by: (e) => e)
          .toList();

      if (!groupedDocuments.containsKey(otherGroupName)) {
        groupedDocuments[otherGroupName] = [];
      }
      isLoading = false;
    });
  }

  void onDocumentDropped(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
      child: Row(
        children: [
          ColoredRotatedSquare(isSolidSquare: false, color: accentColor),
          if (!_isCollapsed)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                label,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: darkTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
