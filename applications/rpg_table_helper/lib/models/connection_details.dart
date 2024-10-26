import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';

part 'connection_details.g.dart';

@JsonSerializable()
@CopyWith()
class PlayerJoinRequests {
  final String playerName;
  final String gameCode;
  final String connectionId;

  PlayerJoinRequests(
      {required this.playerName,
      required this.gameCode,
      required this.connectionId});
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
class ConnectionDetails {
  final bool isConnected;
  final bool isConnecting;
  final bool isInSession;
  final String? sessionConnectionNumberForPlayers;
  final List<PlayerJoinRequests>? openPlayerRequests;
  final List<RpgCharacterConfiguration>? playerProfiles;
  final bool isDm;
  final List<GrantedItemsForPlayer>? lastGrantedItems;

  final String? campagneId;
  final String? playerCharacterId;

  ConnectionDetails({
    required this.openPlayerRequests,
    required this.isConnected,
    required this.sessionConnectionNumberForPlayers,
    required this.isConnecting,
    required this.playerProfiles,
    required this.isInSession,
    required this.isDm,
    required this.lastGrantedItems,
    required this.campagneId,
    required this.playerCharacterId,
  });

  static ConnectionDetails defaultValue() => ConnectionDetails(
        isConnected: false,
        isConnecting: false,
        isInSession: false,
        isDm: false,
        sessionConnectionNumberForPlayers: null,
        playerProfiles: [],
        lastGrantedItems: null,
        openPlayerRequests: [],
        campagneId: null,
        playerCharacterId: null,
      );

  bool get isPlayer => !isDm;

  factory ConnectionDetails.fromJson(Map<String, dynamic> json) =>
      _$ConnectionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionDetailsToJson(this);
}
