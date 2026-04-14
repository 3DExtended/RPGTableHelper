import 'dart:convert';

/// Builds the same JSON envelope shape as [RpgConfigSliceV3EnvelopeBuilder] on the server
/// for client → server (upstream) invokes.
String buildRpgConfigUpstreamEnvelope({
  required String slice,
  required String? previousJson,
  required String newJson,
  required int fromRevision,
  required int toRevision,
}) {
  var normalizedNew = newJson.trim().isEmpty ? '{}' : newJson;

  if (fromRevision <= 0 || previousJson == null || previousJson.trim().isEmpty) {
    return _serializeFullUpstream(slice, normalizedNew);
  }

  final patch = _tryBuildTopLevelPatch(previousJson, normalizedNew);
  if (patch == null || patch.isEmpty) {
    return _serializeFullUpstream(slice, normalizedNew);
  }

  final patchUtf8 = utf8.encode(jsonEncode(patch));
  final fullUtf8 = utf8.encode(jsonEncode(jsonDecode(normalizedNew)));
  if (patchUtf8.length >= fullUtf8.length) {
    return _serializeFullUpstream(slice, normalizedNew);
  }

  return jsonEncode({
    'kind': 'patch',
    'slice': slice,
    'fromRevision': fromRevision,
    'toRevision': toRevision,
    'patch': patch,
  });
}

String _serializeFullUpstream(String slice, String sliceJson) {
  final body = jsonDecode(sliceJson);
  if (body is! Map) {
    return jsonEncode({
      'kind': 'full',
      'slice': slice,
      'body': <String, dynamic>{},
    });
  }
  return jsonEncode({
    'kind': 'full',
    'slice': slice,
    'body': body,
  });
}

List<Map<String, dynamic>>? _tryBuildTopLevelPatch(String oldJson, String newJson) {
  Map<String, dynamic> oldMap;
  Map<String, dynamic> newMap;
  try {
    final o = jsonDecode(oldJson);
    final n = jsonDecode(newJson);
    if (o is! Map || n is! Map) {
      return null;
    }
    oldMap = Map<String, dynamic>.from(o);
    newMap = Map<String, dynamic>.from(n);
  } catch (_) {
    return null;
  }

  final ops = <Map<String, dynamic>>[];

  for (final key in oldMap.keys) {
    if (!newMap.containsKey(key)) {
      ops.add({
        'op': 'remove',
        'path': '/${_escapeJsonPointerSegment(key)}',
      });
    }
  }

  for (final entry in newMap.entries) {
    final key = entry.key;
    final newVal = entry.value;
    if (!oldMap.containsKey(key)) {
      ops.add({
        'op': 'add',
        'path': '/${_escapeJsonPointerSegment(key)}',
        'value': newVal,
      });
    } else if (jsonEncode(oldMap[key]) != jsonEncode(newVal)) {
      ops.add({
        'op': 'replace',
        'path': '/${_escapeJsonPointerSegment(key)}',
        'value': newVal,
      });
    }
  }

  return ops;
}

String _escapeJsonPointerSegment(String token) {
  return token.replaceAll('~', '~0').replaceAll('/', '~1');
}
