// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_details.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlayerJoinRequestsCWProxy {
  PlayerJoinRequests playerName(String playerName);

  PlayerJoinRequests username(String username);

  PlayerJoinRequests campagneJoinRequestId(String campagneJoinRequestId);

  PlayerJoinRequests playerCharacterId(String playerCharacterId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlayerJoinRequests(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlayerJoinRequests(...).copyWith(id: 12, name: "My name")
  /// ````
  PlayerJoinRequests call({
    String? playerName,
    String? username,
    String? campagneJoinRequestId,
    String? playerCharacterId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlayerJoinRequests.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlayerJoinRequests.copyWith.fieldName(...)`
class _$PlayerJoinRequestsCWProxyImpl implements _$PlayerJoinRequestsCWProxy {
  const _$PlayerJoinRequestsCWProxyImpl(this._value);

  final PlayerJoinRequests _value;

  @override
  PlayerJoinRequests playerName(String playerName) =>
      this(playerName: playerName);

  @override
  PlayerJoinRequests username(String username) => this(username: username);

  @override
  PlayerJoinRequests campagneJoinRequestId(String campagneJoinRequestId) =>
      this(campagneJoinRequestId: campagneJoinRequestId);

  @override
  PlayerJoinRequests playerCharacterId(String playerCharacterId) =>
      this(playerCharacterId: playerCharacterId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlayerJoinRequests(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlayerJoinRequests(...).copyWith(id: 12, name: "My name")
  /// ````
  PlayerJoinRequests call({
    Object? playerName = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? campagneJoinRequestId = const $CopyWithPlaceholder(),
    Object? playerCharacterId = const $CopyWithPlaceholder(),
  }) {
    return PlayerJoinRequests(
      playerName:
          playerName == const $CopyWithPlaceholder() || playerName == null
              ? _value.playerName
              // ignore: cast_nullable_to_non_nullable
              : playerName as String,
      username: username == const $CopyWithPlaceholder() || username == null
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
      campagneJoinRequestId:
          campagneJoinRequestId == const $CopyWithPlaceholder() ||
                  campagneJoinRequestId == null
              ? _value.campagneJoinRequestId
              // ignore: cast_nullable_to_non_nullable
              : campagneJoinRequestId as String,
      playerCharacterId: playerCharacterId == const $CopyWithPlaceholder() ||
              playerCharacterId == null
          ? _value.playerCharacterId
          // ignore: cast_nullable_to_non_nullable
          : playerCharacterId as String,
    );
  }
}

extension $PlayerJoinRequestsCopyWith on PlayerJoinRequests {
  /// Returns a callable class that can be used as follows: `instanceOfPlayerJoinRequests.copyWith(...)` or like so:`instanceOfPlayerJoinRequests.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlayerJoinRequestsCWProxy get copyWith =>
      _$PlayerJoinRequestsCWProxyImpl(this);
}

abstract class _$GrantedItemsForPlayerCWProxy {
  GrantedItemsForPlayer characterName(String characterName);

  GrantedItemsForPlayer playerId(String playerId);

  GrantedItemsForPlayer grantedItems(
      List<RpgCharacterOwnedItemPair> grantedItems);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrantedItemsForPlayer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrantedItemsForPlayer(...).copyWith(id: 12, name: "My name")
  /// ````
  GrantedItemsForPlayer call({
    String? characterName,
    String? playerId,
    List<RpgCharacterOwnedItemPair>? grantedItems,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrantedItemsForPlayer.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrantedItemsForPlayer.copyWith.fieldName(...)`
class _$GrantedItemsForPlayerCWProxyImpl
    implements _$GrantedItemsForPlayerCWProxy {
  const _$GrantedItemsForPlayerCWProxyImpl(this._value);

  final GrantedItemsForPlayer _value;

  @override
  GrantedItemsForPlayer characterName(String characterName) =>
      this(characterName: characterName);

  @override
  GrantedItemsForPlayer playerId(String playerId) => this(playerId: playerId);

  @override
  GrantedItemsForPlayer grantedItems(
          List<RpgCharacterOwnedItemPair> grantedItems) =>
      this(grantedItems: grantedItems);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrantedItemsForPlayer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrantedItemsForPlayer(...).copyWith(id: 12, name: "My name")
  /// ````
  GrantedItemsForPlayer call({
    Object? characterName = const $CopyWithPlaceholder(),
    Object? playerId = const $CopyWithPlaceholder(),
    Object? grantedItems = const $CopyWithPlaceholder(),
  }) {
    return GrantedItemsForPlayer(
      characterName:
          characterName == const $CopyWithPlaceholder() || characterName == null
              ? _value.characterName
              // ignore: cast_nullable_to_non_nullable
              : characterName as String,
      playerId: playerId == const $CopyWithPlaceholder() || playerId == null
          ? _value.playerId
          // ignore: cast_nullable_to_non_nullable
          : playerId as String,
      grantedItems:
          grantedItems == const $CopyWithPlaceholder() || grantedItems == null
              ? _value.grantedItems
              // ignore: cast_nullable_to_non_nullable
              : grantedItems as List<RpgCharacterOwnedItemPair>,
    );
  }
}

extension $GrantedItemsForPlayerCopyWith on GrantedItemsForPlayer {
  /// Returns a callable class that can be used as follows: `instanceOfGrantedItemsForPlayer.copyWith(...)` or like so:`instanceOfGrantedItemsForPlayer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrantedItemsForPlayerCWProxy get copyWith =>
      _$GrantedItemsForPlayerCWProxyImpl(this);
}

abstract class _$OpenPlayerConnectionCWProxy {
  OpenPlayerConnection userId(UserIdentifier userId);

  OpenPlayerConnection playerCharacterId(
      PlayerCharacterIdentifier playerCharacterId);

  OpenPlayerConnection configuration(RpgCharacterConfiguration configuration);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OpenPlayerConnection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OpenPlayerConnection(...).copyWith(id: 12, name: "My name")
  /// ````
  OpenPlayerConnection call({
    UserIdentifier? userId,
    PlayerCharacterIdentifier? playerCharacterId,
    RpgCharacterConfiguration? configuration,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOpenPlayerConnection.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOpenPlayerConnection.copyWith.fieldName(...)`
class _$OpenPlayerConnectionCWProxyImpl
    implements _$OpenPlayerConnectionCWProxy {
  const _$OpenPlayerConnectionCWProxyImpl(this._value);

  final OpenPlayerConnection _value;

  @override
  OpenPlayerConnection userId(UserIdentifier userId) => this(userId: userId);

  @override
  OpenPlayerConnection playerCharacterId(
          PlayerCharacterIdentifier playerCharacterId) =>
      this(playerCharacterId: playerCharacterId);

  @override
  OpenPlayerConnection configuration(RpgCharacterConfiguration configuration) =>
      this(configuration: configuration);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OpenPlayerConnection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OpenPlayerConnection(...).copyWith(id: 12, name: "My name")
  /// ````
  OpenPlayerConnection call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? playerCharacterId = const $CopyWithPlaceholder(),
    Object? configuration = const $CopyWithPlaceholder(),
  }) {
    return OpenPlayerConnection(
      userId: userId == const $CopyWithPlaceholder() || userId == null
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as UserIdentifier,
      playerCharacterId: playerCharacterId == const $CopyWithPlaceholder() ||
              playerCharacterId == null
          ? _value.playerCharacterId
          // ignore: cast_nullable_to_non_nullable
          : playerCharacterId as PlayerCharacterIdentifier,
      configuration:
          configuration == const $CopyWithPlaceholder() || configuration == null
              ? _value.configuration
              // ignore: cast_nullable_to_non_nullable
              : configuration as RpgCharacterConfiguration,
    );
  }
}

extension $OpenPlayerConnectionCopyWith on OpenPlayerConnection {
  /// Returns a callable class that can be used as follows: `instanceOfOpenPlayerConnection.copyWith(...)` or like so:`instanceOfOpenPlayerConnection.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OpenPlayerConnectionCWProxy get copyWith =>
      _$OpenPlayerConnectionCWProxyImpl(this);
}

abstract class _$ConnectionDetailsCWProxy {
  ConnectionDetails openPlayerRequests(
      List<PlayerJoinRequests>? openPlayerRequests);

  ConnectionDetails isConnected(bool isConnected);

  ConnectionDetails sessionConnectionNumberForPlayers(
      String? sessionConnectionNumberForPlayers);

  ConnectionDetails isConnecting(bool isConnecting);

  ConnectionDetails connectedPlayers(
      List<OpenPlayerConnection>? connectedPlayers);

  ConnectionDetails isInSession(bool isInSession);

  ConnectionDetails isDm(bool isDm);

  ConnectionDetails lastGrantedItems(
      List<GrantedItemsForPlayer>? lastGrantedItems);

  ConnectionDetails campagneId(String? campagneId);

  ConnectionDetails playerCharacterId(String? playerCharacterId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConnectionDetails(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConnectionDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  ConnectionDetails call({
    List<PlayerJoinRequests>? openPlayerRequests,
    bool? isConnected,
    String? sessionConnectionNumberForPlayers,
    bool? isConnecting,
    List<OpenPlayerConnection>? connectedPlayers,
    bool? isInSession,
    bool? isDm,
    List<GrantedItemsForPlayer>? lastGrantedItems,
    String? campagneId,
    String? playerCharacterId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConnectionDetails.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConnectionDetails.copyWith.fieldName(...)`
class _$ConnectionDetailsCWProxyImpl implements _$ConnectionDetailsCWProxy {
  const _$ConnectionDetailsCWProxyImpl(this._value);

  final ConnectionDetails _value;

  @override
  ConnectionDetails openPlayerRequests(
          List<PlayerJoinRequests>? openPlayerRequests) =>
      this(openPlayerRequests: openPlayerRequests);

  @override
  ConnectionDetails isConnected(bool isConnected) =>
      this(isConnected: isConnected);

  @override
  ConnectionDetails sessionConnectionNumberForPlayers(
          String? sessionConnectionNumberForPlayers) =>
      this(
          sessionConnectionNumberForPlayers: sessionConnectionNumberForPlayers);

  @override
  ConnectionDetails isConnecting(bool isConnecting) =>
      this(isConnecting: isConnecting);

  @override
  ConnectionDetails connectedPlayers(
          List<OpenPlayerConnection>? connectedPlayers) =>
      this(connectedPlayers: connectedPlayers);

  @override
  ConnectionDetails isInSession(bool isInSession) =>
      this(isInSession: isInSession);

  @override
  ConnectionDetails isDm(bool isDm) => this(isDm: isDm);

  @override
  ConnectionDetails lastGrantedItems(
          List<GrantedItemsForPlayer>? lastGrantedItems) =>
      this(lastGrantedItems: lastGrantedItems);

  @override
  ConnectionDetails campagneId(String? campagneId) =>
      this(campagneId: campagneId);

  @override
  ConnectionDetails playerCharacterId(String? playerCharacterId) =>
      this(playerCharacterId: playerCharacterId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConnectionDetails(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConnectionDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  ConnectionDetails call({
    Object? openPlayerRequests = const $CopyWithPlaceholder(),
    Object? isConnected = const $CopyWithPlaceholder(),
    Object? sessionConnectionNumberForPlayers = const $CopyWithPlaceholder(),
    Object? isConnecting = const $CopyWithPlaceholder(),
    Object? connectedPlayers = const $CopyWithPlaceholder(),
    Object? isInSession = const $CopyWithPlaceholder(),
    Object? isDm = const $CopyWithPlaceholder(),
    Object? lastGrantedItems = const $CopyWithPlaceholder(),
    Object? campagneId = const $CopyWithPlaceholder(),
    Object? playerCharacterId = const $CopyWithPlaceholder(),
  }) {
    return ConnectionDetails(
      openPlayerRequests: openPlayerRequests == const $CopyWithPlaceholder()
          ? _value.openPlayerRequests
          // ignore: cast_nullable_to_non_nullable
          : openPlayerRequests as List<PlayerJoinRequests>?,
      isConnected:
          isConnected == const $CopyWithPlaceholder() || isConnected == null
              ? _value.isConnected
              // ignore: cast_nullable_to_non_nullable
              : isConnected as bool,
      sessionConnectionNumberForPlayers:
          sessionConnectionNumberForPlayers == const $CopyWithPlaceholder()
              ? _value.sessionConnectionNumberForPlayers
              // ignore: cast_nullable_to_non_nullable
              : sessionConnectionNumberForPlayers as String?,
      isConnecting:
          isConnecting == const $CopyWithPlaceholder() || isConnecting == null
              ? _value.isConnecting
              // ignore: cast_nullable_to_non_nullable
              : isConnecting as bool,
      connectedPlayers: connectedPlayers == const $CopyWithPlaceholder()
          ? _value.connectedPlayers
          // ignore: cast_nullable_to_non_nullable
          : connectedPlayers as List<OpenPlayerConnection>?,
      isInSession:
          isInSession == const $CopyWithPlaceholder() || isInSession == null
              ? _value.isInSession
              // ignore: cast_nullable_to_non_nullable
              : isInSession as bool,
      isDm: isDm == const $CopyWithPlaceholder() || isDm == null
          ? _value.isDm
          // ignore: cast_nullable_to_non_nullable
          : isDm as bool,
      lastGrantedItems: lastGrantedItems == const $CopyWithPlaceholder()
          ? _value.lastGrantedItems
          // ignore: cast_nullable_to_non_nullable
          : lastGrantedItems as List<GrantedItemsForPlayer>?,
      campagneId: campagneId == const $CopyWithPlaceholder()
          ? _value.campagneId
          // ignore: cast_nullable_to_non_nullable
          : campagneId as String?,
      playerCharacterId: playerCharacterId == const $CopyWithPlaceholder()
          ? _value.playerCharacterId
          // ignore: cast_nullable_to_non_nullable
          : playerCharacterId as String?,
    );
  }
}

extension $ConnectionDetailsCopyWith on ConnectionDetails {
  /// Returns a callable class that can be used as follows: `instanceOfConnectionDetails.copyWith(...)` or like so:`instanceOfConnectionDetails.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConnectionDetailsCWProxy get copyWith =>
      _$ConnectionDetailsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerJoinRequests _$PlayerJoinRequestsFromJson(Map<String, dynamic> json) =>
    PlayerJoinRequests(
      playerName: json['playerName'] as String,
      username: json['username'] as String,
      campagneJoinRequestId: json['campagneJoinRequestId'] as String,
      playerCharacterId: json['playerCharacterId'] as String,
    );

Map<String, dynamic> _$PlayerJoinRequestsToJson(PlayerJoinRequests instance) =>
    <String, dynamic>{
      'playerName': instance.playerName,
      'username': instance.username,
      'playerCharacterId': instance.playerCharacterId,
      'campagneJoinRequestId': instance.campagneJoinRequestId,
    };

GrantedItemsForPlayer _$GrantedItemsForPlayerFromJson(
        Map<String, dynamic> json) =>
    GrantedItemsForPlayer(
      characterName: json['characterName'] as String,
      playerId: json['playerId'] as String,
      grantedItems: (json['grantedItems'] as List<dynamic>)
          .map((e) =>
              RpgCharacterOwnedItemPair.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GrantedItemsForPlayerToJson(
        GrantedItemsForPlayer instance) =>
    <String, dynamic>{
      'characterName': instance.characterName,
      'playerId': instance.playerId,
      'grantedItems': instance.grantedItems,
    };

OpenPlayerConnection _$OpenPlayerConnectionFromJson(
        Map<String, dynamic> json) =>
    OpenPlayerConnection(
      userId: UserIdentifier.fromJson(json['userId'] as Map<String, dynamic>),
      playerCharacterId: PlayerCharacterIdentifier.fromJson(
          json['playerCharacterId'] as Map<String, dynamic>),
      configuration: RpgCharacterConfiguration.fromJson(
          json['configuration'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenPlayerConnectionToJson(
        OpenPlayerConnection instance) =>
    <String, dynamic>{
      'configuration': instance.configuration,
      'userId': instance.userId,
      'playerCharacterId': instance.playerCharacterId,
    };

ConnectionDetails _$ConnectionDetailsFromJson(Map<String, dynamic> json) =>
    ConnectionDetails(
      openPlayerRequests: (json['openPlayerRequests'] as List<dynamic>?)
          ?.map((e) => PlayerJoinRequests.fromJson(e as Map<String, dynamic>))
          .toList(),
      isConnected: json['isConnected'] as bool,
      sessionConnectionNumberForPlayers:
          json['sessionConnectionNumberForPlayers'] as String?,
      isConnecting: json['isConnecting'] as bool,
      connectedPlayers: (json['connectedPlayers'] as List<dynamic>?)
          ?.map((e) => OpenPlayerConnection.fromJson(e as Map<String, dynamic>))
          .toList(),
      isInSession: json['isInSession'] as bool,
      isDm: json['isDm'] as bool,
      lastGrantedItems: (json['lastGrantedItems'] as List<dynamic>?)
          ?.map(
              (e) => GrantedItemsForPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      campagneId: json['campagneId'] as String?,
      playerCharacterId: json['playerCharacterId'] as String?,
    );

Map<String, dynamic> _$ConnectionDetailsToJson(ConnectionDetails instance) =>
    <String, dynamic>{
      'isConnected': instance.isConnected,
      'isConnecting': instance.isConnecting,
      'isInSession': instance.isInSession,
      'sessionConnectionNumberForPlayers':
          instance.sessionConnectionNumberForPlayers,
      'openPlayerRequests': instance.openPlayerRequests,
      'connectedPlayers': instance.connectedPlayers,
      'isDm': instance.isDm,
      'lastGrantedItems': instance.lastGrantedItems,
      'campagneId': instance.campagneId,
      'playerCharacterId': instance.playerCharacterId,
    };
