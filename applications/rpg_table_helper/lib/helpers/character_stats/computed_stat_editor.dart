import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quest_keeper/components/custom_button.dart';
import 'package:quest_keeper/components/custom_dropdown_menu.dart';
import 'package:quest_keeper/components/custom_fa_icon.dart';
import 'package:quest_keeper/components/custom_text_field.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/stat_number_labels.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';
import 'package:quest_keeper/models/computed_stat_formula.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';
import 'package:quest_keeper/services/custom_theme_provider.dart';

/// An option of a multiselect stat a building block can depend on.
typedef ComputedConditionOption = ({
  ComputedTermCondition condition,
  String label,
});

/// Every option of every multiselect stat in [stats].
List<ComputedConditionOption> computedConditionOptions(
  List<StatWithTab> stats,
) {
  var result = <ComputedConditionOption>[];
  for (var (tabName: _, :stat) in stats) {
    if (stat.valueType != CharacterStatValueType.multiselect) continue;
    List<dynamic> options = [];
    try {
      var decoded = jsonDecode(stat.jsonSerializedAdditionalData ?? "{}");
      // Legacy: a bare list of options.
      options = decoded is List
          ? decoded
          : ((decoded as Map<String, dynamic>)["options"] as List? ?? []);
    } catch (_) {
      continue;
    }
    for (var option in options.whereType<Map<String, dynamic>>()) {
      var uuid = option["uuid"]?.toString();
      if (uuid == null) continue;
      result.add((
        condition: ComputedTermCondition(
          statUuid: stat.statUuid,
          optionUuid: uuid,
        ),
        label: "${stat.name}: ${option["label"] ?? ""}",
      ));
    }
  }
  return result;
}

/// Human-readable form of [formula], e.g.
/// "10 + Mod(Weisheit) + ÜB (wenn Fertigkeiten: Wahrnehmung)".
String describeComputedFormula(
  ComputedStatFormula formula, {
  required List<StatWithTab> stats,
  required StatNumberLabels labels,
  required String Function(String label) modifierLabel,
  required String Function(String condition) conditionLabel,
}) {
  var defs = stats.map((s) => s.stat).toList();
  var conditions = computedConditionOptions(stats);
  var result = "${formula.base}";
  for (var term in formula.terms) {
    var label = StatNumbers.labelFor(defs, term.source, labels) ?? "?";
    if (term.mode == ComputedTermMode.modifier) label = modifierLabel(label);
    var factor = term.factor.abs();
    var part = factor == 1 ? label : "$factor × $label";
    if (term.condition != null) {
      var condition = conditions
          .where((c) => c.condition == term.condition)
          .firstOrNull
          ?.label;
      part = "$part ${conditionLabel(condition ?? "?")}";
    }
    result += term.factor < 0 ? " − $part" : " + $part";
  }
  return result;
}

/// Builds a [ComputedStatFormula] from a start value and building blocks.
class ComputedStatEditor extends StatefulWidget {
  const ComputedStatEditor({
    super.key,
    required this.initialFormula,
    required this.availableStats,
    required this.ownStatUuid,
    required this.onChanged,
  });

  final ComputedStatFormula initialFormula;

  /// The campaign's stats the formula may use.
  final List<StatWithTab> availableStats;

  /// The stat being edited; left out of the sources.
  final String? ownStatUuid;

  final void Function(ComputedStatFormula formula) onChanged;

  /// Factors a building block can have.
  static const factors = [1, -1, 2, -2, 3, -3];

  @override
  State<ComputedStatEditor> createState() => _ComputedStatEditorState();
}

class _ComputedStatEditorState extends State<ComputedStatEditor> {
  late ComputedStatFormula formula = widget.initialFormula;
  late final TextEditingController baseController = TextEditingController(
    text: widget.initialFormula.base.toString(),
  );

  @override
  void initState() {
    super.initState();
    baseController.addListener(() {
      var parsed = int.tryParse(baseController.text.trim()) ?? 0;
      if (parsed != formula.base) _update(formula.copyWith(base: parsed));
    });
  }

  @override
  void dispose() {
    baseController.dispose();
    super.dispose();
  }

  void _update(ComputedStatFormula updated) {
    setState(() => formula = updated);
    widget.onChanged(updated);
  }

  void _updateTerm(int index, ComputedStatTerm term) {
    var terms = [...formula.terms];
    terms[index] = term;
    _update(formula.copyWith(terms: terms));
  }

  @override
  Widget build(BuildContext context) {
    var theme = CustomThemeProvider.of(context).theme;
    var labels = statNumberLabelsOf(context);
    var textStyle = Theme.of(context).textTheme.bodyMedium!
        .copyWith(color: theme.darkTextColor);
    var sources = StatNumbers.options(
      widget.availableStats,
      labels,
      includeMaxAndLevel: true,
      excludeStatUuid: widget.ownStatUuid,
    );
    var conditions = computedConditionOptions(widget.availableStats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(S.of(context).computedValueHint, style: textStyle),
        const SizedBox(height: 12),
        CustomTextField(
          key: const ValueKey("computedBase"),
          labelText: S.of(context).computedBase,
          textEditingController: baseController,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).computedTerms,
          style: textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        if (sources.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(S.of(context).computedValueNoSources, style: textStyle),
          ),
        for (var i = 0; i < formula.terms.length; i++)
          _buildTerm(context, i, formula.terms[i], sources, conditions),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: CustomButton(
            key: const ValueKey("computedAddTerm"),
            isSubbutton: true,
            label: S.of(context).addComputedTerm,
            onPressed: sources.isEmpty
                ? null
                : () => _update(
                    formula.copyWith(
                      terms: [
                        ...formula.terms,
                        ComputedStatTerm(source: sources.first.ref),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "${S.of(context).computedPreview}: ${describeComputedFormula(formula, stats: widget.availableStats, labels: labels, modifierLabel: (l) => S.of(context).computedModifierOf(l), conditionLabel: (c) => S.of(context).computedIfPicked(c))}",
          key: const ValueKey("computedPreview"),
          style: textStyle.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildTerm(
    BuildContext context,
    int index,
    ComputedStatTerm term,
    List<StatNumberOption> sources,
    List<ComputedConditionOption> conditions,
  ) {
    var theme = CustomThemeProvider.of(context).theme;
    // Keys carry the value: dropdowns only read their initial value.
    var keyBase = "computedTerm$index";
    var sourceKnown = sources.any((o) => o.ref == term.source);
    var conditionKnown =
        term.condition == null ||
        conditions.any((c) => c.condition == term.condition);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: theme.darkColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomDropdownMenu(
                  isExpanded: true,
                  key: ValueKey("$keyBase-source-${term.source.key}"),
                  label: S.of(context).computedSource,
                  selectedValueTemp: sourceKnown ? term.source.key : null,
                  setter: (key) {
                    var ref = key == null ? null : StatNumberRef.fromKey(key);
                    if (ref == null) return;
                    _updateTerm(index, term.copyWith(source: ref));
                  },
                  items: sources
                      .map(
                        (o) => DropdownMenuItem<String?>(
                          value: o.ref.key,
                          child: Text(
                            o.label == o.groupLabel || o.label.isEmpty
                                ? o.groupLabel
                                : "${o.label} · ${o.groupLabel}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              CustomButton(
                key: ValueKey("$keyBase-delete"),
                variant: CustomButtonVariant.FlatButton,
                isSubbutton: true,
                onPressed: () {
                  var terms = [...formula.terms]..removeAt(index);
                  _update(formula.copyWith(terms: terms));
                },
                icon: CustomFaIcon(
                  size: 16,
                  color: theme.darkColor,
                  icon: FontAwesomeIcons.trashCan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomDropdownMenu(
                isExpanded: true,
                key: ValueKey("$keyBase-mode-${term.mode.name}"),
                label: S.of(context).computedMode,
                selectedValueTemp: term.mode.name,
                setter: (name) {
                  var mode = ComputedTermMode.values
                      .where((m) => m.name == name)
                      .firstOrNull;
                  if (mode == null) return;
                  _updateTerm(index, term.copyWith(mode: mode));
                },
                items: [
                  DropdownMenuItem<String?>(
                    value: ComputedTermMode.value.name,
                    child: Text(S.of(context).computedModeValue),
                  ),
                  DropdownMenuItem<String?>(
                    value: ComputedTermMode.modifier.name,
                    child: Text(S.of(context).computedModeModifier),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomDropdownMenu(
                isExpanded: true,
                key: ValueKey("$keyBase-factor-${term.factor}"),
                label: S.of(context).computedFactor,
                selectedValueTemp:
                    ComputedStatEditor.factors.contains(term.factor)
                    ? term.factor.toString()
                    : null,
                setter: (value) {
                  var factor = int.tryParse(value ?? "");
                  if (factor == null) return;
                  _updateTerm(index, term.copyWith(factor: factor));
                },
                items: ComputedStatEditor.factors
                    .map(
                      (f) => DropdownMenuItem<String?>(
                        value: f.toString(),
                        child: Text(f < 0 ? "− ${-f}×" : "+ $f×"),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          if (conditions.isNotEmpty) ...[
            const SizedBox(height: 10),
            CustomDropdownMenu(
              isExpanded: true,
              key: ValueKey(
                "$keyBase-condition-${term.condition?.optionUuid ?? "none"}",
              ),
              label: S.of(context).computedCondition,
              selectedValueTemp: term.condition == null || !conditionKnown
                  ? ""
                  : "${term.condition!.statUuid}|${term.condition!.optionUuid}",
              setter: (value) {
                if (value == null || value.isEmpty) {
                  _updateTerm(index, term.copyWith(condition: () => null));
                  return;
                }
                var parts = value.split("|");
                _updateTerm(
                  index,
                  term.copyWith(
                    condition: () => ComputedTermCondition(
                      statUuid: parts[0],
                      optionUuid: parts[1],
                    ),
                  ),
                );
              },
              items: [
                DropdownMenuItem<String?>(
                  value: "",
                  child: Text(S.of(context).computedAlways),
                ),
                ...conditions.map(
                  (c) => DropdownMenuItem<String?>(
                    value: "${c.condition.statUuid}|${c.condition.optionUuid}",
                    child: Text(c.label, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
