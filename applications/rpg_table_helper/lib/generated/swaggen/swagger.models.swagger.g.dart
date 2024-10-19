// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppleLoginDto _$AppleLoginDtoFromJson(Map<String, dynamic> json) =>
    AppleLoginDto(
      authorizationCode: json['authorizationCode'] as String,
      identityToken: json['identityToken'] as String,
    );

Map<String, dynamic> _$AppleLoginDtoToJson(AppleLoginDto instance) =>
    <String, dynamic>{
      'authorizationCode': instance.authorizationCode,
      'identityToken': instance.identityToken,
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

LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => LoginDto(
      username: json['username'] as String,
      userSecretByEncryptionChallenge:
          json['userSecretByEncryptionChallenge'] as String,
    );

Map<String, dynamic> _$LoginDtoToJson(LoginDto instance) => <String, dynamic>{
      'username': instance.username,
      'userSecretByEncryptionChallenge':
          instance.userSecretByEncryptionChallenge,
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
      newPassword: json['newPassword'] as String,
      resetCode: json['resetCode'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$ResetPasswordDtoToJson(ResetPasswordDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'newPassword': instance.newPassword,
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
