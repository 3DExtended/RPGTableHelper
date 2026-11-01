import 'package:flutter_riverpod/legacy.dart';
import 'package:quest_keeper/models/fight_state.dart';

/// The open fight as the DM sees it on the server, or null when there is none
/// or the backend does not keep fights. The order the DM screens render stays
/// in `ConnectionDetails.fightSequence`, which is derived from this fight.
final currentFightProvider = StateProvider<FightState?>((ref) => null);
