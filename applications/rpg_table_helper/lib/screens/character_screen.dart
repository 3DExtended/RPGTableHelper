import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.enums.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/rpg_entity_service.dart';

class CharacterScreen extends ConsumerStatefulWidget {
  static String route = "character";

  const CharacterScreen({super.key});

  @override
  ConsumerState<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends ConsumerState<CharacterScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// TODO implement me in the new design!!!
class OpenPlayerJoinRequests extends ConsumerStatefulWidget {
  const OpenPlayerJoinRequests({
    super.key,
    required this.connectionDetails,
  });

  final ConnectionDetails connectionDetails;

  @override
  ConsumerState<OpenPlayerJoinRequests> createState() =>
      _OpenPlayerJoinRequestsState();
}

class _OpenPlayerJoinRequestsState
    extends ConsumerState<OpenPlayerJoinRequests> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: [
        ...widget.connectionDetails.openPlayerRequests!
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
                                onPressed: () async {
                                  var com = DependencyProvider.of(context)
                                      .getService<IRpgEntityService>();

                                  var response = await com.handleJoinRequest(
                                      campagneJoinRequestId:
                                          request.value.campagneJoinRequestId,
                                      typeOfHandle:
                                          HandleJoinRequestType.accept);

                                  await response.possiblyHandleError(context);

                                  // remove this particular request from open requests
                                  deleteJoinRequestAt(request, ref);
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
                                onPressed: () async {
                                  var com = DependencyProvider.of(context)
                                      .getService<IRpgEntityService>();

                                  var response = await com.handleJoinRequest(
                                      campagneJoinRequestId:
                                          request.value.campagneJoinRequestId,
                                      typeOfHandle: HandleJoinRequestType.deny);
                                  await response.possiblyHandleError(context);
                                  // remove this particular request from open requests
                                  deleteJoinRequestAt(request, ref);
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

  void deleteJoinRequestAt(
      MapEntry<int, PlayerJoinRequests> request, WidgetRef ref) {
    var newRequests = [...widget.connectionDetails.openPlayerRequests!];
    newRequests.removeAt(request.key);
    ref
        .read(connectionDetailsProvider.notifier)
        .updateConfiguration(widget.connectionDetails.copyWith(
          openPlayerRequests: newRequests,
        ));
  }
}
