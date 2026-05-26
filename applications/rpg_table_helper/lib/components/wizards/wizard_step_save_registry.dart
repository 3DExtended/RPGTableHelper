/// Lets [WizardManager] persist the active step before swapping steps via sidebar or Next.
typedef WizardStepSaveCallback = void Function();

WizardStepSaveCallback? _activeWizardStepSave;

void registerWizardStepSave(WizardStepSaveCallback? save) {
  _activeWizardStepSave = save;
}

/// Call synchronously before changing wizard step index.
void flushActiveWizardStepSave() {
  _activeWizardStepSave?.call();
}
