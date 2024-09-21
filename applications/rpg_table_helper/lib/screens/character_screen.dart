import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/fill_remaining_space.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';

class CharacterScreen extends ConsumerWidget {
  static String route = "character";

  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var connectionDetails = ref.watch(connectionDetailsProvider).valueOrNull;

    return connectionDetails?.isDm == true
        ? FillRemainingSpace(
            child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CharacterScreen for DMs",
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
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
                            "Deine Session Id (für deine Player): __${connectionDetails!.sessionConnectionNumberForPlayers ?? ""}__"),
                    const SizedBox(
                      height: 20,
                    ),
                    if ((connectionDetails.openPlayerRequests?.length ?? 0) !=
                        0)
                      CustomMarkdownBody(
                          text:
                              "Offene Spieler Anfragen (${connectionDetails.openPlayerRequests?.length ?? 0}):"),
                    const SizedBox(
                      height: 20,
                    ),
                    if ((connectionDetails.openPlayerRequests?.length ?? 0) !=
                        0)
                      OpenPlayerJoinRequests(
                          connectionDetails: connectionDetails),
                    if ((connectionDetails.openPlayerRequests?.length ?? 0) !=
                        0)
                      const SizedBox(
                        height: 20,
                      ),
                    const HorizontalLine(),
                  ],
                ),
              ),
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

class OpenPlayerJoinRequests extends ConsumerWidget {
  const OpenPlayerJoinRequests({
    super.key,
    required this.connectionDetails,
  });

  final ConnectionDetails connectionDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: [
        ...connectionDetails.openPlayerRequests!
            .asMap()
            .entries
            .map((request) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StyledBox(
                        child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Spielername: ${request.value.playerName}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 15,
                            ),
                            CupertinoButton(
                                minSize: 0,
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  "Annehmen",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: const Color.fromARGB(
                                            255, 79, 255, 103),
                                      ),
                                ),
                                onPressed: () {
                                  // TODO make me
                                }),
                            CupertinoButton(
                                minSize: 0,
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Text(
                                  "Ablehnen",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: const Color.fromARGB(
                                            255, 255, 79, 79),
                                      ),
                                ),
                                onPressed: () {
                                  // TODO make me
                                  // remove this particular request from open requests
                                  var newRequests = [
                                    ...connectionDetails.openPlayerRequests!
                                  ];
                                  newRequests.removeAt(request.key);
                                  ref
                                      .read(connectionDetailsProvider.notifier)
                                      .updateConfiguration(
                                          connectionDetails.copyWith(
                                        openPlayerRequests: newRequests,
                                      ));
                                }),
                            const SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    )),
                  ],
                )),
      ],
    );
  }
}
