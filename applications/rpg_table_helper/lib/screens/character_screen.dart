import 'package:flutter/material.dart';
import 'package:rpg_table_helper/components/fill_remaining_space.dart';

class CharacterScreen extends StatelessWidget {
  static String route = "character";

  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FillRemainingSpace(
        child: Container(
      child: const Text(
        "CharacterScreen",
        style: TextStyle(color: Colors.white),
      ),
    ));
  }
}
