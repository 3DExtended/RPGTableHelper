// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prepared_character.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreparedCharacterCWProxy {
  PreparedCharacter uuid(String uuid);

  PreparedCharacter characterName(String characterName);

  PreparedCharacter characterStats(List<RpgCharacterStatValue> characterStats);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PreparedCharacter(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PreparedCharacter(...).copyWith(id: 12, name: "My name")
  /// ```
  PreparedCharacter call({
    String uuid,
    String characterName,
    List<RpgCharacterStatValue> characterStats,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPreparedCharacter.copyWith(...)` or call `instanceOfPreparedCharacter.copyWith.fieldName(value)` for a single field.
class _$PreparedCharacterCWProxyImpl implements _$PreparedCharacterCWProxy {
  const _$PreparedCharacterCWProxyImpl(this._value);

  final PreparedCharacter _value;

  @override
  PreparedCharacter uuid(String uuid) => call(uuid: uuid);

  @override
  PreparedCharacter characterName(String characterName) =>
      call(characterName: characterName);

  @override
  PreparedCharacter characterStats(
    List<RpgCharacterStatValue> characterStats,
  ) => call(characterStats: characterStats);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PreparedCharacter(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PreparedCharacter(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  PreparedCharacter call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? characterName = const $CopyWithPlaceholder(),
    Object? characterStats = const $CopyWithPlaceholder(),
  }) {
    return PreparedCharacter(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      characterName:
          characterName == const $CopyWithPlaceholder() || characterName == null
          ? _value.characterName
          // ignore: cast_nullable_to_non_nullable
          : characterName as String,
      characterStats:
          characterStats == const $CopyWithPlaceholder() ||
              characterStats == null
          ? _value.characterStats
          // ignore: cast_nullable_to_non_nullable
          : characterStats as List<RpgCharacterStatValue>,
    );
  }
}

extension $PreparedCharacterCopyWith on PreparedCharacter {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPreparedCharacter.copyWith(...)` or `instanceOfPreparedCharacter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreparedCharacterCWProxy get copyWith =>
      _$PreparedCharacterCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreparedCharacter _$PreparedCharacterFromJson(Map<String, dynamic> json) =>
    PreparedCharacter(
      uuid: json['uuid'] as String,
      characterName: json['characterName'] as String,
      characterStats: (json['characterStats'] as List<dynamic>)
          .map((e) => RpgCharacterStatValue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PreparedCharacterToJson(PreparedCharacter instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'characterName': instance.characterName,
      'characterStats': instance.characterStats,
    };
