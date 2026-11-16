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

  group('heading of a group', () {
    String label(List<NoteDocumentDto> docs, {String group = 'Meine Notizen'}) =>
        noteGroupDisplayLabel(
          groupName: group,
          documents: docs,
          myUserId: _dm,
          myNotesGroupNames: const ['Meine Notizen', 'My notes'],
          othersNotesLabel: 'Notizen der Spieler',
        );

    test("the DM does not see a player's notes under 'Meine Notizen'", () {
      expect(label([_doc(creator: _me, group: 'Meine Notizen')]),
          'Notizen der Spieler');
    });

    test('also when the player uses the app in English', () {
      expect(label([_doc(creator: _me, group: 'My notes')], group: 'My notes'),
          'Notizen der Spieler');
    });

    test('a group with own documents keeps its name', () {
      expect(
          label([
            _doc(creator: _dm, group: 'Meine Notizen'),
            _doc(creator: _me, group: 'Meine Notizen'),
          ]),
          'Meine Notizen');
    });

    test('other group names and empty groups stay as they are', () {
      expect(label([_doc(creator: _me, group: 'NSCs')], group: 'NSCs'), 'NSCs');
      expect(label([]), 'Meine Notizen');
    });
  });
}
