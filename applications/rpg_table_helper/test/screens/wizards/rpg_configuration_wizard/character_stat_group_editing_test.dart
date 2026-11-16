import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/screens/wizards/rpg_configuration_wizard/character_stat_group_editing.dart';

/// Entries are strings: "D…" is a group divider, everything else a stat.
bool _isDivider(String entry) => entry.startsWith('D');

List<String> _remove(List<String> entries, String stat) =>
    removeStatAndEmptyGroup(
      entries,
      entries.indexOf(stat),
      isGroupDivider: _isDivider,
    );

void main() {
  group('removeStatAndEmptyGroup', () {
    test('drops the divider when its last stat goes', () {
      expect(_remove(['s1', 'D1', 's2', 'D2', 's3'], 's2'), ['s1', 'D2', 's3']);
    });

    test('drops a trailing divider when its last stat goes', () {
      expect(_remove(['s1', 'D1', 's2'], 's2'), ['s1']);
    });

    test('keeps the divider while the group has stats left', () {
      expect(_remove(['s1', 'D1', 's2', 's3'], 's2'), ['s1', 'D1', 's3']);
      expect(_remove(['s1', 'D1', 's2', 's3'], 's3'), ['s1', 'D1', 's2']);
    });

    test('drops the divider that would lead the list when the first group '
        'runs empty', () {
      expect(_remove(['s1', 'D1', 's2'], 's1'), ['s2']);
    });

    test('drops a leading divider together with its last stat', () {
      expect(_remove(['D1', 's1'], 's1'), <String>[]);
    });

    test('removing the only stat leaves an empty list', () {
      expect(_remove(['s1'], 's1'), <String>[]);
    });

    test('does not change the input list', () {
      final entries = ['s1', 'D1', 's2'];
      _remove(entries, 's2');
      expect(entries, ['s1', 'D1', 's2']);
    });
  });

  group('groupNumbersForDividers', () {
    test('numbers dividers after the implicit first group from 2', () {
      expect(
        groupNumbersForDividers([
          's1',
          'D1',
          's2',
          'D2',
          's3',
        ], isGroupDivider: _isDivider),
        {1: 2, 3: 3},
      );
    });

    test('a divider at the top is group 1', () {
      expect(
        groupNumbersForDividers(['D1', 's1', 'D2'], isGroupDivider: _isDivider),
        {0: 1, 2: 2},
      );
    });
  });

  test('countStats ignores dividers', () {
    expect(countStats(['s1', 'D1', 's2', 'D2'], isGroupDivider: _isDivider), 2);
  });
}
