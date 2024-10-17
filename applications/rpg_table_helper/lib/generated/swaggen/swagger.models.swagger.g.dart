// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppleLoginDto _$AppleLoginDtoFromJson(Map<String, dynamic> json) =>
    AppleLoginDto(
      authorizationCode: json['authorizationCode'] as String?,
      identityToken: json['identityToken'] as String?,
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
      accessToken: json['accessToken'] as String?,
      identityToken: json['identityToken'] as String?,
    );

Map<String, dynamic> _$GoogleLoginDtoToJson(GoogleLoginDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'identityToken': instance.identityToken,
    };

LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => LoginDto(
      username: json['username'] as String?,
      userSecretByEncryptionChallenge:
          json['userSecretByEncryptionChallenge'] as String?,
    );

Map<String, dynamic> _$LoginDtoToJson(LoginDto instance) => <String, dynamic>{
      'username': instance.username,
      'userSecretByEncryptionChallenge':
          instance.userSecretByEncryptionChallenge,
    };

RegisterDto _$RegisterDtoFromJson(Map<String, dynamic> json) => RegisterDto(
      apiKey: json['apiKey'] as String?,
      email: json['email'] as String?,
      encryptionChallengeIdentifier: json['encryptionChallengeIdentifier'] ==
              null
          ? null
          : EncryptionChallengeIdentifier.fromJson(
              json['encryptionChallengeIdentifier'] as Map<String, dynamic>),
      username: json['username'] as String?,
      userSecret: json['userSecret'] as String?,
    );

Map<String, dynamic> _$RegisterDtoToJson(RegisterDto instance) =>
    <String, dynamic>{
      'apiKey': instance.apiKey,
      'email': instance.email,
      'encryptionChallengeIdentifier':
          instance.encryptionChallengeIdentifier?.toJson(),
      'username': instance.username,
      'userSecret': instance.userSecret,
    };

ResetPasswordDto _$ResetPasswordDtoFromJson(Map<String, dynamic> json) =>
    ResetPasswordDto(
      email: json['email'] as String?,
      newPassword: json['newPassword'] as String?,
      resetCode: json['resetCode'] as String?,
      username: json['username'] as String?,
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
      email: json['email'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$ResetPasswordRequestDtoToJson(
        ResetPasswordRequestDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
    };
