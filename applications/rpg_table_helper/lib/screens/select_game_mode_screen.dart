import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/components/custom_markdown_body.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/date_time_extensions.dart';
import 'package:quest_keeper/helpers/modals/ask_for_campagne_join_code.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_page_helpers.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/server_communication_service.dart';
import 'package:quest_keeper/services/server_methods_service.dart';

class SelectGameModeScreen extends ConsumerStatefulWidget {
  static const route = 'selectgamemode';

  const SelectGameModeScreen({super.key});

  @override
  ConsumerState<SelectGameModeScreen> createState() =>
      _SelectGameModeScreenState();
}

class _SelectGameModeScreenState extends ConsumerState<SelectGameModeScreen> {
  List<Campagne>? campagnes;
  List<PlayerCharacter>? characters;

  var showLoadingSpinner = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await loadCampagnesAndPlayersFromServer();
    });

    super.initState();
  }

  Future loadCampagnesAndPlayersFromServer() async {
    // load campagnes and players
    if (!mounted) return;
    setState(() {
      showLoadingSpinner = true;
    });

    var service =
        DependencyProvider.of(context).getService<IRpgEntityService>();
    var campagnesResponse = await service.getCampagnesWithPlayerAsDm();
    var charactersResponse = await service.getPlayerCharacetersForPlayer();

    if (!mounted) return;
    await campagnesResponse.possiblyHandleError(context);
    if (!mounted) return;
    await charactersResponse.possiblyHandleError(context);
    setState(() {
      campagnes = campagnesResponse.result ?? [];
      characters = charactersResponse.result ?? [];
      showLoadingSpinner = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: bgColor,
        child: Column(
          children: [
            Navbar(
              backInsteadOfCloseIcon: false,
              closeFunction: null,
              menuOpen: null,
              useTopSafePadding: true,
              titleWidget: Text(
                S.of(context).selectGameMode,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: textColor, fontSize: 24),
              ),
            ),
            Expanded(
              child: campagnes == null ||
                      (showLoadingSpinner == true &&
                          !DependencyProvider.of(context).isMocked)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: CustomLoadingSpinner()),
                          ],
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            AddableColumnHeader(
                                title: S.of(context).chooseACampagne,
                                subtitle: S.of(context).startAsDm,
                                subsubtitle: S
                                    .of(context)
                                    .youOwnXCampaigns(campagnes?.length ?? 0),
                                onPressedHandler: () async {
                                  createNewCampagne();
                                }),
                            SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              children: [
                                ...getOpenCampagnes(),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                              width: 20,
                            ),
                            HorizontalLine(),
                            SizedBox(
                              height: 20,
                              width: 20,
                            ),
                            AddableColumnHeader(
                                title: S.of(context).chooseACharacter,
                                subtitle: S.of(context).joinAsPlayer,
                                subsubtitle: S
                                    .of(context)
                                    .youOwnXCharacters(characters?.length ?? 0),
                                onPressedHandler: () {
                                  // TODO add new character
                                }),
                            SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              children: [
                                ...getCharacters(),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                              width: 20,
                            )
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getOpenCampagnes() {
    return campagnes!
        .map((campagne) => ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: CupertinoButton(
                onPressed: () async {
                  await onCampagneSelected(campagne);
                },
                minSize: 0,
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: darkColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: CustomFaIcon(
                            icon: FontAwesomeIcons.peopleGroup,
                            size: 32,
                            color: darkColor,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: CustomMarkdownBody(
                                        // TODO remove me?
                                        text:
                                            "# ${campagne.campagneName!}\n\n__Last updated:__ ${campagne.lastModifiedAt!.toLocal().format("%d.%m.%Y %H:%M Uhr")}\n\n__Join Code:__ ${campagne.joinCode}\n\n__Config Length (Debug):__ ${(campagne.rpgConfiguration?.length ?? 0).toString()}"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ))
        .toList();
  }

  List<Widget> getCharacters() {
    return characters!
        .map((character) => ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await onCharacterSelected(character);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: darkColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: CustomFaIcon(
                                icon: FontAwesomeIcons.solidUser,
                                size: 32,
                                color: darkColor,
                              ),
                            ),
                            Expanded(
                              child: Builder(builder: (context) {
                                var characterNameToDisplay =
                                    character.characterName!;
                                var imageUrl =
                                    "assets/images/charactercard_placeholder.png";

                                if (character.rpgCharacterConfiguration !=
                                    null) {
                                  var parsedConfig =
                                      RpgCharacterConfiguration.fromJson(
                                          jsonDecode(character
                                              .rpgCharacterConfiguration!));
                                  characterNameToDisplay =
                                      parsedConfig.characterName;

                                  imageUrl = parsedConfig
                                      .getImageUrlWithoutBasePath(null);
                                }

                                var fullImageUrl =
                                    (imageUrl.startsWith("assets")
                                        ? imageUrl
                                        : (apiBaseUrl +
                                            (imageUrl.startsWith("/")
                                                ? (imageUrl.length > 1
                                                    ? imageUrl.substring(1)
                                                    : '')
                                                : imageUrl)));
                                return Row(
                                  children: [
                                    Expanded(
                                      child: CustomMarkdownBody(
                                          text:
                                              "# $characterNameToDisplay\n\n__Last updated:__ ${character.lastModifiedAt!.toLocal().format("%d.%m.%Y %H:%M Uhr")}\n\n__Assigned to campagne:__ ${(character.campagneId != null && character.campagneId!.$value != null).toString()}"),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: BorderedImage(
                                        noPadding: true,
                                        backgroundColor: bgColor,
                                        lightColor: darkColor,
                                        imageUrl: fullImageUrl,
                                        isLoading: false,
                                        isGreyscale: false,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ))
        .toList();
  }

  Future onCampagneSelected(Campagne campagne) async {
    setState(() {
      showLoadingSpinner = true;
    });
    if (campagne.rpgConfiguration != null &&
        campagne.rpgConfiguration!.isNotEmpty) {
      var parsedJson = RpgConfigurationModel.fromJson(
          jsonDecode(campagne.rpgConfiguration!));
      ref
          .read(rpgConfigurationProvider.notifier)
          .updateConfiguration(parsedJson);
    } else {
      ref
          .read(rpgConfigurationProvider.notifier)
          .updateConfiguration(RpgConfigurationModel.getBaseConfiguration());
    }

    var rpgService =
        DependencyProvider.of(context).getService<IRpgEntityService>();

    var joinRequestsResponse = await rpgService.getOpenJoinRequestsForCampagne(
        campagneId: campagne.id!);

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
        (ref.read(connectionDetailsProvider).valueOrNull ??
                ConnectionDetails.defaultValue())
            .copyWith(
                lastPing: null,
                isDm: true,
                connectedPlayers: null,
                fightSequence: null,
                lastGrantedItems: null,

                // TODO test me (once you can create new characters)!!!
                openPlayerRequests: joinRequestsResponse.isSuccessful
                    ? (joinRequestsResponse.result!
                        .map((j) => PlayerJoinRequests(
                              campagneJoinRequestId: j.request.id!.$value!,
                              playerCharacterId: j.playerCharacter.id!.$value!,
                              playerName: j.playerCharacter.characterName ??
                                  S.of(context).characterNameDefault,
                              username: j.username,
                            ))
                        .toList())
                    : List<PlayerJoinRequests>.empty(),
                campagneId: campagne.id!.$value!,
                sessionConnectionNumberForPlayers: campagne.joinCode));

    // start SignalR connection
    if (!mounted || !context.mounted) return;

    var serverCommunicationService = DependencyProvider.of(context)
        .getService<IServerCommunicationService>();
    await serverCommunicationService.startConnection();
    if (!mounted) return;

    // register game in signalr
    final com =
        DependencyProvider.of(context).getService<IServerMethodsService>();
    await com.registerGame(campagneId: campagne.id!.$value!);
    if (!mounted) return;

    // navigate to main game screen (auth screen wrapper)
    navigatorKey.currentState!.pushNamed(DmPageScreen.route).then((asdf) async {
      // when returning to this screen we want to stop all connections as the user is "disconnected"
      //(in the sense that the DM can't send notifications to this player)
      await serverCommunicationService.stopConnection();

      await loadCampagnesAndPlayersFromServer();
    });
  }

  Future onCharacterSelected(PlayerCharacter character) async {
    setState(() {
      showLoadingSpinner = true;
    });
    var serverCommunicationService = DependencyProvider.of(context)
        .getService<IServerCommunicationService>();
    serverCommunicationService.stopConnection();

    if (character.campagneId != null && character.campagneId!.$value != null) {
      // set initial rpg config
      // rpgConfigurationProvider
      var rpgService =
          DependencyProvider.of(context).getService<IRpgEntityService>();

      var campagneLoadResult =
          await rpgService.getCampagneById(campagneId: character.campagneId!);
      if (!mounted) return;
      await campagneLoadResult.possiblyHandleError(context);
      if (!mounted) return;

      if (!campagneLoadResult.isSuccessful) {
        return;
      }

      Map<String, dynamic> map =
          jsonDecode(campagneLoadResult.result!.rpgConfiguration!);

      var receivedConfig = RpgConfigurationModel.fromJson(map);
      ref
          .read(rpgConfigurationProvider.notifier)
          .updateConfiguration(receivedConfig);

      if (character.rpgCharacterConfiguration != null &&
          character.rpgCharacterConfiguration!.isNotEmpty) {
        var parsedJson = RpgCharacterConfiguration.fromJson(
            jsonDecode(character.rpgCharacterConfiguration!));
        ref
            .read(rpgCharacterConfigurationProvider.notifier)
            .updateConfiguration(parsedJson);
      }

      ref.read(connectionDetailsProvider.notifier).updateConfiguration(
          (ref.read(connectionDetailsProvider).valueOrNull ??
                  ConnectionDetails.defaultValue())
              .copyWith(
                  isDm: false,
                  lastPing: null,
                  connectedPlayers: null,
                  fightSequence: null,
                  lastGrantedItems: null,
                  openPlayerRequests: null,
                  campagneId: character.campagneId?.$value,
                  playerCharacterId: character.id!.$value!));

      // start SignalR connection
      await serverCommunicationService.startConnection();
      if (!mounted) return;

      // the player is assigned to a campagne. hence we can start the signal r process here
      final com =
          DependencyProvider.of(context).getService<IServerMethodsService>();
      await com.joinGameSession(playerCharacterId: character.id!.$value!);

      // navigate to main game screen (auth screen wrapper)
      navigatorKey.currentState!
          .pushNamed(PlayerPageScreen.route)
          .then((asdf) async {
        // when returning to this screen we want to stop all connections as the user is "disconnected"
        //(in the sense that the DM can't send notifications to this player)
        await serverCommunicationService.stopConnection();

        await loadCampagnesAndPlayersFromServer();
      });
    } else {
      // 1. show modal for entering a join code
      await askForCampagneJoinCode(context).then((joinCode) async {
        if (joinCode == null) {
          setState(() {
            showLoadingSpinner = false;
          });
          return;
        }
        if (!mounted || !context.mounted) return;

        // 2. create new join request for campagne with join code
        var service =
            DependencyProvider.of(context).getService<IRpgEntityService>();
        var createResponse = await service.createNewCampagneJoinRequest(
          joinCode: joinCode,
          playerCharacterId: character.id!,
        );
        if (!mounted || !context.mounted) return;

        await createResponse.possiblyHandleError(context);

        // 3. TODO wait for "joinrequesthandled" signalR method
        // 4. TODO block user from creating more join requsts...
        // 5. TODO reload this screen after "joinrequesthandled" for this player
      });
    }
  }

  Future createNewCampagne() async {
    var service =
        DependencyProvider.of(context).getService<IRpgEntityService>();
    var result = await DmPageHelpers.askDmForNameOfCampagne(context: context);
    if (result == null) return;

    setState(() {
      showLoadingSpinner = true;
    });
    var createResponse = await service.createNewCampagne(
      campagneName: result,
      baseConfig: RpgConfigurationModel.getBaseConfiguration().copyWith(
        rpgName: result,
        allItems: [],
      ),
    );

    if (!mounted) {
      return;
    }
    await createResponse.possiblyHandleError(context);
    if (!mounted) {
      return;
    }

    if (!createResponse.isSuccessful) {
      setState(() {
        showLoadingSpinner = false;
      });
      return;
    }

    // load campagne from server
    var campagnesResponse = await service.getCampagnesWithPlayerAsDm();
    if (!mounted) {
      return;
    }
    await campagnesResponse.possiblyHandleError(context);
    if (!mounted) {
      return;
    }
    if (!campagnesResponse.isSuccessful) {
      setState(() {
        showLoadingSpinner = false;
      });
      return;
    }

    campagnes = campagnesResponse.result ?? [];

    await onCampagneSelected(campagnes!
        .singleWhere((e) => e.id!.$value! == createResponse.result!.$value!));
  }
}

class AddableColumnHeader extends StatelessWidget {
  const AddableColumnHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.subsubtitle,
    required this.onPressedHandler,
  });

  final String title;
  final String subtitle;
  final String subsubtitle;
  final VoidCallback onPressedHandler;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 1,
          height: 1,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                softWrap: true,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: darkTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: darkTextColor),
              ),
              Text(
                subsubtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: darkTextColor),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            onPressed: onPressedHandler,
            icon: CustomFaIcon(
              size: 16,
              icon: FontAwesomeIcons.plus,
              color: darkColor,
            ),
          ),
        )
      ],
    );
  }
}
