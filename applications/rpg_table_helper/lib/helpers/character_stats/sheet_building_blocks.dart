import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/property_purposes.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/models/rpg_configuration_templates.dart';

/// A property of a template that the game master can take over into their
/// own sheet.
///
/// It keeps its uuid: a property taken over twice would be the same one, and
/// the template's sample values still fit it.
class SheetBuildingBlock {
  const SheetBuildingBlock({
    required this.template,
    required this.tabName,
    required this.stat,
  });

  final RpgConfigurationTemplateId template;

  /// The tab of the template the property is in.
  final String tabName;
  final CharacterStatDefinition stat;

  /// Whether a sheet with [existing] properties already has this one. A
  /// sheet has at most one character summary (name and level).
  bool isOn(Iterable<CharacterStatDefinition> existing) =>
      existing.any((s) =>
          s.statUuid == stat.statUuid ||
          (stat.valueType ==
                  CharacterStatValueType
                      .characterNameWithLevelAndAdditionalDetails &&
              s.valueType == stat.valueType));

  /// What kind of property it is, in the words of the property picker.
  String kind(S s) {
    if (stat.valueType ==
        CharacterStatValueType.characterNameWithLevelAndAdditionalDetails) {
      return s.characterNameWithLevelAndConfigurableDetails;
    }
    for (final info in PropertyPurposeInfo.all) {
      if (info.valueType == stat.valueType) return info.title(s);
    }
    return '';
  }
}

/// The properties of the templates, by template and tab. "Leer" has nothing
/// the others lack.
List<SheetBuildingBlock> sheetBuildingBlocks() => [
      for (final id in RpgConfigurationTemplates.ids)
        if (id != RpgConfigurationTemplateId.empty)
          for (final tab in RpgConfigurationTemplates.build(id)
                  .characterStatTabsDefinition ??
              const <CharacterStatsTabDefinition>[])
            for (final stat in tab.statsInTab)
              SheetBuildingBlock(template: id, tabName: tab.tabName, stat: stat),
    ];
