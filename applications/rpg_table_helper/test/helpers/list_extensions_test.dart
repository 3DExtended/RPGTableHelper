import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/list_extensions.dart';
import 'package:quest_keeper/models/rpg_configuration_model.dart';

class _CharacterStat {
  CharacterStatValueType type;
  _CharacterStat(this.type);
}

class _MyObject {
  final CharacterStatValueType type;
  _MyObject(this.type);
}

void main() {
  group('consecutiveTypeCounts', () {
    test('returns empty list for an empty input list', () {
      List<_MyObject> list = [];
      var result = list.consecutiveTypeCounts((a) => a.type);
      expect(result, []);
    });

    test('returns [1] for a list with one item', () {
      List<_MyObject> list = [_MyObject(CharacterStatValueType.int)];
      var result = list.consecutiveTypeCounts((a) => a.type);
      expect(result, [(CharacterStatValueType.int, 1)]);
    });

    test('returns correct counts for a list with all identical items', () {
      List<_MyObject> list = [
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.int)
      ];
      var result = list.consecutiveTypeCounts((a) => a.type);
      expect(result, [(CharacterStatValueType.int, 3)]);
    });

    test(
        'returns correct counts for a list with no consecutive identical items',
        () {
      List<_MyObject> list = [
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.singleLineText),
        _MyObject(CharacterStatValueType.multiLineText)
      ];
      var result = list.consecutiveTypeCounts((a) => a.type);
      expect(result, [
        (CharacterStatValueType.int, 1),
        (CharacterStatValueType.singleLineText, 1),
        (CharacterStatValueType.multiLineText, 1)
      ]);
    });

    test(
        'returns correct counts for a list with mixed consecutive and non-consecutive items',
        () {
      List<_MyObject> list = [
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.singleLineText),
        _MyObject(CharacterStatValueType.multiLineText),
        _MyObject(CharacterStatValueType.multiLineText),
      ];
      var result = list.consecutiveTypeCounts((a) => a.type);
      expect(result, [
        (CharacterStatValueType.int, 2),
        (CharacterStatValueType.singleLineText, 1),
        (CharacterStatValueType.multiLineText, 2)
      ]);
    });

    test('handles alternating types correctly', () {
      List<_MyObject> list = [
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.multiLineText),
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.multiLineText),
      ];
      var result = list.consecutiveTypeCounts((a) => a.type);
      expect(result, [
        (CharacterStatValueType.int, 1),
        (CharacterStatValueType.multiLineText, 1),
        (CharacterStatValueType.int, 1),
        (CharacterStatValueType.multiLineText, 1)
      ]);
    });

    test('handles multiple groups of consecutive items', () {
      List<_MyObject> list = [
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.singleLineText),
        _MyObject(CharacterStatValueType.singleLineText),
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.int),
        _MyObject(CharacterStatValueType.int),
      ];
      var result = list.consecutiveTypeCounts((a) => a.type);
      expect(result, [
        (CharacterStatValueType.int, 2),
        (CharacterStatValueType.singleLineText, 2),
        (CharacterStatValueType.int, 3)
      ]);
    });
  });

  group('consecutiveCounts extension method', () {
    test('Basic case with consecutive identical items', () {
      final list = [
        _CharacterStat(CharacterStatValueType.multiselect),
        _CharacterStat(CharacterStatValueType.multiselect),
        _CharacterStat(CharacterStatValueType.multiselect),
        _CharacterStat(CharacterStatValueType.int),
      ];
      final result = list.consecutiveCounts((a, b) => a.type == b.type);
      expect(result, [2, 1, 0, 0]);
    });

    test('Single element list', () {
      final list = [_CharacterStat(CharacterStatValueType.int)];
      final result = list.consecutiveCounts((a, b) => a.type == b.type);
      expect(result, [0]);
    });

    test('Empty list', () {
      final list = <_CharacterStat>[];
      final result = list.consecutiveCounts((a, b) => a.type == b.type);
      expect(result, []);
    });

    test('List with no consecutive identical items', () {
      final list = [
        _CharacterStat(CharacterStatValueType.multiLineText),
        _CharacterStat(CharacterStatValueType.singleLineText),
        _CharacterStat(CharacterStatValueType.int),
        _CharacterStat(CharacterStatValueType.intWithMaxValue),
      ];
      final result = list.consecutiveCounts((a, b) => a.type == b.type);
      expect(result, [0, 0, 0, 0]);
    });

    test('List with all identical items', () {
      final list = [
        _CharacterStat(CharacterStatValueType.int),
        _CharacterStat(CharacterStatValueType.int),
        _CharacterStat(CharacterStatValueType.int),
        _CharacterStat(CharacterStatValueType.int),
      ];
      final result = list.consecutiveCounts((a, b) => a.type == b.type);
      expect(result, [3, 2, 1, 0]);
    });

    test('List with alternating items', () {
      final list = [
        _CharacterStat(CharacterStatValueType.int),
        _CharacterStat(CharacterStatValueType.multiselect),
        _CharacterStat(CharacterStatValueType.int),
        _CharacterStat(CharacterStatValueType.multiselect),
      ];
      final result = list.consecutiveCounts((a, b) => a.type == b.type);
      expect(result, [0, 0, 0, 0]);
    });

    test(
        'Real-world case with CharacterStatValueType.intWithCalculatedValue only',
        () {
      final list = [
        _CharacterStat(CharacterStatValueType.intWithCalculatedValue),
        _CharacterStat(CharacterStatValueType.intWithCalculatedValue),
        _CharacterStat(CharacterStatValueType.intWithCalculatedValue),
      ];
      final result = list.consecutiveCounts((a, b) => a.type == b.type);
      expect(result, [2, 1, 0]);
    });
  });

  group('addAllIntoSortedList', () {
    test('adds elements to an empty list', () {
      final list = <int>[];
      list.addAllIntoSortedList([3, 1, 2], (a, b) => a.compareTo(b));

      expect(list, equals([1, 2, 3]));
    });

    test('inserts elements at the beginning of a sorted list', () {
      final list = [3, 4, 5];
      list.addAllIntoSortedList([1, 2], (a, b) => a.compareTo(b));

      expect(list, equals([1, 2, 3, 4, 5]));
    });

    test('inserts elements at the end of a sorted list', () {
      final list = [1, 2, 3];
      list.addAllIntoSortedList([4, 5], (a, b) => a.compareTo(b));

      expect(list, equals([1, 2, 3, 4, 5]));
    });

    test('inserts elements into the middle of a sorted list', () {
      final list = [1, 3, 5];
      list.addAllIntoSortedList([2, 4], (a, b) => a.compareTo(b));

      expect(list, equals([1, 2, 3, 4, 5]));
    });

    test('handles inserting duplicate elements', () {
      final list = [1, 2, 3, 4, 5];
      list.addAllIntoSortedList([2, 3, 3, 4], (a, b) => a.compareTo(b));

      expect(list, equals([1, 2, 2, 3, 3, 3, 4, 4, 5]));
    });

    test('works with a custom comparator (descending order)', () {
      final list = [5, 3, 1];
      list.addAllIntoSortedList([4, 2], (a, b) => b.compareTo(a));

      expect(list, equals([5, 4, 3, 2, 1]));
    });

    test('works with a unordered lists and inserts correcty', () {
      final list = [3, 5, 1];
      list.addAllIntoSortedList([2, 4], (a, b) => a.compareTo(b));

      expect(list, equals([2, 3, 4, 5, 1]));
    });

    test('inserts elements in correct positions for a list of strings', () {
      final list = ['apple', 'banana', 'cherry'];
      list.addAllIntoSortedList(
          ['blueberry', 'avocado'], (a, b) => a.compareTo(b));

      expect(
          list, equals(['apple', 'avocado', 'banana', 'blueberry', 'cherry']));
    });

    test('handles an empty iterable without changing the list', () {
      final list = [1, 2, 3];
      list.addAllIntoSortedList([], (a, b) => a.compareTo(b));

      expect(list, equals([1, 2, 3]));
    });

    test('handles adding elements to an empty list with custom comparator', () {
      final list = <int>[];
      list.addAllIntoSortedList([3, 1, 2], (a, b) => b.compareTo(a));

      expect(list, equals([3, 2, 1]));
    });

    test('maintains stability with elements that are equal', () {
      final list = [1, 2, 3];
      list.addAllIntoSortedList([2, 2, 2], (a, b) => a.compareTo(b));

      expect(list, equals([1, 2, 2, 2, 2, 3]));
    });
  });
}
