import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';

/// Group for a note document the user creates right now (UX test B10).
///
/// A new document joins the group of the selected document only when that
/// document is the user's own. The group of someone else's document (e.g. a
/// document the DM shared) is never taken over: then the document goes into
/// [defaultGroupName].
String groupNameForNewNoteDocument({
  required NoteDocumentDto? selectedDocument,
  required String? myUserId,
  required String defaultGroupName,
}) {
  final selected = selectedDocument;
  final isOwnDocument =
      selected != null &&
      myUserId != null &&
      selected.creatingUserId?.value == myUserId;
  if (isOwnDocument && selected.groupName.trim().isNotEmpty) {
    return selected.groupName;
  }
  return defaultGroupName;
}

/// Heading shown for a document group in the list.
///
/// A player's new notes go into a group that is stored under the name
/// "Meine Notizen" in the player's language (B10). Anyone else who sees that
/// group (the DM, or a player the notes were shared with) would read "my
/// notes" above notes that are not theirs. A group under one of those names
/// that holds only other people's documents is shown as [othersNotesLabel].
/// The stored group name stays as it is.
String noteGroupDisplayLabel({
  required String groupName,
  required List<NoteDocumentDto> documents,
  required String? myUserId,
  required Iterable<String> myNotesGroupNames,
  required String othersNotesLabel,
}) {
  if (myUserId == null || documents.isEmpty) return groupName;
  if (!myNotesGroupNames.contains(groupName)) return groupName;
  final onlyOthersDocuments =
      documents.every((d) => d.creatingUserId?.value != myUserId);
  return onlyOthersDocuments ? othersNotesLabel : groupName;
}
