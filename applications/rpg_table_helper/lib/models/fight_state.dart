import 'package:quest_keeper/models/connection_details.dart';

enum FightParticipantKind { character, companion, enemy }

/// One entry of a fight kept on the server (`/Fight/*`): a character, a
/// companion or an enemy the DM added.
class FightParticipantState {
  final String id;
  final FightParticipantKind kind;

  /// The `uuid` of the character or companion configuration; null for enemies.
  final String? characterUuid;
  final String? playerCharacterId;
  final String name;
  final int? roll;

  /// Place in the initiative order; only the DM sees it, and only once rolled.
  final int? position;
  final bool isPending;

  const FightParticipantState({
    required this.id,
    required this.kind,
    required this.characterUuid,
    required this.playerCharacterId,
    required this.name,
    required this.roll,
    required this.position,
    required this.isPending,
  });

  factory FightParticipantState.fromJson(Map<String, dynamic> json) {
    return FightParticipantState(
      id: json['id'] as String,
      kind: _parseKind(json['kind']),
      characterUuid: json['characterUuid'] as String?,
      playerCharacterId: json['playerCharacterId'] as String?,
      name: json['name'] as String? ?? '',
      roll: (json['roll'] as num?)?.toInt(),
      position: (json['position'] as num?)?.toInt(),
      isPending: json['isPending'] as bool? ?? false,
    );
  }

  static FightParticipantKind _parseKind(Object? raw) {
    return switch (raw.toString().toLowerCase()) {
      'companion' || '1' => FightParticipantKind.companion,
      'enemy' || '2' => FightParticipantKind.enemy,
      _ => FightParticipantKind.character,
    };
  }
}

/// A fight as `GET /Fight/current/{campagneId}` returns it: the DM gets every
/// participant with the order, a player only their own characters.
class FightState {
  final String id;
  final String campagneId;
  final bool isOpen;
  final bool isDmView;
  final int revision;
  final List<FightParticipantState> participants;

  const FightState({
    required this.id,
    required this.campagneId,
    required this.isOpen,
    required this.isDmView,
    required this.revision,
    required this.participants,
  });

  factory FightState.fromJson(Map<String, dynamic> json) {
    return FightState(
      id: json['id'] as String,
      campagneId: json['campagneId'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? false,
      isDmView: json['isDmView'] as bool? ?? false,
      revision: (json['revision'] as num?)?.toInt() ?? 0,
      participants: ((json['participants'] as List<dynamic>?) ?? const [])
          .map((p) => FightParticipantState.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Everyone with a place in the initiative order, first to act first.
  List<FightParticipantState> get ordered {
    final result = participants.where((p) => p.position != null).toList();
    result.sort((a, b) => a.position!.compareTo(b.position!));
    return result;
  }

  /// Characters and companions whose players have not rolled yet.
  List<FightParticipantState> get pending =>
      participants.where((p) => p.isPending).toList();

  /// The order in the shape the DM screens already render.
  FightSequence toFightSequence() {
    return FightSequence(
      fightUuid: id,
      sequence: ordered
          .map((p) => (
                p.kind == FightParticipantKind.enemy ? null : p.characterUuid,
                p.name,
                p.roll ?? 0,
              ))
          .toList(),
    );
  }
}

/// Someone the DM asks to roll when starting a fight.
class FightStartParticipant {
  final String characterUuid;
  final String? playerCharacterId;
  final String name;

  const FightStartParticipant({
    required this.characterUuid,
    required this.playerCharacterId,
    required this.name,
  });
}

/// `initiativeRequested` SSE payload: roll for these of your characters.
class InitiativeRequest {
  final String fightId;
  final String campagneId;
  final List<FightParticipantState> participants;

  const InitiativeRequest({
    required this.fightId,
    required this.campagneId,
    required this.participants,
  });
}
