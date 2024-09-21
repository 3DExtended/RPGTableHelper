// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_details.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlayerJoinRequestsCWProxy {
  PlayerJoinRequests playerName(String playerName);

  PlayerJoinRequests gameCode(String gameCode);

  PlayerJoinRequests connectionId(String connectionId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlayerJoinRequests(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlayerJoinRequests(...).copyWith(id: 12, name: "My name")
  /// ````
  PlayerJoinRequests call({
    String? playerName,
    String? gameCode,
    String? connectionId,
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
  PlayerJoinRequests gameCode(String gameCode) => this(gameCode: gameCode);

  @override
  PlayerJoinRequests connectionId(String connectionId) =>
      this(connectionId: connectionId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlayerJoinRequests(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlayerJoinRequests(...).copyWith(id: 12, name: "My name")
  /// ````
  PlayerJoinRequests call({
    Object? playerName = const $CopyWithPlaceholder(),
    Object? gameCode = const $CopyWithPlaceholder(),
    Object? connectionId = const $CopyWithPlaceholder(),
  }) {
    return PlayerJoinRequests(
      playerName:
          playerName == const $CopyWithPlaceholder() || playerName == null
              ? _value.playerName
              // ignore: cast_nullable_to_non_nullable
              : playerName as String,
      gameCode: gameCode == const $CopyWithPlaceholder() || gameCode == null
          ? _value.gameCode
          // ignore: cast_nullable_to_non_nullable
          : gameCode as String,
      connectionId:
          connectionId == const $CopyWithPlaceholder() || connectionId == null
              ? _value.connectionId
              // ignore: cast_nullable_to_non_nullable
              : connectionId as String,
    );
  }
}

extension $PlayerJoinRequestsCopyWith on PlayerJoinRequests {
  /// Returns a callable class that can be used as follows: `instanceOfPlayerJoinRequests.copyWith(...)` or like so:`instanceOfPlayerJoinRequests.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlayerJoinRequestsCWProxy get copyWith =>
      _$PlayerJoinRequestsCWProxyImpl(this);
}

abstract class _$ConnectionDetailsCWProxy {
  ConnectionDetails openPlayerRequests(
      List<PlayerJoinRequests>? openPlayerRequests);

  ConnectionDetails isConnected(bool isConnected);

  ConnectionDetails sessionConnectionNumberForPlayers(
      String? sessionConnectionNumberForPlayers);

  ConnectionDetails isConnecting(bool isConnecting);

  ConnectionDetails playerProfiles(
      List<RpgCharacterConfiguration>? playerProfiles);

  ConnectionDetails isInSession(bool isInSession);

  ConnectionDetails isDm(bool isDm);

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
    List<RpgCharacterConfiguration>? playerProfiles,
    bool? isInSession,
    bool? isDm,
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
  ConnectionDetails playerProfiles(
          List<RpgCharacterConfiguration>? playerProfiles) =>
      this(playerProfiles: playerProfiles);

  @override
  ConnectionDetails isInSession(bool isInSession) =>
      this(isInSession: isInSession);

  @override
  ConnectionDetails isDm(bool isDm) => this(isDm: isDm);

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
    Object? playerProfiles = const $CopyWithPlaceholder(),
    Object? isInSession = const $CopyWithPlaceholder(),
    Object? isDm = const $CopyWithPlaceholder(),
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
      playerProfiles: playerProfiles == const $CopyWithPlaceholder()
          ? _value.playerProfiles
          // ignore: cast_nullable_to_non_nullable
          : playerProfiles as List<RpgCharacterConfiguration>?,
      isInSession:
          isInSession == const $CopyWithPlaceholder() || isInSession == null
              ? _value.isInSession
              // ignore: cast_nullable_to_non_nullable
              : isInSession as bool,
      isDm: isDm == const $CopyWithPlaceholder() || isDm == null
          ? _value.isDm
          // ignore: cast_nullable_to_non_nullable
          : isDm as bool,
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
      gameCode: json['gameCode'] as String,
      connectionId: json['connectionId'] as String,
    );

Map<String, dynamic> _$PlayerJoinRequestsToJson(PlayerJoinRequests instance) =>
    <String, dynamic>{
      'playerName': instance.playerName,
      'gameCode': instance.gameCode,
      'connectionId': instance.connectionId,
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
      playerProfiles: (json['playerProfiles'] as List<dynamic>?)
          ?.map((e) =>
              RpgCharacterConfiguration.fromJson(e as Map<String, dynamic>))
          .toList(),
      isInSession: json['isInSession'] as bool,
      isDm: json['isDm'] as bool,
    );

Map<String, dynamic> _$ConnectionDetailsToJson(ConnectionDetails instance) =>
    <String, dynamic>{
      'isConnected': instance.isConnected,
      'isConnecting': instance.isConnecting,
      'isInSession': instance.isInSession,
      'sessionConnectionNumberForPlayers':
          instance.sessionConnectionNumberForPlayers,
      'openPlayerRequests': instance.openPlayerRequests,
      'playerProfiles': instance.playerProfiles,
      'isDm': instance.isDm,
    };
