import 'package:quest_keeper/generated/swaggen/swagger.models.swagger.dart';
import 'package:quest_keeper/models/connection_details.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/rpg_entity_service.dart';
import 'package:quest_keeper/services/session/connected_players_mapper.dart';

/// Rebuilds the DM's roster after their `/events` stream reconnected.
///
/// `characterConfigChanged` and `participantOnline` / `participantOffline`
/// notifies sent while the DM was offline are lost. Without this the cards
/// keep stale HP and every player looks offline until the DM re-enters the
/// campagne.
///
/// [onlineUserIds] is the presence snapshot of the re-enter
/// (`POST /Session/enter`). The DM's own account never counts as an online
/// player. Returns `null` when the characters could not be loaded, so the
/// caller keeps the roster it has.
Future<List<OpenPlayerConnection>?> refreshDmRoster({
  required IRpgEntityService rpgEntityService,
  required CampagneIdentifier campagneId,
  required RpgConfigurationModel? campagneConfig,
  required Iterable<String> onlineUserIds,
  String? dmUserId,
}) async {
  final characters = await rpgEntityService.getPlayerCharactersForCampagne(
    campagneId: campagneId,
  );
  if (!characters.isSuccessful || characters.result == null) {
    return null;
  }
  return mapCharactersToOpenPlayerConnections(
    characters.result!,
    campagneConfig: campagneConfig,
    onlineUserIds: onlineUserIds.where((id) => id != dmUserId),
  );
}
