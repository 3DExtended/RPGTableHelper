import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/custom_text_field.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';

class PlayerScreenRecepies extends ConsumerStatefulWidget {
  const PlayerScreenRecepies({
    super.key,
  });

  @override
  ConsumerState<PlayerScreenRecepies> createState() =>
      _PlayerScreenRecepiesState();
}

class _PlayerScreenRecepiesState extends ConsumerState<PlayerScreenRecepies> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var rpgConfig = ref.watch(rpgConfigurationProvider).valueOrNull;
    var rpgCharacterConfig =
        ref.watch(rpgCharacterConfigurationProvider).valueOrNull;

    if (rpgConfig == null || rpgCharacterConfig == null) {
      return Container(); // TODO show error
    }

    var allRecipes = rpgConfig.craftingRecipes;

    return Column(
      children: [
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: true // showSearchField
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20, 0.0),
                  child: CustomTextField(
                      labelText: "Suche",
                      textEditingController: TextEditingController(),
                      newDesign: true,
                      keyboardType: TextInputType.text),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
