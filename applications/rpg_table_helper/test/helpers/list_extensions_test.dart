import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/helpers/list_extensions.dart';

void main() {
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
