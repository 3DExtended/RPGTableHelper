import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/json_differ.dart';

void main() {
  group('JsonDiffer', () {
    test('adds and removes keys with correct patch', () {
      final oldJson = {
        'version': 1,
        'name': 'Alice',
        'age': 30,
      };
      final newJson = {
        'version': 2,
        'name': 'Alice',
        'email': 'alice@example.com',
      };

      final patch = JsonDiffer.diff(oldJson, newJson);

      expect(patch[0], equals({'op': 'version', 'from': 1, 'to': 2}));
      expect(
        patch.sublist(1),
        unorderedEquals([
          {'op': 'remove', 'path': '/age'},
          {'op': 'add', 'path': '/email', 'value': 'alice@example.com'},
        ]),
      );

      final updated = JsonDiffer.apply(original: oldJson, operations: patch);
      expect(updated['version'], equals(2));
      expect(updated['name'], equals('Alice'));
      expect(updated['email'], equals('alice@example.com'));
      expect(updated.containsKey('age'), isFalse);
    });

    test('modifies nested fields correctly', () {
      final oldJson = {
        'version': 1,
        'user': {'name': 'Alice', 'city': 'Paris'}
      };
      final newJson = {
        'version': 2,
        'user': {'name': 'Alice', 'city': 'Berlin'}
      };

      final patch = JsonDiffer.diff(oldJson, newJson);

      expect(patch[0], equals({'op': 'version', 'from': 1, 'to': 2}));
      expect(
        patch.sublist(1),
        equals([
          {'op': 'replace', 'path': '/user/city', 'value': 'Berlin'}
        ]),
      );

      final updated = JsonDiffer.apply(original: oldJson, operations: patch);
      expect(updated['user']['city'], equals('Berlin'));
      expect(updated['version'], equals(2));
    });

    test('adds to array with correct patch', () {
      final oldJson = {
        'version': 1,
        'tags': ['a']
      };
      final newJson = {
        'version': 2,
        'tags': ['a', 'b']
      };

      final patch = JsonDiffer.diff(oldJson, newJson);

      expect(patch[0], equals({'op': 'version', 'from': 1, 'to': 2}));
      expect(
        patch.sublist(1),
        equals([
          {'op': 'add', 'path': '/tags/1', 'value': 'b'}
        ]),
      );

      final updated = JsonDiffer.apply(original: oldJson, operations: patch);
      expect(updated['tags'], equals(['a', 'b']));
    });

    test('removes from array with correct patch', () {
      final oldJson = {
        'version': 1,
        'tags': ['a', 'b', 'c']
      };
      final newJson = {
        'version': 2,
        'tags': ['a']
      };

      final patch = JsonDiffer.diff(oldJson, newJson);

      expect(patch[0], equals({'op': 'version', 'from': 1, 'to': 2}));
      expect(
        patch.sublist(1),
        equals([
          {'op': 'remove', 'path': '/tags/2'},
          {'op': 'remove', 'path': '/tags/1'},
        ]),
      );

      final updated = JsonDiffer.apply(original: oldJson, operations: patch);
      expect(updated['tags'], equals(['a']));
    });

    test('detects and replaces type change', () {
      final oldJson = {
        'version': 1,
        'key': {'sub': 1}
      };
      final newJson = {'version': 2, 'key': 'value'};

      final patch = JsonDiffer.diff(oldJson, newJson);

      expect(patch[0], equals({'op': 'version', 'from': 1, 'to': 2}));
      expect(
        patch.sublist(1),
        equals([
          {'op': 'replace', 'path': '/key', 'value': 'value'}
        ]),
      );

      final updated = JsonDiffer.apply(original: oldJson, operations: patch);
      expect(updated['key'], equals('value'));
    });

    test('empty patch for version-only change', () {
      final oldJson = {'version': 5, 'x': 1};
      final newJson = {'version': 6, 'x': 1};

      final patch = JsonDiffer.diff(oldJson, newJson);
      expect(patch.length, equals(1));
      expect(patch[0], equals({'op': 'version', 'from': 5, 'to': 6}));

      final updated = JsonDiffer.apply(original: oldJson, operations: patch);
      expect(updated['version'], equals(6));
      expect(updated['x'], equals(1));
    });

    test('throws if version op is missing', () {
      final oldJson = {'version': 1, 'x': 10};
      final patch = [
        {'op': 'replace', 'path': '/x', 'value': 20}
      ];

      expect(
        () => JsonDiffer.apply(original: oldJson, operations: patch),
        throwsException,
      );
    });

    test('throws on version mismatch', () {
      final oldJson = {'version': 4, 'x': 100};
      final newJson = {'version': 5, 'x': 200};
      final patch = JsonDiffer.diff(oldJson, newJson);

      final tampered = Map<String, dynamic>.from(oldJson)..['version'] = 3;

      expect(
        () => JsonDiffer.apply(original: tampered, operations: patch),
        throwsException,
      );
    });

    test('multiple mixed operations with patch check', () {
      final oldJson = {
        'version': 1,
        'a': 1,
        'b': [10, 20],
        'c': {'x': true}
      };
      final newJson = {
        'version': 2,
        'a': 2,
        'b': [10, 30, 40],
        'c': {'x': false, 'y': 'new'}
      };

      final patch = JsonDiffer.diff(oldJson, newJson);

      expect(patch[0], equals({'op': 'version', 'from': 1, 'to': 2}));
      expect(
        patch.sublist(1),
        unorderedEquals([
          {'op': 'replace', 'path': '/a', 'value': 2},
          {'op': 'replace', 'path': '/b/1', 'value': 30},
          {'op': 'add', 'path': '/b/2', 'value': 40},
          {
            'op': 'replace',
            'path': '/c',
            'value': {'x': false, 'y': 'new'}
          }
        ]),
      );

      final updated = JsonDiffer.apply(original: oldJson, operations: patch);
      expect(updated['a'], equals(2));
      expect(updated['b'], equals([10, 30, 40]));
      expect(updated['c']['x'], isFalse);
      expect(updated['c']['y'], equals('new'));
    });
  });
}
