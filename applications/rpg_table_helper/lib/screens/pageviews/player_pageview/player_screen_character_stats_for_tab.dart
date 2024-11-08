import 'package:flutter/material.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';

class PlayerScreenCharacterStatsForTab extends StatelessWidget {
  const PlayerScreenCharacterStatsForTab({
    super.key,
    required this.tabDef,
    required this.rpgConfig,
    required this.charToRender,
  });

  final CharacterStatsTabDefinition tabDef;
  final RpgConfigurationModel rpgConfig;
  final RpgCharacterConfigurationBase? charToRender;

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO create me
      color: Colors.red,
      child: Text(tabDef.tabName +
          rpgConfig.rpgName +
          (charToRender?.characterName ?? "")),
    );
  }
}
