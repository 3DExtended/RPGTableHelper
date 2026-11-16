import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/bordered_image.dart';
import 'package:quest_keeper/components/app_style_dialog.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_loading_spinner.dart';
import 'package:quest_keeper/components/horizontal_line.dart';
import 'package:quest_keeper/components/navbar.dart';
import 'package:quest_keeper/constants.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/helpers/connection_details_provider.dart';
import 'package:quest_keeper/helpers/current_fight_provider.dart';
import 'package:quest_keeper/helpers/date_time_extensions.dart';
import 'package:quest_keeper/helpers/modals/ask_for_campagne_join_code.dart';
import 'package:quest_keeper/helpers/modals/ask_for_new_campagne_name.dart';
import 'package:quest_keeper/helpers/rpg_character_configuration_provider.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/main.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/screens/pageviews/dm_pageview/dm_page_screen.dart';
import 'package:quest_keeper/screens/pageviews/player_pageview/player_page_screen.dart';
import 'package:quest_keeper/screens/preauthorized/login_screen.dart';
import 'package:quest_keeper/screens/settings/user_settings_screen.dart';
import 'package:quest_keeper/screens/wizards/all_wizard_configurations.dart';
import 'package:quest_keeper/services/auth/session_refresh_coordinator.dart';
import 'package:quest_keeper/services/auth/session_revoker.dart';
import 'package:quest_keeper/services/config_sync/config_sync_session_controller.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';
import 'package:quest_keeper/services/dependency_provider.dart';
import 'package:quest_keeper/services/join_requests/pending_join_request_store.dart';
import 'package:quest_keeper/services/join_requests/join_request_notification_controller.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/session/connected_players_mapper.dart';
import 'package:quest_keeper/services/session/session_entry_coordinator.dart';
import 'package:quest_keeper/services/onboarding_intent_store.dart';
import 'package:quest_keeper/services/session/dm_roster_refresh.dart';
import 'package:quest_keeper/services/session/session_presence_keeper.dart';
import 'package:quest_keeper/services/server_methods_service.dart';
import 'package:quest_keeper/services/session_commands/session_command_notification_controller.dart';
import 'package:quest_keeper/services/snack_bar_service.dart';
import 'package:quest_keeper/services/sse/events_client.dart';

class SelectGameModeScreen extends ConsumerStatefulWidget {
  static const route = 'selectgamemode';

  static const runAGamePathKey = ValueKey('runAGamePath');
  static const joinAGamePathKey = ValueKey('joinAGamePath');
  static const noCampagnesCtaKey = ValueKey('noCampagnesCta');
  static const noCharactersCtaKey = ValueKey('noCharactersCta');

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

  /// Join requests sent from this device that the DM has not answered yet,
  /// by character id (SP-1: "waiting for approval" on the character card).
  Map<String, PendingJoinRequest> _pendingJoinRequests = {};

  /// Open join requests per campagne id, for the badge on the DM's cards.
  Map<String, int> _openJoinRequestCounts = {};

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await loadCampagnesAndPlayersFromServer();
      if (!mounted) return;
      await _startJoinRequestNotifications();
      if (!mounted) return;
      await _openPathFromOnboardingIntent();
    });

    // auth-04: every successful auth path (login, register, Apple/Google,
    // complete-SSO) lands here, so this is the single place that covers
    // "start proactive refresh monitoring after login" for all of them, in
    // addition to `SessionRestorerScreen` covering cold-start restore.
    // Idempotent: cancels/reschedules from the current persisted expiry.
    _startSessionMonitoringIfPossible();

    super.initState();
  }

  /// Best-effort: some widget/golden tests wire only the services a given
  /// screen needs onto a raw `GetIt` rather than the full
  /// `DependencyProvider`.
  void _startSessionMonitoringIfPossible() {
    var getIt = DependencyProvider.getIt;
    if (getIt == null || !getIt.isRegistered<ISessionRefreshCoordinator>()) {
      return;
    }
    unawaited(getIt.get<ISessionRefreshCoordinator>().startMonitoring());
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

    final connectionDetails = ref.read(connectionDetailsProvider).value;
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

    if ((campagnes ?? const <Campagne>[])
        .any((c) => c.id?.value == event.campagneId)) {
      setState(() {
        _openJoinRequestCounts[event.campagneId] =
            (_openJoinRequestCounts[event.campagneId] ?? 0) + 1;
      });
    }

    final snackService =
        DependencyProvider.of(context).getService<ISnackBarService>();
    snackService.showSnackBar(
      snack: SnackBar(
        content: Text(
          S.of(context).joinRequestCreatedForDm(event.playerName, event.username),
        ),
        duration: const Duration(seconds: 8),
        showCloseIcon: true,
      ),
      uniqueId: 'joinRequestCreated-${event.requestId}',
    );
  }

  void _onJoinRequestResolved(JoinRequestResolvedEvent event) {
    if (!mounted) return;

    final pending = _pendingJoinRequests.values.firstWhereOrNull(
        (p) => p.campagneJoinRequestId == event.requestId);
    if (pending != null) {
      // Accepted or denied: either way the character is no longer waiting.
      unawaited(ref
          .read(pendingJoinRequestStoreProvider)
          .remove(pending.playerCharacterId));
      setState(() {
        _pendingJoinRequests.remove(pending.playerCharacterId);
      });
    }

    _notifyJoinResolved(
      accepted: event.accepted,
      source: 'sse',
      playerCharacterId: pending?.playerCharacterId,
    );
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
              ? S.of(context).joinRequestAcceptedMessage
              : S.of(context).joinRequestDeniedMessage,
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
    final characterIdValue = playerCharacterId.value;
    if (characterIdValue == null) return;

    for (var attempt = 0; attempt < 45; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final response = await service.getPlayerCharacetersForPlayer();
      if (!response.isSuccessful || response.result == null) {
        continue;
      }

      final match = response.result!.firstWhereOrNull(
        (c) => c.id?.value == characterIdValue,
      );
      final campagneId = match?.campagneId?.value;

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

  /// Clears local JWT + refresh token, best-effort revokes this device's
  /// session on the server, then returns to `LoginScreen`. Cold start must
  /// not restore the session afterwards (no refresh token left to restore
  /// from).
  Future<void> _logout() async {
    var sessionRevoker =
        DependencyProvider.of(context).getService<ISessionRevoker>();
    await sessionRevoker.logout();
    _stopSessionMonitoringIfPossible();
    if (!mounted) return;

    navigatorKey.currentState!
        .pushNamedAndRemoveUntil(LoginScreen.route, (r) => false);
  }

  void _stopSessionMonitoringIfPossible() {
    var getIt = DependencyProvider.getIt;
    if (getIt == null || !getIt.isRegistered<ISessionRefreshCoordinator>()) {
      return;
    }
    getIt.get<ISessionRefreshCoordinator>().stopMonitoring();
  }

  /// SL-1: the welcome screen asked "lead or join?" before sign-in. Someone
  /// who has no campagne and no character yet lands right in the matching
  /// dialog. The choice is used once.
  Future<void> _openPathFromOnboardingIntent() async {
    final intent = await readOnboardingIntent();
    if (intent == null || !mounted) return;
    await clearOnboardingIntent();
    if (!mounted) return;
    final hasNothingYet =
        (campagnes ?? const []).isEmpty && (characters ?? const []).isEmpty;
    if (!hasNothingYet) return;
    switch (intent) {
      case OnboardingIntent.lead:
        await createNewCampagne();
      case OnboardingIntent.join:
        await _joinCampagne();
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
    if (!mounted) return;

    final pending = await reconcilePendingJoinRequests(
      store: ref.read(pendingJoinRequestStoreProvider),
      characters: charactersResponse.result ?? const [],
    );
    if (!mounted) return;

    setState(() {
      campagnes = campagnesResponse.result ?? [];
      characters = charactersResponse.result ?? [];
      _pendingJoinRequests = pending;
      showLoadingSpinner = false;
    });

    unawaited(_refreshOpenJoinRequestCounts());
  }

  /// SL-3/SL-9: one request per campagne for the open-requests badge.
  /// Best-effort: a failure only hides the badge, it never shows an error.
  Future<void> _refreshOpenJoinRequestCounts() async {
    final ownCampagnes = campagnes ?? const <Campagne>[];
    if (ownCampagnes.isEmpty) return;
    final service =
        DependencyProvider.of(context).getService<IRpgEntityService>();

    Future<MapEntry<String, int>?> countFor(Campagne campagne) async {
      final id = campagne.id;
      if (id?.value == null) return null;
      try {
        final response =
            await service.getOpenJoinRequestsForCampagne(campagneId: id!);
        if (!response.isSuccessful || response.result == null) return null;
        return MapEntry(id.value!, response.result!.length);
      } catch (_) {
        return null;
      }
    }

    final entries = await Future.wait(ownCampagnes.map(countFor));
    if (!mounted) return;
    setState(() {
      _openJoinRequestCounts = Map.fromEntries(entries.nonNulls);
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
              logoutFunction: () => _logout(),
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
                            _buildIntro(context),
                            SizedBox(
                              height: 30,
                            ),
                            HorizontalLine(),
                            SizedBox(
                              height: 20,
                            ),
                            AddableColumnHeader(
                              title: S.of(context).chooseACampagne,
                              subtitle: S.of(context).startAsDm,
                              subsubtitle: S
                                  .of(context)
                                  .youOwnXCampaigns(campagnes?.length ?? 0),
                              actionLabel: (campagnes ?? []).isEmpty
                                  ? null
                                  : S.of(context).newCampaign,
                              onPressedHandler: () async {
                                await createNewCampagne();
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            if ((campagnes ?? []).isEmpty)
                              EmptyListCallToAction(
                                key: SelectGameModeScreen.noCampagnesCtaKey,
                                text: S.of(context).noCampagnesYetHint,
                                actionLabel: S.of(context).createCampagneAction,
                                onPressed: () async {
                                  await createNewCampagne();
                                },
                              )
                            else
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
                              actionLabel: (characters ?? []).isEmpty
                                  ? null
                                  : S.of(context).joinCampagneAction,
                              onPressedHandler: () async {
                                await _joinCampagne();
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            if ((characters ?? []).isEmpty)
                              EmptyListCallToAction(
                                key: SelectGameModeScreen.noCharactersCtaKey,
                                text: S.of(context).noCharactersYetHint,
                                actionLabel: S.of(context).joinCampagneAction,
                                onPressed: () async {
                                  await _joinCampagne();
                                },
                              )
                            else
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

  /// SL-3 / SP-1: what the app is, and the two ways in.
  Widget _buildIntro(BuildContext context) {
    final s = S.of(context);
    final theme = CustomThemeProvider.of(context).theme;

    return Column(
      children: [
        Text(
          s.welcomeToQuestKeeper,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: theme.darkTextColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 10),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Text(
            s.questKeeperIntro,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: theme.darkTextColor,
                  fontSize: 16,
                ),
          ),
        ),
        SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: [
            RolePathCard(
              key: SelectGameModeScreen.runAGamePathKey,
              icon: FontAwesomeIcons.hatWizard,
              title: s.pathRunAGameTitle,
              subtitle: s.pathRunAGameSubtitle,
              onPressed: () async {
                await createNewCampagne();
              },
            ),
            RolePathCard(
              key: SelectGameModeScreen.joinAGamePathKey,
              icon: FontAwesomeIcons.doorOpen,
              title: s.pathJoinAGameTitle,
              subtitle: s.pathJoinAGameSubtitle,
              onPressed: () async {
                await _joinCampagne();
              },
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> getOpenCampagnes() {
    return campagnes!.map((campagne) {
      final theme = CustomThemeProvider.of(context).theme;
      final openRequests = _openJoinRequestCounts[campagne.id?.value] ?? 0;
      final textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: theme.darkTextColor,
            fontSize: 14,
          );

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: CupertinoButton(
          onPressed: () async {
            await onCampagneSelected(campagne);
          },
          padding: EdgeInsets.zero,
          minimumSize: Size(0, 0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.darkColor),
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
                      color: theme.darkColor,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardTitle(text: campagne.campagneName ?? ""),
                        if (openRequests > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: StatusBadge(
                              key: ValueKey(
                                  "openJoinRequestsBadge-${campagne.id?.value}"),
                              icon: FontAwesomeIcons.userPlus,
                              text: S
                                  .of(context)
                                  .openJoinRequestsBadge(openRequests),
                              emphasized: true,
                            ),
                          ),
                        SizedBox(height: 8),
                        if (campagne.joinCode != null)
                          Text(
                            S
                                .of(context)
                                .joinCodeForNewPlayers(campagne.joinCode!),
                            style: textStyle,
                          ),
                        // B11: this is when the campagne config was saved last,
                        // not when the group last played or wrote notes.
                        if (campagne.lastModifiedAt != null)
                          Text(
                            S.of(context).campagneSettingsChangedAt(campagne
                                .lastModifiedAt!
                                .toLocal()
                                .format("%d.%m.%Y, %H:%M")),
                            style: textStyle.copyWith(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> getCharacters() {
    return characters!.map((character) {
      final theme = CustomThemeProvider.of(context).theme;
      final textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: theme.darkTextColor,
            fontSize: 14,
          );
      final isAssigned = character.campagneId?.value != null;
      final isPending = !isAssigned &&
          _pendingJoinRequests.containsKey(character.id?.value);

      var characterNameToDisplay = character.characterName ?? "";
      var imageUrl = "assets/images/charactercard_placeholder.png";
      if (character.rpgCharacterConfiguration != null) {
        var parsedConfig = RpgCharacterConfiguration.fromJson(
            jsonDecode(character.rpgCharacterConfiguration!));
        characterNameToDisplay = parsedConfig.characterName;
        imageUrl = parsedConfig.getImageUrlWithoutBasePath(null);
      }
      var fullImageUrl =
          (imageUrl.startsWith("assets") ? imageUrl : apiImageUrl(imageUrl));

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await onCharacterSelected(character);
          },
          minimumSize: Size(0, 0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: theme.darkColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: LayoutBuilder(builder: (context, constraints) {
                // SP-9: on phones the big image left too little room, and
                // names broke inside words ("Mira Do|rnwald").
                final compact = constraints.maxWidth < 420;
                final imageSize = compact ? 88.0 : 150.0;

                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (!compact)
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: CustomFaIcon(
                          icon: FontAwesomeIcons.solidUser,
                          size: 32,
                          color: theme.darkColor,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CardTitle(text: characterNameToDisplay),
                          SizedBox(height: 8),
                          if (isAssigned && character.lastModifiedAt != null)
                            Text(
                              S.of(context).characterLastEditedAt(character
                                  .lastModifiedAt!
                                  .toLocal()
                                  .format("%d.%m.%Y, %H:%M")),
                              style: textStyle,
                            )
                          else if (isPending)
                            StatusBadge(
                              key: ValueKey(
                                  "pendingJoinBadge-${character.id?.value}"),
                              icon: FontAwesomeIcons.hourglassHalf,
                              text: S.of(context).waitingForDmApproval,
                            )
                          else if (!isAssigned)
                            Text(
                              S.of(context).characterNotInCampagneHint,
                              style: textStyle,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: imageSize,
                      width: imageSize,
                      child: BorderedImage(
                        noPadding: true,
                        backgroundColor: theme.bgColor,
                        lightColor: theme.darkColor,
                        imageUrl: fullImageUrl,
                        isLoading: false,
                        isGreyscale: false,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      );
    }).toList();
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
      applyCampagneConfig: (config) => ref
          .read(rpgConfigurationProvider.notifier)
          .updateConfiguration(config),
      readCampagneConfig: () =>
          ref.read(rpgConfigurationProvider).value ??
          RpgConfigurationModel.getBaseConfiguration(),
      applyCharacterConfig: (config) => ref
          .read(rpgCharacterConfigurationProvider.notifier)
          .updateConfiguration(config),
      readCharacterConfig: () =>
          ref.read(rpgCharacterConfigurationProvider).value ??
          RpgCharacterConfiguration.getBaseConfiguration(
              ref.read(rpgConfigurationProvider).value),
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
    final connectionDetails = ref.read(connectionDetailsProvider).value;
    final connectedPlayers = connectionDetails?.connectedPlayers;
    if (connectionDetails == null || connectedPlayers == null) {
      return;
    }

    final updated = connectedPlayers
        .map((p) => p.playerCharacterId.value == characterId
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
    final connectionDetails = ref.read(connectionDetailsProvider).value;
    final connectedPlayers = connectionDetails?.connectedPlayers;
    if (connectionDetails == null || connectedPlayers == null) {
      return;
    }

    // Ignore presence for the campagne DM account: opening the table as DM
    // must not mark a DM-owned test character as "player online".
    final dmCampagne = (campagnes ?? const <Campagne>[])
        .where((c) => c.id?.value == connectionDetails.campagneId)
        .firstOrNull;
    final dmUserId = dmCampagne?.dmUserId?.value;
    if (dmUserId != null && userId == dmUserId) {
      return;
    }

    final known = connectedPlayers.any((p) => p.userId.value == userId);
    List<PlayerCharacter>? allCharacters;
    if (!known && online && connectionDetails.campagneId != null) {
      final rpgService =
          DependencyProvider.of(context).getService<IRpgEntityService>();
      final charsResponse = await rpgService.getPlayerCharactersForCampagne(
        campagneId: CampagneIdentifier(value: connectionDetails.campagneId!),
      );
      if (charsResponse.isSuccessful) {
        allCharacters = charsResponse.result;
      }
    }

    if (!mounted) return;

    final latest = ref.read(connectionDetailsProvider).value;
    if (latest?.connectedPlayers == null) {
      return;
    }

    final updated = applyParticipantPresence(
      connectedPlayers: latest!.connectedPlayers!,
      userId: userId,
      online: online,
      allCharacters: allCharacters,
      campagneConfig: ref.read(rpgConfigurationProvider).value,
    );

    ref
        .read(connectionDetailsProvider.notifier)
        .updateConfiguration(latest.copyWith(connectedPlayers: updated));
  }

  /// sse-06: builds a fresh [SessionCommandNotificationController] wired to
  /// this session's `/events` stream. Its callbacks re-serialize the parsed
  /// SSE payload and hand off to the [IServerMethodsService] fight/grant
  /// handlers (`playersAreAskedForRolls`, `dmReceivedFightSequenceAnswer`,
  /// `grantPlayerItems`) so the roll-modal and grant-toast UX is driven purely
  /// over SSE. Started/stopped per session-entry, like
  /// [_buildConfigSyncSessionController].
  SessionCommandNotificationController
      _buildSessionCommandNotificationController() {
    final eventsClient =
        DependencyProvider.of(context).getService<EventsClient>();
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
        // event.playerCharacterId is the character's server id - compare it
        // against the session's character id, not the config's local uuid.
        final ownCharacterId =
            ref.read(connectionDetailsProvider).value?.playerCharacterId;
        final currentCharacter =
            ref.read(rpgCharacterConfigurationProvider).value;
        if (currentCharacter == null ||
            ownCharacterId == null ||
            ownCharacterId != event.playerCharacterId) {
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
      onInitiativeRequested: serverMethodsService.initiativeRequested,
      onInitiativeSettled: serverMethodsService.initiativeSettled,
      onFightUpdated: serverMethodsService.fightUpdated,
      onFightEnded: serverMethodsService.fightEnded,
    );
  }

  /// Re-enters the table session whenever the SSE stream reconnects, then
  /// catches up on config changes and the fight missed while disconnected.
  SessionPresenceKeeper _buildSessionPresenceKeeper(
    IRpgEntityService rpgService,
    CampagneIdentifier campagneId,
    ConfigSyncSessionController configSyncSessionController, {
    Future<void> Function(List<String> onlineUserIds)? onPresenceSnapshot,
  }) {
    final serverMethodsService =
        DependencyProvider.of(context).getService<IServerMethodsService>();
    return SessionPresenceKeeper(
      eventsClient: DependencyProvider.of(context).getService<EventsClient>(),
      rpgEntityService: rpgService,
      campagneId: campagneId,
      onPresenceSnapshot: onPresenceSnapshot,
      onReentered: () async {
        await configSyncSessionController.catchUpAfterReconnect();
        await serverMethodsService.catchUpOnFight();
      },
    )..start();
  }

  /// While the stream was down the DM missed character and presence
  /// notifies, so HP values and online states would stay stale. Loads the
  /// roster again, the same way entering the table does.
  Future<void> _refreshDmRosterAfterReconnect(
    IRpgEntityService rpgService,
    CampagneIdentifier campagneId,
    String? dmUserId,
    List<String> onlineUserIds,
  ) async {
    final roster = await refreshDmRoster(
      rpgEntityService: rpgService,
      campagneId: campagneId,
      campagneConfig: ref.read(rpgConfigurationProvider).value,
      onlineUserIds: onlineUserIds,
      dmUserId: dmUserId,
    );
    if (roster == null || !mounted) return;
    final details = ref.read(connectionDetailsProvider).value;
    // The DM may have left the table while the request was running.
    if (details == null ||
        !details.isDm ||
        details.campagneId != campagneId.value) {
      return;
    }
    ref
        .read(connectionDetailsProvider.notifier)
        .updateConfiguration(details.copyWith(connectedPlayers: roster));
  }

  Future onCampagneSelected(Campagne campagne,
      {bool openSetupWizard = false}) async {
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
    var campagneSnapshotResponse =
        await rpgService.getCampagneRpgConfigSnapshot(
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
    final dmUserId = hydratedCampagne.dmUserId?.value;
    final onlinePlayerUserIds = hydrationResponse.result!.onlineUserIds
        .where((id) => dmUserId == null || id != dmUserId)
        .toList();

    var connectedPlayers = mapCharactersToOpenPlayerConnections(
      hydrationResponse.result!.allCharacters ?? const [],
      campagneConfig: campagneConfigModel,
      onlineUserIds: onlinePlayerUserIds,
    );

    ref.read(connectionDetailsProvider.notifier).updateConfiguration(
        (ref.read(connectionDetailsProvider).value ??
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
                              campagneJoinRequestId: j.request.id!.value!,
                              playerCharacterId: j.playerCharacter.id!.value!,
                              playerName: j.playerCharacter.characterName ??
                                  S.of(context).characterNameDefault,
                              username: j.username,
                            ))
                        .toList())
                    : List<PlayerJoinRequests>.empty(),
                campagneId: campagne.id!.value!,
                sessionConnectionNumberForPlayers: campagne.joinCode));

    // sse-06: session-scoped fight/roll and item-grant SSE notifies.
    var sessionCommandController = _buildSessionCommandNotificationController();
    sessionCommandController.start();
    var sessionPresenceKeeper = _buildSessionPresenceKeeper(
      rpgService,
      campagne.id!,
      configSyncSessionController,
      onPresenceSnapshot: (onlineUserIds) => _refreshDmRosterAfterReconnect(
          rpgService, campagne.id!, dmUserId, onlineUserIds),
    );

    if (!mounted || !context.mounted) return;

    // sse-08: config edits now persist via REST/ConfigSync (no SignalR hub).
    final com =
        DependencyProvider.of(context).getService<IServerMethodsService>();
    com.activeConfigSyncSessionController = configSyncSessionController;
    await com.registerGame(campagneId: campagne.id!.value!);
    if (!mounted) return;

    // navigate to main game screen (auth screen wrapper)
    navigatorKey.currentState!.pushNamed(DmPageScreen.route).then((asdf) async {
      // when returning to this screen we tear down the session's SSE + config
      // sync so the user is "disconnected" from live table updates.
      com.activeConfigSyncSessionController = null;
      await configSyncSessionController.stop();
      await sessionCommandController.stop();
      await sessionPresenceKeeper.stop();
      await sessionEntryCoordinator.leave(campagneId: campagne.id!);
      ref.read(currentFightProvider.notifier).state = null;

      await loadCampagnesAndPlayersFromServer();
    });

    if (openSetupWizard) {
      // SL-4: the same assistant the gear icon on the DM page opens; closing
      // it lands on the DM page.
      unawaited(navigatorKey.currentState!
          .pushNamed(allWizardConfigurations.entries.first.key));
    }

    // A fight stored on the server goes on where the DM left it.
    unawaited(com.catchUpOnFight());
  }

  Future onCharacterSelected(PlayerCharacter character) async {
    setState(() {
      showLoadingSpinner = true;
    });

    if (character.campagneId != null && character.campagneId!.value != null) {
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

      Map<String, dynamic> map =
          jsonDecode(hydrationResponse.result!.campagne.rpgConfiguration!);

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
          (ref.read(connectionDetailsProvider).value ??
                  ConnectionDetails.defaultValue())
              .copyWith(
                  isDm: false,
                  lastPing: null,
                  connectedPlayers: null,
                  fightSequence: null,
                  lastGrantedItems: null,
                  openPlayerRequests: null,
                  campagneId: character.campagneId?.value,
                  playerCharacterId: character.id!.value!));

      // sse-04: start listening for campagneConfigChanged / characterConfigChanged
      // SSE notifies so this client catches up on config edits made by other
      // session participants (e.g. the DM).
      var configSyncSessionController =
          _buildConfigSyncSessionController(rpgService);
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
      var sessionCommandController =
          _buildSessionCommandNotificationController();
      sessionCommandController.start();
      var sessionPresenceKeeper = _buildSessionPresenceKeeper(
          rpgService, character.campagneId!, configSyncSessionController);

      if (!mounted) return;

      // sse-08: character edits now persist via REST/ConfigSync (no SignalR hub).
      final com =
          DependencyProvider.of(context).getService<IServerMethodsService>();
      com.activeConfigSyncSessionController = configSyncSessionController;
      await com.joinGameSession(playerCharacterId: character.id!.value!);

      // navigate to main game screen (auth screen wrapper)
      navigatorKey.currentState!
          .pushNamed(PlayerPageScreen.route)
          .then((asdf) async {
        // when returning to this screen we tear down the session's SSE + config
        // sync so the user is "disconnected" from live table updates.
        com.activeConfigSyncSessionController = null;
        await configSyncSessionController.stop();
        await sessionCommandController.stop();
        await sessionPresenceKeeper.stop();
        await sessionEntryCoordinator.leave(campagneId: character.campagneId!);

        await loadCampagnesAndPlayersFromServer();
      });

      // Asks for the rolls of a fight the DM started while this player was away.
      unawaited(com.catchUpOnFight());
    } else {
      setState(() {
        showLoadingSpinner = false;
      });

      // SP-1: a request is already with the DM - tapping again explains the
      // wait instead of opening the join dialog once more.
      if (_pendingJoinRequests.containsKey(character.id?.value)) {
        await _showWaitingForApproval(character);
        return;
      }

      await _joinCampagne(existingCharacter: character);
    }
  }

  /// "Kampagne beitreten": join code (and, without [existingCharacter], the
  /// name of a new character), then the request goes to the DM and the
  /// character shows "waiting for approval" until the DM answers.
  Future<void> _joinCampagne({PlayerCharacter? existingCharacter}) async {
    final result = await askForCampagneJoinCode(
      context,
      existingCharacterId: existingCharacter?.id,
    );
    if (!mounted) return;

    if (result == null) {
      // The dialog may have created the character before the player gave up
      // (e.g. after a wrong code); show it so it can join later.
      if (existingCharacter == null) {
        await loadCampagnesAndPlayersFromServer();
      }
      return;
    }

    final pending = PendingJoinRequest(
      playerCharacterId: result.playerCharacterId.value!,
      campagneJoinRequestId: result.campagneJoinRequestId,
      joinCode: result.joinCode,
      requestedAt: DateTime.now(),
    );
    await ref.read(pendingJoinRequestStoreProvider).save(pending);
    if (!mounted) return;
    setState(() {
      _pendingJoinRequests[pending.playerCharacterId] = pending;
    });

    DependencyProvider.of(context).getService<ISnackBarService>().showSnackBar(
          snack: SnackBar(
            content: Text(S.of(context).joinRequestSentConfirmation),
            duration: Duration(seconds: 8),
            showCloseIcon: true,
          ),
          uniqueId: "joinRequestWasSent-${pending.playerCharacterId}",
        );

    await loadCampagnesAndPlayersFromServer();
    if (!mounted) return;

    // Refresh SSE right before waiting: idle connections often look connected
    // locally but are already gone on the server (resolve notify then no-ops).
    final eventsClient =
        DependencyProvider.of(context).getService<EventsClient>();
    await eventsClient.forceReconnect();
    if (!mounted) return;
    _joinRequestController?.start();

    // Prefer SSE joinRequestResolved; also poll REST in case the proxy
    // dropped the player's /events stream (seen against Cloudflare prod).
    unawaited(_pollForJoinAcceptance(playerCharacterId: result.playerCharacterId));
  }

  Future<void> _showWaitingForApproval(PlayerCharacter character) async {
    final s = S.of(context);
    var name = character.characterName ?? "";
    if (character.rpgCharacterConfiguration != null) {
      name = RpgCharacterConfiguration.fromJson(
              jsonDecode(character.rpgCharacterConfiguration!))
          .characterName;
    }

    final enterCodeAgain = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppStyleDialog(
        title: s.waitingForApprovalTitle,
        onClose: () => Navigator.of(dialogContext).pop(false),
        actions: [
          // Way out when the DM declined while the app was closed: the API
          // cannot tell this device, so the wait would never end otherwise.
          CustomButton(
            label: s.enterCodeAgainAction,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
          CustomButton(
            variant: CustomButtonVariant.AccentButton,
            label: s.ok,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
        ],
        child: Text(
          s.waitingForApprovalText(name),
          style: appModalBodyStyle(dialogContext),
        ),
      ),
    );
    if (!mounted || enterCodeAgain != true) return;

    await _joinCampagne(existingCharacter: character);
  }

  Future createNewCampagne() async {
    var service =
        DependencyProvider.of(context).getService<IRpgEntityService>();
    var result = await askForNewCampagneName(context);
    if (result == null || !mounted) return;

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

    // SL-4: a new campagne goes straight into the setup assistant.
    await onCampagneSelected(
        campagnes!
            .singleWhere((e) => e.id!.value! == createResponse.result!.value!),
        openSetupWizard: true);
  }
}

/// Section header of the role selection: title, two lines of context and an
/// optional labelled action button below.
class AddableColumnHeader extends StatelessWidget {
  const AddableColumnHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.subsubtitle,
    required this.onPressedHandler,
    this.actionLabel,
  });

  final String title;
  final String subtitle;
  final String subsubtitle;
  final VoidCallback onPressedHandler;

  /// Hides the action button when `null` (the empty list shows its own
  /// call to action then).
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    return Column(
      children: [
        Text(
          title,
          softWrap: true,
          maxLines: 3,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: theme.darkTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: theme.darkTextColor),
        ),
        Text(
          subsubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: theme.darkTextColor),
        ),
        if (actionLabel != null) ...[
          SizedBox(height: 10),
          CustomButton(
            onPressed: onPressedHandler,
            icon: CustomFaIcon(
              size: 16,
              icon: FontAwesomeIcons.plus,
              color: theme.darkColor,
            ),
            label: actionLabel,
          ),
        ],
      ],
    );
  }
}

/// One of the two big ways in at the top of the role selection.
class RolePathCard extends StatelessWidget {
  const RolePathCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final FaIconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final availableWidth = MediaQuery.sizeOf(context).width - 40;

    return SizedBox(
      width: availableWidth < 400 ? availableWidth : 400,
      child: CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.accentColor, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CustomFaIcon(icon: icon, size: 32, color: theme.accentColor),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: theme.darkTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: theme.darkTextColor,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),
              CustomFaIcon(
                icon: FontAwesomeIcons.chevronRight,
                size: 16,
                color: theme.darkColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown instead of an empty list: what to do, and a labelled button for it.
class EmptyListCallToAction extends StatelessWidget {
  const EmptyListCallToAction({
    super.key,
    required this.text,
    required this.actionLabel,
    required this.onPressed,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: theme.darkTextColor,
                  fontSize: 16,
                ),
          ),
          SizedBox(height: 15),
          CustomButton(
            variant: CustomButtonVariant.AccentButton,
            onPressed: onPressed,
            icon: CustomFaIcon(
              size: 16,
              icon: FontAwesomeIcons.plus,
              color: isNightCartographerActive(context)
                  ? theme.bgColor
                  : theme.textColor,
            ),
            label: actionLabel,
          ),
        ],
      ),
    );
  }
}

/// Small pill on a card, e.g. "2 offene Anfragen" or the pending join state.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  final FaIconData icon;
  final String text;

  /// Accent fill for things that want attention (open join requests).
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeProvider.of(context).theme;
    final foreground = emphasized
        ? (isNightCartographerActive(context) ? theme.bgColor : theme.textColor)
        : theme.darkTextColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: emphasized ? theme.accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: emphasized ? theme.accentColor : theme.darkColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomFaIcon(icon: icon, size: 12, color: foreground),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card title that shrinks instead of breaking inside a word (SP-9).
class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      maxLines: 2,
      minFontSize: 14,
      wrapWords: false,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: CustomThemeProvider.of(context).theme.darkTextColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
