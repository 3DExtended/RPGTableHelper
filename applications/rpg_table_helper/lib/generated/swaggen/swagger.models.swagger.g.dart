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
      rpgConfiguration: json['rpgConfiguration'] == null
          ? null
          : StringOption.fromJson(
              json['rpgConfiguration'] as Map<String, dynamic>),
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
      'rpgConfiguration': instance.rpgConfiguration?.toJson(),
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

CampagneIdentifierOption _$CampagneIdentifierOptionFromJson(
        Map<String, dynamic> json) =>
    CampagneIdentifierOption(
      isNone: json['isNone'] as bool?,
      isSome: json['isSome'] as bool?,
    );

Map<String, dynamic> _$CampagneIdentifierOptionToJson(
        CampagneIdentifierOption instance) =>
    <String, dynamic>{
      'isNone': instance.isNone,
      'isSome': instance.isSome,
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
      rpgCharacterConfiguration: json['rpgCharacterConfiguration'] == null
          ? null
          : StringOption.fromJson(
              json['rpgCharacterConfiguration'] as Map<String, dynamic>),
      characterName: json['characterName'] as String?,
      playerUserId: json['playerUserId'] == null
          ? null
          : UserIdentifier.fromJson(
              json['playerUserId'] as Map<String, dynamic>),
      campagneId: json['campagneId'] == null
          ? null
          : CampagneIdentifierOption.fromJson(
              json['campagneId'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlayerCharacterToJson(PlayerCharacter instance) =>
    <String, dynamic>{
      'id': instance.id?.toJson(),
      'creationDate': instance.creationDate?.toIso8601String(),
      'lastModifiedAt': instance.lastModifiedAt?.toIso8601String(),
      'rpgCharacterConfiguration': instance.rpgCharacterConfiguration?.toJson(),
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

StringOption _$StringOptionFromJson(Map<String, dynamic> json) => StringOption(
      isNone: json['isNone'] as bool?,
      isSome: json['isSome'] as bool?,
    );

Map<String, dynamic> _$StringOptionToJson(StringOption instance) =>
    <String, dynamic>{
      'isNone': instance.isNone,
      'isSome': instance.isSome,
    };

UserIdentifier _$UserIdentifierFromJson(Map<String, dynamic> json) =>
    UserIdentifier(
      $value: json['value'] as String?,
    );

Map<String, dynamic> _$UserIdentifierToJson(UserIdentifier instance) =>
    <String, dynamic>{
      'value': instance.$value,
    };
