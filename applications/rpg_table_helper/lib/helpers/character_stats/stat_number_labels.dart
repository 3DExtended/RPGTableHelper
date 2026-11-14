import 'package:flutter/widgets.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/helpers/character_stats/stat_numbers.dart';

/// The localized suffixes [StatNumbers] puts into labels.
StatNumberLabels statNumberLabelsOf(BuildContext context) => StatNumberLabels(
  calculated: S.of(context).calculatedValueShort,
  max: S.of(context).maxValueShort,
  level: S.of(context).level,
);
