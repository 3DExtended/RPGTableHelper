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
                const DeepCollectionEquality().equals(
                  other.authorizationCode,
                  authorizationCode,
                )) &&
            (identical(other.identityToken, identityToken) ||
                const DeepCollectionEquality().equals(
                  other.identityToken,
                  identityToken,
                )));
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
  AppleLoginDetails copyWith({
    String? authorizationCode,
    String? identityToken,
  }) {
    return AppleLoginDetails(
      authorizationCode: authorizationCode ?? this.authorizationCode,
      identityToken: identityToken ?? this.identityToken,
    );
  }

  AppleLoginDetails copyWithWrapped({
    Wrapped<String>? authorizationCode,
    Wrapped<String>? identityToken,
  }) {
    return AppleLoginDetails(
      authorizationCode: (authorizationCode != null
          ? authorizationCode.value
          : this.authorizationCode),
      identityToken: (identityToken != null
          ? identityToken.value
          : this.identityToken),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Campagne {
  const Campagne({
    this.rpgConfiguration,
    this.campagneName,
    this.joinCode,
    this.dmUserId,
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory Campagne.fromJson(Map<String, dynamic> json) =>
      _$CampagneFromJson(json);

  static const toJsonFactory = _$CampagneToJson;
  Map<String, dynamic> toJson() => _$CampagneToJson(this);

  @JsonKey(name: 'rpgConfiguration')
  final String? rpgConfiguration;
  @JsonKey(name: 'campagneName')
  final String? campagneName;
  @JsonKey(name: 'joinCode')
  final String? joinCode;
  @JsonKey(name: 'dmUserId')
  final UserIdentifier? dmUserId;
  @JsonKey(name: 'id')
  final CampagneIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory = _$CampagneFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Campagne &&
            (identical(other.rpgConfiguration, rpgConfiguration) ||
                const DeepCollectionEquality().equals(
                  other.rpgConfiguration,
                  rpgConfiguration,
                )) &&
            (identical(other.campagneName, campagneName) ||
                const DeepCollectionEquality().equals(
                  other.campagneName,
                  campagneName,
                )) &&
            (identical(other.joinCode, joinCode) ||
                const DeepCollectionEquality().equals(
                  other.joinCode,
                  joinCode,
                )) &&
            (identical(other.dmUserId, dmUserId) ||
                const DeepCollectionEquality().equals(
                  other.dmUserId,
                  dmUserId,
                )) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(rpgConfiguration) ^
      const DeepCollectionEquality().hash(campagneName) ^
      const DeepCollectionEquality().hash(joinCode) ^
      const DeepCollectionEquality().hash(dmUserId) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $CampagneExtension on Campagne {
  Campagne copyWith({
    String? rpgConfiguration,
    String? campagneName,
    String? joinCode,
    UserIdentifier? dmUserId,
    CampagneIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return Campagne(
      rpgConfiguration: rpgConfiguration ?? this.rpgConfiguration,
      campagneName: campagneName ?? this.campagneName,
      joinCode: joinCode ?? this.joinCode,
      dmUserId: dmUserId ?? this.dmUserId,
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  Campagne copyWithWrapped({
    Wrapped<String?>? rpgConfiguration,
    Wrapped<String?>? campagneName,
    Wrapped<String?>? joinCode,
    Wrapped<UserIdentifier?>? dmUserId,
    Wrapped<CampagneIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return Campagne(
      rpgConfiguration: (rpgConfiguration != null
          ? rpgConfiguration.value
          : this.rpgConfiguration),
      campagneName: (campagneName != null
          ? campagneName.value
          : this.campagneName),
      joinCode: (joinCode != null ? joinCode.value : this.joinCode),
      dmUserId: (dmUserId != null ? dmUserId.value : this.dmUserId),
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneCreateDto {
  const CampagneCreateDto({this.rpgConfiguration, required this.campagneName});

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
                const DeepCollectionEquality().equals(
                  other.rpgConfiguration,
                  rpgConfiguration,
                )) &&
            (identical(other.campagneName, campagneName) ||
                const DeepCollectionEquality().equals(
                  other.campagneName,
                  campagneName,
                )));
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
      campagneName: campagneName ?? this.campagneName,
    );
  }

  CampagneCreateDto copyWithWrapped({
    Wrapped<String?>? rpgConfiguration,
    Wrapped<String>? campagneName,
  }) {
    return CampagneCreateDto(
      rpgConfiguration: (rpgConfiguration != null
          ? rpgConfiguration.value
          : this.rpgConfiguration),
      campagneName: (campagneName != null
          ? campagneName.value
          : this.campagneName),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneIdentifier {
  const CampagneIdentifier({this.$value});

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
      $value: ($value != null ? $value.value : this.$value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneIdentifierGuidNodeModelBase {
  const CampagneIdentifierGuidNodeModelBase({
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory CampagneIdentifierGuidNodeModelBase.fromJson(
    Map<String, dynamic> json,
  ) => _$CampagneIdentifierGuidNodeModelBaseFromJson(json);

  static const toJsonFactory = _$CampagneIdentifierGuidNodeModelBaseToJson;
  Map<String, dynamic> toJson() =>
      _$CampagneIdentifierGuidNodeModelBaseToJson(this);

  @JsonKey(name: 'id')
  final CampagneIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory = _$CampagneIdentifierGuidNodeModelBaseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CampagneIdentifierGuidNodeModelBase &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $CampagneIdentifierGuidNodeModelBaseExtension
    on CampagneIdentifierGuidNodeModelBase {
  CampagneIdentifierGuidNodeModelBase copyWith({
    CampagneIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return CampagneIdentifierGuidNodeModelBase(
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  CampagneIdentifierGuidNodeModelBase copyWithWrapped({
    Wrapped<CampagneIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return CampagneIdentifierGuidNodeModelBase(
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneJoinRequest {
  const CampagneJoinRequest({
    this.userId,
    this.playerId,
    this.campagneId,
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory CampagneJoinRequest.fromJson(Map<String, dynamic> json) =>
      _$CampagneJoinRequestFromJson(json);

  static const toJsonFactory = _$CampagneJoinRequestToJson;
  Map<String, dynamic> toJson() => _$CampagneJoinRequestToJson(this);

  @JsonKey(name: 'userId')
  final UserIdentifier? userId;
  @JsonKey(name: 'playerId')
  final PlayerCharacterIdentifier? playerId;
  @JsonKey(name: 'campagneId')
  final CampagneIdentifier? campagneId;
  @JsonKey(name: 'id')
  final CampagneJoinRequestIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory = _$CampagneJoinRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CampagneJoinRequest &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.playerId, playerId) ||
                const DeepCollectionEquality().equals(
                  other.playerId,
                  playerId,
                )) &&
            (identical(other.campagneId, campagneId) ||
                const DeepCollectionEquality().equals(
                  other.campagneId,
                  campagneId,
                )) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(playerId) ^
      const DeepCollectionEquality().hash(campagneId) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $CampagneJoinRequestExtension on CampagneJoinRequest {
  CampagneJoinRequest copyWith({
    UserIdentifier? userId,
    PlayerCharacterIdentifier? playerId,
    CampagneIdentifier? campagneId,
    CampagneJoinRequestIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return CampagneJoinRequest(
      userId: userId ?? this.userId,
      playerId: playerId ?? this.playerId,
      campagneId: campagneId ?? this.campagneId,
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  CampagneJoinRequest copyWithWrapped({
    Wrapped<UserIdentifier?>? userId,
    Wrapped<PlayerCharacterIdentifier?>? playerId,
    Wrapped<CampagneIdentifier?>? campagneId,
    Wrapped<CampagneJoinRequestIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return CampagneJoinRequest(
      userId: (userId != null ? userId.value : this.userId),
      playerId: (playerId != null ? playerId.value : this.playerId),
      campagneId: (campagneId != null ? campagneId.value : this.campagneId),
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneJoinRequestCreateDto {
  const CampagneJoinRequestCreateDto({
    required this.campagneJoinCode,
    required this.playerCharacterId,
  });

  factory CampagneJoinRequestCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CampagneJoinRequestCreateDtoFromJson(json);

  static const toJsonFactory = _$CampagneJoinRequestCreateDtoToJson;
  Map<String, dynamic> toJson() => _$CampagneJoinRequestCreateDtoToJson(this);

  @JsonKey(name: 'campagneJoinCode')
  final String campagneJoinCode;
  @JsonKey(name: 'playerCharacterId')
  final String playerCharacterId;
  static const fromJsonFactory = _$CampagneJoinRequestCreateDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CampagneJoinRequestCreateDto &&
            (identical(other.campagneJoinCode, campagneJoinCode) ||
                const DeepCollectionEquality().equals(
                  other.campagneJoinCode,
                  campagneJoinCode,
                )) &&
            (identical(other.playerCharacterId, playerCharacterId) ||
                const DeepCollectionEquality().equals(
                  other.playerCharacterId,
                  playerCharacterId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(campagneJoinCode) ^
      const DeepCollectionEquality().hash(playerCharacterId) ^
      runtimeType.hashCode;
}

extension $CampagneJoinRequestCreateDtoExtension
    on CampagneJoinRequestCreateDto {
  CampagneJoinRequestCreateDto copyWith({
    String? campagneJoinCode,
    String? playerCharacterId,
  }) {
    return CampagneJoinRequestCreateDto(
      campagneJoinCode: campagneJoinCode ?? this.campagneJoinCode,
      playerCharacterId: playerCharacterId ?? this.playerCharacterId,
    );
  }

  CampagneJoinRequestCreateDto copyWithWrapped({
    Wrapped<String>? campagneJoinCode,
    Wrapped<String>? playerCharacterId,
  }) {
    return CampagneJoinRequestCreateDto(
      campagneJoinCode: (campagneJoinCode != null
          ? campagneJoinCode.value
          : this.campagneJoinCode),
      playerCharacterId: (playerCharacterId != null
          ? playerCharacterId.value
          : this.playerCharacterId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneJoinRequestIdentifier {
  const CampagneJoinRequestIdentifier({this.$value});

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
      $value: ($value != null ? $value.value : this.$value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CampagneJoinRequestIdentifierGuidNodeModelBase {
  const CampagneJoinRequestIdentifierGuidNodeModelBase({
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory CampagneJoinRequestIdentifierGuidNodeModelBase.fromJson(
    Map<String, dynamic> json,
  ) => _$CampagneJoinRequestIdentifierGuidNodeModelBaseFromJson(json);

  static const toJsonFactory =
      _$CampagneJoinRequestIdentifierGuidNodeModelBaseToJson;
  Map<String, dynamic> toJson() =>
      _$CampagneJoinRequestIdentifierGuidNodeModelBaseToJson(this);

  @JsonKey(name: 'id')
  final CampagneJoinRequestIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory =
      _$CampagneJoinRequestIdentifierGuidNodeModelBaseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CampagneJoinRequestIdentifierGuidNodeModelBase &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $CampagneJoinRequestIdentifierGuidNodeModelBaseExtension
    on CampagneJoinRequestIdentifierGuidNodeModelBase {
  CampagneJoinRequestIdentifierGuidNodeModelBase copyWith({
    CampagneJoinRequestIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return CampagneJoinRequestIdentifierGuidNodeModelBase(
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  CampagneJoinRequestIdentifierGuidNodeModelBase copyWithWrapped({
    Wrapped<CampagneJoinRequestIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return CampagneJoinRequestIdentifierGuidNodeModelBase(
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EncryptedMessageWrapperDto {
  const EncryptedMessageWrapperDto({this.encryptedMessage});

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
                const DeepCollectionEquality().equals(
                  other.encryptedMessage,
                  encryptedMessage,
                )));
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
      encryptedMessage: encryptedMessage ?? this.encryptedMessage,
    );
  }

  EncryptedMessageWrapperDto copyWithWrapped({
    Wrapped<String?>? encryptedMessage,
  }) {
    return EncryptedMessageWrapperDto(
      encryptedMessage: (encryptedMessage != null
          ? encryptedMessage.value
          : this.encryptedMessage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EncryptionChallengeIdentifier {
  const EncryptionChallengeIdentifier({this.$value});

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
      $value: ($value != null ? $value.value : this.$value),
    );
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
                const DeepCollectionEquality().equals(
                  other.accessToken,
                  accessToken,
                )) &&
            (identical(other.identityToken, identityToken) ||
                const DeepCollectionEquality().equals(
                  other.identityToken,
                  identityToken,
                )));
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
      identityToken: identityToken ?? this.identityToken,
    );
  }

  GoogleLoginDto copyWithWrapped({
    Wrapped<String>? accessToken,
    Wrapped<String>? identityToken,
  }) {
    return GoogleLoginDto(
      accessToken: (accessToken != null ? accessToken.value : this.accessToken),
      identityToken: (identityToken != null
          ? identityToken.value
          : this.identityToken),
    );
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
                  other.campagneJoinRequestId,
                  campagneJoinRequestId,
                )) &&
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
  HandleJoinRequestDto copyWith({
    String? campagneJoinRequestId,
    enums.HandleJoinRequestType? type,
  }) {
    return HandleJoinRequestDto(
      campagneJoinRequestId:
          campagneJoinRequestId ?? this.campagneJoinRequestId,
      type: type ?? this.type,
    );
  }

  HandleJoinRequestDto copyWithWrapped({
    Wrapped<String>? campagneJoinRequestId,
    Wrapped<enums.HandleJoinRequestType>? type,
  }) {
    return HandleJoinRequestDto(
      campagneJoinRequestId: (campagneJoinRequestId != null
          ? campagneJoinRequestId.value
          : this.campagneJoinRequestId),
      type: (type != null ? type.value : this.type),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class HttpValidationProblemDetails {
  const HttpValidationProblemDetails({
    this.errors,
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
  });

  factory HttpValidationProblemDetails.fromJson(Map<String, dynamic> json) =>
      _$HttpValidationProblemDetailsFromJson(json);

  static const toJsonFactory = _$HttpValidationProblemDetailsToJson;
  Map<String, dynamic> toJson() => _$HttpValidationProblemDetailsToJson(this);

  @JsonKey(name: 'errors')
  final Map<String, dynamic>? errors;
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
  static const fromJsonFactory = _$HttpValidationProblemDetailsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HttpValidationProblemDetails &&
            (identical(other.errors, errors) ||
                const DeepCollectionEquality().equals(other.errors, errors)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.detail, detail) ||
                const DeepCollectionEquality().equals(other.detail, detail)) &&
            (identical(other.instance, instance) ||
                const DeepCollectionEquality().equals(
                  other.instance,
                  instance,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(errors) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(detail) ^
      const DeepCollectionEquality().hash(instance) ^
      runtimeType.hashCode;
}

extension $HttpValidationProblemDetailsExtension
    on HttpValidationProblemDetails {
  HttpValidationProblemDetails copyWith({
    Map<String, dynamic>? errors,
    String? type,
    String? title,
    int? status,
    String? detail,
    String? instance,
  }) {
    return HttpValidationProblemDetails(
      errors: errors ?? this.errors,
      type: type ?? this.type,
      title: title ?? this.title,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      instance: instance ?? this.instance,
    );
  }

  HttpValidationProblemDetails copyWithWrapped({
    Wrapped<Map<String, dynamic>?>? errors,
    Wrapped<String?>? type,
    Wrapped<String?>? title,
    Wrapped<int?>? status,
    Wrapped<String?>? detail,
    Wrapped<String?>? instance,
  }) {
    return HttpValidationProblemDetails(
      errors: (errors != null ? errors.value : this.errors),
      type: (type != null ? type.value : this.type),
      title: (title != null ? title.value : this.title),
      status: (status != null ? status.value : this.status),
      detail: (detail != null ? detail.value : this.detail),
      instance: (instance != null ? instance.value : this.instance),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ImageBlock {
  const ImageBlock({
    required this.imageMetaDataId,
    required this.publicImageUrl,
    this.markdownText,
    this.id,
    this.creationDate,
    this.lastModifiedAt,
    this.isDeleted,
    this.noteDocumentId,
    this.creatingUserId,
    this.permittedUsers,
  });

  factory ImageBlock.fromJson(Map<String, dynamic> json) =>
      _$ImageBlockFromJson(json);

  static const toJsonFactory = _$ImageBlockToJson;
  Map<String, dynamic> toJson() => _$ImageBlockToJson(this);

  @JsonKey(name: 'imageMetaDataId')
  final ImageMetaDataIdentifier imageMetaDataId;
  @JsonKey(name: 'publicImageUrl')
  final String publicImageUrl;
  @JsonKey(name: 'markdownText')
  final String? markdownText;
  @JsonKey(name: 'id')
  final NoteBlockModelBaseIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  @JsonKey(name: 'isDeleted')
  final bool? isDeleted;
  @JsonKey(name: 'noteDocumentId')
  final NoteDocumentIdentifier? noteDocumentId;
  @JsonKey(name: 'creatingUserId')
  final UserIdentifier? creatingUserId;
  @JsonKey(name: 'permittedUsers', defaultValue: <UserIdentifier>[])
  final List<UserIdentifier>? permittedUsers;
  static const fromJsonFactory = _$ImageBlockFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ImageBlock &&
            (identical(other.imageMetaDataId, imageMetaDataId) ||
                const DeepCollectionEquality().equals(
                  other.imageMetaDataId,
                  imageMetaDataId,
                )) &&
            (identical(other.publicImageUrl, publicImageUrl) ||
                const DeepCollectionEquality().equals(
                  other.publicImageUrl,
                  publicImageUrl,
                )) &&
            (identical(other.markdownText, markdownText) ||
                const DeepCollectionEquality().equals(
                  other.markdownText,
                  markdownText,
                )) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )) &&
            (identical(other.isDeleted, isDeleted) ||
                const DeepCollectionEquality().equals(
                  other.isDeleted,
                  isDeleted,
                )) &&
            (identical(other.noteDocumentId, noteDocumentId) ||
                const DeepCollectionEquality().equals(
                  other.noteDocumentId,
                  noteDocumentId,
                )) &&
            (identical(other.creatingUserId, creatingUserId) ||
                const DeepCollectionEquality().equals(
                  other.creatingUserId,
                  creatingUserId,
                )) &&
            (identical(other.permittedUsers, permittedUsers) ||
                const DeepCollectionEquality().equals(
                  other.permittedUsers,
                  permittedUsers,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(imageMetaDataId) ^
      const DeepCollectionEquality().hash(publicImageUrl) ^
      const DeepCollectionEquality().hash(markdownText) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      const DeepCollectionEquality().hash(isDeleted) ^
      const DeepCollectionEquality().hash(noteDocumentId) ^
      const DeepCollectionEquality().hash(creatingUserId) ^
      const DeepCollectionEquality().hash(permittedUsers) ^
      runtimeType.hashCode;
}

extension $ImageBlockExtension on ImageBlock {
  ImageBlock copyWith({
    ImageMetaDataIdentifier? imageMetaDataId,
    String? publicImageUrl,
    String? markdownText,
    NoteBlockModelBaseIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
    bool? isDeleted,
    NoteDocumentIdentifier? noteDocumentId,
    UserIdentifier? creatingUserId,
    List<UserIdentifier>? permittedUsers,
  }) {
    return ImageBlock(
      imageMetaDataId: imageMetaDataId ?? this.imageMetaDataId,
      publicImageUrl: publicImageUrl ?? this.publicImageUrl,
      markdownText: markdownText ?? this.markdownText,
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      noteDocumentId: noteDocumentId ?? this.noteDocumentId,
      creatingUserId: creatingUserId ?? this.creatingUserId,
      permittedUsers: permittedUsers ?? this.permittedUsers,
    );
  }

  ImageBlock copyWithWrapped({
    Wrapped<ImageMetaDataIdentifier>? imageMetaDataId,
    Wrapped<String>? publicImageUrl,
    Wrapped<String?>? markdownText,
    Wrapped<NoteBlockModelBaseIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
    Wrapped<bool?>? isDeleted,
    Wrapped<NoteDocumentIdentifier?>? noteDocumentId,
    Wrapped<UserIdentifier?>? creatingUserId,
    Wrapped<List<UserIdentifier>?>? permittedUsers,
  }) {
    return ImageBlock(
      imageMetaDataId: (imageMetaDataId != null
          ? imageMetaDataId.value
          : this.imageMetaDataId),
      publicImageUrl: (publicImageUrl != null
          ? publicImageUrl.value
          : this.publicImageUrl),
      markdownText: (markdownText != null
          ? markdownText.value
          : this.markdownText),
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
      isDeleted: (isDeleted != null ? isDeleted.value : this.isDeleted),
      noteDocumentId: (noteDocumentId != null
          ? noteDocumentId.value
          : this.noteDocumentId),
      creatingUserId: (creatingUserId != null
          ? creatingUserId.value
          : this.creatingUserId),
      permittedUsers: (permittedUsers != null
          ? permittedUsers.value
          : this.permittedUsers),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ImageMetaData {
  const ImageMetaData({
    this.createdForCampagneId,
    this.locallyStored,
    this.apiKey,
    this.creatorId,
    this.imageType,
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory ImageMetaData.fromJson(Map<String, dynamic> json) =>
      _$ImageMetaDataFromJson(json);

  static const toJsonFactory = _$ImageMetaDataToJson;
  Map<String, dynamic> toJson() => _$ImageMetaDataToJson(this);

  @JsonKey(name: 'createdForCampagneId')
  final CampagneIdentifier? createdForCampagneId;
  @JsonKey(name: 'locallyStored')
  final bool? locallyStored;
  @JsonKey(name: 'apiKey')
  final String? apiKey;
  @JsonKey(name: 'creatorId')
  final UserIdentifier? creatorId;
  @JsonKey(
    name: 'imageType',
    toJson: imageTypeNullableToJson,
    fromJson: imageTypeNullableFromJson,
  )
  final enums.ImageType? imageType;
  @JsonKey(name: 'id')
  final ImageMetaDataIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory = _$ImageMetaDataFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ImageMetaData &&
            (identical(other.createdForCampagneId, createdForCampagneId) ||
                const DeepCollectionEquality().equals(
                  other.createdForCampagneId,
                  createdForCampagneId,
                )) &&
            (identical(other.locallyStored, locallyStored) ||
                const DeepCollectionEquality().equals(
                  other.locallyStored,
                  locallyStored,
                )) &&
            (identical(other.apiKey, apiKey) ||
                const DeepCollectionEquality().equals(other.apiKey, apiKey)) &&
            (identical(other.creatorId, creatorId) ||
                const DeepCollectionEquality().equals(
                  other.creatorId,
                  creatorId,
                )) &&
            (identical(other.imageType, imageType) ||
                const DeepCollectionEquality().equals(
                  other.imageType,
                  imageType,
                )) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(createdForCampagneId) ^
      const DeepCollectionEquality().hash(locallyStored) ^
      const DeepCollectionEquality().hash(apiKey) ^
      const DeepCollectionEquality().hash(creatorId) ^
      const DeepCollectionEquality().hash(imageType) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $ImageMetaDataExtension on ImageMetaData {
  ImageMetaData copyWith({
    CampagneIdentifier? createdForCampagneId,
    bool? locallyStored,
    String? apiKey,
    UserIdentifier? creatorId,
    enums.ImageType? imageType,
    ImageMetaDataIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return ImageMetaData(
      createdForCampagneId: createdForCampagneId ?? this.createdForCampagneId,
      locallyStored: locallyStored ?? this.locallyStored,
      apiKey: apiKey ?? this.apiKey,
      creatorId: creatorId ?? this.creatorId,
      imageType: imageType ?? this.imageType,
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  ImageMetaData copyWithWrapped({
    Wrapped<CampagneIdentifier?>? createdForCampagneId,
    Wrapped<bool?>? locallyStored,
    Wrapped<String?>? apiKey,
    Wrapped<UserIdentifier?>? creatorId,
    Wrapped<enums.ImageType?>? imageType,
    Wrapped<ImageMetaDataIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return ImageMetaData(
      createdForCampagneId: (createdForCampagneId != null
          ? createdForCampagneId.value
          : this.createdForCampagneId),
      locallyStored: (locallyStored != null
          ? locallyStored.value
          : this.locallyStored),
      apiKey: (apiKey != null ? apiKey.value : this.apiKey),
      creatorId: (creatorId != null ? creatorId.value : this.creatorId),
      imageType: (imageType != null ? imageType.value : this.imageType),
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ImageMetaDataIdentifier {
  const ImageMetaDataIdentifier({this.$value});

  factory ImageMetaDataIdentifier.fromJson(Map<String, dynamic> json) =>
      _$ImageMetaDataIdentifierFromJson(json);

  static const toJsonFactory = _$ImageMetaDataIdentifierToJson;
  Map<String, dynamic> toJson() => _$ImageMetaDataIdentifierToJson(this);

  @JsonKey(name: 'value')
  final String? $value;
  static const fromJsonFactory = _$ImageMetaDataIdentifierFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ImageMetaDataIdentifier &&
            (identical(other.$value, $value) ||
                const DeepCollectionEquality().equals(other.$value, $value)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($value) ^ runtimeType.hashCode;
}

extension $ImageMetaDataIdentifierExtension on ImageMetaDataIdentifier {
  ImageMetaDataIdentifier copyWith({String? $value}) {
    return ImageMetaDataIdentifier($value: $value ?? this.$value);
  }

  ImageMetaDataIdentifier copyWithWrapped({Wrapped<String?>? $value}) {
    return ImageMetaDataIdentifier(
      $value: ($value != null ? $value.value : this.$value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ImageMetaDataIdentifierGuidNodeModelBase {
  const ImageMetaDataIdentifierGuidNodeModelBase({
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory ImageMetaDataIdentifierGuidNodeModelBase.fromJson(
    Map<String, dynamic> json,
  ) => _$ImageMetaDataIdentifierGuidNodeModelBaseFromJson(json);

  static const toJsonFactory = _$ImageMetaDataIdentifierGuidNodeModelBaseToJson;
  Map<String, dynamic> toJson() =>
      _$ImageMetaDataIdentifierGuidNodeModelBaseToJson(this);

  @JsonKey(name: 'id')
  final ImageMetaDataIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory =
      _$ImageMetaDataIdentifierGuidNodeModelBaseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ImageMetaDataIdentifierGuidNodeModelBase &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $ImageMetaDataIdentifierGuidNodeModelBaseExtension
    on ImageMetaDataIdentifierGuidNodeModelBase {
  ImageMetaDataIdentifierGuidNodeModelBase copyWith({
    ImageMetaDataIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return ImageMetaDataIdentifierGuidNodeModelBase(
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  ImageMetaDataIdentifierGuidNodeModelBase copyWithWrapped({
    Wrapped<ImageMetaDataIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return ImageMetaDataIdentifierGuidNodeModelBase(
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
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
                const DeepCollectionEquality().equals(
                  other.request,
                  request,
                )) &&
            (identical(other.playerCharacter, playerCharacter) ||
                const DeepCollectionEquality().equals(
                  other.playerCharacter,
                  playerCharacter,
                )) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )));
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
  JoinRequestForCampagneDto copyWith({
    CampagneJoinRequest? request,
    PlayerCharacter? playerCharacter,
    String? username,
  }) {
    return JoinRequestForCampagneDto(
      request: request ?? this.request,
      playerCharacter: playerCharacter ?? this.playerCharacter,
      username: username ?? this.username,
    );
  }

  JoinRequestForCampagneDto copyWithWrapped({
    Wrapped<CampagneJoinRequest>? request,
    Wrapped<PlayerCharacter>? playerCharacter,
    Wrapped<String>? username,
  }) {
    return JoinRequestForCampagneDto(
      request: (request != null ? request.value : this.request),
      playerCharacter: (playerCharacter != null
          ? playerCharacter.value
          : this.playerCharacter),
      username: (username != null ? username.value : this.username),
    );
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
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )) &&
            (identical(
                  other.userSecretByEncryptionChallenge,
                  userSecretByEncryptionChallenge,
                ) ||
                const DeepCollectionEquality().equals(
                  other.userSecretByEncryptionChallenge,
                  userSecretByEncryptionChallenge,
                )));
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
  LoginWithUsernameAndPasswordDto copyWith({
    String? username,
    String? userSecretByEncryptionChallenge,
  }) {
    return LoginWithUsernameAndPasswordDto(
      username: username ?? this.username,
      userSecretByEncryptionChallenge:
          userSecretByEncryptionChallenge ??
          this.userSecretByEncryptionChallenge,
    );
  }

  LoginWithUsernameAndPasswordDto copyWithWrapped({
    Wrapped<String>? username,
    Wrapped<String>? userSecretByEncryptionChallenge,
  }) {
    return LoginWithUsernameAndPasswordDto(
      username: (username != null ? username.value : this.username),
      userSecretByEncryptionChallenge: (userSecretByEncryptionChallenge != null
          ? userSecretByEncryptionChallenge.value
          : this.userSecretByEncryptionChallenge),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NoteBlockModelBase {
  const NoteBlockModelBase({
    this.isDeleted,
    this.noteDocumentId,
    this.creatingUserId,
    this.permittedUsers,
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory NoteBlockModelBase.fromJson(Map<String, dynamic> json) =>
      _$NoteBlockModelBaseFromJson(json);

  static const toJsonFactory = _$NoteBlockModelBaseToJson;
  Map<String, dynamic> toJson() => _$NoteBlockModelBaseToJson(this);

  @JsonKey(name: 'isDeleted')
  final bool? isDeleted;
  @JsonKey(name: 'noteDocumentId')
  final NoteDocumentIdentifier? noteDocumentId;
  @JsonKey(name: 'creatingUserId')
  final UserIdentifier? creatingUserId;
  @JsonKey(name: 'permittedUsers', defaultValue: <UserIdentifier>[])
  final List<UserIdentifier>? permittedUsers;
  @JsonKey(name: 'id')
  final NoteBlockModelBaseIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory = _$NoteBlockModelBaseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NoteBlockModelBase &&
            (identical(other.isDeleted, isDeleted) ||
                const DeepCollectionEquality().equals(
                  other.isDeleted,
                  isDeleted,
                )) &&
            (identical(other.noteDocumentId, noteDocumentId) ||
                const DeepCollectionEquality().equals(
                  other.noteDocumentId,
                  noteDocumentId,
                )) &&
            (identical(other.creatingUserId, creatingUserId) ||
                const DeepCollectionEquality().equals(
                  other.creatingUserId,
                  creatingUserId,
                )) &&
            (identical(other.permittedUsers, permittedUsers) ||
                const DeepCollectionEquality().equals(
                  other.permittedUsers,
                  permittedUsers,
                )) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(isDeleted) ^
      const DeepCollectionEquality().hash(noteDocumentId) ^
      const DeepCollectionEquality().hash(creatingUserId) ^
      const DeepCollectionEquality().hash(permittedUsers) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $NoteBlockModelBaseExtension on NoteBlockModelBase {
  NoteBlockModelBase copyWith({
    bool? isDeleted,
    NoteDocumentIdentifier? noteDocumentId,
    UserIdentifier? creatingUserId,
    List<UserIdentifier>? permittedUsers,
    NoteBlockModelBaseIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return NoteBlockModelBase(
      isDeleted: isDeleted ?? this.isDeleted,
      noteDocumentId: noteDocumentId ?? this.noteDocumentId,
      creatingUserId: creatingUserId ?? this.creatingUserId,
      permittedUsers: permittedUsers ?? this.permittedUsers,
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  NoteBlockModelBase copyWithWrapped({
    Wrapped<bool?>? isDeleted,
    Wrapped<NoteDocumentIdentifier?>? noteDocumentId,
    Wrapped<UserIdentifier?>? creatingUserId,
    Wrapped<List<UserIdentifier>?>? permittedUsers,
    Wrapped<NoteBlockModelBaseIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return NoteBlockModelBase(
      isDeleted: (isDeleted != null ? isDeleted.value : this.isDeleted),
      noteDocumentId: (noteDocumentId != null
          ? noteDocumentId.value
          : this.noteDocumentId),
      creatingUserId: (creatingUserId != null
          ? creatingUserId.value
          : this.creatingUserId),
      permittedUsers: (permittedUsers != null
          ? permittedUsers.value
          : this.permittedUsers),
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NoteBlockModelBaseIdentifier {
  const NoteBlockModelBaseIdentifier({this.$value});

  factory NoteBlockModelBaseIdentifier.fromJson(Map<String, dynamic> json) =>
      _$NoteBlockModelBaseIdentifierFromJson(json);

  static const toJsonFactory = _$NoteBlockModelBaseIdentifierToJson;
  Map<String, dynamic> toJson() => _$NoteBlockModelBaseIdentifierToJson(this);

  @JsonKey(name: 'value')
  final String? $value;
  static const fromJsonFactory = _$NoteBlockModelBaseIdentifierFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NoteBlockModelBaseIdentifier &&
            (identical(other.$value, $value) ||
                const DeepCollectionEquality().equals(other.$value, $value)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($value) ^ runtimeType.hashCode;
}

extension $NoteBlockModelBaseIdentifierExtension
    on NoteBlockModelBaseIdentifier {
  NoteBlockModelBaseIdentifier copyWith({String? $value}) {
    return NoteBlockModelBaseIdentifier($value: $value ?? this.$value);
  }

  NoteBlockModelBaseIdentifier copyWithWrapped({Wrapped<String?>? $value}) {
    return NoteBlockModelBaseIdentifier(
      $value: ($value != null ? $value.value : this.$value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NoteBlockModelBaseIdentifierGuidNodeModelBase {
  const NoteBlockModelBaseIdentifierGuidNodeModelBase({
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory NoteBlockModelBaseIdentifierGuidNodeModelBase.fromJson(
    Map<String, dynamic> json,
  ) => _$NoteBlockModelBaseIdentifierGuidNodeModelBaseFromJson(json);

  static const toJsonFactory =
      _$NoteBlockModelBaseIdentifierGuidNodeModelBaseToJson;
  Map<String, dynamic> toJson() =>
      _$NoteBlockModelBaseIdentifierGuidNodeModelBaseToJson(this);

  @JsonKey(name: 'id')
  final NoteBlockModelBaseIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory =
      _$NoteBlockModelBaseIdentifierGuidNodeModelBaseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NoteBlockModelBaseIdentifierGuidNodeModelBase &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $NoteBlockModelBaseIdentifierGuidNodeModelBaseExtension
    on NoteBlockModelBaseIdentifierGuidNodeModelBase {
  NoteBlockModelBaseIdentifierGuidNodeModelBase copyWith({
    NoteBlockModelBaseIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return NoteBlockModelBaseIdentifierGuidNodeModelBase(
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  NoteBlockModelBaseIdentifierGuidNodeModelBase copyWithWrapped({
    Wrapped<NoteBlockModelBaseIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return NoteBlockModelBaseIdentifierGuidNodeModelBase(
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NoteDocumentDto {
  const NoteDocumentDto({
    this.isDeleted,
    this.creationDate,
    this.lastModifiedAt,
    this.id,
    required this.groupName,
    this.creatingUserId,
    required this.title,
    required this.createdForCampagneId,
    required this.imageBlocks,
    required this.textBlocks,
  });

  factory NoteDocumentDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDocumentDtoFromJson(json);

  static const toJsonFactory = _$NoteDocumentDtoToJson;
  Map<String, dynamic> toJson() => _$NoteDocumentDtoToJson(this);

  @JsonKey(name: 'isDeleted')
  final bool? isDeleted;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  @JsonKey(name: 'id')
  final NoteDocumentIdentifier? id;
  @JsonKey(name: 'groupName')
  final String groupName;
  @JsonKey(name: 'creatingUserId')
  final UserIdentifier? creatingUserId;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'createdForCampagneId')
  final CampagneIdentifier createdForCampagneId;
  @JsonKey(name: 'imageBlocks', defaultValue: <ImageBlock>[])
  final List<ImageBlock> imageBlocks;
  @JsonKey(name: 'textBlocks', defaultValue: <TextBlock>[])
  final List<TextBlock> textBlocks;
  static const fromJsonFactory = _$NoteDocumentDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NoteDocumentDto &&
            (identical(other.isDeleted, isDeleted) ||
                const DeepCollectionEquality().equals(
                  other.isDeleted,
                  isDeleted,
                )) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.groupName, groupName) ||
                const DeepCollectionEquality().equals(
                  other.groupName,
                  groupName,
                )) &&
            (identical(other.creatingUserId, creatingUserId) ||
                const DeepCollectionEquality().equals(
                  other.creatingUserId,
                  creatingUserId,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.createdForCampagneId, createdForCampagneId) ||
                const DeepCollectionEquality().equals(
                  other.createdForCampagneId,
                  createdForCampagneId,
                )) &&
            (identical(other.imageBlocks, imageBlocks) ||
                const DeepCollectionEquality().equals(
                  other.imageBlocks,
                  imageBlocks,
                )) &&
            (identical(other.textBlocks, textBlocks) ||
                const DeepCollectionEquality().equals(
                  other.textBlocks,
                  textBlocks,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(isDeleted) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(groupName) ^
      const DeepCollectionEquality().hash(creatingUserId) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(createdForCampagneId) ^
      const DeepCollectionEquality().hash(imageBlocks) ^
      const DeepCollectionEquality().hash(textBlocks) ^
      runtimeType.hashCode;
}

extension $NoteDocumentDtoExtension on NoteDocumentDto {
  NoteDocumentDto copyWith({
    bool? isDeleted,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
    NoteDocumentIdentifier? id,
    String? groupName,
    UserIdentifier? creatingUserId,
    String? title,
    CampagneIdentifier? createdForCampagneId,
    List<ImageBlock>? imageBlocks,
    List<TextBlock>? textBlocks,
  }) {
    return NoteDocumentDto(
      isDeleted: isDeleted ?? this.isDeleted,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      creatingUserId: creatingUserId ?? this.creatingUserId,
      title: title ?? this.title,
      createdForCampagneId: createdForCampagneId ?? this.createdForCampagneId,
      imageBlocks: imageBlocks ?? this.imageBlocks,
      textBlocks: textBlocks ?? this.textBlocks,
    );
  }

  NoteDocumentDto copyWithWrapped({
    Wrapped<bool?>? isDeleted,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
    Wrapped<NoteDocumentIdentifier?>? id,
    Wrapped<String>? groupName,
    Wrapped<UserIdentifier?>? creatingUserId,
    Wrapped<String>? title,
    Wrapped<CampagneIdentifier>? createdForCampagneId,
    Wrapped<List<ImageBlock>>? imageBlocks,
    Wrapped<List<TextBlock>>? textBlocks,
  }) {
    return NoteDocumentDto(
      isDeleted: (isDeleted != null ? isDeleted.value : this.isDeleted),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
      id: (id != null ? id.value : this.id),
      groupName: (groupName != null ? groupName.value : this.groupName),
      creatingUserId: (creatingUserId != null
          ? creatingUserId.value
          : this.creatingUserId),
      title: (title != null ? title.value : this.title),
      createdForCampagneId: (createdForCampagneId != null
          ? createdForCampagneId.value
          : this.createdForCampagneId),
      imageBlocks: (imageBlocks != null ? imageBlocks.value : this.imageBlocks),
      textBlocks: (textBlocks != null ? textBlocks.value : this.textBlocks),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NoteDocumentIdentifier {
  const NoteDocumentIdentifier({this.$value});

  factory NoteDocumentIdentifier.fromJson(Map<String, dynamic> json) =>
      _$NoteDocumentIdentifierFromJson(json);

  static const toJsonFactory = _$NoteDocumentIdentifierToJson;
  Map<String, dynamic> toJson() => _$NoteDocumentIdentifierToJson(this);

  @JsonKey(name: 'value')
  final String? $value;
  static const fromJsonFactory = _$NoteDocumentIdentifierFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NoteDocumentIdentifier &&
            (identical(other.$value, $value) ||
                const DeepCollectionEquality().equals(other.$value, $value)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($value) ^ runtimeType.hashCode;
}

extension $NoteDocumentIdentifierExtension on NoteDocumentIdentifier {
  NoteDocumentIdentifier copyWith({String? $value}) {
    return NoteDocumentIdentifier($value: $value ?? this.$value);
  }

  NoteDocumentIdentifier copyWithWrapped({Wrapped<String?>? $value}) {
    return NoteDocumentIdentifier(
      $value: ($value != null ? $value.value : this.$value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NoteDocumentPlayerDescriptorDto {
  const NoteDocumentPlayerDescriptorDto({
    required this.userId,
    this.playerCharacterName,
    required this.isDm,
    required this.isYou,
  });

  factory NoteDocumentPlayerDescriptorDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDocumentPlayerDescriptorDtoFromJson(json);

  static const toJsonFactory = _$NoteDocumentPlayerDescriptorDtoToJson;
  Map<String, dynamic> toJson() =>
      _$NoteDocumentPlayerDescriptorDtoToJson(this);

  @JsonKey(name: 'userId')
  final UserIdentifier userId;
  @JsonKey(name: 'playerCharacterName')
  final String? playerCharacterName;
  @JsonKey(name: 'isDm')
  final bool isDm;
  @JsonKey(name: 'isYou')
  final bool isYou;
  static const fromJsonFactory = _$NoteDocumentPlayerDescriptorDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NoteDocumentPlayerDescriptorDto &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.playerCharacterName, playerCharacterName) ||
                const DeepCollectionEquality().equals(
                  other.playerCharacterName,
                  playerCharacterName,
                )) &&
            (identical(other.isDm, isDm) ||
                const DeepCollectionEquality().equals(other.isDm, isDm)) &&
            (identical(other.isYou, isYou) ||
                const DeepCollectionEquality().equals(other.isYou, isYou)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(playerCharacterName) ^
      const DeepCollectionEquality().hash(isDm) ^
      const DeepCollectionEquality().hash(isYou) ^
      runtimeType.hashCode;
}

extension $NoteDocumentPlayerDescriptorDtoExtension
    on NoteDocumentPlayerDescriptorDto {
  NoteDocumentPlayerDescriptorDto copyWith({
    UserIdentifier? userId,
    String? playerCharacterName,
    bool? isDm,
    bool? isYou,
  }) {
    return NoteDocumentPlayerDescriptorDto(
      userId: userId ?? this.userId,
      playerCharacterName: playerCharacterName ?? this.playerCharacterName,
      isDm: isDm ?? this.isDm,
      isYou: isYou ?? this.isYou,
    );
  }

  NoteDocumentPlayerDescriptorDto copyWithWrapped({
    Wrapped<UserIdentifier>? userId,
    Wrapped<String?>? playerCharacterName,
    Wrapped<bool>? isDm,
    Wrapped<bool>? isYou,
  }) {
    return NoteDocumentPlayerDescriptorDto(
      userId: (userId != null ? userId.value : this.userId),
      playerCharacterName: (playerCharacterName != null
          ? playerCharacterName.value
          : this.playerCharacterName),
      isDm: (isDm != null ? isDm.value : this.isDm),
      isYou: (isYou != null ? isYou.value : this.isYou),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PlayerCharacter {
  const PlayerCharacter({
    this.rpgCharacterConfiguration,
    this.characterName,
    this.playerUserId,
    this.campagneId,
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory PlayerCharacter.fromJson(Map<String, dynamic> json) =>
      _$PlayerCharacterFromJson(json);

  static const toJsonFactory = _$PlayerCharacterToJson;
  Map<String, dynamic> toJson() => _$PlayerCharacterToJson(this);

  @JsonKey(name: 'rpgCharacterConfiguration')
  final String? rpgCharacterConfiguration;
  @JsonKey(name: 'characterName')
  final String? characterName;
  @JsonKey(name: 'playerUserId')
  final UserIdentifier? playerUserId;
  @JsonKey(name: 'campagneId')
  final CampagneIdentifier? campagneId;
  @JsonKey(name: 'id')
  final PlayerCharacterIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory = _$PlayerCharacterFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PlayerCharacter &&
            (identical(
                  other.rpgCharacterConfiguration,
                  rpgCharacterConfiguration,
                ) ||
                const DeepCollectionEquality().equals(
                  other.rpgCharacterConfiguration,
                  rpgCharacterConfiguration,
                )) &&
            (identical(other.characterName, characterName) ||
                const DeepCollectionEquality().equals(
                  other.characterName,
                  characterName,
                )) &&
            (identical(other.playerUserId, playerUserId) ||
                const DeepCollectionEquality().equals(
                  other.playerUserId,
                  playerUserId,
                )) &&
            (identical(other.campagneId, campagneId) ||
                const DeepCollectionEquality().equals(
                  other.campagneId,
                  campagneId,
                )) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(rpgCharacterConfiguration) ^
      const DeepCollectionEquality().hash(characterName) ^
      const DeepCollectionEquality().hash(playerUserId) ^
      const DeepCollectionEquality().hash(campagneId) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $PlayerCharacterExtension on PlayerCharacter {
  PlayerCharacter copyWith({
    String? rpgCharacterConfiguration,
    String? characterName,
    UserIdentifier? playerUserId,
    CampagneIdentifier? campagneId,
    PlayerCharacterIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return PlayerCharacter(
      rpgCharacterConfiguration:
          rpgCharacterConfiguration ?? this.rpgCharacterConfiguration,
      characterName: characterName ?? this.characterName,
      playerUserId: playerUserId ?? this.playerUserId,
      campagneId: campagneId ?? this.campagneId,
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  PlayerCharacter copyWithWrapped({
    Wrapped<String?>? rpgCharacterConfiguration,
    Wrapped<String?>? characterName,
    Wrapped<UserIdentifier?>? playerUserId,
    Wrapped<CampagneIdentifier?>? campagneId,
    Wrapped<PlayerCharacterIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return PlayerCharacter(
      rpgCharacterConfiguration: (rpgCharacterConfiguration != null
          ? rpgCharacterConfiguration.value
          : this.rpgCharacterConfiguration),
      characterName: (characterName != null
          ? characterName.value
          : this.characterName),
      playerUserId: (playerUserId != null
          ? playerUserId.value
          : this.playerUserId),
      campagneId: (campagneId != null ? campagneId.value : this.campagneId),
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
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
            (identical(
                  other.rpgCharacterConfiguration,
                  rpgCharacterConfiguration,
                ) ||
                const DeepCollectionEquality().equals(
                  other.rpgCharacterConfiguration,
                  rpgCharacterConfiguration,
                )) &&
            (identical(other.characterName, characterName) ||
                const DeepCollectionEquality().equals(
                  other.characterName,
                  characterName,
                )) &&
            (identical(other.campagneId, campagneId) ||
                const DeepCollectionEquality().equals(
                  other.campagneId,
                  campagneId,
                )));
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
  PlayerCharacterCreateDto copyWith({
    String? rpgCharacterConfiguration,
    String? characterName,
    String? campagneId,
  }) {
    return PlayerCharacterCreateDto(
      rpgCharacterConfiguration:
          rpgCharacterConfiguration ?? this.rpgCharacterConfiguration,
      characterName: characterName ?? this.characterName,
      campagneId: campagneId ?? this.campagneId,
    );
  }

  PlayerCharacterCreateDto copyWithWrapped({
    Wrapped<String?>? rpgCharacterConfiguration,
    Wrapped<String>? characterName,
    Wrapped<String?>? campagneId,
  }) {
    return PlayerCharacterCreateDto(
      rpgCharacterConfiguration: (rpgCharacterConfiguration != null
          ? rpgCharacterConfiguration.value
          : this.rpgCharacterConfiguration),
      characterName: (characterName != null
          ? characterName.value
          : this.characterName),
      campagneId: (campagneId != null ? campagneId.value : this.campagneId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PlayerCharacterIdentifier {
  const PlayerCharacterIdentifier({this.$value});

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
      $value: ($value != null ? $value.value : this.$value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PlayerCharacterIdentifierGuidNodeModelBase {
  const PlayerCharacterIdentifierGuidNodeModelBase({
    this.id,
    this.creationDate,
    this.lastModifiedAt,
  });

  factory PlayerCharacterIdentifierGuidNodeModelBase.fromJson(
    Map<String, dynamic> json,
  ) => _$PlayerCharacterIdentifierGuidNodeModelBaseFromJson(json);

  static const toJsonFactory =
      _$PlayerCharacterIdentifierGuidNodeModelBaseToJson;
  Map<String, dynamic> toJson() =>
      _$PlayerCharacterIdentifierGuidNodeModelBaseToJson(this);

  @JsonKey(name: 'id')
  final PlayerCharacterIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  static const fromJsonFactory =
      _$PlayerCharacterIdentifierGuidNodeModelBaseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PlayerCharacterIdentifierGuidNodeModelBase &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      runtimeType.hashCode;
}

extension $PlayerCharacterIdentifierGuidNodeModelBaseExtension
    on PlayerCharacterIdentifierGuidNodeModelBase {
  PlayerCharacterIdentifierGuidNodeModelBase copyWith({
    PlayerCharacterIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
  }) {
    return PlayerCharacterIdentifierGuidNodeModelBase(
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  PlayerCharacterIdentifierGuidNodeModelBase copyWithWrapped({
    Wrapped<PlayerCharacterIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
  }) {
    return PlayerCharacterIdentifierGuidNodeModelBase(
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
    );
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
                const DeepCollectionEquality().equals(
                  other.instance,
                  instance,
                )));
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
  ProblemDetails copyWith({
    String? type,
    String? title,
    int? status,
    String? detail,
    String? instance,
  }) {
    return ProblemDetails(
      type: type ?? this.type,
      title: title ?? this.title,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      instance: instance ?? this.instance,
    );
  }

  ProblemDetails copyWithWrapped({
    Wrapped<String?>? type,
    Wrapped<String?>? title,
    Wrapped<int?>? status,
    Wrapped<String?>? detail,
    Wrapped<String?>? instance,
  }) {
    return ProblemDetails(
      type: (type != null ? type.value : this.type),
      title: (title != null ? title.value : this.title),
      status: (status != null ? status.value : this.status),
      detail: (detail != null ? detail.value : this.detail),
      instance: (instance != null ? instance.value : this.instance),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class RegisterWithApiKeyDto {
  const RegisterWithApiKeyDto({required this.apiKey, required this.username});

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
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )));
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
      apiKey: apiKey ?? this.apiKey,
      username: username ?? this.username,
    );
  }

  RegisterWithApiKeyDto copyWithWrapped({
    Wrapped<String>? apiKey,
    Wrapped<String>? username,
  }) {
    return RegisterWithApiKeyDto(
      apiKey: (apiKey != null ? apiKey.value : this.apiKey),
      username: (username != null ? username.value : this.username),
    );
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
            (identical(
                  other.encryptionChallengeIdentifier,
                  encryptionChallengeIdentifier,
                ) ||
                const DeepCollectionEquality().equals(
                  other.encryptionChallengeIdentifier,
                  encryptionChallengeIdentifier,
                )) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )) &&
            (identical(other.userSecret, userSecret) ||
                const DeepCollectionEquality().equals(
                  other.userSecret,
                  userSecret,
                )));
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
  RegisterWithUsernamePasswordDto copyWith({
    String? email,
    EncryptionChallengeIdentifier? encryptionChallengeIdentifier,
    String? username,
    String? userSecret,
  }) {
    return RegisterWithUsernamePasswordDto(
      email: email ?? this.email,
      encryptionChallengeIdentifier:
          encryptionChallengeIdentifier ?? this.encryptionChallengeIdentifier,
      username: username ?? this.username,
      userSecret: userSecret ?? this.userSecret,
    );
  }

  RegisterWithUsernamePasswordDto copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<EncryptionChallengeIdentifier>? encryptionChallengeIdentifier,
    Wrapped<String>? username,
    Wrapped<String>? userSecret,
  }) {
    return RegisterWithUsernamePasswordDto(
      email: (email != null ? email.value : this.email),
      encryptionChallengeIdentifier: (encryptionChallengeIdentifier != null
          ? encryptionChallengeIdentifier.value
          : this.encryptionChallengeIdentifier),
      username: (username != null ? username.value : this.username),
      userSecret: (userSecret != null ? userSecret.value : this.userSecret),
    );
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
                const DeepCollectionEquality().equals(
                  other.newHashedPassword,
                  newHashedPassword,
                )) &&
            (identical(other.resetCode, resetCode) ||
                const DeepCollectionEquality().equals(
                  other.resetCode,
                  resetCode,
                )) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )));
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
  ResetPasswordDto copyWith({
    String? email,
    String? newHashedPassword,
    String? resetCode,
    String? username,
  }) {
    return ResetPasswordDto(
      email: email ?? this.email,
      newHashedPassword: newHashedPassword ?? this.newHashedPassword,
      resetCode: resetCode ?? this.resetCode,
      username: username ?? this.username,
    );
  }

  ResetPasswordDto copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? newHashedPassword,
    Wrapped<String>? resetCode,
    Wrapped<String>? username,
  }) {
    return ResetPasswordDto(
      email: (email != null ? email.value : this.email),
      newHashedPassword: (newHashedPassword != null
          ? newHashedPassword.value
          : this.newHashedPassword),
      resetCode: (resetCode != null ? resetCode.value : this.resetCode),
      username: (username != null ? username.value : this.username),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ResetPasswordRequestDto {
  const ResetPasswordRequestDto({required this.email, required this.username});

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
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )));
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
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }

  ResetPasswordRequestDto copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? username,
  }) {
    return ResetPasswordRequestDto(
      email: (email != null ? email.value : this.email),
      username: (username != null ? username.value : this.username),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class TextBlock {
  const TextBlock({
    this.markdownText,
    this.id,
    this.creationDate,
    this.lastModifiedAt,
    this.isDeleted,
    this.noteDocumentId,
    this.creatingUserId,
    this.permittedUsers,
  });

  factory TextBlock.fromJson(Map<String, dynamic> json) =>
      _$TextBlockFromJson(json);

  static const toJsonFactory = _$TextBlockToJson;
  Map<String, dynamic> toJson() => _$TextBlockToJson(this);

  @JsonKey(name: 'markdownText')
  final String? markdownText;
  @JsonKey(name: 'id')
  final NoteBlockModelBaseIdentifier? id;
  @JsonKey(name: 'creationDate')
  final DateTime? creationDate;
  @JsonKey(name: 'lastModifiedAt')
  final DateTime? lastModifiedAt;
  @JsonKey(name: 'isDeleted')
  final bool? isDeleted;
  @JsonKey(name: 'noteDocumentId')
  final NoteDocumentIdentifier? noteDocumentId;
  @JsonKey(name: 'creatingUserId')
  final UserIdentifier? creatingUserId;
  @JsonKey(name: 'permittedUsers', defaultValue: <UserIdentifier>[])
  final List<UserIdentifier>? permittedUsers;
  static const fromJsonFactory = _$TextBlockFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TextBlock &&
            (identical(other.markdownText, markdownText) ||
                const DeepCollectionEquality().equals(
                  other.markdownText,
                  markdownText,
                )) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.creationDate, creationDate) ||
                const DeepCollectionEquality().equals(
                  other.creationDate,
                  creationDate,
                )) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                const DeepCollectionEquality().equals(
                  other.lastModifiedAt,
                  lastModifiedAt,
                )) &&
            (identical(other.isDeleted, isDeleted) ||
                const DeepCollectionEquality().equals(
                  other.isDeleted,
                  isDeleted,
                )) &&
            (identical(other.noteDocumentId, noteDocumentId) ||
                const DeepCollectionEquality().equals(
                  other.noteDocumentId,
                  noteDocumentId,
                )) &&
            (identical(other.creatingUserId, creatingUserId) ||
                const DeepCollectionEquality().equals(
                  other.creatingUserId,
                  creatingUserId,
                )) &&
            (identical(other.permittedUsers, permittedUsers) ||
                const DeepCollectionEquality().equals(
                  other.permittedUsers,
                  permittedUsers,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(markdownText) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(creationDate) ^
      const DeepCollectionEquality().hash(lastModifiedAt) ^
      const DeepCollectionEquality().hash(isDeleted) ^
      const DeepCollectionEquality().hash(noteDocumentId) ^
      const DeepCollectionEquality().hash(creatingUserId) ^
      const DeepCollectionEquality().hash(permittedUsers) ^
      runtimeType.hashCode;
}

extension $TextBlockExtension on TextBlock {
  TextBlock copyWith({
    String? markdownText,
    NoteBlockModelBaseIdentifier? id,
    DateTime? creationDate,
    DateTime? lastModifiedAt,
    bool? isDeleted,
    NoteDocumentIdentifier? noteDocumentId,
    UserIdentifier? creatingUserId,
    List<UserIdentifier>? permittedUsers,
  }) {
    return TextBlock(
      markdownText: markdownText ?? this.markdownText,
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      noteDocumentId: noteDocumentId ?? this.noteDocumentId,
      creatingUserId: creatingUserId ?? this.creatingUserId,
      permittedUsers: permittedUsers ?? this.permittedUsers,
    );
  }

  TextBlock copyWithWrapped({
    Wrapped<String?>? markdownText,
    Wrapped<NoteBlockModelBaseIdentifier?>? id,
    Wrapped<DateTime?>? creationDate,
    Wrapped<DateTime?>? lastModifiedAt,
    Wrapped<bool?>? isDeleted,
    Wrapped<NoteDocumentIdentifier?>? noteDocumentId,
    Wrapped<UserIdentifier?>? creatingUserId,
    Wrapped<List<UserIdentifier>?>? permittedUsers,
  }) {
    return TextBlock(
      markdownText: (markdownText != null
          ? markdownText.value
          : this.markdownText),
      id: (id != null ? id.value : this.id),
      creationDate: (creationDate != null
          ? creationDate.value
          : this.creationDate),
      lastModifiedAt: (lastModifiedAt != null
          ? lastModifiedAt.value
          : this.lastModifiedAt),
      isDeleted: (isDeleted != null ? isDeleted.value : this.isDeleted),
      noteDocumentId: (noteDocumentId != null
          ? noteDocumentId.value
          : this.noteDocumentId),
      creatingUserId: (creatingUserId != null
          ? creatingUserId.value
          : this.creatingUserId),
      permittedUsers: (permittedUsers != null
          ? permittedUsers.value
          : this.permittedUsers),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UserIdentifier {
  const UserIdentifier({this.$value});

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
      $value: ($value != null ? $value.value : this.$value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ImageStreamimageuploadPost$RequestBody {
  const ImageStreamimageuploadPost$RequestBody({this.image});

  factory ImageStreamimageuploadPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$ImageStreamimageuploadPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ImageStreamimageuploadPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$ImageStreamimageuploadPost$RequestBodyToJson(this);

  @JsonKey(name: 'image')
  final String? image;
  static const fromJsonFactory =
      _$ImageStreamimageuploadPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ImageStreamimageuploadPost$RequestBody &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(image) ^ runtimeType.hashCode;
}

extension $ImageStreamimageuploadPost$RequestBodyExtension
    on ImageStreamimageuploadPost$RequestBody {
  ImageStreamimageuploadPost$RequestBody copyWith({String? image}) {
    return ImageStreamimageuploadPost$RequestBody(image: image ?? this.image);
  }

  ImageStreamimageuploadPost$RequestBody copyWithWrapped({
    Wrapped<String?>? image,
  }) {
    return ImageStreamimageuploadPost$RequestBody(
      image: (image != null ? image.value : this.image),
    );
  }
}

String? handleJoinRequestTypeNullableToJson(
  enums.HandleJoinRequestType? handleJoinRequestType,
) {
  return handleJoinRequestType?.value;
}

String? handleJoinRequestTypeToJson(
  enums.HandleJoinRequestType handleJoinRequestType,
) {
  return handleJoinRequestType.value;
}

enums.HandleJoinRequestType handleJoinRequestTypeFromJson(
  Object? handleJoinRequestType, [
  enums.HandleJoinRequestType? defaultValue,
]) {
  return enums.HandleJoinRequestType.values.firstWhereOrNull(
        (e) =>
            e.value.toString().toLowerCase() ==
            handleJoinRequestType?.toString().toLowerCase(),
      ) ??
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
  return enums.HandleJoinRequestType.values.firstWhereOrNull(
        (e) =>
            e.value.toString().toLowerCase() ==
            handleJoinRequestType.toString().toLowerCase(),
      ) ??
      defaultValue;
}

String handleJoinRequestTypeExplodedListToJson(
  List<enums.HandleJoinRequestType>? handleJoinRequestType,
) {
  return handleJoinRequestType?.map((e) => e.value!).join(',') ?? '';
}

List<String> handleJoinRequestTypeListToJson(
  List<enums.HandleJoinRequestType>? handleJoinRequestType,
) {
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

String? imageTypeNullableToJson(enums.ImageType? imageType) {
  return imageType?.value;
}

String? imageTypeToJson(enums.ImageType imageType) {
  return imageType.value;
}

enums.ImageType imageTypeFromJson(
  Object? imageType, [
  enums.ImageType? defaultValue,
]) {
  return enums.ImageType.values.firstWhereOrNull(
        (e) =>
            e.value.toString().toLowerCase() ==
            imageType?.toString().toLowerCase(),
      ) ??
      defaultValue ??
      enums.ImageType.swaggerGeneratedUnknown;
}

enums.ImageType? imageTypeNullableFromJson(
  Object? imageType, [
  enums.ImageType? defaultValue,
]) {
  if (imageType == null) {
    return null;
  }
  return enums.ImageType.values.firstWhereOrNull(
        (e) =>
            e.value.toString().toLowerCase() ==
            imageType.toString().toLowerCase(),
      ) ??
      defaultValue;
}

String imageTypeExplodedListToJson(List<enums.ImageType>? imageType) {
  return imageType?.map((e) => e.value!).join(',') ?? '';
}

List<String> imageTypeListToJson(List<enums.ImageType>? imageType) {
  if (imageType == null) {
    return [];
  }

  return imageType.map((e) => e.value!).toList();
}

List<enums.ImageType> imageTypeListFromJson(
  List? imageType, [
  List<enums.ImageType>? defaultValue,
]) {
  if (imageType == null) {
    return defaultValue ?? [];
  }

  return imageType.map((e) => imageTypeFromJson(e.toString())).toList();
}

List<enums.ImageType>? imageTypeNullableListFromJson(
  List? imageType, [
  List<enums.ImageType>? defaultValue,
]) {
  if (imageType == null) {
    return defaultValue;
  }

  return imageType.map((e) => imageTypeFromJson(e.toString())).toList();
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
