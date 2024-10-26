// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'dart:convert';

import 'swagger.enums.swagger.dart' as enums;

part 'swagger.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class AppleLoginDetails {
  const AppleLoginDetails({
    required this.authorizationCode,
    required this.identityToken,
  });

  factory AppleLoginDetails.fromJson(Map<String, dynamic> json) =>
      _$AppleLoginDetailsFromJson(json);

  static const toJsonFactory = _$AppleLoginDetailsToJson;
  Map<String, dynamic> toJson() => _$AppleLoginDetailsToJson(this);

  @JsonKey(name: 'authorizationCode')
  final String authorizationCode;
  @JsonKey(name: 'identityToken')
  final String identityToken;
  static const fromJsonFactory = _$AppleLoginDetailsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AppleLoginDetails &&
            (identical(other.authorizationCode, authorizationCode) ||
                const DeepCollectionEquality()
                    .equals(other.authorizationCode, authorizationCode)) &&
            (identical(other.identityToken, identityToken) ||
                const DeepCollectionEquality()
                    .equals(other.identityToken, identityToken)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(authorizationCode) ^
      const DeepCollectionEquality().hash(identityToken) ^
      runtimeType.hashCode;
}

extension $AppleLoginDetailsExtension on AppleLoginDetails {
  AppleLoginDetails copyWith(
      {String? authorizationCode, String? identityToken}) {
    return AppleLoginDetails(
        authorizationCode: authorizationCode ?? this.authorizationCode,
        identityToken: identityToken ?? this.identityToken);
  }

  AppleLoginDetails copyWithWrapped(
      {Wrapped<String>? authorizationCode, Wrapped<String>? identityToken}) {
    return AppleLoginDetails(
        authorizationCode: (authorizationCode != null
            ? authorizationCode.value
            : this.authorizationCode),
        identityToken:
            (identityToken != null ? identityToken.value : this.identityToken));
  }
}

@JsonSerializable(explicitToJson: true)
class Campagne {
  const Campagne({
    this.id,
    this.creationDate,
    this.lastModifiedAt,
    this.rpgConfiguration,
    this.campagneName,
    this.joinCode,
    this.dmUserId,
  });

  factory Campagne.fromJson(Map<String, dynamic> json) =>
      _$CampagneFromJson(json);

  static const toJsonFactory = _$CampagneToJson;
  Map<String, dynamic> toJson() => _$CampagneToJson(this);

  @JsonKey(name: 'id')
  final CampagneIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  @JsonKey(name: 'rpgConfiguration')
  final String? rpgConfiguration;
  @JsonKey(name: 'campagneName')
  final String? campagneName;
  @JsonKey(name: 'joinCode')
  final String? joinCode;
  @JsonKey(name: 'dmUserId')
  final UserIdentifier? dmUserId;
  static const fromJsonFactory = _$CampagneFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Campagne &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality()
                    .equals(other.creationDate, creationDate)) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality()
                    .equals(other.lastModifiedAt, lastModifiedAt)) &&
            (identical(other.rpgConfiguration, rpgConfiguration) ||
                const DeepCollectionEquality()
                    .equals(other.rpgConfiguration, rpgConfiguration)) &&
            (identical(other.campagneName, campagneName) ||
                const DeepCollectionEquality()
                    .equals(other.campagneName, campagneName)) &&
            (identical(other.joinCode, joinCode) ||
                const DeepCollectionEquality()
                    .equals(other.joinCode, joinCode)) &&
            (identical(other.dmUserId, dmUserId) ||
                const DeepCollectionEquality()
                    .equals(other.dmUserId, dmUserId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      const DeepCollectionEquality().hash(rpgConfiguration) ^
      const DeepCollectionEquality().hash(campagneName) ^
      const DeepCollectionEquality().hash(joinCode) ^
      const DeepCollectionEquality().hash(dmUserId) ^
      runtimeType.hashCode;
}

extension $CampagneExtension on Campagne {
  Campagne copyWith(
      {CampagneIdentifier? id,
      DateTime? creationDate,
      DateTime? lastModifiedAt,
      String? rpgConfiguration,
      String? campagneName,
      String? joinCode,
      UserIdentifier? dmUserId}) {
    return Campagne(
        id: id ?? this.id,
        creationDate: creationDate ?? this.creationDate,
        lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
        rpgConfiguration: rpgConfiguration ?? this.rpgConfiguration,
        campagneName: campagneName ?? this.campagneName,
        joinCode: joinCode ?? this.joinCode,
        dmUserId: dmUserId ?? this.dmUserId);
  }

  Campagne copyWithWrapped(
      {Wrapped<CampagneIdentifier?>? id,
      Wrapped<DateTime?>? creationDate,
      Wrapped<DateTime?>? lastModifiedAt,
      Wrapped<String?>? rpgConfiguration,
      Wrapped<String?>? campagneName,
      Wrapped<String?>? joinCode,
      Wrapped<UserIdentifier?>? dmUserId}) {
    return Campagne(
        id: (id != null ? id.value : this.id),
        creationDate:
            (creationDate != null ? creationDate.value : this.creationDate),
        lastModifiedAt: (lastModifiedAt != null
            ? lastModifiedAt.value
            : this.lastModifiedAt),
        rpgConfiguration: (rpgConfiguration != null
            ? rpgConfiguration.value
            : this.rpgConfiguration),
        campagneName:
            (campagneName != null ? campagneName.value : this.campagneName),
        joinCode: (joinCode != null ? joinCode.value : this.joinCode),
        dmUserId: (dmUserId != null ? dmUserId.value : this.dmUserId));
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneCreateDto {
  const CampagneCreateDto({
    this.rpgConfiguration,
    required this.campagneName,
  });

  factory CampagneCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CampagneCreateDtoFromJson(json);

  static const toJsonFactory = _$CampagneCreateDtoToJson;
  Map<String, dynamic> toJson() => _$CampagneCreateDtoToJson(this);

  @JsonKey(name: 'rpgConfiguration')
  final String? rpgConfiguration;
  @JsonKey(name: 'campagneName')
  final String campagneName;
  static const fromJsonFactory = _$CampagneCreateDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CampagneCreateDto &&
            (identical(other.rpgConfiguration, rpgConfiguration) ||
                const DeepCollectionEquality()
                    .equals(other.rpgConfiguration, rpgConfiguration)) &&
            (identical(other.campagneName, campagneName) ||
                const DeepCollectionEquality()
                    .equals(other.campagneName, campagneName)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(rpgConfiguration) ^
      const DeepCollectionEquality().hash(campagneName) ^
      runtimeType.hashCode;
}

extension $CampagneCreateDtoExtension on CampagneCreateDto {
  CampagneCreateDto copyWith({String? rpgConfiguration, String? campagneName}) {
    return CampagneCreateDto(
        rpgConfiguration: rpgConfiguration ?? this.rpgConfiguration,
        campagneName: campagneName ?? this.campagneName);
  }

  CampagneCreateDto copyWithWrapped(
      {Wrapped<String?>? rpgConfiguration, Wrapped<String>? campagneName}) {
    return CampagneCreateDto(
        rpgConfiguration: (rpgConfiguration != null
            ? rpgConfiguration.value
            : this.rpgConfiguration),
        campagneName:
            (campagneName != null ? campagneName.value : this.campagneName));
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneIdentifier {
  const CampagneIdentifier({
    this.$value,
  });

  factory CampagneIdentifier.fromJson(Map<String, dynamic> json) =>
      _$CampagneIdentifierFromJson(json);

  static const toJsonFactory = _$CampagneIdentifierToJson;
  Map<String, dynamic> toJson() => _$CampagneIdentifierToJson(this);

  @JsonKey(name: 'value')
  final String? $value;
  static const fromJsonFactory = _$CampagneIdentifierFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CampagneIdentifier &&
            (identical(other.$value, $value) ||
                const DeepCollectionEquality().equals(other.$value, $value)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($value) ^ runtimeType.hashCode;
}

extension $CampagneIdentifierExtension on CampagneIdentifier {
  CampagneIdentifier copyWith({String? $value}) {
    return CampagneIdentifier($value: $value ?? this.$value);
  }

  CampagneIdentifier copyWithWrapped({Wrapped<String?>? $value}) {
    return CampagneIdentifier(
        $value: ($value != null ? $value.value : this.$value));
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneJoinRequest {
  const CampagneJoinRequest({
    this.id,
    this.creationDate,
    this.lastModifiedAt,
    this.userId,
    this.playerId,
    this.campagneId,
  });

  factory CampagneJoinRequest.fromJson(Map<String, dynamic> json) =>
      _$CampagneJoinRequestFromJson(json);

  static const toJsonFactory = _$CampagneJoinRequestToJson;
  Map<String, dynamic> toJson() => _$CampagneJoinRequestToJson(this);

  @JsonKey(name: 'id')
  final CampagneJoinRequestIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  @JsonKey(name: 'userId')
  final UserIdentifier? userId;
  @JsonKey(name: 'playerId')
  final PlayerCharacterIdentifier? playerId;
  @JsonKey(name: 'campagneId')
  final CampagneIdentifier? campagneId;
  static const fromJsonFactory = _$CampagneJoinRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CampagneJoinRequest &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality()
                    .equals(other.creationDate, creationDate)) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality()
                    .equals(other.lastModifiedAt, lastModifiedAt)) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.playerId, playerId) ||
                const DeepCollectionEquality()
                    .equals(other.playerId, playerId)) &&
            (identical(other.campagneId, campagneId) ||
                const DeepCollectionEquality()
                    .equals(other.campagneId, campagneId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(playerId) ^
      const DeepCollectionEquality().hash(campagneId) ^
      runtimeType.hashCode;
}

extension $CampagneJoinRequestExtension on CampagneJoinRequest {
  CampagneJoinRequest copyWith(
      {CampagneJoinRequestIdentifier? id,
      DateTime? creationDate,
      DateTime? lastModifiedAt,
      UserIdentifier? userId,
      PlayerCharacterIdentifier? playerId,
      CampagneIdentifier? campagneId}) {
    return CampagneJoinRequest(
        id: id ?? this.id,
        creationDate: creationDate ?? this.creationDate,
        lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
        userId: userId ?? this.userId,
        playerId: playerId ?? this.playerId,
        campagneId: campagneId ?? this.campagneId);
  }

  CampagneJoinRequest copyWithWrapped(
      {Wrapped<CampagneJoinRequestIdentifier?>? id,
      Wrapped<DateTime?>? creationDate,
      Wrapped<DateTime?>? lastModifiedAt,
      Wrapped<UserIdentifier?>? userId,
      Wrapped<PlayerCharacterIdentifier?>? playerId,
      Wrapped<CampagneIdentifier?>? campagneId}) {
    return CampagneJoinRequest(
        id: (id != null ? id.value : this.id),
        creationDate:
            (creationDate != null ? creationDate.value : this.creationDate),
        lastModifiedAt: (lastModifiedAt != null
            ? lastModifiedAt.value
            : this.lastModifiedAt),
        userId: (userId != null ? userId.value : this.userId),
        playerId: (playerId != null ? playerId.value : this.playerId),
        campagneId: (campagneId != null ? campagneId.value : this.campagneId));
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneJoinRequestCreateDto {
  const CampagneJoinRequestCreateDto({
    required this.campagneId,
    required this.playerCharacterId,
  });

  factory CampagneJoinRequestCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CampagneJoinRequestCreateDtoFromJson(json);

  static const toJsonFactory = _$CampagneJoinRequestCreateDtoToJson;
  Map<String, dynamic> toJson() => _$CampagneJoinRequestCreateDtoToJson(this);

  @JsonKey(name: 'campagneId')
  final String campagneId;
  @JsonKey(name: 'playerCharacterId')
  final String playerCharacterId;
  static const fromJsonFactory = _$CampagneJoinRequestCreateDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CampagneJoinRequestCreateDto &&
            (identical(other.campagneId, campagneId) ||
                const DeepCollectionEquality()
                    .equals(other.campagneId, campagneId)) &&
            (identical(other.playerCharacterId, playerCharacterId) ||
                const DeepCollectionEquality()
                    .equals(other.playerCharacterId, playerCharacterId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(campagneId) ^
      const DeepCollectionEquality().hash(playerCharacterId) ^
      runtimeType.hashCode;
}

extension $CampagneJoinRequestCreateDtoExtension
    on CampagneJoinRequestCreateDto {
  CampagneJoinRequestCreateDto copyWith(
      {String? campagneId, String? playerCharacterId}) {
    return CampagneJoinRequestCreateDto(
        campagneId: campagneId ?? this.campagneId,
        playerCharacterId: playerCharacterId ?? this.playerCharacterId);
  }

  CampagneJoinRequestCreateDto copyWithWrapped(
      {Wrapped<String>? campagneId, Wrapped<String>? playerCharacterId}) {
    return CampagneJoinRequestCreateDto(
        campagneId: (campagneId != null ? campagneId.value : this.campagneId),
        playerCharacterId: (playerCharacterId != null
            ? playerCharacterId.value
            : this.playerCharacterId));
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneJoinRequestIdentifier {
  const CampagneJoinRequestIdentifier({
    this.$value,
  });

  factory CampagneJoinRequestIdentifier.fromJson(Map<String, dynamic> json) =>
      _$CampagneJoinRequestIdentifierFromJson(json);

  static const toJsonFactory = _$CampagneJoinRequestIdentifierToJson;
  Map<String, dynamic> toJson() => _$CampagneJoinRequestIdentifierToJson(this);

  @JsonKey(name: 'value')
  final String? $value;
  static const fromJsonFactory = _$CampagneJoinRequestIdentifierFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CampagneJoinRequestIdentifier &&
            (identical(other.$value, $value) ||
                const DeepCollectionEquality().equals(other.$value, $value)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($value) ^ runtimeType.hashCode;
}

extension $CampagneJoinRequestIdentifierExtension
    on CampagneJoinRequestIdentifier {
  CampagneJoinRequestIdentifier copyWith({String? $value}) {
    return CampagneJoinRequestIdentifier($value: $value ?? this.$value);
  }

  CampagneJoinRequestIdentifier copyWithWrapped({Wrapped<String?>? $value}) {
    return CampagneJoinRequestIdentifier(
        $value: ($value != null ? $value.value : this.$value));
  }
}

@JsonSerializable(explicitToJson: true)
class EncryptedMessageWrapperDto {
  const EncryptedMessageWrapperDto({
    this.encryptedMessage,
  });

  factory EncryptedMessageWrapperDto.fromJson(Map<String, dynamic> json) =>
      _$EncryptedMessageWrapperDtoFromJson(json);

  static const toJsonFactory = _$EncryptedMessageWrapperDtoToJson;
  Map<String, dynamic> toJson() => _$EncryptedMessageWrapperDtoToJson(this);

  @JsonKey(name: 'encryptedMessage')
  final String? encryptedMessage;
  static const fromJsonFactory = _$EncryptedMessageWrapperDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EncryptedMessageWrapperDto &&
            (identical(other.encryptedMessage, encryptedMessage) ||
                const DeepCollectionEquality()
                    .equals(other.encryptedMessage, encryptedMessage)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(encryptedMessage) ^
      runtimeType.hashCode;
}

extension $EncryptedMessageWrapperDtoExtension on EncryptedMessageWrapperDto {
  EncryptedMessageWrapperDto copyWith({String? encryptedMessage}) {
    return EncryptedMessageWrapperDto(
        encryptedMessage: encryptedMessage ?? this.encryptedMessage);
  }

  EncryptedMessageWrapperDto copyWithWrapped(
      {Wrapped<String?>? encryptedMessage}) {
    return EncryptedMessageWrapperDto(
        encryptedMessage: (encryptedMessage != null
            ? encryptedMessage.value
            : this.encryptedMessage));
  }
}

@JsonSerializable(explicitToJson: true)
class EncryptionChallengeIdentifier {
  const EncryptionChallengeIdentifier({
    this.$value,
  });

  factory EncryptionChallengeIdentifier.fromJson(Map<String, dynamic> json) =>
      _$EncryptionChallengeIdentifierFromJson(json);

  static const toJsonFactory = _$EncryptionChallengeIdentifierToJson;
  Map<String, dynamic> toJson() => _$EncryptionChallengeIdentifierToJson(this);

  @JsonKey(name: 'value')
  final String? $value;
  static const fromJsonFactory = _$EncryptionChallengeIdentifierFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EncryptionChallengeIdentifier &&
            (identical(other.$value, $value) ||
                const DeepCollectionEquality().equals(other.$value, $value)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($value) ^ runtimeType.hashCode;
}

extension $EncryptionChallengeIdentifierExtension
    on EncryptionChallengeIdentifier {
  EncryptionChallengeIdentifier copyWith({String? $value}) {
    return EncryptionChallengeIdentifier($value: $value ?? this.$value);
  }

  EncryptionChallengeIdentifier copyWithWrapped({Wrapped<String?>? $value}) {
    return EncryptionChallengeIdentifier(
        $value: ($value != null ? $value.value : this.$value));
  }
}

@JsonSerializable(explicitToJson: true)
class GoogleLoginDto {
  const GoogleLoginDto({
    required this.accessToken,
    required this.identityToken,
  });

  factory GoogleLoginDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleLoginDtoFromJson(json);

  static const toJsonFactory = _$GoogleLoginDtoToJson;
  Map<String, dynamic> toJson() => _$GoogleLoginDtoToJson(this);

  @JsonKey(name: 'accessToken')
  final String accessToken;
  @JsonKey(name: 'identityToken')
  final String identityToken;
  static const fromJsonFactory = _$GoogleLoginDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is GoogleLoginDto &&
            (identical(other.accessToken, accessToken) ||
                const DeepCollectionEquality()
                    .equals(other.accessToken, accessToken)) &&
            (identical(other.identityToken, identityToken) ||
                const DeepCollectionEquality()
                    .equals(other.identityToken, identityToken)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(accessToken) ^
      const DeepCollectionEquality().hash(identityToken) ^
      runtimeType.hashCode;
}

extension $GoogleLoginDtoExtension on GoogleLoginDto {
  GoogleLoginDto copyWith({String? accessToken, String? identityToken}) {
    return GoogleLoginDto(
        accessToken: accessToken ?? this.accessToken,
        identityToken: identityToken ?? this.identityToken);
  }

  GoogleLoginDto copyWithWrapped(
      {Wrapped<String>? accessToken, Wrapped<String>? identityToken}) {
    return GoogleLoginDto(
        accessToken:
            (accessToken != null ? accessToken.value : this.accessToken),
        identityToken:
            (identityToken != null ? identityToken.value : this.identityToken));
  }
}

@JsonSerializable(explicitToJson: true)
class HandleJoinRequestDto {
  const HandleJoinRequestDto({
    required this.campagneJoinRequestId,
    required this.type,
  });

  factory HandleJoinRequestDto.fromJson(Map<String, dynamic> json) =>
      _$HandleJoinRequestDtoFromJson(json);

  static const toJsonFactory = _$HandleJoinRequestDtoToJson;
  Map<String, dynamic> toJson() => _$HandleJoinRequestDtoToJson(this);

  @JsonKey(name: 'campagneJoinRequestId')
  final String campagneJoinRequestId;
  @JsonKey(
    name: 'type',
    toJson: handleJoinRequestTypeToJson,
    fromJson: handleJoinRequestTypeFromJson,
  )
  final enums.HandleJoinRequestType type;
  static const fromJsonFactory = _$HandleJoinRequestDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HandleJoinRequestDto &&
            (identical(other.campagneJoinRequestId, campagneJoinRequestId) ||
                const DeepCollectionEquality().equals(
                    other.campagneJoinRequestId, campagneJoinRequestId)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(campagneJoinRequestId) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $HandleJoinRequestDtoExtension on HandleJoinRequestDto {
  HandleJoinRequestDto copyWith(
      {String? campagneJoinRequestId, enums.HandleJoinRequestType? type}) {
    return HandleJoinRequestDto(
        campagneJoinRequestId:
            campagneJoinRequestId ?? this.campagneJoinRequestId,
        type: type ?? this.type);
  }

  HandleJoinRequestDto copyWithWrapped(
      {Wrapped<String>? campagneJoinRequestId,
      Wrapped<enums.HandleJoinRequestType>? type}) {
    return HandleJoinRequestDto(
        campagneJoinRequestId: (campagneJoinRequestId != null
            ? campagneJoinRequestId.value
            : this.campagneJoinRequestId),
        type: (type != null ? type.value : this.type));
  }
}

@JsonSerializable(explicitToJson: true)
class JoinRequestForCampagneDto {
  const JoinRequestForCampagneDto({
    required this.request,
    required this.playerCharacter,
    required this.username,
  });

  factory JoinRequestForCampagneDto.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestForCampagneDtoFromJson(json);

  static const toJsonFactory = _$JoinRequestForCampagneDtoToJson;
  Map<String, dynamic> toJson() => _$JoinRequestForCampagneDtoToJson(this);

  @JsonKey(name: 'request')
  final CampagneJoinRequest request;
  @JsonKey(name: 'playerCharacter')
  final PlayerCharacter playerCharacter;
  @JsonKey(name: 'username')
  final String username;
  static const fromJsonFactory = _$JoinRequestForCampagneDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is JoinRequestForCampagneDto &&
            (identical(other.request, request) ||
                const DeepCollectionEquality()
                    .equals(other.request, request)) &&
            (identical(other.playerCharacter, playerCharacter) ||
                const DeepCollectionEquality()
                    .equals(other.playerCharacter, playerCharacter)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(request) ^
      const DeepCollectionEquality().hash(playerCharacter) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $JoinRequestForCampagneDtoExtension on JoinRequestForCampagneDto {
  JoinRequestForCampagneDto copyWith(
      {CampagneJoinRequest? request,
      PlayerCharacter? playerCharacter,
      String? username}) {
    return JoinRequestForCampagneDto(
        request: request ?? this.request,
        playerCharacter: playerCharacter ?? this.playerCharacter,
        username: username ?? this.username);
  }

  JoinRequestForCampagneDto copyWithWrapped(
      {Wrapped<CampagneJoinRequest>? request,
      Wrapped<PlayerCharacter>? playerCharacter,
      Wrapped<String>? username}) {
    return JoinRequestForCampagneDto(
        request: (request != null ? request.value : this.request),
        playerCharacter: (playerCharacter != null
            ? playerCharacter.value
            : this.playerCharacter),
        username: (username != null ? username.value : this.username));
  }
}

@JsonSerializable(explicitToJson: true)
class LoginWithUsernameAndPasswordDto {
  const LoginWithUsernameAndPasswordDto({
    required this.username,
    required this.userSecretByEncryptionChallenge,
  });

  factory LoginWithUsernameAndPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$LoginWithUsernameAndPasswordDtoFromJson(json);

  static const toJsonFactory = _$LoginWithUsernameAndPasswordDtoToJson;
  Map<String, dynamic> toJson() =>
      _$LoginWithUsernameAndPasswordDtoToJson(this);

  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'userSecretByEncryptionChallenge')
  final String userSecretByEncryptionChallenge;
  static const fromJsonFactory = _$LoginWithUsernameAndPasswordDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LoginWithUsernameAndPasswordDto &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)) &&
            (identical(other.userSecretByEncryptionChallenge,
                    userSecretByEncryptionChallenge) ||
                const DeepCollectionEquality().equals(
                    other.userSecretByEncryptionChallenge,
                    userSecretByEncryptionChallenge)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(userSecretByEncryptionChallenge) ^
      runtimeType.hashCode;
}

extension $LoginWithUsernameAndPasswordDtoExtension
    on LoginWithUsernameAndPasswordDto {
  LoginWithUsernameAndPasswordDto copyWith(
      {String? username, String? userSecretByEncryptionChallenge}) {
    return LoginWithUsernameAndPasswordDto(
        username: username ?? this.username,
        userSecretByEncryptionChallenge: userSecretByEncryptionChallenge ??
            this.userSecretByEncryptionChallenge);
  }

  LoginWithUsernameAndPasswordDto copyWithWrapped(
      {Wrapped<String>? username,
      Wrapped<String>? userSecretByEncryptionChallenge}) {
    return LoginWithUsernameAndPasswordDto(
        username: (username != null ? username.value : this.username),
        userSecretByEncryptionChallenge:
            (userSecretByEncryptionChallenge != null
                ? userSecretByEncryptionChallenge.value
                : this.userSecretByEncryptionChallenge));
  }
}

@JsonSerializable(explicitToJson: true)
class PlayerCharacter {
  const PlayerCharacter({
    this.id,
    this.creationDate,
    this.lastModifiedAt,
    this.rpgCharacterConfiguration,
    this.characterName,
    this.playerUserId,
    this.campagneId,
  });

  factory PlayerCharacter.fromJson(Map<String, dynamic> json) =>
      _$PlayerCharacterFromJson(json);

  static const toJsonFactory = _$PlayerCharacterToJson;
  Map<String, dynamic> toJson() => _$PlayerCharacterToJson(this);

  @JsonKey(name: 'id')
  final PlayerCharacterIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  @JsonKey(name: 'rpgCharacterConfiguration')
  final String? rpgCharacterConfiguration;
  @JsonKey(name: 'characterName')
  final String? characterName;
  @JsonKey(name: 'playerUserId')
  final UserIdentifier? playerUserId;
  @JsonKey(name: 'campagneId')
  final CampagneIdentifier? campagneId;
  static const fromJsonFactory = _$PlayerCharacterFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PlayerCharacter &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality()
                    .equals(other.creationDate, creationDate)) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality()
                    .equals(other.lastModifiedAt, lastModifiedAt)) &&
            (identical(other.rpgCharacterConfiguration,
                    rpgCharacterConfiguration) ||
                const DeepCollectionEquality().equals(
                    other.rpgCharacterConfiguration,
                    rpgCharacterConfiguration)) &&
            (identical(other.characterName, characterName) ||
                const DeepCollectionEquality()
                    .equals(other.characterName, characterName)) &&
            (identical(other.playerUserId, playerUserId) ||
                const DeepCollectionEquality()
                    .equals(other.playerUserId, playerUserId)) &&
            (identical(other.campagneId, campagneId) ||
                const DeepCollectionEquality()
                    .equals(other.campagneId, campagneId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      const DeepCollectionEquality().hash(rpgCharacterConfiguration) ^
      const DeepCollectionEquality().hash(characterName) ^
      const DeepCollectionEquality().hash(playerUserId) ^
      const DeepCollectionEquality().hash(campagneId) ^
      runtimeType.hashCode;
}

extension $PlayerCharacterExtension on PlayerCharacter {
  PlayerCharacter copyWith(
      {PlayerCharacterIdentifier? id,
      DateTime? creationDate,
      DateTime? lastModifiedAt,
      String? rpgCharacterConfiguration,
      String? characterName,
      UserIdentifier? playerUserId,
      CampagneIdentifier? campagneId}) {
    return PlayerCharacter(
        id: id ?? this.id,
        creationDate: creationDate ?? this.creationDate,
        lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
        rpgCharacterConfiguration:
            rpgCharacterConfiguration ?? this.rpgCharacterConfiguration,
        characterName: characterName ?? this.characterName,
        playerUserId: playerUserId ?? this.playerUserId,
        campagneId: campagneId ?? this.campagneId);
  }

  PlayerCharacter copyWithWrapped(
      {Wrapped<PlayerCharacterIdentifier?>? id,
      Wrapped<DateTime?>? creationDate,
      Wrapped<DateTime?>? lastModifiedAt,
      Wrapped<String?>? rpgCharacterConfiguration,
      Wrapped<String?>? characterName,
      Wrapped<UserIdentifier?>? playerUserId,
      Wrapped<CampagneIdentifier?>? campagneId}) {
    return PlayerCharacter(
        id: (id != null ? id.value : this.id),
        creationDate:
            (creationDate != null ? creationDate.value : this.creationDate),
        lastModifiedAt: (lastModifiedAt != null
            ? lastModifiedAt.value
            : this.lastModifiedAt),
        rpgCharacterConfiguration: (rpgCharacterConfiguration != null
            ? rpgCharacterConfiguration.value
            : this.rpgCharacterConfiguration),
        characterName:
            (characterName != null ? characterName.value : this.characterName),
        playerUserId:
            (playerUserId != null ? playerUserId.value : this.playerUserId),
        campagneId: (campagneId != null ? campagneId.value : this.campagneId));
  }
}

@JsonSerializable(explicitToJson: true)
class PlayerCharacterCreateDto {
  const PlayerCharacterCreateDto({
    this.rpgCharacterConfiguration,
    required this.characterName,
    this.campagneId,
  });

  factory PlayerCharacterCreateDto.fromJson(Map<String, dynamic> json) =>
      _$PlayerCharacterCreateDtoFromJson(json);

  static const toJsonFactory = _$PlayerCharacterCreateDtoToJson;
  Map<String, dynamic> toJson() => _$PlayerCharacterCreateDtoToJson(this);

  @JsonKey(name: 'rpgCharacterConfiguration')
  final String? rpgCharacterConfiguration;
  @JsonKey(name: 'characterName')
  final String characterName;
  @JsonKey(name: 'campagneId')
  final String? campagneId;
  static const fromJsonFactory = _$PlayerCharacterCreateDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PlayerCharacterCreateDto &&
            (identical(other.rpgCharacterConfiguration,
                    rpgCharacterConfiguration) ||
                const DeepCollectionEquality().equals(
                    other.rpgCharacterConfiguration,
                    rpgCharacterConfiguration)) &&
            (identical(other.characterName, characterName) ||
                const DeepCollectionEquality()
                    .equals(other.characterName, characterName)) &&
            (identical(other.campagneId, campagneId) ||
                const DeepCollectionEquality()
                    .equals(other.campagneId, campagneId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(rpgCharacterConfiguration) ^
      const DeepCollectionEquality().hash(characterName) ^
      const DeepCollectionEquality().hash(campagneId) ^
      runtimeType.hashCode;
}

extension $PlayerCharacterCreateDtoExtension on PlayerCharacterCreateDto {
  PlayerCharacterCreateDto copyWith(
      {String? rpgCharacterConfiguration,
      String? characterName,
      String? campagneId}) {
    return PlayerCharacterCreateDto(
        rpgCharacterConfiguration:
            rpgCharacterConfiguration ?? this.rpgCharacterConfiguration,
        characterName: characterName ?? this.characterName,
        campagneId: campagneId ?? this.campagneId);
  }

  PlayerCharacterCreateDto copyWithWrapped(
      {Wrapped<String?>? rpgCharacterConfiguration,
      Wrapped<String>? characterName,
      Wrapped<String?>? campagneId}) {
    return PlayerCharacterCreateDto(
        rpgCharacterConfiguration: (rpgCharacterConfiguration != null
            ? rpgCharacterConfiguration.value
            : this.rpgCharacterConfiguration),
        characterName:
            (characterName != null ? characterName.value : this.characterName),
        campagneId: (campagneId != null ? campagneId.value : this.campagneId));
  }
}

@JsonSerializable(explicitToJson: true)
class PlayerCharacterIdentifier {
  const PlayerCharacterIdentifier({
    this.$value,
  });

  factory PlayerCharacterIdentifier.fromJson(Map<String, dynamic> json) =>
      _$PlayerCharacterIdentifierFromJson(json);

  static const toJsonFactory = _$PlayerCharacterIdentifierToJson;
  Map<String, dynamic> toJson() => _$PlayerCharacterIdentifierToJson(this);

  @JsonKey(name: 'value')
  final String? $value;
  static const fromJsonFactory = _$PlayerCharacterIdentifierFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PlayerCharacterIdentifier &&
            (identical(other.$value, $value) ||
                const DeepCollectionEquality().equals(other.$value, $value)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($value) ^ runtimeType.hashCode;
}

extension $PlayerCharacterIdentifierExtension on PlayerCharacterIdentifier {
  PlayerCharacterIdentifier copyWith({String? $value}) {
    return PlayerCharacterIdentifier($value: $value ?? this.$value);
  }

  PlayerCharacterIdentifier copyWithWrapped({Wrapped<String?>? $value}) {
    return PlayerCharacterIdentifier(
        $value: ($value != null ? $value.value : this.$value));
  }
}

@JsonSerializable(explicitToJson: true)
class ProblemDetails {
  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
  });

  factory ProblemDetails.fromJson(Map<String, dynamic> json) =>
      _$ProblemDetailsFromJson(json);

  static const toJsonFactory = _$ProblemDetailsToJson;
  Map<String, dynamic> toJson() => _$ProblemDetailsToJson(this);

  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'status')
  final int? status;
  @JsonKey(name: 'detail')
  final String? detail;
  @JsonKey(name: 'instance')
  final String? instance;
  static const fromJsonFactory = _$ProblemDetailsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProblemDetails &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.detail, detail) ||
                const DeepCollectionEquality().equals(other.detail, detail)) &&
            (identical(other.instance, instance) ||
                const DeepCollectionEquality()
                    .equals(other.instance, instance)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(detail) ^
      const DeepCollectionEquality().hash(instance) ^
      runtimeType.hashCode;
}

extension $ProblemDetailsExtension on ProblemDetails {
  ProblemDetails copyWith(
      {String? type,
      String? title,
      int? status,
      String? detail,
      String? instance}) {
    return ProblemDetails(
        type: type ?? this.type,
        title: title ?? this.title,
        status: status ?? this.status,
        detail: detail ?? this.detail,
        instance: instance ?? this.instance);
  }

  ProblemDetails copyWithWrapped(
      {Wrapped<String?>? type,
      Wrapped<String?>? title,
      Wrapped<int?>? status,
      Wrapped<String?>? detail,
      Wrapped<String?>? instance}) {
    return ProblemDetails(
        type: (type != null ? type.value : this.type),
        title: (title != null ? title.value : this.title),
        status: (status != null ? status.value : this.status),
        detail: (detail != null ? detail.value : this.detail),
        instance: (instance != null ? instance.value : this.instance));
  }
}

@JsonSerializable(explicitToJson: true)
class RegisterWithApiKeyDto {
  const RegisterWithApiKeyDto({
    required this.apiKey,
    required this.username,
  });

  factory RegisterWithApiKeyDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterWithApiKeyDtoFromJson(json);

  static const toJsonFactory = _$RegisterWithApiKeyDtoToJson;
  Map<String, dynamic> toJson() => _$RegisterWithApiKeyDtoToJson(this);

  @JsonKey(name: 'apiKey')
  final String apiKey;
  @JsonKey(name: 'username')
  final String username;
  static const fromJsonFactory = _$RegisterWithApiKeyDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RegisterWithApiKeyDto &&
            (identical(other.apiKey, apiKey) ||
                const DeepCollectionEquality().equals(other.apiKey, apiKey)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(apiKey) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $RegisterWithApiKeyDtoExtension on RegisterWithApiKeyDto {
  RegisterWithApiKeyDto copyWith({String? apiKey, String? username}) {
    return RegisterWithApiKeyDto(
        apiKey: apiKey ?? this.apiKey, username: username ?? this.username);
  }

  RegisterWithApiKeyDto copyWithWrapped(
      {Wrapped<String>? apiKey, Wrapped<String>? username}) {
    return RegisterWithApiKeyDto(
        apiKey: (apiKey != null ? apiKey.value : this.apiKey),
        username: (username != null ? username.value : this.username));
  }
}

@JsonSerializable(explicitToJson: true)
class RegisterWithUsernamePasswordDto {
  const RegisterWithUsernamePasswordDto({
    required this.email,
    required this.encryptionChallengeIdentifier,
    required this.username,
    required this.userSecret,
  });

  factory RegisterWithUsernamePasswordDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterWithUsernamePasswordDtoFromJson(json);

  static const toJsonFactory = _$RegisterWithUsernamePasswordDtoToJson;
  Map<String, dynamic> toJson() =>
      _$RegisterWithUsernamePasswordDtoToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'encryptionChallengeIdentifier')
  final EncryptionChallengeIdentifier encryptionChallengeIdentifier;
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'userSecret')
  final String userSecret;
  static const fromJsonFactory = _$RegisterWithUsernamePasswordDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RegisterWithUsernamePasswordDto &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.encryptionChallengeIdentifier,
                    encryptionChallengeIdentifier) ||
                const DeepCollectionEquality().equals(
                    other.encryptionChallengeIdentifier,
                    encryptionChallengeIdentifier)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)) &&
            (identical(other.userSecret, userSecret) ||
                const DeepCollectionEquality()
                    .equals(other.userSecret, userSecret)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(encryptionChallengeIdentifier) ^
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(userSecret) ^
      runtimeType.hashCode;
}

extension $RegisterWithUsernamePasswordDtoExtension
    on RegisterWithUsernamePasswordDto {
  RegisterWithUsernamePasswordDto copyWith(
      {String? email,
      EncryptionChallengeIdentifier? encryptionChallengeIdentifier,
      String? username,
      String? userSecret}) {
    return RegisterWithUsernamePasswordDto(
        email: email ?? this.email,
        encryptionChallengeIdentifier:
            encryptionChallengeIdentifier ?? this.encryptionChallengeIdentifier,
        username: username ?? this.username,
        userSecret: userSecret ?? this.userSecret);
  }

  RegisterWithUsernamePasswordDto copyWithWrapped(
      {Wrapped<String>? email,
      Wrapped<EncryptionChallengeIdentifier>? encryptionChallengeIdentifier,
      Wrapped<String>? username,
      Wrapped<String>? userSecret}) {
    return RegisterWithUsernamePasswordDto(
        email: (email != null ? email.value : this.email),
        encryptionChallengeIdentifier: (encryptionChallengeIdentifier != null
            ? encryptionChallengeIdentifier.value
            : this.encryptionChallengeIdentifier),
        username: (username != null ? username.value : this.username),
        userSecret: (userSecret != null ? userSecret.value : this.userSecret));
  }
}

@JsonSerializable(explicitToJson: true)
class ResetPasswordDto {
  const ResetPasswordDto({
    required this.email,
    required this.newHashedPassword,
    required this.resetCode,
    required this.username,
  });

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDtoFromJson(json);

  static const toJsonFactory = _$ResetPasswordDtoToJson;
  Map<String, dynamic> toJson() => _$ResetPasswordDtoToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'newHashedPassword')
  final String newHashedPassword;
  @JsonKey(name: 'resetCode')
  final String resetCode;
  @JsonKey(name: 'username')
  final String username;
  static const fromJsonFactory = _$ResetPasswordDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ResetPasswordDto &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.newHashedPassword, newHashedPassword) ||
                const DeepCollectionEquality()
                    .equals(other.newHashedPassword, newHashedPassword)) &&
            (identical(other.resetCode, resetCode) ||
                const DeepCollectionEquality()
                    .equals(other.resetCode, resetCode)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(newHashedPassword) ^
      const DeepCollectionEquality().hash(resetCode) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $ResetPasswordDtoExtension on ResetPasswordDto {
  ResetPasswordDto copyWith(
      {String? email,
      String? newHashedPassword,
      String? resetCode,
      String? username}) {
    return ResetPasswordDto(
        email: email ?? this.email,
        newHashedPassword: newHashedPassword ?? this.newHashedPassword,
        resetCode: resetCode ?? this.resetCode,
        username: username ?? this.username);
  }

  ResetPasswordDto copyWithWrapped(
      {Wrapped<String>? email,
      Wrapped<String>? newHashedPassword,
      Wrapped<String>? resetCode,
      Wrapped<String>? username}) {
    return ResetPasswordDto(
        email: (email != null ? email.value : this.email),
        newHashedPassword: (newHashedPassword != null
            ? newHashedPassword.value
            : this.newHashedPassword),
        resetCode: (resetCode != null ? resetCode.value : this.resetCode),
        username: (username != null ? username.value : this.username));
  }
}

@JsonSerializable(explicitToJson: true)
class ResetPasswordRequestDto {
  const ResetPasswordRequestDto({
    required this.email,
    required this.username,
  });

  factory ResetPasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestDtoFromJson(json);

  static const toJsonFactory = _$ResetPasswordRequestDtoToJson;
  Map<String, dynamic> toJson() => _$ResetPasswordRequestDtoToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'username')
  final String username;
  static const fromJsonFactory = _$ResetPasswordRequestDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ResetPasswordRequestDto &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $ResetPasswordRequestDtoExtension on ResetPasswordRequestDto {
  ResetPasswordRequestDto copyWith({String? email, String? username}) {
    return ResetPasswordRequestDto(
        email: email ?? this.email, username: username ?? this.username);
  }

  ResetPasswordRequestDto copyWithWrapped(
      {Wrapped<String>? email, Wrapped<String>? username}) {
    return ResetPasswordRequestDto(
        email: (email != null ? email.value : this.email),
        username: (username != null ? username.value : this.username));
  }
}

@JsonSerializable(explicitToJson: true)
class UserIdentifier {
  const UserIdentifier({
    this.$value,
  });

  factory UserIdentifier.fromJson(Map<String, dynamic> json) =>
      _$UserIdentifierFromJson(json);

  static const toJsonFactory = _$UserIdentifierToJson;
  Map<String, dynamic> toJson() => _$UserIdentifierToJson(this);

  @JsonKey(name: 'value')
  final String? $value;
  static const fromJsonFactory = _$UserIdentifierFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserIdentifier &&
            (identical(other.$value, $value) ||
                const DeepCollectionEquality().equals(other.$value, $value)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($value) ^ runtimeType.hashCode;
}

extension $UserIdentifierExtension on UserIdentifier {
  UserIdentifier copyWith({String? $value}) {
    return UserIdentifier($value: $value ?? this.$value);
  }

  UserIdentifier copyWithWrapped({Wrapped<String?>? $value}) {
    return UserIdentifier(
        $value: ($value != null ? $value.value : this.$value));
  }
}

String? handleJoinRequestTypeNullableToJson(
    enums.HandleJoinRequestType? handleJoinRequestType) {
  return handleJoinRequestType?.value;
}

String? handleJoinRequestTypeToJson(
    enums.HandleJoinRequestType handleJoinRequestType) {
  return handleJoinRequestType.value;
}

enums.HandleJoinRequestType handleJoinRequestTypeFromJson(
  Object? handleJoinRequestType, [
  enums.HandleJoinRequestType? defaultValue,
]) {
  return enums.HandleJoinRequestType.values.firstWhereOrNull((e) =>
          e.value.toString().toLowerCase() ==
          handleJoinRequestType?.toString().toLowerCase()) ??
      defaultValue ??
      enums.HandleJoinRequestType.swaggerGeneratedUnknown;
}

enums.HandleJoinRequestType? handleJoinRequestTypeNullableFromJson(
  Object? handleJoinRequestType, [
  enums.HandleJoinRequestType? defaultValue,
]) {
  if (handleJoinRequestType == null) {
    return null;
  }
  return enums.HandleJoinRequestType.values.firstWhereOrNull((e) =>
          e.value.toString().toLowerCase() ==
          handleJoinRequestType.toString().toLowerCase()) ??
      defaultValue;
}

String handleJoinRequestTypeExplodedListToJson(
    List<enums.HandleJoinRequestType>? handleJoinRequestType) {
  return handleJoinRequestType?.map((e) => e.value!).join(',') ?? '';
}

List<String> handleJoinRequestTypeListToJson(
    List<enums.HandleJoinRequestType>? handleJoinRequestType) {
  if (handleJoinRequestType == null) {
    return [];
  }

  return handleJoinRequestType.map((e) => e.value!).toList();
}

List<enums.HandleJoinRequestType> handleJoinRequestTypeListFromJson(
  List? handleJoinRequestType, [
  List<enums.HandleJoinRequestType>? defaultValue,
]) {
  if (handleJoinRequestType == null) {
    return defaultValue ?? [];
  }

  return handleJoinRequestType
      .map((e) => handleJoinRequestTypeFromJson(e.toString()))
      .toList();
}

List<enums.HandleJoinRequestType>? handleJoinRequestTypeNullableListFromJson(
  List? handleJoinRequestType, [
  List<enums.HandleJoinRequestType>? defaultValue,
]) {
  if (handleJoinRequestType == null) {
    return defaultValue;
  }

  return handleJoinRequestType
      .map((e) => handleJoinRequestTypeFromJson(e.toString()))
      .toList();
}

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
