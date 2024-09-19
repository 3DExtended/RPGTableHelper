import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/fill_remaining_space.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';

class CharacterScreen extends ConsumerWidget {
  static String route = "character";

  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;

    return connectionDetails?.isDm == true
        ? FillRemainingSpace(
            child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CharacterScreen for DMs",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomMarkdownBody(
                    text:
                        "Deine Session Id (für deine Player): __${connectionDetails!.sessionConnectionNumberForPlayers ?? ""}__")
              ],
            ),
          ))
        : FillRemainingSpace(
            child: Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              "CharacterScreen",
              style: TextStyle(color: Colors.white),
            ),
          ));
  }
}
