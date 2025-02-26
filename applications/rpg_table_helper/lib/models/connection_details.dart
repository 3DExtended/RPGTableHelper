import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';

part 'connection_details.g.dart';

@JsonSerializable()
@CopyWith()
class PlayerJoinRequests {
  final String playerName;
  final String username;
  final String playerCharacterId;
  final String campagneJoinRequestId;

  PlayerJoinRequests(
      {required this.playerName,
      required this.username,
      required this.campagneJoinRequestId,
      required this.playerCharacterId});
  factory PlayerJoinRequests.fromJson(Map<String, dynamic> json) =>
      _$PlayerJoinRequestsFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerJoinRequestsToJson(this);
}

@JsonSerializable()
@CopyWith()
class GrantedItemsForPlayer {
  final String characterName;
  final String playerId;
  final List<RpgCharacterOwnedItemPair> grantedItems;

  GrantedItemsForPlayer({
    required this.characterName,
    required this.playerId,
    required this.grantedItems,
  });

  factory GrantedItemsForPlayer.fromJson(Map<String, dynamic> json) =>
      _$GrantedItemsForPlayerFromJson(json);

  Map<String, dynamic> toJson() => _$GrantedItemsForPlayerToJson(this);
}

@JsonSerializable()
@CopyWith()
class OpenPlayerConnection {
  final RpgCharacterConfiguration configuration;
  final UserIdentifier userId;
  final PlayerCharacterIdentifier playerCharacterId;
  final DateTime? lastPing;

  OpenPlayerConnection({
    required this.userId,
    required this.playerCharacterId,
    required this.configuration,
    required this.lastPing,
  });

  factory OpenPlayerConnection.fromJson(Map<String, dynamic> json) =>
      _$OpenPlayerConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPlayerConnectionToJson(this);
}

@JsonSerializable()
@CopyWith()
class FightSequence {
  final String fightUuid;

  // characterId is null for opponents the DM added manually to the fight
  final List<(String? characterId, String characterName, int roll)> sequence;

  FightSequence({required this.fightUuid, required this.sequence});

  factory FightSequence.fromJson(Map<String, dynamic> json) =>
      _$FightSequenceFromJson(json);

  Map<String, dynamic> toJson() => _$FightSequenceToJson(this);
}

@JsonSerializable()
@CopyWith()
class ConnectionDetails {
  final bool isConnected;
  final bool isConnecting;
  final bool isInSession;
  final String? sessionConnectionNumberForPlayers;
  final List<PlayerJoinRequests>? openPlayerRequests;
  final List<OpenPlayerConnection>? connectedPlayers;
  final bool isDm;
  final List<GrantedItemsForPlayer>? lastGrantedItems;

  final DateTime? lastPing;

  final FightSequence? fightSequence;

  final String? campagneId;
  final String? playerCharacterId;

  ConnectionDetails({
    required this.openPlayerRequests,
    required this.isConnected,
    required this.sessionConnectionNumberForPlayers,
    required this.isConnecting,
    required this.connectedPlayers,
    required this.isInSession,
    required this.isDm,
    required this.fightSequence,
    required this.lastGrantedItems,
    required this.campagneId,
    required this.playerCharacterId,
    required this.lastPing,
  });

  static ConnectionDetails defaultValue() => ConnectionDetails(
      isConnected: false,
      isConnecting: false,
      isInSession: false,
      fightSequence: null,
      isDm: false,
      sessionConnectionNumberForPlayers: null,
      connectedPlayers: [],
      lastGrantedItems: null,
      openPlayerRequests: [],
      campagneId: null,
      playerCharacterId: null,
      lastPing: null);

  bool get isPlayer => !isDm;

  factory ConnectionDetails.fromJson(Map<String, dynamic> json) =>
      _$ConnectionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionDetailsToJson(this);
}
