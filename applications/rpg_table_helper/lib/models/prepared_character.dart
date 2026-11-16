import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';

part 'prepared_character.g.dart';

/// A character the game master prepared in the campaign ("vorbereiteter
/// Charakter"): a name and the sheet's values. A player who joins can take
/// it over instead of filling in the sheet.
///
/// Kept in the campaign's configuration, so no server change is needed;
/// app versions that do not know it ignore it.
@JsonSerializable()
@CopyWith()
class PreparedCharacter {
  final String uuid;
  final String characterName;
  final List<RpgCharacterStatValue> characterStats;

  PreparedCharacter({
    required this.uuid,
    required this.characterName,
    required this.characterStats,
  });

  factory PreparedCharacter.fromJson(Map<String, dynamic> json) =>
      _$PreparedCharacterFromJson(json);

  Map<String, dynamic> toJson() => _$PreparedCharacterToJson(this);
}
