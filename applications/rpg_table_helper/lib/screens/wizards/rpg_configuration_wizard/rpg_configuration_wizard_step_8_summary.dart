import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quest_keeper/components/wizards/two_part_wizard_step_body.dart';
import 'package:quest_keeper/components/wizards/wizard_step_base.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/rpg_configuration_provider.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// "1 Gold = 10 Silber = 100 Kupfer", largest currency first. Empty when no
/// currency is defined.
String formatCurrencySummary(CurrencyDefinition definition) {
  final types = definition.currencyTypes;
  if (types.isEmpty) {
    return "";
  }

  final numberFormat = NumberFormat('#,###');
  final parts = <String>[];
  var amount = 1;
  for (var i = types.length - 1; i >= 0; i--) {
    parts.add("${numberFormat.format(amount)} ${types[i].name}");
    amount *= types[i].multipleOfPreviousValue ?? 1;
  }
  if (parts.length == 1) {
    return types.single.name;
  }
  return parts.join(" = ");
}

/// Last wizard step: shows what is set up and closes the wizard with "Done".
class RpgConfigurationWizardStep8Summary extends WizardStepBase {
  const RpgConfigurationWizardStep8Summary({
    required super.onPreviousBtnPressed,
    required super.onNextBtnPressed,
    required super.setWizardTitle,
    super.key,
  });

  @override
  ConsumerState<RpgConfigurationWizardStep8Summary> createState() =>
      _RpgConfigurationWizardStep8SummaryState();
}

class _RpgConfigurationWizardStep8SummaryState
    extends ConsumerState<RpgConfigurationWizardStep8Summary> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.setWizardTitle(S.of(context).wizardSummaryStepTitle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(rpgConfigurationProvider).value;
    final s = S.of(context);

    final rows = <(String, String)>[];
    if (config != null) {
      final tabs = config.characterStatTabsDefinition ?? const [];
      final statCount = tabs.fold<int>(
        0,
        (sum, tab) => sum + tab.statsInTab.length,
      );
      final currency = formatCurrencySummary(config.currencyDefinition);

      rows.addAll([
        (
          s.wizardSummaryCampaignLabel,
          config.rpgName.trim().isEmpty
              ? s.wizardSummaryNotSet
              : config.rpgName,
        ),
        (
          s.wizardCharacterSheetStepTitle,
          "${s.wizardSummaryTabCount(tabs.length)}, ${s.wizardSummaryPropertyCount(statCount)}",
        ),
        (
          s.wizardCurrencyStepTitle,
          currency.isEmpty ? s.wizardSummaryNotSet : currency,
        ),
        (
          s.wizardItemsStepTitle,
          s.wizardSummaryItemCount(config.allItems.length),
        ),
        (
          s.wizardRecipesStepTitle,
          s.wizardSummaryRecipeCount(config.craftingRecipes.length),
        ),
      ]);
    }

    final textColor = CustomThemeProvider.of(context).theme.darkTextColor;

    return TwoPartWizardStepBody(
      isLandscapeMode:
          MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height,
      stepHelperText: s.wizardSummaryStepHelper,
      onPreviousBtnPressed: widget.onPreviousBtnPressed,
      onNextBtnPressed: widget.onNextBtnPressed,
      sideBarFlex: 1,
      contentFlex: 2,
      contentChildren: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.$1,
                    style: Theme.of(context).textTheme.labelLarge!
                        .copyWith(color: textColor.withValues(alpha: 0.75)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    row.$2,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
