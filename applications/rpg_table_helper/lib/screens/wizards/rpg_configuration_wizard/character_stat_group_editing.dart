/// List helpers for the character sheet step of the configuration wizard.
///
/// A tab's editor list mixes stats and group dividers. A divider starts a new
/// group; the stats before the first divider form the first group.
library;

/// Removes the stat at [statIndex]. When that leaves its group without any
/// stats, the group's divider goes too, so no empty "group" line stays
/// behind.
///
/// When the first group (the one without a divider) runs empty, the divider
/// that now leads the list is dropped instead: a leading divider has no
/// meaning and is not restored when the configuration is loaded again.
List<T> removeStatAndEmptyGroup<T>(
  List<T> entries,
  int statIndex, {
  required bool Function(T entry) isGroupDivider,
}) {
  final result = [...entries]..removeAt(statIndex);

  var groupStart = statIndex - 1;
  while (groupStart >= 0 && !isGroupDivider(result[groupStart])) {
    groupStart--;
  }

  // After the removal, statIndex points at the entry that followed the stat.
  final nextIsGroupBoundary =
      statIndex >= result.length || isGroupDivider(result[statIndex]);
  final groupIsEmpty = groupStart == statIndex - 1 && nextIsGroupBoundary;
  if (!groupIsEmpty) {
    return result;
  }

  if (groupStart >= 0) {
    result.removeAt(groupStart);
  } else if (statIndex < result.length) {
    result.removeAt(statIndex);
  }
  return result;
}

/// The 1-based number shown on each group divider, keyed by list index.
///
/// The first group has no divider, so the first divider after some stats
/// reads "group 2". A divider at the very top reads "group 1".
Map<int, int> groupNumbersForDividers<T>(
  List<T> entries, {
  required bool Function(T entry) isGroupDivider,
}) {
  final numbers = <int, int>{};
  var currentGroup = 0;
  for (var i = 0; i < entries.length; i++) {
    if (isGroupDivider(entries[i])) {
      currentGroup++;
      numbers[i] = currentGroup;
    } else if (currentGroup == 0) {
      currentGroup = 1;
    }
  }
  return numbers;
}

/// Number of stats (not dividers) in [entries].
int countStats<T>(
  List<T> entries, {
  required bool Function(T entry) isGroupDivider,
}) {
  return entries.where((e) => !isGroupDivider(e)).length;
}
