// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'dart:convert';

part 'swagger.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class AppleLoginDto {
  const AppleLoginDto({
    required this.authorizationCode,
    required this.identityToken,
  });

  factory AppleLoginDto.fromJson(Map<String, dynamic> json) =>
      _$AppleLoginDtoFromJson(json);

  static const toJsonFactory = _$AppleLoginDtoToJson;
  Map<String, dynamic> toJson() => _$AppleLoginDtoToJson(this);

  @JsonKey(name: 'authorizationCode')
  final String authorizationCode;
  @JsonKey(name: 'identityToken')
  final String identityToken;
  static const fromJsonFactory = _$AppleLoginDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AppleLoginDto &&
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

extension $AppleLoginDtoExtension on AppleLoginDto {
  AppleLoginDto copyWith({String? authorizationCode, String? identityToken}) {
    return AppleLoginDto(
        authorizationCode: authorizationCode ?? this.authorizationCode,
        identityToken: identityToken ?? this.identityToken);
  }

  AppleLoginDto copyWithWrapped(
      {Wrapped<String>? authorizationCode, Wrapped<String>? identityToken}) {
    return AppleLoginDto(
        authorizationCode: (authorizationCode != null
            ? authorizationCode.value
            : this.authorizationCode),
        identityToken:
            (identityToken != null ? identityToken.value : this.identityToken));
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
class LoginDto {
  const LoginDto({
    required this.username,
    required this.userSecretByEncryptionChallenge,
  });

  factory LoginDto.fromJson(Map<String, dynamic> json) =>
      _$LoginDtoFromJson(json);

  static const toJsonFactory = _$LoginDtoToJson;
  Map<String, dynamic> toJson() => _$LoginDtoToJson(this);

  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'userSecretByEncryptionChallenge')
  final String userSecretByEncryptionChallenge;
  static const fromJsonFactory = _$LoginDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LoginDto &&
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

extension $LoginDtoExtension on LoginDto {
  LoginDto copyWith(
      {String? username, String? userSecretByEncryptionChallenge}) {
    return LoginDto(
        username: username ?? this.username,
        userSecretByEncryptionChallenge: userSecretByEncryptionChallenge ??
            this.userSecretByEncryptionChallenge);
  }

  LoginDto copyWithWrapped(
      {Wrapped<String>? username,
      Wrapped<String>? userSecretByEncryptionChallenge}) {
    return LoginDto(
        username: (username != null ? username.value : this.username),
        userSecretByEncryptionChallenge:
            (userSecretByEncryptionChallenge != null
                ? userSecretByEncryptionChallenge.value
                : this.userSecretByEncryptionChallenge));
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
    required this.newPassword,
    required this.resetCode,
    required this.username,
  });

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDtoFromJson(json);

  static const toJsonFactory = _$ResetPasswordDtoToJson;
  Map<String, dynamic> toJson() => _$ResetPasswordDtoToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'newPassword')
  final String newPassword;
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
            (identical(other.newPassword, newPassword) ||
                const DeepCollectionEquality()
                    .equals(other.newPassword, newPassword)) &&
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
      const DeepCollectionEquality().hash(newPassword) ^
      const DeepCollectionEquality().hash(resetCode) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $ResetPasswordDtoExtension on ResetPasswordDto {
  ResetPasswordDto copyWith(
      {String? email,
      String? newPassword,
      String? resetCode,
      String? username}) {
    return ResetPasswordDto(
        email: email ?? this.email,
        newPassword: newPassword ?? this.newPassword,
        resetCode: resetCode ?? this.resetCode,
        username: username ?? this.username);
  }

  ResetPasswordDto copyWithWrapped(
      {Wrapped<String>? email,
      Wrapped<String>? newPassword,
      Wrapped<String>? resetCode,
      Wrapped<String>? username}) {
    return ResetPasswordDto(
        email: (email != null ? email.value : this.email),
        newPassword:
            (newPassword != null ? newPassword.value : this.newPassword),
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
