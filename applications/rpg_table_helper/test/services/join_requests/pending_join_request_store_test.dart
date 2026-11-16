import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/services/join_requests/pending_join_request_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

PendingJoinRequest _pending(String characterId) => PendingJoinRequest(
  playerCharacterId: characterId,
  campagneJoinRequestId: 'request-$characterId',
  joinCode: '699-457',
  requestedAt: DateTime.utc(2026, 11, 16, 14, 15),
);

PlayerCharacter _character(String id, {String? campagneId}) => PlayerCharacter(
  id: PlayerCharacterIdentifier(value: id),
  characterName: id,
  campagneId: campagneId == null ? null : CampagneIdentifier(value: campagneId),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'keeps pending requests across store instances (app restarts)',
    () async {
      await const SharedPreferencesPendingJoinRequestStore().save(
        _pending('mira'),
      );

      final loaded = await const SharedPreferencesPendingJoinRequestStore()
          .loadAll();

      expect(loaded, {'mira': _pending('mira')});
    },
  );

  test('remove drops one entry', () async {
    const store = SharedPreferencesPendingJoinRequestStore();
    await store.save(_pending('mira'));
    await store.save(_pending('kardan'));

    await store.remove('mira');

    expect((await store.loadAll()).keys, ['kardan']);
  });

  test('broken storage reads as empty', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesPendingJoinRequestStore.storageKey: 'not json',
    });

    expect(
      await const SharedPreferencesPendingJoinRequestStore().loadAll(),
      isEmpty,
    );
  });

  test('reconcile clears characters that joined a campagne', () async {
    final store = InMemoryPendingJoinRequestStore({
      'mira': _pending('mira'),
      'kardan': _pending('kardan'),
      'other-account': _pending('other-account'),
    });

    final stillPending = await reconcilePendingJoinRequests(
      store: store,
      characters: [
        _character('mira', campagneId: 'campagne-1'),
        _character('kardan'),
      ],
    );

    expect(stillPending.keys, unorderedEquals(['kardan', 'other-account']));
    expect(store.entries.keys, unorderedEquals(['kardan', 'other-account']));
  });
}
