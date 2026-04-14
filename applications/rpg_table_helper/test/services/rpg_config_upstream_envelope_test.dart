import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:json_patch/json_patch.dart';
import 'package:quest_keeper/services/rpg_config_upstream_envelope.dart';

void main() {
  test('upstream patch smaller than full uses patch kind', () {
    const oldJson =
        '{"keep":true,"drop":false,"blob":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}';
    const newJson = '{"keep":true,"blob":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}';
    final env = buildRpgConfigUpstreamEnvelope(
      slice: 'cold',
      previousJson: oldJson,
      newJson: newJson,
      fromRevision: 3,
      toRevision: 4,
    );
    final map = jsonDecode(env) as Map<String, dynamic>;
    expect(map['kind'], 'patch');
    expect(map['fromRevision'], 3);
    final patches = (map['patch'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final out = JsonPatch.apply(jsonDecode(oldJson), patches);
    expect(jsonEncode(out), newJson);
  });

  test('upstream first slice uses full without revision', () {
    const newJson = '{"a":1}';
    final env = buildRpgConfigUpstreamEnvelope(
      slice: 'hot',
      previousJson: null,
      newJson: newJson,
      fromRevision: 0,
      toRevision: 1,
    );
    final map = jsonDecode(env) as Map<String, dynamic>;
    expect(map['kind'], 'full');
    expect(map['body'], isA<Map>());
  });
}
