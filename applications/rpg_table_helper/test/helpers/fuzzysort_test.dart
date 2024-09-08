import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/helpers/fuzzysort.dart';

void main() {
  group('FuzzySort', () {
    late Fuzzysort fuzzySort;

    setUp(() {
      fuzzySort = Fuzzysort();
    });

    test('prepare prepares a target string correctly', () {
      var prepared = fuzzySort.prepare('TestString');
      expect(prepared.target, 'TestString');
      expect(prepared.targetLower, 'teststring');
      expect(prepared.targetLowerCodes, isNotNull);
      expect(prepared.targetLowerCodes!.length, 10);
      expect(prepared.nextBeginningIndexes, isNull);
    });

    test('prepareSearch prepares a search string correctly', () {
      var preparedSearch = fuzzySort.prepareSearch('test');
      expect(preparedSearch.lower, 'test');
      expect(preparedSearch.lowerCodes.length, 4);
      expect(preparedSearch.spaceSearches, isEmpty);
    });

    test('prepareBeginningIndexes identifies beginning indexes correctly', () {
      // Test case 1: Simple case with uppercase and lowercase transitions
      String target1 = 'HelloWorld';
      List<int> result1 = fuzzySort.prepareBeginningIndexes(target1);
      expect(result1, [0, 5]);

      // Test case 2: Mixed alphanumeric and non-alphanumeric characters
      String target2 = 'Test_123';
      List<int> result2 = fuzzySort.prepareBeginningIndexes(target2);
      expect(result2, [0, 4, 5]);

      // Test case 3: All lowercase letters
      String target3 = 'alllowercase';
      List<int> result3 = fuzzySort.prepareBeginningIndexes(target3);
      expect(result3, [0]);

      // Test case 4: All uppercase letters
      String target4 = 'ALLUPPERCASE';
      List<int> result4 = fuzzySort.prepareBeginningIndexes(target4);
      expect(result4, [0]);

      // Test case 5: Non-alphanumeric characters
      String target5 = '1234!@#\$';
      List<int> result5 = fuzzySort.prepareBeginningIndexes(target5);
      expect(result5, [0, 4, 5, 6, 7]);

      // Test case 6: Empty string
      String target6 = '';
      List<int> result6 = fuzzySort.prepareBeginningIndexes(target6);
      expect(result6, []);

      // Test case 7: Single character
      String target7 = 'A';
      List<int> result7 = fuzzySort.prepareBeginningIndexes(target7);
      expect(result7, [0]);

      // Test case 8: Continuous numeric characters
      String target8 = '1234567890';
      List<int> result8 = fuzzySort.prepareBeginningIndexes(target8);
      expect(result8, [0]);

      // Test case 9: Mixed case with transitions
      String target9 = 'aA1!bB2@cC3#';
      List<int> result9 = fuzzySort.prepareBeginningIndexes(target9);
      expect(result9, [0, 1, 3, 4, 5, 7, 8, 9, 11]);

      // Test case 10: No transitions
      String target10 = 'AaAaAaAa';
      List<int> result10 = fuzzySort.prepareBeginningIndexes(target10);
      expect(result10, [0, 2, 4, 6]);
    });

    test(
        'prepareNextBeginningIndexes identifies correct next beginning indexes',
        () {
      // Test case 1: Simple case with uppercase and lowercase transitions
      String target1 = 'HelloWorld';
      List<int> result1 = fuzzySort.prepareNextBeginningIndexes(target1);
      expect(result1, [5, 5, 5, 5, 5, 10, 10, 10, 10, 10]);

      // Test case 2: Mixed alphanumeric and non-alphanumeric characters
      String target2 = 'Test_123';
      List<int> result2 = fuzzySort.prepareNextBeginningIndexes(target2);
      expect(result2, [4, 4, 4, 4, 5, 8, 8, 8]);

      // Test case 3: All lowercase letters
      String target3 = 'alllowercase';
      List<int> result3 = fuzzySort.prepareNextBeginningIndexes(target3);
      expect(result3, [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12]);

      // Test case 4: All uppercase letters
      String target4 = 'ALLUPPERCASE';
      List<int> result4 = fuzzySort.prepareNextBeginningIndexes(target4);
      expect(result4, [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12]);

      // Test case 5: Non-alphanumeric characters
      String target5 = '1234!@#\$';
      List<int> result5 = fuzzySort.prepareNextBeginningIndexes(target5);
      expect(result5, [4, 4, 4, 4, 5, 6, 7, 8]);

      // Test case 6: Empty string
      String target6 = '';
      List<int> result6 = fuzzySort.prepareNextBeginningIndexes(target6);
      expect(result6, []);

      // Test case 7: Single character
      String target7 = 'A';
      List<int> result7 = fuzzySort.prepareNextBeginningIndexes(target7);
      expect(result7, [1]);

      // Test case 8: Continuous numeric characters
      String target8 = '1234567890';
      List<int> result8 = fuzzySort.prepareNextBeginningIndexes(target8);
      expect(result8, [10, 10, 10, 10, 10, 10, 10, 10, 10, 10]);

      // Test case 9: Mixed case with transitions
      String target9 = 'aA1!bB2@cC3#';
      List<int> result9 = fuzzySort.prepareNextBeginningIndexes(target9);
      expect(result9, [1, 3, 3, 4, 5, 7, 7, 8, 9, 11, 11, 12]);

      // Test case 10: No transitions
      String target10 = 'AaAaAaAa';
      List<int> result10 = fuzzySort.prepareNextBeginningIndexes(target10);
      expect(result10, [2, 2, 4, 4, 6, 6, 8, 8]);
    });

    test('algorithm performs fuzzy search correctly', () {
      var prepared = fuzzySort.prepare('TestString');
      var preparedSearch = fuzzySort.prepareSearch('test');

      var result = fuzzySort.algorithm(preparedSearch, prepared, false, true);

      expect(result, isNotNull);
      expect(result!.target, 'TestString');
      expect(result.score, isNot(equals(0.0)));
      expect(result.indexes, isNotEmpty);
    });

    test('algorithmSpaces handles multiple searches correctly', () {
      var prepared = fuzzySort.prepare('TestString');
      var preparedSearch1 = fuzzySort.prepareSearch('test');
      var preparedSearch2 = fuzzySort.prepareSearch('string');

      preparedSearch1.spaceSearches = [preparedSearch2];

      var result = fuzzySort.algorithmSpaces(preparedSearch1, prepared, true);

      expect(result, isNotNull);
      expect(result!.target, 'TestString');
      expect(result.score, isNot(equals(0.0)));
      expect(result.indexes, isNotEmpty);
    });

    test('Basic case with no spaces', () {
      var prepared = Prepared('TestString');
      var preparedSearch = PreparedSearch('test');
      preparedSearch.spaceSearches.add(preparedSearch);

      var result = fuzzySort.algorithmSpaces(preparedSearch, prepared, false);

      expect(result, isNotNull);
      expect(result?.score, isNot(equals(0.0)));
    });

    test('Case with multiple searches', () {
      var prepared = Prepared('AnotherTestString');
      var search1 = PreparedSearch('test');
      var search2 = PreparedSearch('string');
      var search3 = PreparedSearch('another');
      search1.spaceSearches.add(search2);
      search2.spaceSearches.add(search3);

      var result = fuzzySort.algorithmSpaces(search1, prepared, false);

      expect(result, isNotNull);
      expect(result!.score, isNot(equals(0.0)));
    });

    test('Case with no matches and partial matches allowed', () {
      var prepared = Prepared('NoMatchHere');
      var search = PreparedSearch('test');
      search.spaceSearches.add(search);

      var result = fuzzySort.algorithmSpaces(search, prepared, true);

      expect(result, isNull); // No matches should result in null
    });

    test('Case with spaces in search term', () {
      var prepared = Prepared('Test String with Spaces');
      var search = PreparedSearch('test string');
      search.spaceSearches.add(search);

      var result = fuzzySort.algorithmSpaces(search, prepared, false);

      expect(result, isNotNull);
      expect(result!.score, isNot(equals(0.0)));
    });

    test('Case with multiple spaces in search term and various target', () {
      var prepared = Prepared('Complex Target String');
      var search1 = PreparedSearch('complex');
      var search2 = PreparedSearch('target');
      search1.spaceSearches.add(search2);
      search2.spaceSearches.add(search1); // Circular reference to test

      var result = fuzzySort.algorithmSpaces(search1, prepared, false);

      expect(result, isNotNull);
      expect(result!.score, isNot(equals(0.0)));
    });

    test('Case with empty search and target', () {
      var prepared = Prepared('');
      var search = PreparedSearch('');
      search.spaceSearches.add(search);

      var result = fuzzySort.algorithmSpaces(search, prepared, false);

      expect(result, isNull);
    });

    test('Case with empty target but non-empty search', () {
      var prepared = Prepared('');
      var search = PreparedSearch('test');
      search.spaceSearches.add(search);

      var result = fuzzySort.algorithmSpaces(search, prepared, false);

      expect(result, isNull); // No matches possible
    });

    test('should return correct results when search is matched', () {
      final targets = [
        Prepared('test1'),
        Prepared('test2'),
        Prepared('test3'),
      ];

      final options = {'threshold': 0.0, 'limit': 2};
      final results = fuzzySort.go('test', targets, options);

      expect(results.length, equals(2));
      expect(results[0].score, greaterThanOrEqualTo(results[1].score));
    });

    test('should return if words in the middle are present', () {
      final targets = [
        Prepared('hello asdf world'),
        Prepared('Hello asdf World'),
      ];

      final options = {'threshold': 0.0, 'limit': 2};
      final results = fuzzySort.go('hello world', targets, options);

      expect(results.length, equals(2));
      expect(results[0].score, greaterThanOrEqualTo(results[1].score));
    });

    test('should respect limit parameter', () {
      final targets = [
        Prepared('test1'),
        Prepared('test2'),
        Prepared('test3'),
      ];

      final options = {'threshold': 0.0, 'limit': 1};
      final results = fuzzySort.go('test', targets, options);

      expect(results.length, equals(1));
    });

    test('should return empty list when no results meet threshold', () {
      final targets = [
        Prepared('test1'),
        Prepared('test2'),
      ];

      final options = {'threshold': 10.0};
      final results = fuzzySort.go('test', targets, options);

      expect(results, isEmpty);
    });

    test('should handle empty search input', () {
      final targets = [
        Prepared('test1'),
        Prepared('test2'),
      ];

      final options = {'threshold': 0.0, 'limit': 2};
      final results = fuzzySort.go('', targets, options);

      expect(results.length, equals(0));
    });

    test('should handle no options provided', () {
      final targets = [
        Prepared('test1'),
        Prepared('test2'),
        Prepared('test3'),
      ];

      final results = fuzzySort.go('test', targets, null);

      expect(results.length, equals(3)); // should return all results
    });
  });
}
