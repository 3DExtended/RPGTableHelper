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
