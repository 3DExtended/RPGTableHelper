/// Lets [WizardManager] persist the active step before swapping steps via sidebar or Next.
typedef WizardStepSaveCallback = void Function();

WizardStepSaveCallback? _activeWizardStepSave;

void registerWizardStepSave(WizardStepSaveCallback? save) {
  _activeWizardStepSave = save;
}

/// Clears [save] if it is still the active callback.
///
/// Call from a step's dispose. On a step change the next step registers
/// before the previous one is disposed, so a plain `registerWizardStepSave(null)`
/// would drop the new step's callback.
void unregisterWizardStepSave(WizardStepSaveCallback save) {
  if (_activeWizardStepSave == save) {
    _activeWizardStepSave = null;
  }
}

/// Call synchronously before changing wizard step index.
void flushActiveWizardStepSave() {
  _activeWizardStepSave?.call();
}
