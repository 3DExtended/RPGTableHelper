import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_table_helper/helpers/fuzzysort.dart';

void main() {
  group('FuzzySort', () {
    late Fuzzysort fuzzySort;

    setUp(() {
      fuzzySort = Fuzzysort();
    });

    test('prepare prepares a target string correctly', () {
      var prepared = fuzzySort.prepare(
          'TestString', "eeed0eec-6391-45c2-907f-70371a8268c1");
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
      var prepared = fuzzySort.prepare(
          'TestString', "e9009c82-c518-4b0f-b045-a999111b7f1b");
      var preparedSearch = fuzzySort.prepareSearch('test');

      var result = fuzzySort.algorithm(preparedSearch, prepared, false, true);

      expect(result, isNotNull);
      expect(result!.target, 'TestString');
      expect(result.score, isNot(equals(0.0)));
      expect(result.indexes, isNotEmpty);
    });

    test('algorithmSpaces handles multiple searches correctly', () {
      var prepared = fuzzySort.prepare(
          'TestString', "b99adda1-f51d-41ac-b45d-f8b59cfa246a");
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
      var prepared = FuzzySearchPreparedTarget(
          target: 'TestString',
          identifier: "d6c05ca1-3275-4256-b55c-1682420dbc15");
      var preparedSearch = PreparedSearch('test');
      preparedSearch.spaceSearches.add(preparedSearch);

      var result = fuzzySort.algorithmSpaces(preparedSearch, prepared, false);

      expect(result, isNotNull);
      expect(result?.score, isNot(equals(0.0)));
    });

    test('Case with multiple searches', () {
      var prepared = FuzzySearchPreparedTarget(
          target: 'AnotherTestString',
          identifier: "76dca456-5122-4bbc-98fc-efbf0ea52296");
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
      var prepared = FuzzySearchPreparedTarget(
          target: 'NoMatchHere',
          identifier: "92d34799-3e7d-4123-adb2-50cb6042f1dd");
      var search = PreparedSearch('test');
      search.spaceSearches.add(search);

      var result = fuzzySort.algorithmSpaces(search, prepared, true);

      expect(result, isNull); // No matches should result in null
    });

    test('Case with spaces in search term', () {
      var prepared = FuzzySearchPreparedTarget(
          target: 'Test String with Spaces',
          identifier: "4d450021-879f-446f-8f25-8d3e67dc47aa");
      var search = PreparedSearch('test string');
      search.spaceSearches.add(search);

      var result = fuzzySort.algorithmSpaces(search, prepared, false);

      expect(result, isNotNull);
      expect(result!.score, isNot(equals(0.0)));
    });

    test('Case with multiple spaces in search term and various target', () {
      var prepared = FuzzySearchPreparedTarget(
          target: 'Complex Target String',
          identifier: "89af97da-d189-4c4a-9ab3-a00fd3b1c2bb");
      var search1 = PreparedSearch('complex');
      var search2 = PreparedSearch('target');
      search1.spaceSearches.add(search2);
      search2.spaceSearches.add(search1); // Circular reference to test

      var result = fuzzySort.algorithmSpaces(search1, prepared, false);

      expect(result, isNotNull);
      expect(result!.score, isNot(equals(0.0)));
    });

    test('Case with empty search and target', () {
      var prepared = FuzzySearchPreparedTarget(
          target: '', identifier: "17040914-1d76-46fe-8959-92a1c45f1ac6");
      var search = PreparedSearch('');
      search.spaceSearches.add(search);

      var result = fuzzySort.algorithmSpaces(search, prepared, false);

      expect(result, isNull);
    });

    test('Case with empty target but non-empty search', () {
      var prepared = FuzzySearchPreparedTarget(
          target: '', identifier: "d6f99415-40f7-4dd7-bb5d-53486bad2b54");
      var search = PreparedSearch('test');
      search.spaceSearches.add(search);

      var result = fuzzySort.algorithmSpaces(search, prepared, false);

      expect(result, isNull); // No matches possible
    });

    test('should return correct results when search is matched', () {
      final targets = [
        FuzzySearchPreparedTarget(
            target: 'test1',
            identifier: "e67959c4-fa19-4052-a7bd-5e059ea13f59"),
        FuzzySearchPreparedTarget(
            target: 'test2',
            identifier: "2ea69ae2-7643-45b9-a69f-93541da9aef4"),
        FuzzySearchPreparedTarget(
            target: 'test3',
            identifier: "e6bece2f-94f4-4df9-bb70-161e786a7e84"),
      ];

      final options = {'threshold': 0.0, 'limit': 2};
      final results = fuzzySort.go('test', targets, options);

      expect(results.length, equals(2));
      expect(results[0].score, greaterThanOrEqualTo(results[1].score));
    });

    test('should return if words in the middle are present', () {
      final targets = [
        FuzzySearchPreparedTarget(
            target: 'hello asdf world',
            identifier: "a7bd0ca3-fc6c-4163-bae2-e5f5e7457744"),
        FuzzySearchPreparedTarget(
            target: 'Hello asdf World',
            identifier: "65c8eb80-1bf2-4cd8-b33b-544072ed6d8b"),
      ];

      final options = {'threshold': 0.0, 'limit': 2};
      final results = fuzzySort.go('hello world', targets, options);

      expect(results.length, equals(2));
      expect(results[0].score, greaterThanOrEqualTo(results[1].score));
    });

    test('should respect limit parameter', () {
      final targets = [
        FuzzySearchPreparedTarget(
            target: 'test1',
            identifier: "b15f74bf-8963-4bb7-8e23-248939b6d6fe"),
        FuzzySearchPreparedTarget(
            target: 'test2',
            identifier: "9b55a8f5-dda8-4b02-9c0e-f44d07367b47"),
        FuzzySearchPreparedTarget(
            target: 'test3',
            identifier: "4aea35fd-70c9-4e10-8dcf-8d191d992921"),
      ];

      final options = {'threshold': 0.0, 'limit': 1};
      final results = fuzzySort.go('test', targets, options);

      expect(results.length, equals(1));
    });

    test('should return empty list when no results meet threshold', () {
      final targets = [
        FuzzySearchPreparedTarget(
            target: 'test1',
            identifier: "670697ee-f7ab-4f63-b8e6-017dfd5f4719"),
        FuzzySearchPreparedTarget(
            target: 'test2',
            identifier: "0941fb86-bbe8-4dbe-9a13-78a8c469ddaf"),
      ];

      final options = {'threshold': 10.0};
      final results = fuzzySort.go('test', targets, options);

      expect(results, isEmpty);
    });

    test('should handle empty search input', () {
      final targets = [
        FuzzySearchPreparedTarget(
            target: 'test1',
            identifier: "87cd2214-e8f0-4386-945b-277a47a1123a"),
        FuzzySearchPreparedTarget(
            target: 'test2',
            identifier: "e4241999-3a36-4b1b-80c9-28f562792863"),
      ];

      final options = {'threshold': 0.0, 'limit': 2};
      final results = fuzzySort.go('', targets, options);

      expect(results.length, equals(0));
    });

    test('should handle no options provided', () {
      final targets = [
        FuzzySearchPreparedTarget(
            target: 'test1',
            identifier: "d9c28cb8-583a-4e8f-837d-f53467501fad"),
        FuzzySearchPreparedTarget(
            target: 'test2',
            identifier: "6a0704f0-2688-4355-8dfd-c95e87882292"),
        FuzzySearchPreparedTarget(
            target: 'test3',
            identifier: "c23259d2-89a0-4a57-8766-e0da268e696c"),
      ];

      final results = fuzzySort.go('test', targets, null);

      expect(results.length, equals(3)); // should return all results
    });

    test(
        'should return partial results for multiple target search with no options provided',
        () {
      final targets = [
        FuzzySearchPreparedTarget(
            target: 'test1',
            identifier: "b5bdf19d-5550-4eb6-9385-462028072aa3"),
        FuzzySearchPreparedTarget(
            target: 'test2',
            identifier: "f4d27e2a-81a5-48c9-b5c3-12bceadead23"),
        FuzzySearchPreparedTarget(
            target: 'asdf3',
            identifier: "6a7141d5-54af-4587-bb26-20f86e1e1641"),
      ];

      final results = fuzzySort.go('test', targets, null);

      expect(results.length, equals(2)); // should return all results
    });
  });
}
