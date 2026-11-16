import 'package:flutter/material.dart';
import 'package:quest_keeper/components/wizards/wizard_manager.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin_chrome.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

class WizardConfiguration {
  /// Every step, including those only shown for a new campaign.
  final List<WizardStepDefinition> steps;

  WizardConfiguration({required this.steps});

  /// The steps the wizard shows: all of them while a new campaign is set
  /// up, without the [WizardStepDefinition.onlyForNewSetup] ones otherwise.
  List<WizardStepDefinition> stepsFor({required bool isNewSetup}) => isNewSetup
      ? steps
      : steps.where((s) => !s.onlyForNewSetup).toList();

  /// Builders of the steps shown when the wizard edits a campaign.
  List<WizardStepBuilder> get stepBuilders =>
      stepsFor(isNewSetup: false).map((s) => s.builder).toList();
}

/// Arguments of a wizard route. Without them the wizard opens to edit the
/// campaign (gear icon on the DM page).
class WizardRouteArguments {
  /// The wizard opens right after creating a campaign and also shows the
  /// steps only a new campaign gets (the template choice).
  final bool isNewSetup;

  const WizardRouteArguments({this.isNewSetup = false});

  /// [arguments] of a route, or the defaults when they are something else.
  static WizardRouteArguments of(Object? arguments) =>
      arguments is WizardRouteArguments
          ? arguments
          : const WizardRouteArguments();
}

class WizardRendererForConfiguration extends StatelessWidget {
  final WizardConfiguration configuration;
  final int? startStepIndex;

  /// See [WizardRouteArguments.isNewSetup].
  final bool isNewSetup;

  const WizardRendererForConfiguration({
    super.key,
    required this.configuration,
    this.startStepIndex,
    this.isNewSetup = false,
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
        steps: configuration.stepsFor(isNewSetup: isNewSetup),
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
