import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
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
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_helpers.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/screens/settings/user_settings_screen.dart';
import 'package:quest_keeper/services/config_sync/config_sync_session_controller.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/join_requests/join_request_notification_controller.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/session/connected_players_mapper.dart';
import 'package:quest_keeper/services/session/session_entry_coordinator.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:quest_keeper/services/session_commands/session_command_notification_controller.dart';
import 'package:quest_keeper/services/snack_bar_service.dart';
import 'package:quest_keeper/services/sse/events_client.dart';
import 'package:uuid/v7.dart';

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

  JoinRequestNotificationController? _joinRequestController;
  /// Character ids for which we already showed join-accepted UI (SSE or poll).
  final Set<String> _joinAcceptNotifiedCharacterIds = {};

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await loadCampagnesAndPlayersFromServer();
      if (!mounted) return;
      await _startJoinRequestNotifications();
    });

    super.initState();
  }

  /// sse-05: keeps join-request notifies flowing from the app shell, even
  /// before any `SessionEnter` - the DM sees new requests, the player sees
  /// resolutions, whenever their `/events` stream is up. This screen's state
  /// stays alive (offstage) while a campagne/character session is pushed on
  /// top of it, so the subscription also covers requests that arrive while
  /// the DM is already managing the table.
  Future<void> _startJoinRequestNotifications() async {
    if (!mounted) return;
    final eventsClient =
        DependencyProvider.of(context).getService<EventsClient>();
    // Prefer a fresh stream: Cloudflare/proxies can drop idle SSE while the
    // client still reports isConnected=true, which silently loses join resolves.
    await eventsClient.forceReconnect();
    if (!mounted) return;

    _joinRequestController ??= JoinRequestNotificationController(
      eventsClient: eventsClient,
      onJoinRequestCreated: _onJoinRequestCreated,
      onJoinRequestResolved: _onJoinRequestResolved,
    );
    _joinRequestController!.start();
  }

  void _onJoinRequestCreated(JoinRequestCreatedEvent event) {
    if (!mounted) return;

    final connectionDetails =
        ref.read(connectionDetailsProvider).valueOrNull;
    if (connectionDetails != null &&
        connectionDetails.isDm &&
        connectionDetails.campagneId == event.campagneId) {
      final openRequests = <PlayerJoinRequests>[
        ...(connectionDetails.openPlayerRequests ?? []),
        event.toPlayerJoinRequest(),
      ];
      ref.read(connectionDetailsProvider.notifier).updateConfiguration(
            connectionDetails.copyWith(openPlayerRequests: openRequests),
          );
    }

    final snackService =
        DependencyProvider.of(context).getService<ISnackBarService>();
    snackService.showSnackBar(
      snack: SnackBar(
        content: Text(
          '${event.playerName} (${event.username}) wants to join your campagne.',
        ),
        duration: const Duration(seconds: 8),
        showCloseIcon: true,
      ),
      uniqueId: 'joinRequestCreated-${event.requestId}',
    );
  }

  void _onJoinRequestResolved(JoinRequestResolvedEvent event) {
    if (!mounted) return;

    _notifyJoinResolved(accepted: event.accepted, source: 'sse');
  }

  void _notifyJoinResolved({
    required bool accepted,
    String source = 'sse',
    String? playerCharacterId,
  }) {
    if (accepted &&
        playerCharacterId != null &&
        !_joinAcceptNotifiedCharacterIds.add(playerCharacterId)) {
      return;
    }

    final snackService =
        DependencyProvider.of(context).getService<ISnackBarService>();
    snackService.showSnackBar(
      snack: SnackBar(
        content: Text(
          accepted
              ? 'Your join request was accepted! You can now enter the campagne.'
              : 'Your join request was denied.',
        ),
        duration: const Duration(seconds: 8),
        showCloseIcon: true,
      ),
      uniqueId: 'joinRequestResolved-$source-${playerCharacterId ?? 'unknown'}',
    );

    if (accepted) {
      unawaited(loadCampagnesAndPlayersFromServer());
    }
  }

  /// Fallback when `joinRequestResolved` SSE is dropped (idle proxy timeout).
  /// Polls until the character gains a campagneId (accept) or times out.
  Future<void> _pollForJoinAcceptance({
    required PlayerCharacterIdentifier playerCharacterId,
  }) async {
    final service =
        DependencyProvider.of(context).getService<IRpgEntityService>();
    final characterIdValue = playerCharacterId.$value;
    if (characterIdValue == null) return;

    for (var attempt = 0; attempt < 45; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final response = await service.getPlayerCharacetersForPlayer();
      if (!response.isSuccessful || response.result == null) {
        continue;
      }

      final match = response.result!.firstWhereOrNull(
        (c) => c.id?.$value == characterIdValue,
      );
      final campagneId = match?.campagneId?.$value;

      if (campagneId != null && campagneId.isNotEmpty) {
        _notifyJoinResolved(
          accepted: true,
          source: 'poll',
          playerCharacterId: characterIdValue,
        );
        return;
      }
    }
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
    unawaited(_joinRequestController?.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: CustomThemeProvider.of(context).theme.bgColor,
        child: Column(
          children: [
            Navbar(
              backInsteadOfCloseIcon: false,
              closeFunction: null,
              menuOpen: () =>
                  Navigator.of(context).pushNamed(UserSettingsScreen.route),
              useTopSafePadding: true,
              titleWidget: Text(
                S.of(context).selectGameMode,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: CustomThemeProvider.of(context)
                                .brightnessNotifier
                                .value ==
                            Brightness.light
                        ? CustomThemeProvider.of(context).theme.textColor
                        : CustomThemeProvider.of(context).theme.darkTextColor,
                    fontSize: 24),
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
                                onPressedHandler: () async {
                                  await createNewCharacter();
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
                    border: Border.all(
                        color: CustomThemeProvider.of(context).theme.darkColor),
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
                            color:
                                CustomThemeProvider.of(context).theme.darkColor,
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
                    border: Border.all(
                        color: CustomThemeProvider.of(context).theme.darkColor),
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
                                color: CustomThemeProvider.of(context)
                                    .theme
                                    .darkColor,
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
                                        backgroundColor:
                                            CustomThemeProvider.of(context)
                                                .theme
                                                .bgColor,
                                        lightColor:
                                            CustomThemeProvider.of(context)
                                                .theme
                                                .darkColor,
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

  /// Builds a [ConfigSyncSessionController] wired to this session's Riverpod
  /// stores. Callers start it for whichever entities apply
  /// (campagne/character) and must [ConfigSyncSessionController.stop] it when
  /// the session ends. It is both the read path (catch-up on remote
  /// `*ConfigChanged` SSE notifies) and, after sse-08, the sole write path:
  /// [IServerMethodsService.activeConfigSyncSessionController] is pointed at it
  /// so editor-driven config edits persist via debounced REST PATCH/PUT.
  ConfigSyncSessionController _buildConfigSyncSessionController(
      IRpgEntityService rpgService,
      {void Function(String characterId, RpgCharacterConfiguration config)?
          onRemoteCharacterConfig,
      void Function(String userId)? onParticipantOnline,
      void Function(String userId)? onParticipantOffline}) {
    return ConfigSyncSessionController(
      rpgEntityService: rpgService,
      eventsClient: DependencyProvider.of(context).getService<EventsClient>(),
      applyCampagneConfig: (config) =>
          ref.read(rpgConfigurationProvider.notifier).updateConfiguration(config),
      readCampagneConfig: () =>
          ref.read(rpgConfigurationProvider).valueOrNull ??
          RpgConfigurationModel.getBaseConfiguration(),
      applyCharacterConfig: (config) => ref
          .read(rpgCharacterConfigurationProvider.notifier)
          .updateConfiguration(config),
      readCharacterConfig: () =>
          ref.read(rpgCharacterConfigurationProvider).valueOrNull ??
          RpgCharacterConfiguration.getBaseConfiguration(
              ref.read(rpgConfigurationProvider).valueOrNull),
      onRemoteCharacterConfig: onRemoteCharacterConfig,
      onParticipantOnline: onParticipantOnline,
      onParticipantOffline: onParticipantOffline,
    );
  }

  /// DM-only: patches the config of an already-known `connectedPlayers`
  /// entry in place when a `characterConfigChanged` SSE notify (for a
  /// character other than the DM's own, since the DM has none) arrives via
  /// [ConfigSyncSessionController.onRemoteCharacterConfig]. No-ops if the
  /// character isn't part of the currently hydrated roster.
  ///
  /// Does **not** touch [OpenPlayerConnection.lastPing] — config sync is not
  /// presence.
  void _onRemoteCharacterConfigForDm(
      String characterId, RpgCharacterConfiguration config) {
    final connectionDetails = ref.read(connectionDetailsProvider).valueOrNull;
    final connectedPlayers = connectionDetails?.connectedPlayers;
    if (connectionDetails == null || connectedPlayers == null) {
      return;
    }

    final updated = connectedPlayers
        .map((p) => p.playerCharacterId.$value == characterId
            ? p.copyWith(configuration: config)
            : p)
        .toList();

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
        connectionDetails.copyWith(connectedPlayers: updated));
  }

  /// DM-only: reflects `participantOnline` / `participantOffline` presence
  /// SSE notifies onto `connectedPlayers` via [lastPing].
  ///
  /// When an unknown user comes online (typical after a newly accepted join),
  /// refreshes the campagne character list so the roster can grow, then marks
  /// them online.
  Future<void> _onParticipantPresenceForDm(String userId,
      {required bool online}) async {
    final connectionDetails = ref.read(connectionDetailsProvider).valueOrNull;
    final connectedPlayers = connectionDetails?.connectedPlayers;
    if (connectionDetails == null || connectedPlayers == null) {
      return;
    }

    // Ignore presence for the campagne DM account: opening the table as DM
    // must not mark a DM-owned test character as "player online".
    final dmCampagne = (campagnes ?? const <Campagne>[])
        .where((c) => c.id?.$value == connectionDetails.campagneId)
        .firstOrNull;
    final dmUserId = dmCampagne?.dmUserId?.$value;
    if (dmUserId != null && userId == dmUserId) {
      return;
    }

    final known = connectedPlayers.any((p) => p.userId.$value == userId);
    List<PlayerCharacter>? allCharacters;
    if (!known && online && connectionDetails.campagneId != null) {
      final rpgService =
          DependencyProvider.of(context).getService<IRpgEntityService>();
      final charsResponse = await rpgService.getPlayerCharactersForCampagne(
        campagneId: CampagneIdentifier($value: connectionDetails.campagneId!),
      );
      if (charsResponse.isSuccessful) {
        allCharacters = charsResponse.result;
      }
    }

    if (!mounted) return;

    final latest = ref.read(connectionDetailsProvider).valueOrNull;
    if (latest?.connectedPlayers == null) {
      return;
    }

    final updated = applyParticipantPresence(
      connectedPlayers: latest!.connectedPlayers!,
      userId: userId,
      online: online,
      allCharacters: allCharacters,
      campagneConfig: ref.read(rpgConfigurationProvider).valueOrNull,
    );

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
        latest.copyWith(connectedPlayers: updated));
  }

  /// sse-06: builds a fresh [SessionCommandNotificationController] wired to
  /// this session's `/events` stream. Its callbacks re-serialize the parsed
  /// SSE payload and hand off to the [IServerMethodsService] fight/grant
  /// handlers (`playersAreAskedForRolls`, `dmReceivedFightSequenceAnswer`,
  /// `grantPlayerItems`) so the roll-modal and grant-toast UX is driven purely
  /// over SSE. Started/stopped per session-entry, like
  /// [_buildConfigSyncSessionController].
  SessionCommandNotificationController _buildSessionCommandNotificationController() {
    final eventsClient = DependencyProvider.of(context).getService<EventsClient>();
    final serverMethodsService =
        DependencyProvider.of(context).getService<IServerMethodsService>();

    return SessionCommandNotificationController(
      eventsClient: eventsClient,
      onPlayersAreAskedForRolls: (event) {
        serverMethodsService.playersAreAskedForRolls(
          jsonEncode(
            FightSequence(fightUuid: event.fightUuid, sequence: event.sequence),
          ),
        );
      },
      onDmReceivedFightSequenceAnswer: (event) {
        serverMethodsService.dmReceivedFightSequenceAnswer(
          jsonEncode(
            FightSequence(fightUuid: event.fightUuid, sequence: event.sequence),
          ),
        );
      },
      onItemsGranted: (event) {
        final currentCharacter =
            ref.read(rpgCharacterConfigurationProvider).valueOrNull;
        if (currentCharacter == null ||
            currentCharacter.uuid != event.playerCharacterId) {
          return;
        }
        final grant = GrantedItemsForPlayer(
          characterName: currentCharacter.characterName,
          playerId: event.playerCharacterId,
          grantedItems: event.items
              .map((i) => RpgCharacterOwnedItemPair(
                    itemUuid: i.itemUuid,
                    amount: i.amount,
                  ))
              .toList(),
        );
        serverMethodsService.grantPlayerItems(jsonEncode([grant]));
      },
    );
  }

  Future onCampagneSelected(Campagne campagne) async {
    setState(() {
      showLoadingSpinner = true;
    });

    var rpgService =
        DependencyProvider.of(context).getService<IRpgEntityService>();
    var sessionEntryCoordinator =
        SessionEntryCoordinator(rpgEntityService: rpgService);

    // REST hydration: SessionEnter, then campagne config + all characters in campagne.
    var hydrationResponse =
        await sessionEntryCoordinator.enterAsDm(campagneId: campagne.id!);
    if (!mounted || !context.mounted) return;
    await hydrationResponse.possiblyHandleError(context);
    if (!mounted) return;
    if (!hydrationResponse.isSuccessful) {
      setState(() {
        showLoadingSpinner = false;
      });
      return;
    }

    var hydratedCampagne = hydrationResponse.result!.campagne;
    RpgConfigurationModel campagneConfigModel;
    if (hydratedCampagne.rpgConfiguration != null &&
        hydratedCampagne.rpgConfiguration!.isNotEmpty) {
      var parsedJson = RpgConfigurationModel.fromJson(
          jsonDecode(hydratedCampagne.rpgConfiguration!));
      ref
          .read(rpgConfigurationProvider.notifier)
          .updateConfiguration(parsedJson);
      campagneConfigModel = parsedJson;
    } else {
      final base = RpgConfigurationModel.getBaseConfiguration();
      ref.read(rpgConfigurationProvider.notifier).updateConfiguration(base);
      campagneConfigModel = base;
    }

    // sse-08 follow-up: the DM never calls startForCharacter (they have no
    // "own" character), so remote characterConfigChanged / presence notifies
    // for *other* participants are routed through these companion callbacks
    // instead, which patch the hydrated connectedPlayers roster below.
    var configSyncSessionController = _buildConfigSyncSessionController(
      rpgService,
      onRemoteCharacterConfig: _onRemoteCharacterConfigForDm,
      onParticipantOnline: (userId) {
        _onParticipantPresenceForDm(userId, online: true);
      },
      onParticipantOffline: (userId) {
        _onParticipantPresenceForDm(userId, online: false);
      },
    );
    var campagneSnapshotResponse = await rpgService.getCampagneRpgConfigSnapshot(
      campagneId: campagne.id!,
    );
    if (!mounted) return;
    if (campagneSnapshotResponse.isSuccessful &&
        campagneSnapshotResponse.result != null) {
      configSyncSessionController.startForCampagne(
        campagneId: campagne.id!,
        initialRevision: campagneSnapshotResponse.result!.revision,
      );
    }

    var joinRequestsResponse = await rpgService.getOpenJoinRequestsForCampagne(
        campagneId: campagne.id!);

    // bugfix (post sse-08): hydrate connectedPlayers from the REST-fetched
    // characters right away, instead of leaving it null - otherwise the DM's
    // live views (character overview, fight sequence, grant items, ...) have
    // nothing to render until a characterConfigChanged notify happens to
    // arrive for every single character.
    // Character "online" means a player has opened that character (player
    // SessionEnter), not that the DM opened the table. Exclude the campagne
    // DM's userId from the presence snapshot when hydrating the roster.
    final dmUserId = hydratedCampagne.dmUserId?.$value;
    final onlinePlayerUserIds = hydrationResponse.result!.onlineUserIds
        .where((id) => dmUserId == null || id != dmUserId)
        .toList();

    var connectedPlayers = mapCharactersToOpenPlayerConnections(
      hydrationResponse.result!.allCharacters ?? const [],
      campagneConfig: campagneConfigModel,
      onlineUserIds: onlinePlayerUserIds,
    );

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
        (ref.read(connectionDetailsProvider).valueOrNull ??
                ConnectionDetails.defaultValue())
            .copyWith(
                lastPing: null,
                isDm: true,
                connectedPlayers: connectedPlayers,
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

    // sse-06: session-scoped fight/roll and item-grant SSE notifies.
    var sessionCommandController = _buildSessionCommandNotificationController();
    sessionCommandController.start();

    if (!mounted || !context.mounted) return;

    // sse-08: config edits now persist via REST/ConfigSync (no SignalR hub).
    final com =
        DependencyProvider.of(context).getService<IServerMethodsService>();
    com.activeConfigSyncSessionController = configSyncSessionController;
    await com.registerGame(campagneId: campagne.id!.$value!);
    if (!mounted) return;

    // navigate to main game screen (auth screen wrapper)
    navigatorKey.currentState!.pushNamed(DmPageScreen.route).then((asdf) async {
      // when returning to this screen we tear down the session's SSE + config
      // sync so the user is "disconnected" from live table updates.
      com.activeConfigSyncSessionController = null;
      await configSyncSessionController.stop();
      await sessionCommandController.stop();
      await sessionEntryCoordinator.leave(campagneId: campagne.id!);

      await loadCampagnesAndPlayersFromServer();
    });
  }

  Future onCharacterSelected(PlayerCharacter character) async {
    setState(() {
      showLoadingSpinner = true;
    });

    if (character.campagneId != null && character.campagneId!.$value != null) {
      // set initial rpg config
      // rpgConfigurationProvider
      var rpgService =
          DependencyProvider.of(context).getService<IRpgEntityService>();
      var sessionEntryCoordinator =
          SessionEntryCoordinator(rpgEntityService: rpgService);

      // REST hydration: SessionEnter, then campagne config + own character.
      var hydrationResponse = await sessionEntryCoordinator.enterAsPlayer(
        campagneId: character.campagneId!,
        playerCharacterId: character.id!,
      );
      if (!mounted) return;
      await hydrationResponse.possiblyHandleError(context);
      if (!mounted) return;

      if (!hydrationResponse.isSuccessful) {
        setState(() {
          showLoadingSpinner = false;
        });
        return;
      }

      Map<String, dynamic> map = jsonDecode(
          hydrationResponse.result!.campagne.rpgConfiguration!);

      var receivedConfig = RpgConfigurationModel.fromJson(map);
      ref
          .read(rpgConfigurationProvider.notifier)
          .updateConfiguration(receivedConfig);

      var hydratedCharacter =
          hydrationResponse.result!.ownCharacter ?? character;
      if (hydratedCharacter.rpgCharacterConfiguration != null &&
          hydratedCharacter.rpgCharacterConfiguration!.isNotEmpty) {
        var parsedJson = RpgCharacterConfiguration.fromJson(
            jsonDecode(hydratedCharacter.rpgCharacterConfiguration!));
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

      // sse-04: start listening for campagneConfigChanged / characterConfigChanged
      // SSE notifies so this client catches up on config edits made by other
      // session participants (e.g. the DM).
      var configSyncSessionController = _buildConfigSyncSessionController(rpgService);
      var campagneSnapshotResponse =
          await rpgService.getCampagneRpgConfigSnapshot(
        campagneId: character.campagneId!,
      );
      if (!mounted) return;
      if (campagneSnapshotResponse.isSuccessful &&
          campagneSnapshotResponse.result != null) {
        configSyncSessionController.startForCampagne(
          campagneId: character.campagneId!,
          initialRevision: campagneSnapshotResponse.result!.revision,
        );
      }
      var characterSnapshotResponse =
          await rpgService.getCharacterRpgConfigSnapshot(
        playerCharacterId: character.id!,
      );
      if (!mounted) return;
      if (characterSnapshotResponse.isSuccessful &&
          characterSnapshotResponse.result != null) {
        configSyncSessionController.startForCharacter(
          playerCharacterId: character.id!,
          initialRevision: characterSnapshotResponse.result!.revision,
        );
      }

      // sse-06: session-scoped fight/roll and item-grant SSE notifies.
      var sessionCommandController = _buildSessionCommandNotificationController();
      sessionCommandController.start();

      if (!mounted) return;

      // sse-08: character edits now persist via REST/ConfigSync (no SignalR hub).
      final com =
          DependencyProvider.of(context).getService<IServerMethodsService>();
      com.activeConfigSyncSessionController = configSyncSessionController;
      await com.joinGameSession(playerCharacterId: character.id!.$value!);

      // navigate to main game screen (auth screen wrapper)
      navigatorKey.currentState!
          .pushNamed(PlayerPageScreen.route)
          .then((asdf) async {
        // when returning to this screen we tear down the session's SSE + config
        // sync so the user is "disconnected" from live table updates.
        com.activeConfigSyncSessionController = null;
        await configSyncSessionController.stop();
        await sessionCommandController.stop();
        await sessionEntryCoordinator.leave(campagneId: character.campagneId!);

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

        setState(() {
          showLoadingSpinner = false;
        });

        if (!createResponse.isSuccessful) {
          return;
        }

        // Refresh SSE right before waiting: idle connections often look connected
        // locally but are already gone on the server (resolve notify then no-ops).
        final eventsClient =
            DependencyProvider.of(context).getService<EventsClient>();
        await eventsClient.forceReconnect();
        if (!mounted) return;
        _joinRequestController?.start();

        // TODO show popup that the request was sent to the dm
        var snackService =
            DependencyProvider.of(context).getService<ISnackBarService>();
        snackService.showSnackBar(
            snack: SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min, // this property

                children: [
                  Text(
                    "Join Request sent",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontSize: 24,
                        color: CustomThemeProvider.of(context).theme.textColor),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      "Join request was sent to the DM. They need to confirm it before you can join the campagne."),
                ],
              ),
              duration: Duration(seconds: 15),
              showCloseIcon: true,
            ),
            uniqueId:
                "joinRequestWasSent-d0b3e639-f361-49b6-8cd6-68bb9a201b21");

        // 3. Prefer SSE joinRequestResolved; also poll REST in case the proxy
        // dropped the player's /events stream (seen against Cloudflare prod).
        unawaited(_pollForJoinAcceptance(playerCharacterId: character.id!));
        // TODO block user from creating more join requests for the same character
        // while one is still pending.
      });
    }
  }

  Future createNewCharacter() async {
    var service =
        DependencyProvider.of(context).getService<IRpgEntityService>();
    // first ask user for character name
    var result =
        await PlayerPageHelpers.askPlayerForCharacterName(context: context);
    if (result == null) return;

    setState(() {
      showLoadingSpinner = true;
    });

    var createResponse = await service.createNewCharacter(
      characterName: result,
      characterConfigJson: jsonEncode(
        RpgCharacterConfiguration.getBaseConfiguration(null).copyWith(
          characterName: result,
          inventory: [],
          isAlternateFormActive: false,
          alternateForm: null,
          alternateForms: null,
          characterStats: [],
          moneyInBaseType: 0,
          uuid: UuidV7().generate(),
          companionCharacters: [],
          transformationComponents: [],
        ),
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

    // reload characters from server
    var charactersResponse = await service.getPlayerCharacetersForPlayer();

    if (!mounted) return;
    await charactersResponse.possiblyHandleError(context);
    setState(() {
      characters = charactersResponse.result ?? [];
      showLoadingSpinner = false;
    });
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

    // reload campagne from server
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
                      color:
                          CustomThemeProvider.of(context).theme.darkTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: CustomThemeProvider.of(context).theme.darkTextColor),
              ),
              Text(
                subsubtitle,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: CustomThemeProvider.of(context).theme.darkTextColor),
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
              color: CustomThemeProvider.of(context).theme.darkColor,
            ),
          ),
        )
      ],
    );
  }
}
