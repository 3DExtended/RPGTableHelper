import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/custom_markdown_body.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/navbar_new_design.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/connection_details_provider.dart';
import 'package:rpg_table_helper/helpers/date_time_extensions.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/helpers/rpg_character_configuration_provider.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/connection_details.dart';
import 'package:rpg_table_helper/models/rpg_character_configuration.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:rpg_table_helper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/rpg_entity_service.dart';
import 'package:rpg_table_helper/services/server_communication_service.dart';
import 'package:rpg_table_helper/services/server_methods_service.dart';

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
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var isLandscape = width >= height;
    // TODO remove me
    if (kDebugMode || !kDebugMode) isLandscape = true;

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
                "Select Game Mode", // TODO localize
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
                  : LayoutBuilder(builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: RowColumnFlipper(
                                isLandscapeMode: isLandscape,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ConditionalWidgetWrapper(
                                      condition: isLandscape,
                                      wrapper: (context, child) =>
                                          Expanded(child: child),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: !isLandscape ? 20.0 : 20.0,
                                          right: !isLandscape ? 20.0 : 0.0,
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              AddableColumnHeader(
                                                  title:
                                                      "Choose a campagne", // TODO localize
                                                  subtitle:
                                                      "Start as DM", // TODO localize
                                                  subsubtitle:
                                                      "You own ${campagnes?.length ?? 0} campagnes.", // TODO localize
                                                  onPressedHandler: () {
                                                    // TODO add new campagne
                                                  }),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      ...getOpenCampagnes(),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ]),
                                      )),
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                  ),
                                  isLandscape
                                      ? Container(
                                          width: 1,
                                          height: constraints.maxHeight - 40,
                                          color: darkColor,
                                        )
                                      : HorizontalLine(),
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                  ),
                                  ConditionalWidgetWrapper(
                                    condition: isLandscape,
                                    wrapper: (context, child) =>
                                        Expanded(child: child),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: !isLandscape ? 20.0 : 0.0,
                                        right: !isLandscape ? 20.0 : 0.0,
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AddableColumnHeader(
                                                title:
                                                    "Choose a character (Join as Player)", // TODO localize
                                                subtitle:
                                                    "Join as Player", // TODO localize
                                                subsubtitle:
                                                    "You own ${characters?.length ?? 0} character.", // TODO localize
                                                onPressedHandler: () {
                                                  // TODO add new character
                                                }),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    ...getCharacters(),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getOpenCampagnes() {
    return campagnes!
        .map((campagne) => Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: CupertinoButton(
                onPressed: () async {
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
                        .updateConfiguration(
                            RpgConfigurationModel.getBaseConfiguration());
                  }

                  ref
                      .read(connectionDetailsProvider.notifier)
                      .updateConfiguration(
                          (ref.read(connectionDetailsProvider).valueOrNull ??
                                  ConnectionDetails.defaultValue())
                              .copyWith(
                                  isDm: true,
                                  campagneId: campagne.id!.$value!,
                                  sessionConnectionNumberForPlayers:
                                      campagne.joinCode));

                  // start SignalR connection
                  var serverCommunicationService =
                      DependencyProvider.of(context)
                          .getService<IServerCommunicationService>();
                  await serverCommunicationService.startConnection();
                  if (!mounted) return;

                  // register game in signalr
                  final com = DependencyProvider.of(context)
                      .getService<IServerMethodsService>();
                  await com.registerGame(campagneId: campagne.id!.$value!);
                  if (!mounted) return;

                  // navigate to main game screen (auth screen wrapper)
                  navigatorKey.currentState!
                      .pushNamed(DmPageScreen.route)
                      .then((asdf) async {
                    // when returning to this screen we want to stop all connections as the user is "disconnected"
                    //(in the sense that the DM can't send notifications to this player)
                    await serverCommunicationService.stopConnection();

                    await loadCampagnesAndPlayersFromServer();
                  });
                },
                minSize: 0,
                padding: EdgeInsets.all(0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: darkColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: CustomMarkdownBody(
                                  text:
                                      "# ${campagne.campagneName!}\n\n__Last updated:__ ${campagne.lastModifiedAt!.toLocal().format("%d.%m.%Y %H:%M Uhr")}\n\n__Join Code:__ ${campagne.joinCode}\n\n__Config Length (Debug):__ ${(campagne.rpgConfiguration?.length ?? 0).toString()}"),
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

  List<Widget> getCharacters() {
    return characters!
        .map((character) => Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.all(0),
                onPressed: () async {
                  setState(() {
                    showLoadingSpinner = true;
                  });
                  var serverCommunicationService =
                      DependencyProvider.of(context)
                          .getService<IServerCommunicationService>();
                  serverCommunicationService.stopConnection();

                  if (character.campagneId != null &&
                      character.campagneId!.$value != null) {
                    // set initial rpg config
                    // rpgConfigurationProvider
                    var rpgService = DependencyProvider.of(context)
                        .getService<IRpgEntityService>();

                    var campagneLoadResult = await rpgService.getCampagneById(
                        campagneId: character.campagneId!);
                    if (!mounted) return;
                    await campagneLoadResult.possiblyHandleError(context);
                    if (!mounted) return;

                    if (!campagneLoadResult.isSuccessful) {
                      return;
                    }

                    Map<String, dynamic> map = jsonDecode(
                        campagneLoadResult.result!.rpgConfiguration!);

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

                    ref
                        .read(connectionDetailsProvider.notifier)
                        .updateConfiguration(
                            (ref.read(connectionDetailsProvider).valueOrNull ??
                                    ConnectionDetails.defaultValue())
                                .copyWith(
                                    campagneId: character.campagneId?.$value,
                                    playerCharacterId: character.id!.$value!));

                    // start SignalR connection
                    await serverCommunicationService.startConnection();
                    if (!mounted) return;

                    // the player is assigned to a campagne. hence we can start the signal r process here
                    final com = DependencyProvider.of(context)
                        .getService<IServerMethodsService>();
                    await com.joinGameSession(
                        playerCharacterId: character.id!.$value!);

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
                    await askForCampagneJoinCode(context)
                        .then((joinCode) async {
                      if (joinCode == null) {
                        setState(() {
                          showLoadingSpinner = false;
                        });
                        return;
                      }

                      // 2. create new join request for campagne with join code
                      var service = DependencyProvider.of(context)
                          .getService<IRpgEntityService>();
                      var createResponse =
                          await service.createNewCampagneJoinRequest(
                        joinCode: joinCode,
                        playerCharacterId: character.id!,
                      );

                      await createResponse.possiblyHandleError(context);

                      // 3. TODO wait for "joinrequesthandled" signalR method
                      // 4. TODO block user from creating more join requsts...
                      // 5. TODO reload this screen after "joinrequesthandled" for this player
                    });
                  }
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
                            Expanded(
                              child: Builder(builder: (context) {
                                var characterNameToDisplay =
                                    character.characterName!;
                                if (character.rpgCharacterConfiguration !=
                                    null) {
                                  var parsedConfig =
                                      RpgCharacterConfiguration.fromJson(
                                          jsonDecode(character
                                              .rpgCharacterConfiguration!));
                                  characterNameToDisplay =
                                      parsedConfig.characterName;
                                }
                                return CustomMarkdownBody(
                                    text:
                                        "# $characterNameToDisplay\n\n__Last updated:__ ${character.lastModifiedAt!.toLocal().format("%d.%m.%Y %H:%M Uhr")}\n\n__Assigned to campagne:__ ${(character.campagneId != null && character.campagneId!.$value != null).toString()}");
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
  final Null Function() onPressedHandler;

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
