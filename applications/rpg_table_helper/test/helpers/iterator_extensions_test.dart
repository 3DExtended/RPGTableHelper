import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/helpers/iterator_extensions.dart';

void main() {
  group('IterableExtensions', () {
    test('sortBy sorts numbers in ascending order', () {
      final numbers = [3, 1, 4, 1, 5, 9, 2, 6];
      final sortedNumbers = numbers.sortBy((n) => n as num).toList();

      expect(sortedNumbers, equals([1, 1, 2, 3, 4, 5, 6, 9]));
    });

    test('sortBy sorts strings in ascending order by length', () {
      final strings = ['apple', 'kiwi', 'banana', 'pear'];
      final sortedStrings = strings.sortBy<num>((s) => s.length).toList();

      expect(sortedStrings, equals(['kiwi', 'pear', 'apple', 'banana']));
    });

    test('sortBy sorts objects by a property', () {
      final people = [
        {'name': 'John', 'age': 30},
        {'name': 'Alice', 'age': 25},
        {'name': 'Bob', 'age': 35}
      ];

      final sortedPeople = people.sortBy<num>((p) => p['age'] as int).toList();

      expect(
          sortedPeople,
          equals([
            {'name': 'Alice', 'age': 25},
            {'name': 'John', 'age': 30},
            {'name': 'Bob', 'age': 35}
          ]));
    });

    test('sortByDescending sorts numbers in descending order', () {
      final numbers = [3, 1, 4, 1, 5, 9, 2, 6];
      final sortedNumbers = numbers.sortByDescending<num>((n) => n).toList();

      expect(sortedNumbers, equals([9, 6, 5, 4, 3, 2, 1, 1]));
    });

    test('sortByDescending sorts strings in descending order by length', () {
      final strings = ['apple', 'kiwi', 'banana', 'pear'];
      final sortedStrings =
          strings.sortByDescending<num>((s) => s.length).toList();

      expect(sortedStrings, equals(['banana', 'apple', 'kiwi', 'pear']));
    });

    test('sortBy works with empty iterable', () {
      final emptyList = <int>[];
      final sortedEmptyList = emptyList.sortBy<num>((n) => n).toList();

      expect(sortedEmptyList, equals([]));
    });

    test('sortByDescending works with empty iterable', () {
      final emptyList = <int>[];
      final sortedEmptyList =
          emptyList.sortByDescending<num>((n) => n).toList();

      expect(sortedEmptyList, equals([]));
    });

    test('sortByDescending with objects works correctly', () {
      final people = [
        {'name': 'John', 'age': 30},
        {'name': 'Alice', 'age': 25},
        {'name': 'Bob', 'age': 35}
      ];

      final sortedPeople =
          people.sortByDescending<num>((p) => p['age'] as int).toList();

      expect(
          sortedPeople,
          equals([
            {'name': 'Bob', 'age': 35},
            {'name': 'John', 'age': 30},
            {'name': 'Alice', 'age': 25}
          ]));
    });

    test('sortBy with custom comparison logic', () {
      final numbers = [1, 2, 3, 4, 5];
      // Custom sorting based on modulo of 2 (even first)
      final sortedNumbers = numbers.sortBy<num>((n) => n % 2).toList();

      expect(sortedNumbers, equals([2, 4, 1, 3, 5])); // evens first
    });
  });
}
