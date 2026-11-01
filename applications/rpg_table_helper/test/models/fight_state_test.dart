import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/models/fight_state.dart';

Map<String, dynamic> _participant(
  String id,
  String kind,
  String name, {
  String? uuid,
  int? roll,
  int? position,
  bool pending = false,
}) =>
    {
      'id': id,
      'kind': kind,
      'characterUuid': uuid,
      'playerCharacterId': uuid == null ? null : 'pc-$uuid',
      'name': name,
      'roll': roll,
      'position': position,
      'isPending': pending,
    };

void main() {
  final dmFight = FightState.fromJson({
    'id': 'fight-1',
    'campagneId': 'camp-1',
    'isOpen': true,
    'isDmView': true,
    'revision': 4,
    'participants': [
      _participant('p-wolf', 'Companion', 'Fang', uuid: 'wolf', pending: true),
      _participant('p-goblin', 'Enemy', 'Goblin', roll: 14, position: 1),
      _participant('p-aria', 'Character', 'Aria',
          uuid: 'aria', roll: 18, position: 0),
      _participant('p-borin', 'Character', 'Borin',
          uuid: 'borin', roll: 9, position: 2),
    ],
  });

  test('reads the participants as the server sends them', () {
    expect(dmFight.id, 'fight-1');
    expect(dmFight.isDmView, isTrue);
    expect(dmFight.revision, 4);
    expect(dmFight.participants.map((p) => p.kind), [
      FightParticipantKind.companion,
      FightParticipantKind.enemy,
      FightParticipantKind.character,
      FightParticipantKind.character,
    ]);
    expect(dmFight.participants.first.playerCharacterId, 'pc-wolf');
  });

  test('orders by position and leaves out who has not rolled', () {
    expect(dmFight.ordered.map((p) => p.name), ['Aria', 'Goblin', 'Borin']);
    expect(dmFight.pending.map((p) => p.name), ['Fang']);
  });

  test('turns into the fight sequence the DM screens render', () {
    final sequence = dmFight.toFightSequence();

    expect(sequence.fightUuid, 'fight-1');
    expect(sequence.sequence, [
      ('aria', 'Aria', 18),
      (null, 'Goblin', 14),
      ('borin', 'Borin', 9),
    ]);
  });

  test('accepts numeric kinds and missing optional fields', () {
    final fight = FightState.fromJson({
      'id': 'fight-2',
      'participants': [
        {'id': 'x', 'kind': 2, 'name': 'Orc'},
      ],
    });

    expect(fight.isOpen, isFalse);
    expect(fight.participants.single.kind, FightParticipantKind.enemy);
    expect(fight.participants.single.isPending, isFalse);
    expect(fight.ordered, isEmpty);
  });
}
