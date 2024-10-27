// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppleLoginDetails _$AppleLoginDetailsFromJson(Map<String, dynamic> json) =>
    AppleLoginDetails(
      authorizationCode: json['authorizationCode'] as String,
      identityToken: json['identityToken'] as String,
    );

Map<String, dynamic> _$AppleLoginDetailsToJson(AppleLoginDetails instance) =>
    <String, dynamic>{
      'authorizationCode': instance.authorizationCode,
      'identityToken': instance.identityToken,
    };

Campagne _$CampagneFromJson(Map<String, dynamic> json) => Campagne(
      id: json['id'] == null
          ? null
          : CampagneIdentifier.fromJson(json['id'] as Map<String, dynamic>),
      creationDate: json['creationDate'] == null
          ? null
          : DateTime.parse(json['creationDate'] as String),
      lastModifiedAt: json['lastModifiedAt'] == null
          ? null
          : DateTime.parse(json['lastModifiedAt'] as String),
      rpgConfiguration: json['rpgConfiguration'] as String?,
      campagneName: json['campagneName'] as String?,
      joinCode: json['joinCode'] as String?,
      dmUserId: json['dmUserId'] == null
          ? null
          : UserIdentifier.fromJson(json['dmUserId'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CampagneToJson(Campagne instance) => <String, dynamic>{
      'id': instance.id?.toJson(),
      'creationDate': instance.creationDate?.toIso8601String(),
      'lastModifiedAt': instance.lastModifiedAt?.toIso8601String(),
      'rpgConfiguration': instance.rpgConfiguration,
      'campagneName': instance.campagneName,
      'joinCode': instance.joinCode,
      'dmUserId': instance.dmUserId?.toJson(),
    };

CampagneCreateDto _$CampagneCreateDtoFromJson(Map<String, dynamic> json) =>
    CampagneCreateDto(
      rpgConfiguration: json['rpgConfiguration'] as String?,
      campagneName: json['campagneName'] as String,
    );

Map<String, dynamic> _$CampagneCreateDtoToJson(CampagneCreateDto instance) =>
    <String, dynamic>{
      'rpgConfiguration': instance.rpgConfiguration,
      'campagneName': instance.campagneName,
    };

CampagneIdentifier _$CampagneIdentifierFromJson(Map<String, dynamic> json) =>
    CampagneIdentifier(
      $value: json['value'] as String?,
    );

Map<String, dynamic> _$CampagneIdentifierToJson(CampagneIdentifier instance) =>
    <String, dynamic>{
      'value': instance.$value,
    };

CampagneJoinRequest _$CampagneJoinRequestFromJson(Map<String, dynamic> json) =>
    CampagneJoinRequest(
      id: json['id'] == null
          ? null
          : CampagneJoinRequestIdentifier.fromJson(
              json['id'] as Map<String, dynamic>),
      creationDate: json['creationDate'] == null
          ? null
          : DateTime.parse(json['creationDate'] as String),
      lastModifiedAt: json['lastModifiedAt'] == null
          ? null
          : DateTime.parse(json['lastModifiedAt'] as String),
      userId: json['userId'] == null
          ? null
          : UserIdentifier.fromJson(json['userId'] as Map<String, dynamic>),
      playerId: json['playerId'] == null
          ? null
          : PlayerCharacterIdentifier.fromJson(
              json['playerId'] as Map<String, dynamic>),
      campagneId: json['campagneId'] == null
          ? null
          : CampagneIdentifier.fromJson(
              json['campagneId'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CampagneJoinRequestToJson(
        CampagneJoinRequest instance) =>
    <String, dynamic>{
      'id': instance.id?.toJson(),
      'creationDate': instance.creationDate?.toIso8601String(),
      'lastModifiedAt': instance.lastModifiedAt?.toIso8601String(),
      'userId': instance.userId?.toJson(),
      'playerId': instance.playerId?.toJson(),
      'campagneId': instance.campagneId?.toJson(),
    };

CampagneJoinRequestCreateDto _$CampagneJoinRequestCreateDtoFromJson(
        Map<String, dynamic> json) =>
    CampagneJoinRequestCreateDto(
      campagneJoinCode: json['campagneJoinCode'] as String,
      playerCharacterId: json['playerCharacterId'] as String,
    );

Map<String, dynamic> _$CampagneJoinRequestCreateDtoToJson(
        CampagneJoinRequestCreateDto instance) =>
    <String, dynamic>{
      'campagneJoinCode': instance.campagneJoinCode,
      'playerCharacterId': instance.playerCharacterId,
    };

CampagneJoinRequestIdentifier _$CampagneJoinRequestIdentifierFromJson(
        Map<String, dynamic> json) =>
    CampagneJoinRequestIdentifier(
      $value: json['value'] as String?,
    );

Map<String, dynamic> _$CampagneJoinRequestIdentifierToJson(
        CampagneJoinRequestIdentifier instance) =>
    <String, dynamic>{
      'value': instance.$value,
    };

EncryptedMessageWrapperDto _$EncryptedMessageWrapperDtoFromJson(
        Map<String, dynamic> json) =>
    EncryptedMessageWrapperDto(
      encryptedMessage: json['encryptedMessage'] as String?,
    );

Map<String, dynamic> _$EncryptedMessageWrapperDtoToJson(
        EncryptedMessageWrapperDto instance) =>
    <String, dynamic>{
      'encryptedMessage': instance.encryptedMessage,
    };

EncryptionChallengeIdentifier _$EncryptionChallengeIdentifierFromJson(
        Map<String, dynamic> json) =>
    EncryptionChallengeIdentifier(
      $value: json['value'] as String?,
    );

Map<String, dynamic> _$EncryptionChallengeIdentifierToJson(
        EncryptionChallengeIdentifier instance) =>
    <String, dynamic>{
      'value': instance.$value,
    };

GoogleLoginDto _$GoogleLoginDtoFromJson(Map<String, dynamic> json) =>
    GoogleLoginDto(
      accessToken: json['accessToken'] as String,
      identityToken: json['identityToken'] as String,
    );

Map<String, dynamic> _$GoogleLoginDtoToJson(GoogleLoginDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'identityToken': instance.identityToken,
    };

HandleJoinRequestDto _$HandleJoinRequestDtoFromJson(
        Map<String, dynamic> json) =>
    HandleJoinRequestDto(
      campagneJoinRequestId: json['campagneJoinRequestId'] as String,
      type: handleJoinRequestTypeFromJson(json['type']),
    );

Map<String, dynamic> _$HandleJoinRequestDtoToJson(
        HandleJoinRequestDto instance) =>
    <String, dynamic>{
      'campagneJoinRequestId': instance.campagneJoinRequestId,
      'type': handleJoinRequestTypeToJson(instance.type),
    };

JoinRequestForCampagneDto _$JoinRequestForCampagneDtoFromJson(
        Map<String, dynamic> json) =>
    JoinRequestForCampagneDto(
      request:
          CampagneJoinRequest.fromJson(json['request'] as Map<String, dynamic>),
      playerCharacter: PlayerCharacter.fromJson(
          json['playerCharacter'] as Map<String, dynamic>),
      username: json['username'] as String,
    );

Map<String, dynamic> _$JoinRequestForCampagneDtoToJson(
        JoinRequestForCampagneDto instance) =>
    <String, dynamic>{
      'request': instance.request.toJson(),
      'playerCharacter': instance.playerCharacter.toJson(),
      'username': instance.username,
    };

LoginWithUsernameAndPasswordDto _$LoginWithUsernameAndPasswordDtoFromJson(
        Map<String, dynamic> json) =>
    LoginWithUsernameAndPasswordDto(
      username: json['username'] as String,
      userSecretByEncryptionChallenge:
          json['userSecretByEncryptionChallenge'] as String,
    );

Map<String, dynamic> _$LoginWithUsernameAndPasswordDtoToJson(
        LoginWithUsernameAndPasswordDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'userSecretByEncryptionChallenge':
          instance.userSecretByEncryptionChallenge,
    };

PlayerCharacter _$PlayerCharacterFromJson(Map<String, dynamic> json) =>
    PlayerCharacter(
      id: json['id'] == null
          ? null
          : PlayerCharacterIdentifier.fromJson(
              json['id'] as Map<String, dynamic>),
      creationDate: json['creationDate'] == null
          ? null
          : DateTime.parse(json['creationDate'] as String),
      lastModifiedAt: json['lastModifiedAt'] == null
          ? null
          : DateTime.parse(json['lastModifiedAt'] as String),
      rpgCharacterConfiguration: json['rpgCharacterConfiguration'] as String?,
      characterName: json['characterName'] as String?,
      playerUserId: json['playerUserId'] == null
          ? null
          : UserIdentifier.fromJson(
              json['playerUserId'] as Map<String, dynamic>),
      campagneId: json['campagneId'] == null
          ? null
          : CampagneIdentifier.fromJson(
              json['campagneId'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlayerCharacterToJson(PlayerCharacter instance) =>
    <String, dynamic>{
      'id': instance.id?.toJson(),
      'creationDate': instance.creationDate?.toIso8601String(),
      'lastModifiedAt': instance.lastModifiedAt?.toIso8601String(),
      'rpgCharacterConfiguration': instance.rpgCharacterConfiguration,
      'characterName': instance.characterName,
      'playerUserId': instance.playerUserId?.toJson(),
      'campagneId': instance.campagneId?.toJson(),
    };

PlayerCharacterCreateDto _$PlayerCharacterCreateDtoFromJson(
        Map<String, dynamic> json) =>
    PlayerCharacterCreateDto(
      rpgCharacterConfiguration: json['rpgCharacterConfiguration'] as String?,
      characterName: json['characterName'] as String,
      campagneId: json['campagneId'] as String?,
    );

Map<String, dynamic> _$PlayerCharacterCreateDtoToJson(
        PlayerCharacterCreateDto instance) =>
    <String, dynamic>{
      'rpgCharacterConfiguration': instance.rpgCharacterConfiguration,
      'characterName': instance.characterName,
      'campagneId': instance.campagneId,
    };

PlayerCharacterIdentifier _$PlayerCharacterIdentifierFromJson(
        Map<String, dynamic> json) =>
    PlayerCharacterIdentifier(
      $value: json['value'] as String?,
    );

Map<String, dynamic> _$PlayerCharacterIdentifierToJson(
        PlayerCharacterIdentifier instance) =>
    <String, dynamic>{
      'value': instance.$value,
    };

ProblemDetails _$ProblemDetailsFromJson(Map<String, dynamic> json) =>
    ProblemDetails(
      type: json['type'] as String?,
      title: json['title'] as String?,
      status: (json['status'] as num?)?.toInt(),
      detail: json['detail'] as String?,
      instance: json['instance'] as String?,
    );

Map<String, dynamic> _$ProblemDetailsToJson(ProblemDetails instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'status': instance.status,
      'detail': instance.detail,
      'instance': instance.instance,
    };

RegisterWithApiKeyDto _$RegisterWithApiKeyDtoFromJson(
        Map<String, dynamic> json) =>
    RegisterWithApiKeyDto(
      apiKey: json['apiKey'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$RegisterWithApiKeyDtoToJson(
        RegisterWithApiKeyDto instance) =>
    <String, dynamic>{
      'apiKey': instance.apiKey,
      'username': instance.username,
    };

RegisterWithUsernamePasswordDto _$RegisterWithUsernamePasswordDtoFromJson(
        Map<String, dynamic> json) =>
    RegisterWithUsernamePasswordDto(
      email: json['email'] as String,
      encryptionChallengeIdentifier: EncryptionChallengeIdentifier.fromJson(
          json['encryptionChallengeIdentifier'] as Map<String, dynamic>),
      username: json['username'] as String,
      userSecret: json['userSecret'] as String,
    );

Map<String, dynamic> _$RegisterWithUsernamePasswordDtoToJson(
        RegisterWithUsernamePasswordDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'encryptionChallengeIdentifier':
          instance.encryptionChallengeIdentifier.toJson(),
      'username': instance.username,
      'userSecret': instance.userSecret,
    };

ResetPasswordDto _$ResetPasswordDtoFromJson(Map<String, dynamic> json) =>
    ResetPasswordDto(
      email: json['email'] as String,
      newHashedPassword: json['newHashedPassword'] as String,
      resetCode: json['resetCode'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$ResetPasswordDtoToJson(ResetPasswordDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'newHashedPassword': instance.newHashedPassword,
      'resetCode': instance.resetCode,
      'username': instance.username,
    };

ResetPasswordRequestDto _$ResetPasswordRequestDtoFromJson(
        Map<String, dynamic> json) =>
    ResetPasswordRequestDto(
      email: json['email'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$ResetPasswordRequestDtoToJson(
        ResetPasswordRequestDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
    };

UserIdentifier _$UserIdentifierFromJson(Map<String, dynamic> json) =>
    UserIdentifier(
      $value: json['value'] as String?,
    );

Map<String, dynamic> _$UserIdentifierToJson(UserIdentifier instance) =>
    <String, dynamic>{
      'value': instance.$value,
    };
