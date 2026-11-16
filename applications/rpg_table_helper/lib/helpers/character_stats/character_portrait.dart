import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// True when the sheet has its own image property. The character form then
/// does not also ask for the portrait of the character summary, so it shows
/// one image picker instead of two.
bool sheetHasImageProperty(RpgConfigurationModel? config) =>
    config != null &&
    StatNumbers.allStats(config)
        .any((s) => s.valueType == CharacterStatValueType.singleImage);
