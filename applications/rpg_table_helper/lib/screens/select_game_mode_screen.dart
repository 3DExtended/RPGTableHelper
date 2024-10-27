import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_button.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';
import 'package:rpg_table_helper/components/custom_loading_spinner.dart';
import 'package:rpg_table_helper/components/horizontal_line.dart';
import 'package:rpg_table_helper/components/row_column_flipper.dart';
import 'package:rpg_table_helper/components/styled_box.dart';
import 'package:rpg_table_helper/components/tab_handler.dart';
import 'package:rpg_table_helper/components/wizards/two_part_wizard_step_body.dart';
import 'package:rpg_table_helper/constants.dart';
import 'package:rpg_table_helper/generated/swaggen/swagger.models.swagger.dart';
import 'package:rpg_table_helper/helpers/date_time_extensions.dart';
import 'package:rpg_table_helper/helpers/modal_helpers.dart';
import 'package:rpg_table_helper/helpers/rpg_configuration_provider.dart';
import 'package:rpg_table_helper/main.dart';
import 'package:rpg_table_helper/models/rpg_configuration_model.dart';
import 'package:rpg_table_helper/screens/wizards/rpg_configuration_wizard/rpg_configuration_wizard_step_7_crafting_recipes.dart';
import 'package:rpg_table_helper/services/dependency_provider.dart';
import 'package:rpg_table_helper/services/rpg_entity_service.dart';
import 'package:rpg_table_helper/services/server_communication_service.dart';
import 'package:rpg_table_helper/services/server_methods_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if (!mounted) return;

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
      });
    });

    // TODO check if there is a cached player...

    Future.delayed(Duration.zero, () async {
      if (!mounted) return;

      if (DependencyProvider.of(context).isMocked) return;
      var prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey(sharedPrefsKeyRpgConfigJson)) {
        var loadedJsonForRpgConfig =
            prefs.getString(sharedPrefsKeyRpgConfigJson);
        var parsedJson =
            RpgConfigurationModel.fromJson(jsonDecode(loadedJsonForRpgConfig!));
        if (!mounted) return;

        await showSynchronizeLocallySavedRpgCampagne(context)
            .then((value) async {
          if (value != true) {
            return;
          }

          // save to cloud
          if (!mounted) return;

          var service =
              DependencyProvider.of(context).getService<IRpgEntityService>();
          var createResult = await service.saveCampagneAsNewCampagne(
              campagneName: parsedJson.rpgName,
              rpgConfig: loadedJsonForRpgConfig);
          if (!mounted) return;

          await createResult.possiblyHandleError(context);
        });
      }
    });

    super.initState();
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
    isLandscape = true;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/bg.png",
            fit: BoxFit.fill,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(79, 0, 0, 0),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isLandscape ? outerPadding : outerPadding * 2,
                outerPadding * 2,
                outerPadding * 2,
                !isLandscape ? outerPadding : outerPadding * 2,
              ),
              child: StyledBox(
                overrideInnerDecoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                      "assets/images/bg.png",
                    ),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Container(
                  color: const Color.fromARGB(34, 67, 67, 67),
                  child: campagnes == null
                      ? CustomLoadingSpinner()
                      : LayoutBuilder(builder: (context, constraints) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Select Game Mode", // TODO localize
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              HorizontalLine(),
                              SizedBox(
                                height: 10,
                              ),
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
                                                    onPressedHandler: () {}),
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
                                            height: constraints.maxHeight - 120,
                                            color: const Color.fromARGB(
                                                78, 255, 255, 255),
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
                                                  onPressedHandler: () {}),
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
                          );
                        }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getOpenCampagnes() {
    return campagnes!
        .map((campagne) => Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: CupertinoButton(
                onPressed: () async {
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
                  navigatorKey.currentState!.pushNamedAndRemoveUntil(
                      AuthorizedScreenWrapper.route, (r) => false);
                },
                minSize: 0,
                padding: EdgeInsets.all(0),
                child: StyledBox(
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
                  if (character.campagneId != null &&
                      character.campagneId!.$value != null) {
                    // TODO set rpg config and id to connection details

                    // start SignalR connection
                    var serverCommunicationService =
                        DependencyProvider.of(context)
                            .getService<IServerCommunicationService>();
                    await serverCommunicationService.startConnection();
                    if (!mounted) return;

                    // the player is assigned to a campagne. hence we can start the signal r process here
                    final com = DependencyProvider.of(context)
                        .getService<IServerMethodsService>();
                    await com.joinGameSession(
                        playerCharacterId: character.id!.$value!);

                    // navigate to main game screen (auth screen wrapper)
                    navigatorKey.currentState!.pushNamedAndRemoveUntil(
                        AuthorizedScreenWrapper.route, (r) => false);
                  } else {
                    // 1. show modal for entering a join code
                    await askForCampagneJoinCode(context)
                        .then((joinCode) async {
                      if (joinCode == null) {
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
                child: StyledBox(
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
                                      "# ${character.characterName!}\n\n__Last updated:__ ${character.lastModifiedAt!.toLocal().format("%d.%m.%Y %H:%M Uhr")}"),
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
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.white),
              ),
              Text(
                subsubtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: CustomButton(
              onPressed: onPressedHandler,
              icon: CustomFaIcon(size: 12, icon: FontAwesomeIcons.plus),
            ),
          ),
        )
      ],
    );
  }
}
