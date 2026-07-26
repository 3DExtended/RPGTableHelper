import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

/// Ephemeral Fight/Initiative wizard selection that survives step dispose
/// (Back → Character Stats → return) without being persisted as a completed
/// campaign setting.
class InitiativeBonusWizardDraft {
  final String? selectedStatUuid;
  final String? selectedListEntryUuid;
  final InitiativeBonusField? selectedField;

  const InitiativeBonusWizardDraft({
    required this.selectedStatUuid,
    required this.selectedListEntryUuid,
    required this.selectedField,
  });
}

final initiativeBonusWizardDraftProvider =
    StateProvider<InitiativeBonusWizardDraft?>((ref) => null);
