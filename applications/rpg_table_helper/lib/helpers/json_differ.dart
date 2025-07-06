import 'dart:convert';

class JsonDiffer {
  /// Diffs two versioned JSON blobs and returns a patch.
  /// Optionally includes current and new version numbers.
  static List<Map<String, dynamic>> diff(
    Map<String, dynamic> oldJson,
    Map<String, dynamic> newJson,
  ) {
    final oldVersion = oldJson['version'] as int?;
    final newVersion = newJson['version'] as int?;

    if (oldVersion == null || newVersion == null) {
      throw Exception("Missing 'version' key in JSON");
    }

    final patch = _diff(oldJson, newJson);

    patch.insert(0, {
      'op': 'version',
      'from': oldVersion,
      'to': newVersion,
    });

    return patch;
  }

  /// Applies a versioned patch only if the version matches.
  static Map<String, dynamic> apply({
    required Map<String, dynamic> original,
    required List<Map<String, dynamic>> operations,
  }) {
    if (operations.isEmpty || operations[0]['op'] != 'version') {
      throw Exception("Missing version operation at beginning of patch");
    }

    final versionOp = operations[0];
    final from = versionOp['from'];
    final to = versionOp['to'];

    if (original['version'] != from) {
      throw Exception(
          "Version mismatch: expected $from, found ${original['version']}");
    }

    // Remove version op
    final actualOps = operations.sublist(1);
    final updated = _apply(original, actualOps);

    updated['version'] = to;
    return updated;
  }

  /// Internal: Diffs recursively
  static List<Map<String, dynamic>> _diff(
    dynamic oldJson,
    dynamic newJson, [
    String basePath = '',
  ]) {
    final patch = <Map<String, dynamic>>[];

    if (oldJson is Map && newJson is Map) {
      final keys = {...oldJson.keys, ...newJson.keys};
      for (final key in keys) {
        if (key == 'version') continue;

        final path = '$basePath/$key';
        final oldVal = oldJson[key];
        final newVal = newJson[key];

        if (!newJson.containsKey(key)) {
          patch.add({'op': 'remove', 'path': path});
        } else if (!oldJson.containsKey(key)) {
          patch.add({'op': 'add', 'path': path, 'value': newVal});
        } else if (oldVal.runtimeType != newVal.runtimeType) {
          patch.add({'op': 'replace', 'path': path, 'value': newVal});
        } else if (oldVal is Map || oldVal is List) {
          patch.addAll(_diff(oldVal, newVal, path));
        } else if (oldVal != newVal) {
          patch.add({'op': 'replace', 'path': path, 'value': newVal});
        }
      }
    } else if (oldJson is List && newJson is List) {
      final minLen =
          oldJson.length < newJson.length ? oldJson.length : newJson.length;
      for (var i = 0; i < minLen; i++) {
        final path = '$basePath/$i';
        final oldItem = oldJson[i];
        final newItem = newJson[i];

        if (oldItem.runtimeType != newItem.runtimeType) {
          patch.add({'op': 'replace', 'path': path, 'value': newItem});
        } else if (oldItem is Map || oldItem is List) {
          patch.addAll(_diff(oldItem, newItem, path));
        } else if (oldItem != newItem) {
          patch.add({'op': 'replace', 'path': path, 'value': newItem});
        }
      }

      if (newJson.length > oldJson.length) {
        for (var i = oldJson.length; i < newJson.length; i++) {
          patch.add({'op': 'add', 'path': '$basePath/$i', 'value': newJson[i]});
        }
      } else if (oldJson.length > newJson.length) {
        var removeOperations = <Map<String, dynamic>>[];

        for (var i = newJson.length; i < oldJson.length; i++) {
          removeOperations.add({'op': 'remove', 'path': '$basePath/$i'});
        }
        patch.addAll(removeOperations.reversed);
      }
    }

    return patch;
  }

  /// Internal: Applies patch operations
  static Map<String, dynamic> _apply(
    Map<String, dynamic> original,
    List<Map<String, dynamic>> operations,
  ) {
    final updated = jsonDecode(jsonEncode(original));

    dynamic getParent(dynamic root, List<String> segments) {
      dynamic current = root;
      for (int i = 0; i < segments.length - 1; i++) {
        final key = segments[i];
        if (current is Map) {
          current = current[key];
        } else if (current is List) {
          current = current[int.parse(key)];
        }
      }
      return current;
    }

    for (final op in operations) {
      final type = op['op'] as String?;
      final path = op['path'] as String?;
      final value = op['value'];
      final keys = path?.split('/').where((e) => e.isNotEmpty).toList() ?? [];
      final lastKey = keys.last;
      final parent = getParent(updated, keys);

      if (parent is Map) {
        if (type == 'add' || type == 'replace') {
          parent[lastKey] = value;
        } else if (type == 'remove') {
          parent.remove(lastKey);
        }
      } else if (parent is List) {
        final index = int.parse(lastKey);
        if (type == 'add') {
          if (index == parent.length) {
            parent.add(value);
          } else {
            parent.insert(index, value);
          }
        } else if (type == 'replace') {
          parent[index] = value;
        } else if (type == 'remove') {
          parent.removeAt(index);
        }
      }
    }

    return Map<String, dynamic>.from(updated);
  }
}
