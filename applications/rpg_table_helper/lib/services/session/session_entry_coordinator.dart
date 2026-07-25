import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';

/// Result of REST hydration performed right after a table `SessionEnter`.
///
/// [allCharacters] is populated for the DM path, [ownCharacter] for the
/// player path — the other is left `null`.
///
/// [onlineUserIds] is the presence snapshot from `POST /Session/enter`
/// (including the caller).
class SessionHydrationResult {
  const SessionHydrationResult({
    required this.campagne,
    this.allCharacters,
    this.ownCharacter,
    this.onlineUserIds = const [],
  });

  final Campagne campagne;
  final List<PlayerCharacter>? allCharacters;
  final PlayerCharacter? ownCharacter;
  final List<String> onlineUserIds;
}

/// Coordinates table session presence (`SessionEnter`/leave) with the REST
/// hydration pull that must follow a successful enter: DM gets the campagne
/// config plus every character in the campagne, a player gets the campagne
/// config plus their own character.
abstract class ISessionEntryCoordinator {
  const ISessionEntryCoordinator();

  Future<HRResponse<SessionHydrationResult>> enterAsDm({
    required CampagneIdentifier campagneId,
  });

  Future<HRResponse<SessionHydrationResult>> enterAsPlayer({
    required CampagneIdentifier campagneId,
    required PlayerCharacterIdentifier playerCharacterId,
  });

  Future<void> leave({required CampagneIdentifier campagneId});
}

class SessionEntryCoordinator extends ISessionEntryCoordinator {
  const SessionEntryCoordinator({required this.rpgEntityService});

  final IRpgEntityService rpgEntityService;

  @override
  Future<HRResponse<SessionHydrationResult>> enterAsDm({
    required CampagneIdentifier campagneId,
  }) async {
    final enterResult =
        await rpgEntityService.enterSession(campagneId: campagneId);
    if (!enterResult.isSuccessful) {
      return _propagateError(enterResult);
    }

    final campagneResult =
        await rpgEntityService.getCampagneById(campagneId: campagneId);
    if (!campagneResult.isSuccessful) {
      return _propagateError(campagneResult);
    }

    final charactersResult = await rpgEntityService
        .getPlayerCharactersForCampagne(campagneId: campagneId);

    return HRResponse.fromResult(
      SessionHydrationResult(
        campagne: campagneResult.result!,
        allCharacters: charactersResult.result ?? const [],
        onlineUserIds: enterResult.result ?? const [],
      ),
    );
  }

  @override
  Future<HRResponse<SessionHydrationResult>> enterAsPlayer({
    required CampagneIdentifier campagneId,
    required PlayerCharacterIdentifier playerCharacterId,
  }) async {
    final enterResult =
        await rpgEntityService.enterSession(campagneId: campagneId);
    if (!enterResult.isSuccessful) {
      return _propagateError(enterResult);
    }

    final campagneResult =
        await rpgEntityService.getCampagneById(campagneId: campagneId);
    if (!campagneResult.isSuccessful) {
      return _propagateError(campagneResult);
    }

    final characterResult = await rpgEntityService.getPlayerCharacterById(
      playerCharacterId: playerCharacterId,
    );

    return HRResponse.fromResult(
      SessionHydrationResult(
        campagne: campagneResult.result!,
        ownCharacter: characterResult.result,
        onlineUserIds: enterResult.result ?? const [],
      ),
    );
  }

  @override
  Future<void> leave({required CampagneIdentifier campagneId}) async {
    await rpgEntityService.leaveSession(campagneId: campagneId);
  }

  HRResponse<SessionHydrationResult> _propagateError(HRResponseBase source) {
    return HRResponse.error(
      source.humanReadableError ?? 'Could not enter session.',
      source.errorCode ?? 'unknown-session-enter-error',
      errorFromServer: source.errorFromServer,
      statusCode: source.statusCode,
    );
  }
}
