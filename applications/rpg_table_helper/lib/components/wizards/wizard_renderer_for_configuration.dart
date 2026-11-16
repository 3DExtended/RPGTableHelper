import 'package:flutter/material.dart';
import 'package:quest_keeper/components/wizards/wizard_manager.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class WizardConfiguration {
  final List<WizardStepDefinition> steps;

  WizardConfiguration({required this.steps});

  List<WizardStepBuilder> get stepBuilders =>
      steps.map((s) => s.builder).toList();
}

class WizardRendererForConfiguration extends StatelessWidget {
  final WizardConfiguration configuration;
  final int? startStepIndex;
  const WizardRendererForConfiguration({
    super.key,
    required this.configuration,
    this.startStepIndex,
  });

  @override
  Widget build(BuildContext context) {
    final decorated = isDecoratedSheetSkinActive(context);
    // Match DM/player shells: leather under chrome; classic solid surface otherwise.
    final scaffoldBg = decorated
        ? CustomThemeProvider.of(context).theme.secondaryNavbarColor
        : CustomThemeProvider.of(context).theme.bgColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      resizeToAvoidBottomInset: true,
      body: WizardManager(
        startStepIndex: startStepIndex,
        steps: configuration.steps,
        onFinish: () {
          // Everything is already saved step by step; confirm it once the
          // wizard is done.
          final messenger = ScaffoldMessenger.maybeOf(context);
          final message = S.of(context).wizardSavedSnackbar;
          Navigator.of(context).pop();
          messenger?.hideCurrentSnackBar();
          messenger?.showSnackBar(SnackBar(content: Text(message)));
        },
      ),
    );
  }
}
