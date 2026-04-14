import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:json_patch/json_patch.dart';

void main() {
  test('JsonPatch.apply matches server top-level remove op', () {
    const oldJson = '{"keep":true,"drop":false}';
    const newJson = '{"keep":true}';
    final old = jsonDecode(oldJson) as Object;
    final patches = <Map<String, dynamic>>[
      {'op': 'remove', 'path': '/drop'},
    ];
    final out = JsonPatch.apply(old, patches);
    expect(jsonEncode(out), newJson);
  });
}
