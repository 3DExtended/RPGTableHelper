import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/note_document_grouping.dart';

const _me = 'user-me';
const _dm = 'user-dm';

NoteDocumentDto _doc({required String creator, required String group}) =>
    NoteDocumentDto(
      id: NoteDocumentIdentifier(value: 'doc'),
      title: 'Dokument',
      groupName: group,
      createdForCampagneId: CampagneIdentifier(value: 'campaign'),
      creatingUserId: UserIdentifier(value: creator),
      creationDate: DateTime(2026, 11, 16),
      lastModifiedAt: DateTime(2026, 11, 16),
      isDeleted: false,
      textBlocks: [],
      imageBlocks: [],
    );

void main() {
  test('B10: the group of a document of someone else is never taken over', () {
    expect(
      groupNameForNewNoteDocument(
        selectedDocument: _doc(creator: _dm, group: 'NSCs'),
        myUserId: _me,
        defaultGroupName: 'Meine Notizen',
      ),
      'Meine Notizen',
    );
  });

  test('a new document joins the group of my selected document', () {
    expect(
      groupNameForNewNoteDocument(
        selectedDocument: _doc(creator: _me, group: 'Reise'),
        myUserId: _me,
        defaultGroupName: 'Meine Notizen',
      ),
      'Reise',
    );
  });

  test(
    'without a selected document or own user, the default group is used',
    () {
      expect(
        groupNameForNewNoteDocument(
          selectedDocument: null,
          myUserId: _me,
          defaultGroupName: 'Sonstiges',
        ),
        'Sonstiges',
      );
      expect(
        groupNameForNewNoteDocument(
          selectedDocument: _doc(creator: _me, group: 'Reise'),
          myUserId: null,
          defaultGroupName: 'Sonstiges',
        ),
        'Sonstiges',
      );
    },
  );

  test('a blank group of my document falls back to the default group', () {
    expect(
      groupNameForNewNoteDocument(
        selectedDocument: _doc(creator: _me, group: '  '),
        myUserId: _me,
        defaultGroupName: 'Meine Notizen',
      ),
      'Meine Notizen',
    );
  });
}
