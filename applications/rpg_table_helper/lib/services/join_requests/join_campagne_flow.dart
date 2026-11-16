import 'dart:convert';

import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/humanreadable_response.dart';
import 'package:quest_keeper/models/rpg_character_configuration.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:uuid/v7.dart';

/// Character config for a character that does not belong to a campagne yet.
///
/// It has no stats: once the DM accepts the join request, the player page
/// asks for every stat the campagne's sheet requires.
String buildInitialCharacterConfigJson(String characterName) {
  return jsonEncode(
    RpgCharacterConfiguration.getBaseConfiguration(null).copyWith(
      characterName: characterName,
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
  );
}

/// True for the 400 the backend sends when no campagne has the join code.
bool isUnknownJoinCodeResponse(HRResponseBase response) {
  if (response.isSuccessful || response.statusCode != 400) return false;
  final body = (response.errorFromServer ?? '').toLowerCase();
  return body.contains('could not find campagne for join code');
}

sealed class JoinCampagneOutcome {
  const JoinCampagneOutcome({required this.playerCharacterId});

  /// The character the request was (or would have been) sent for. Set as
  /// soon as a new character exists, so a retry reuses it instead of
  /// creating a second one.
  final PlayerCharacterIdentifier? playerCharacterId;
}

class JoinCampagneRequested extends JoinCampagneOutcome {
  const JoinCampagneRequested({
    required PlayerCharacterIdentifier super.playerCharacterId,
    required this.campagneJoinRequestId,
  });

  final String? campagneJoinRequestId;
}

/// No campagne has this join code. Shown inline, not as an error dialog.
class JoinCampagneUnknownCode extends JoinCampagneOutcome {
  const JoinCampagneUnknownCode({required super.playerCharacterId});
}

/// Any other failure; [response] goes to the generic error dialog.
class JoinCampagneFailed extends JoinCampagneOutcome {
  const JoinCampagneFailed({
    required super.playerCharacterId,
    required this.response,
  });

  final HRResponseBase response;
}

/// Sends a join request for [joinCode].
///
/// The API only accepts join requests for an existing character, so without
/// [playerCharacterId] a new character named [newCharacterName] is created
/// first. The backend checks the character before the code, which means a
/// wrong code can only be detected after the character exists.
Future<JoinCampagneOutcome> requestToJoinCampagne({
  required IRpgEntityService service,
  required String joinCode,
  PlayerCharacterIdentifier? playerCharacterId,
  String? newCharacterName,
}) async {
  var characterId = playerCharacterId;
  if (characterId == null) {
    final name = (newCharacterName ?? '').trim();
    final createResponse = await service.createNewCharacter(
      characterName: name,
      characterConfigJson: buildInitialCharacterConfigJson(name),
    );
    if (!createResponse.isSuccessful || createResponse.result?.value == null) {
      return JoinCampagneFailed(
        playerCharacterId: null,
        response: createResponse,
      );
    }
    characterId = createResponse.result!;
  }

  final requestResponse = await service.createNewCampagneJoinRequest(
    joinCode: joinCode,
    playerCharacterId: characterId,
  );

  if (requestResponse.isSuccessful) {
    return JoinCampagneRequested(
      playerCharacterId: characterId,
      campagneJoinRequestId: requestResponse.result?.value,
    );
  }
  if (isUnknownJoinCodeResponse(requestResponse)) {
    return JoinCampagneUnknownCode(playerCharacterId: characterId);
  }
  return JoinCampagneFailed(
    playerCharacterId: characterId,
    response: requestResponse,
  );
}
