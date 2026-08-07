// Helpers for multiselect option list text (summary vs long description).

/// Prefer DM-authored [summary]; otherwise derive a short blurb from [description].
String resolveMultiselectListText({
  required String? summary,
  required String description,
}) {
  final trimmed = summary?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  return shortBlurbFromDescription(description);
}

/// Legacy fallback used when no `summary` is stored on the option.
String shortBlurbFromDescription(String description) {
  final lines = description
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  for (final line in lines) {
    final lower = line.toLowerCase();
    if (lower.startsWith('zeitaufwand') ||
        lower.startsWith('reichweite') ||
        lower.startsWith('komponenten') ||
        lower.startsWith('wirkungsdauer') ||
        lower.contains('grades') ||
        lower.contains('zaubertrick') ||
        lower.contains('(ritual)')) {
      continue;
    }
    final sentence = line.split('.').first.trim();
    if (sentence.isEmpty) continue;
    if (sentence.length > 90) {
      return '${sentence.substring(0, 87)}…';
    }
    return '$sentence.';
  }
  return '';
}
