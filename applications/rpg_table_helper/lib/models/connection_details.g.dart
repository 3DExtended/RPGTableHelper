// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_details.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConnectionDetailsCWProxy {
  ConnectionDetails isConnected(bool isConnected);

  ConnectionDetails sessionConnectionNumberForPlayers(
      String? sessionConnectionNumberForPlayers);

  ConnectionDetails isConnecting(bool isConnecting);

  ConnectionDetails isDm(bool isDm);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConnectionDetails(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConnectionDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  ConnectionDetails call({
    bool? isConnected,
    String? sessionConnectionNumberForPlayers,
    bool? isConnecting,
    bool? isDm,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConnectionDetails.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConnectionDetails.copyWith.fieldName(...)`
class _$ConnectionDetailsCWProxyImpl implements _$ConnectionDetailsCWProxy {
  const _$ConnectionDetailsCWProxyImpl(this._value);

  final ConnectionDetails _value;

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
  ConnectionDetails isDm(bool isDm) => this(isDm: isDm);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConnectionDetails(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConnectionDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  ConnectionDetails call({
    Object? isConnected = const $CopyWithPlaceholder(),
    Object? sessionConnectionNumberForPlayers = const $CopyWithPlaceholder(),
    Object? isConnecting = const $CopyWithPlaceholder(),
    Object? isDm = const $CopyWithPlaceholder(),
  }) {
    return ConnectionDetails(
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

ConnectionDetails _$ConnectionDetailsFromJson(Map<String, dynamic> json) =>
    ConnectionDetails(
      isConnected: json['isConnected'] as bool,
      sessionConnectionNumberForPlayers:
          json['sessionConnectionNumberForPlayers'] as String?,
      isConnecting: json['isConnecting'] as bool,
      isDm: json['isDm'] as bool,
    );

Map<String, dynamic> _$ConnectionDetailsToJson(ConnectionDetails instance) =>
    <String, dynamic>{
      'isConnected': instance.isConnected,
      'isConnecting': instance.isConnecting,
      'sessionConnectionNumberForPlayers':
          instance.sessionConnectionNumberForPlayers,
      'isDm': instance.isDm,
    };
