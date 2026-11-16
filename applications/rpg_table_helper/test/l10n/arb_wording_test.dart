import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/generated/l10n.dart';
import 'package:quest_keeper/l10n/app_localizations_de.dart';

/// The texts of an ARB file by key, without the "@key" metadata.
Map<String, String> _arbTexts(String path) {
  final arb = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final entry in arb.entries)
      if (!entry.key.startsWith('@') && entry.value is String)
        entry.key: entry.value as String,
  };
}

/// Keys whose text matches [pattern], with the text, for readable failures.
List<String> _matches(Map<String, String> texts, RegExp pattern) => [
  for (final entry in texts.entries)
    if (pattern.hasMatch(entry.value)) '${entry.key}: ${entry.value}',
];

/// Guards the wording against leftovers the UX test of 2026-11-16 found
/// (B6, SL-3): "DM" instead of "Spielleitung", English words in German texts.
void main() {
  final de = _arbTexts('lib/l10n/intl_de.arb');
  final en = _arbTexts('lib/l10n/intl_en.arb');

  test('reads the texts of both ARB files', () {
    expect(de.length, greaterThan(500));
    expect(en.length, greaterThan(500));
  });

  test('German texts say "Spielleitung", not "DM" or "Spielleiter"', () {
    expect(
      _matches(de, RegExp(r'\bDM\b|Dungeon ?Master|\bSpielleiter(in)?\b')),
      isEmpty,
    );
  });

  test('English texts say "game master", not "DM" or "Dungeon Master"', () {
    // "Dungeon Master" is a trademark of Wizards of the Coast.
    expect(_matches(en, RegExp(r'\bDM\b|Dungeon ?Master')), isEmpty);
  });

  test('German texts contain no typical English words', () {
    final english = RegExp(
      r'\b(the|and|you|your|please|cancel|settings|save|delete|loading|'
      r'error|failed|campaign)\b',
      caseSensitive: false,
    );
    expect(_matches(de, english), isEmpty);
  });

  test('German texts use the imperative "Gib", not "Gebe"', () {
    expect(_matches(de, RegExp(r'\bGebe\b')), isEmpty);
  });

  group('changed texts', () {
    late S s;
    setUp(() async => s = await S.load(const Locale('de')));

    test('the author label of the game master', () {
      expect(s.dm, 'Spielleitung');
      expect(AppLocalizationsDe().dm, 'Spielleitung');
    });

    test('received items use a plural', () {
      expect(s.receivedXNewItems(1), 'Du hast ein neues Item erhalten:');
      expect(s.receivedXNewItems(3), 'Du hast 3 neue Items erhalten:');
    });

    test('English "send" is no longer German', () async {
      final en = await S.load(const Locale('en'));
      expect(en.send, 'Send');
      expect(en.dm, 'Game master');
    });
  });
}
